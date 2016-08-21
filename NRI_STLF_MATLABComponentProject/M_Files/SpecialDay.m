% Special Day
function Final_Forecast=SpecialDay(yy,mm,dd,lsys,Ghcal,calH)

locate=find(Ghcal(:,1)==yy & Ghcal(:,2)==mm & Ghcal(:,3)==dd);
fromyear=min(calH(:,1));
toyear=max(calH(:,1));

if isempty(locate)
    I=0;
    special_shamsi_days=[1 1; 1 2; 1 3; 1 4 ; 1 12; 1 13; 3 14; 3 15; 11 22; 12 29];
    YY=fromyear:toyear;
    aa=YY;
    for i=1:length(YY)
        MM(i)=mm;
        DD(i)=dd;
    end
else       
    I=Ghcal(locate,4);
    nn=fromyear:toyear;
    aa=find(Ghcal(:,4) ==I & Ghcal(:,1)>=fromyear & Ghcal(:,1)<=toyear);
    if aa(end)>locate
        aa=aa(1:end-1);
    end
    for i=1:length(aa)
        YY(i)=Ghcal(aa(i),1);
        MM(i)=Ghcal(aa(i),2);
        DD(i)=Ghcal(aa(i),3);
    end
end

hh=1;
for i=1:length(aa)
    fft(i)=find(calH(:,1) == YY(i) & calH(:,2) ==MM(i) & calH(:,3) == DD(i));
    calcod(i)=calH(fft(i),4);
    fftj(i)=fft(i)-calcod(i);
end

for i=1:length(aa)-1         % I IS THE TRAINING YEAR
    P(:,i)=[(lsys((fft(i)-1)*24-23:(fft(i)-1)*24)-lsys((fft(i)-1)*24-47:(fft(i)-1)*24-24))./lsys((fft(i)-1)*24-47:(fft(i)-1)*24-24);...
        calcod(i)];
    T(:,i)=(lsys((fft(i)-1)*24+1:(fft(i))*24)-lsys((fft(i)-1)*24-23:(fft(i)-1)*24))./lsys((fft(i)-1)*24-23:(fft(i)-1)*24);
end
i=length(aa);
X=[(lsys((fft(i)-1)*24-23:(fft(i)-1)*24)-lsys((fft(i)-1)*24-47:(fft(i)-1)*24-24))./lsys((fft(i)-1)*24-47:(fft(i)-1)*24-24);...
        calcod(i)];
    %% Addidg Code by Mostafa Gholami
    % ITLMS Code to Densification of Database
    num=[];
    for i=1:size(P,2)
        if calcod(1,i)==calcod(1,end)
            num=[num,i];
        end 
    end
    if isempty(num)==1
        num=1:size(P,2);
    end
    [P,T]=ITLMSfunction(P,T);
    
    %%
    [Pn,minp,maxp,Tn,mint,maxt] = premnmx(P,T);
    [Xn] = tramnmx(X,minp,maxp);
    
    cnt=1;
    gamma=zeros(6-1+1,1);
    logev=zeros(6-1+1,1);

    for nh=1:6
        [samples, net,gamma(cnt),logev(cnt)]=myscgtrain2(Pn',Tn',nh);            
        cnt=cnt+1;
    end
    [oo,cnt]=max(real(logev));
    nh=1:6;
    nh=nh(cnt);

    [samples, net]=myhmctrain2(Pn',Tn',nh);

    qn=mylf1_test(samples, net, Xn');
    q = postmnmx(qn',mint,maxt);
    Final_Forecast=lsys((fft(end)-1)*24-23:(fft(end)-1)*24).*(1+q);     
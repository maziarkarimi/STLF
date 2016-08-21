function [prediction]=BNNpredict(lsys,yy,mm,dd,weatherdata,calH,calD,Ghcal)


%%
global minp maxp samples net mint maxt

lct=find(calD(:,1) == yy & calD(:,2) ==mm & calD(:,3) == dd );
weekday=calD(lct,4);
after_hol=0;
% if for after special days
if (lct>=9)
    if ((calD(lct-1,5)>=2) && (calD(lct-1,5)<=6) && (calD(lct,5)==1) && (calD(lct,4)~=7))
        flag=1;i=1;
        while flag==1
            if ((calD(lct-i,5)>=2) && (calD(lct-i,5)<=6))
                after_hol=after_hol+1;
                i=i+1;
            elseif (calD(lct-i,4)==7)
                after_hol=after_hol+1;
                i=i+1;
            else
                flag=0;
            end
        end
    end
end

lsys=reshape(lsys(:,6:29)',size(lsys,1)*24,1);
lsysMain=lsys;
%% build mean matrice for 5 & 6 Farvardin
if (mm==1 && dd==5) || (mm==1 && dd==6)
    y1=1;
    y2=1;
    f5=find(calH(:,3)==5 & calH(:,2)==1 & calH(:,5)==1 & calH(:,1)<yy);
    for i=1:length(f5)
        if (calH(f5(i),5)==1) && (calH(f5(i)-1,5)==2)
            farv5(y1,:)=(lsys(f5(i)*24-23:f5(i)*24)-lsys(f5(i)*24-47:f5(i)*24-24))./lsys(f5(i)*24-47:f5(i)*24-24);
            y1=y1+1;
        end
        if (calH(f5(i)+1,5)==1) && (calH(f5(i),5)==1)
            farv6(y2,:)=(lsys(f5(i)*24+1:f5(i)*24+24)-lsys(f5(i)*24-23:f5(i)*24))./lsys(f5(i)*24-23:f5(i)*24);
            y2=y2+1;
        end
    end
end
%% Build Database
%input: ekhtelaf bare diroz va 2roz pish taghsim bar 2roz pish
%output: ekhtelaf bare emroz va diroz taghsim bar diroz
P=[];
k=1;
FFT=25;
cnt=1;
cnt_tmp=(FFT-1)/24+2;
%% Ramezan Identification
isramezan=zeros(size(calH,1),1);
fy=min(calH(:,1));ty=max(calH(:,1));dy=ty-fy+1;
framezan=find(Ghcal(:,4) == 16 & Ghcal(:,1) >= fy & Ghcal(:,1) <= ty);
lramezan=find(Ghcal(:,4) == 14 & Ghcal(:,1) >= fy & Ghcal(:,1) <= ty);
if isempty(find(framezan < lramezan(1,1))) == 1
    lctH=find(calH(:,1)==Ghcal(lramezan(1,1),1) & ...
        calH(:,2)==Ghcal(lramezan(1,1),2) & ...
        calH(:,3)==Ghcal(lramezan(1,1),3));
    isramezan(1:lctH,1)=1;
end
for i=1:size(framezan,1)
    ff=find(lramezan > framezan(i,1));
    if isempty(ff) == 0
        lctH1=find(calH(:,1)==Ghcal(framezan(i,1),1) & ...
            calH(:,2)==Ghcal(framezan(i,1),2) & ...
            calH(:,3)==Ghcal(framezan(i,1),3));
        lctH2=find(calH(:,1)==Ghcal(lramezan(ff(1,1),1),1) & ...
            calH(:,2)==Ghcal(lramezan(ff(1,1),1),2) & ...
            calH(:,3)==Ghcal(lramezan(ff(1,1),1),3));
        isramezan(lctH1:lctH2,1)=1;
    else
        lctH1=find(calH(:,1)==Ghcal(framezan(i,1),1) & ...
            calH(:,2)==Ghcal(framezan(i,1),2) & ...
            calH(:,3)==Ghcal(framezan(i,1),3));
        isramezan(lctH1:end,1)=1;
    end
end
lctH=find(calH(:,1) == yy & calH(:,2) ==mm & calH(:,3) == dd );
if isramezan(lctH,1)==1
    ramezan=1;
else
    ramezan=0;
end
%%
while (FFT+24*k) < length(lsys)
    if ramezan==1
        if isramezan(FFT+k-23-1,1)==1
            monthflag=1;after_hol=0;
            if (calH(FFT+k-23,5)== 1)&& (calH(FFT+k-23-1,5)== 1) && (calH(FFT+k-23-2,5)== 1)
                % Saturdays Prediction
                if ((weekday == 1) && (calH(FFT+k-23,4)== 1) && (monthflag==1)) && (after_hol==0)
                    P1(:,cnt)=[(lsys(FFT+24*k-24:FFT+24*k-1)-lsys(FFT+24*k-48:FFT+24*k-25))./lsys(FFT+24*k-48:FFT+24*k-25);...
                        calH(FFT+k-23-1,4)];
                    if(isempty(weatherdata) ==0)
                        P(:,cnt)=[P1(:,cnt);weatherdata(cnt_tmp,6:7)'];
                    else
                        P(:,cnt)=P1(:,cnt);
                    end
                    T(:,cnt)=[(lsys(FFT+24*k:FFT+24*k+23)-lsys(FFT+24*k-24:FFT+24*k-1))./lsys(FFT+24*k-24:FFT+24*k-1)];
                    cnt=cnt+1;
                    
                end
                
                % Sundays Prediction
                if (weekday == 2) && (calH(FFT+k-23,4)== 2) && monthflag==1 && (after_hol==0)
                    P1(:,cnt)=[(lsys(FFT+24*k-24:FFT+24*k-1)-lsys(FFT+24*k-48:FFT+24*k-25))./lsys(FFT+24*k-48:FFT+24*k-25);...
                        calH(FFT+k-23-1,4)];
                    if(isempty(weatherdata) ==0)
                        P(:,cnt)=[P1(:,cnt);weatherdata(cnt_tmp,6:7)'];
                    else
                        P(:,cnt)=P1(:,cnt);
                    end
                    T(:,cnt)=[(lsys(FFT+24*k:FFT+24*k+23)-lsys(FFT+24*k-24:FFT+24*k-1))./lsys(FFT+24*k-24:FFT+24*k-1)];
                    cnt=cnt+1;
                    %                 cnt_tmp=cnt_tmp+1;
                end
                
                % Mondays to Wednesdays Prediction
                if (weekday >= 3) && (weekday <= 5) && (calH(FFT+k-23,4) >= 3) && (calH(FFT+k-23,4) <= 5) && monthflag==1 && (after_hol==0)
                    P1(:,cnt)=[(lsys(FFT+24*k-24:FFT+24*k-1)-lsys(FFT+24*k-48:FFT+24*k-25))./lsys(FFT+24*k-48:FFT+24*k-25);...
                        calH(FFT+k-23-1,4)];
                    if(isempty(weatherdata) ==0)
                        P(:,cnt)=[P1(:,cnt);weatherdata(cnt_tmp,6:7)'];
                    else
                        P(:,cnt)=P1(:,cnt);
                    end
                    T(:,cnt)=[(lsys(FFT+24*k:FFT+24*k+23)-lsys(FFT+24*k-24:FFT+24*k-1))./lsys(FFT+24*k-24:FFT+24*k-1)];
                    cnt=cnt+1;
                    %                 cnt_tmp=cnt_tmp+1;
                end
                
                % Thursdays Prediction
                if (weekday == 6) && (calH(FFT+k-23,4)== 6) && monthflag==1 && (after_hol==0)
                    P1(:,cnt)=[(lsys(FFT+24*k-24:FFT+24*k-1)-lsys(FFT+24*k-48:FFT+24*k-25))./lsys(FFT+24*k-48:FFT+24*k-25);...
                        calH(FFT+k-23-1,4)];
                    if(isempty(weatherdata) ==0)
                        P(:,cnt)=[P1(:,cnt);weatherdata(cnt_tmp,6:7)'];
                    else
                        P(:,cnt)=P1(:,cnt);
                    end
                    T(:,cnt)=[(lsys(FFT+24*k:FFT+24*k+23)-lsys(FFT+24*k-24:FFT+24*k-1))./lsys(FFT+24*k-24:FFT+24*k-1)];
                    cnt=cnt+1;
                    %                 cnt_tmp=cnt_tmp+1;
                end
                
                % Fridays Prediction
                if (weekday == 7) && (calH(FFT+k-23,4)== 7) && monthflag==1 && (after_hol==0)
                    P1(:,cnt)=[(lsys(FFT+24*k-24:FFT+24*k-1)-lsys(FFT+24*k-48:FFT+24*k-25))./lsys(FFT+24*k-48:FFT+24*k-25);...
                        calH(FFT+k-23-1,4)];
                    if(isempty(weatherdata) ==0)
                        P(:,cnt)=[P1(:,cnt);weatherdata(cnt_tmp,6:7)'];
                    else
                        P(:,cnt)=P1(:,cnt);
                    end
                    T(:,cnt)=[(lsys(FFT+24*k:FFT+24*k+23)-lsys(FFT+24*k-24:FFT+24*k-1))./lsys(FFT+24*k-24:FFT+24*k-1)];
                    cnt=cnt+1;
                    %                 cnt_tmp=cnt_tmp+1;
                end
                cnt_tmp=cnt_tmp+1;
                k=k+1;
            else
                k=k+2;
                cnt_tmp=cnt_tmp+2;
            end
        else
            k=k+2;
            cnt_tmp=cnt_tmp+2;
        end
    else
        if (calH(FFT+k-23,5)== 1)&& (calH(FFT+k-23-1,5)== 1) && (calH(FFT+k-23-2,5)== 1) && (after_hol==0)
            monthflag=0;
            if mm==1
                if calH(FFT+k-23,2)>=1 && calH(FFT+k-23,2)<=3
                    monthflag=1;
                end
            elseif mm==2 || mm==3 || mm==4 || mm==5 || mm==8 || mm==9 || mm==10 || mm==11
                if calH(FFT+k-23,2)>=(mm-1) && calH(FFT+k-23,2)<=(mm+1)
                    monthflag=1;
                end
            elseif mm==6
                if calH(FFT+k-23,2)>=5 && calH(FFT+k-23,2)<=6
                    monthflag=1;
                end
            elseif mm==7
                if calH(FFT+k-23,2)>=7 && calH(FFT+k-23,2)<=8
                    monthflag=1;
                end
            elseif mm==12
                if calH(FFT+k-23,2)>=10 && calH(FFT+k-23,2)<=12
                    monthflag=1;
                end
            end
            % Saturdays Prediction
            if ((weekday == 1) && (calH(FFT+k-23,4)== 1) && (monthflag==1)) && (after_hol==0)
                P1(:,cnt)=[(lsys(FFT+24*k-24:FFT+24*k-1)-lsys(FFT+24*k-48:FFT+24*k-25))./lsys(FFT+24*k-48:FFT+24*k-25);...
                    calH(FFT+k-23-1,4)];
                if(isempty(weatherdata) ==0)
                    P(:,cnt)=[P1(:,cnt);weatherdata(cnt_tmp,6:7)'];
                else
                    P(:,cnt)=P1(:,cnt);
                end
                T(:,cnt)=[(lsys(FFT+24*k:FFT+24*k+23)-lsys(FFT+24*k-24:FFT+24*k-1))./lsys(FFT+24*k-24:FFT+24*k-1)];
                cnt=cnt+1;
                
            end
            
            % Sundays Prediction
            if (weekday == 2) && (calH(FFT+k-23,4)== 2) && monthflag==1 && (after_hol==0)
                P1(:,cnt)=[(lsys(FFT+24*k-24:FFT+24*k-1)-lsys(FFT+24*k-48:FFT+24*k-25))./lsys(FFT+24*k-48:FFT+24*k-25);...
                    calH(FFT+k-23-1,4)];
                if(isempty(weatherdata) ==0)
                    P(:,cnt)=[P1(:,cnt);weatherdata(cnt_tmp,6:7)'];
                else
                    P(:,cnt)=P1(:,cnt);
                end
                T(:,cnt)=[(lsys(FFT+24*k:FFT+24*k+23)-lsys(FFT+24*k-24:FFT+24*k-1))./lsys(FFT+24*k-24:FFT+24*k-1)];
                cnt=cnt+1;
                %                 cnt_tmp=cnt_tmp+1;
            end
            
            % Mondays to Wednesdays Prediction
            if (weekday >= 3) && (weekday <= 5) && (calH(FFT+k-23,4) >= 3) && (calH(FFT+k-23,4) <= 5) && monthflag==1 && (after_hol==0)
                P1(:,cnt)=[(lsys(FFT+24*k-24:FFT+24*k-1)-lsys(FFT+24*k-48:FFT+24*k-25))./lsys(FFT+24*k-48:FFT+24*k-25);...
                    calH(FFT+k-23-1,4)];
                if(isempty(weatherdata) ==0)
                    P(:,cnt)=[P1(:,cnt);weatherdata(cnt_tmp,6:7)'];
                else
                    P(:,cnt)=P1(:,cnt);
                end
                T(:,cnt)=[(lsys(FFT+24*k:FFT+24*k+23)-lsys(FFT+24*k-24:FFT+24*k-1))./lsys(FFT+24*k-24:FFT+24*k-1)];
                cnt=cnt+1;
                %                 cnt_tmp=cnt_tmp+1;
            end
            
            % Thursdays Prediction
            if (weekday == 6) && (calH(FFT+k-23,4)== 6) && monthflag==1 && (after_hol==0)
                P1(:,cnt)=[(lsys(FFT+24*k-24:FFT+24*k-1)-lsys(FFT+24*k-48:FFT+24*k-25))./lsys(FFT+24*k-48:FFT+24*k-25);...
                    calH(FFT+k-23-1,4)];
                if(isempty(weatherdata) ==0)
                    P(:,cnt)=[P1(:,cnt);weatherdata(cnt_tmp,6:7)'];
                else
                    P(:,cnt)=P1(:,cnt);
                end
                T(:,cnt)=[(lsys(FFT+24*k:FFT+24*k+23)-lsys(FFT+24*k-24:FFT+24*k-1))./lsys(FFT+24*k-24:FFT+24*k-1)];
                cnt=cnt+1;
                %                 cnt_tmp=cnt_tmp+1;
            end
            % Fridays Prediction
            if (weekday == 7) && (calH(FFT+k-23,4)== 7) && monthflag==1 && (after_hol==0)
                P1(:,cnt)=[(lsys(FFT+24*k-24:FFT+24*k-1)-lsys(FFT+24*k-48:FFT+24*k-25))./lsys(FFT+24*k-48:FFT+24*k-25);...
                    calH(FFT+k-23-1,4)];
                if(isempty(weatherdata) ==0)
                    P(:,cnt)=[P1(:,cnt);weatherdata(cnt_tmp,6:7)'];
                else
                    P(:,cnt)=P1(:,cnt);
                end
                T(:,cnt)=[(lsys(FFT+24*k:FFT+24*k+23)-lsys(FFT+24*k-24:FFT+24*k-1))./lsys(FFT+24*k-24:FFT+24*k-1)];
                cnt=cnt+1;
                %                 cnt_tmp=cnt_tmp+1;
            end
            cnt_tmp=cnt_tmp+1;
            k=k+1;
        elseif (after_hol~=0)
            % After holidays
            if ((after_hol~=0) && (calH(FFT+k-23,5)== 1))
                a_hol=0;
                for i=1:after_hol
                    if (FFT+k-23-i)>0
                        if (calH(FFT+k-23-i,5)>=2) && (calH(FFT+k-23-i,5)<=6)
                            a_hol=a_hol+1;
                        end
                    end
                end
                if after_hol == a_hol
                    P1(:,cnt)=[(lsys(FFT+24*k-24:FFT+24*k-1)-lsys(FFT+24*k-48:FFT+24*k-25))./lsys(FFT+24*k-48:FFT+24*k-25);...
                        calH(FFT+k-23-1,4)];
                    if(isempty(weatherdata) ==0)
                        P(:,cnt)=[P1(:,cnt);weatherdata(cnt_tmp,6:7)'];
                    else
                        P(:,cnt)=P1(:,cnt);
                    end
                    T(:,cnt)=[(lsys(FFT+24*k:FFT+24*k+23)-lsys(FFT+24*k-24:FFT+24*k-1))./lsys(FFT+24*k-24:FFT+24*k-1)];
                    calcod(cnt,:)=calH(FFT+k-24,:);
                    cnt=cnt+1;
                    cnt_tmp=cnt_tmp+1;
                end
            end
            k=k+1;
            cnt_tmp=cnt_tmp+1;
        else
            k=k+2;
            cnt_tmp=cnt_tmp+2;
        end
    end
end
%% normalizing the load data according to hour
if (mm==1 && dd==5)
    mean_farv5=mean(farv5);
    mean_farv6=mean(farv6);
end
if isempty(P)==1 || isempty(T)==1
    disp('Increase the Year number');
    prediction=[];
else
    [Pn,minp,maxp,Tn,mint,maxt] = premnmx(P,T);
    
    %% Database Builder and training
    nh=6;
    
    [samples,net]=mylf1_train(Pn',Tn',nh);
    
    %% forecazsting process
    
    FFT=1;
    cnt=1;
    mape=0;
    Final=[];
    mapesfa=[];
    lsys_Forecast=[];
    lct1=find(calH(:,1) == yy & calH(:,2) == 1 & calH(:,3) == 1 );
    lsys=lsys(24*lct1-23:end);
    lct=find(calD(:,1) == yy & calD(:,2) ==mm & calD(:,3) == dd );
    
%     close all
    k=lct;
    
    code=calD(k,5);
    yy=calD(k,1);
    mm=calD(k,2);
    dd=calD(k,3);
    weekday=calD(k,4);
    
    % forecasting 1 farvardin
    if (k==1 || k==2 )
        Final_Forecast(k,:)=SpecialDay_first(yy,mm,dd,lsysMain,Ghcal,calH);
    end
    
    %forecasting 2 ta 4 farvardin
    if  ( (k>= 3) && (k<=4) )
        Final_Forecast(k,:)=SpecialDay(yy,mm,dd,lsysMain,Ghcal,calH);
    end
    
    
    if (k>=5)
        % build the input for forecasting
        X=[(lsys(FFT+24*k-48:FFT+24*k-25)-lsys(FFT+24*k-72:FFT+24*k-49))./lsys(FFT+24*k-72:FFT+24*k-49);...
            calD(FFT+k-2,4)];
        if(isempty(weatherdata) ==0)
            X=[X;weatherdata(k,6:7)'];
        end
        
        % Forecasting
        [Xn] = tramnmx(X,minp,maxp);
        qn=mylf1_test(samples, net, Xn');
        
        q = postmnmx(qn',mint,maxt);
        FF2=[(1+q).*lsys(FFT+24*k-48:FFT+24*k-25)]';
        
        % forecasting for special days
        if ( (code>= 2) && (code<=5))
            Final_Forecast(k,:)=SpecialDay(yy,mm,dd,lsysMain,Ghcal,calH);
        else
            Final_Forecast(k,:)=FF2;
        end
        
        % forecasting for 5 farvardin
        if (mm==1)&&(dd==5)
            Final_Forecast(k,:)=(1+mean_farv5).*FF2;
            if calD(FFT+k-1,4)~=7
                FF2=Final_Forecast(k,:);
            end
        end
        % forecasting for 6 farvardin
        if (mm==1)&&(dd==6)&& calD(FFT+k-1,4)==1
            Final_Forecast(k,:)=(1+mean_farv6).*FF2;
        end
        
        % forecasting for first day of ramadan
        if (code==8)
            FF_r=SpecialDay(yy,mm,dd,lsysMain,Ghcal,calH);
            FF2(4:6)=FF_r(4:6);
            Final_Forecast(k,:)=FF2;
        end
    end
    prediction=Final_Forecast(lct,:);
end
function [Indtesta,net,INPUTsNUM,TempNUM]=LoadTraining_online(SPECIAL,yy,mm,dd,A,TT2,InputData,k)

numberofneurons=15;
smothing_factor=1/3;

max_trainingdata=2000;

if ((mm==1)||(mm==7))
    IND1=[find((A(:,1)<yy).*(A(:,2)==mm));find((A(:,1)<yy).*(A(:,2)==mm+1))];
elseif ((mm==12)||(mm==6))
    IND1=[find((A(:,1)==yy).*(A(:,2)==mm-1));find((A(:,1)<yy).*(A(:,2)==mm-1));find((A(:,1)<yy).*(A(:,2)==mm))];
else
    IND1=[find((A(:,1)==yy).*(A(:,2)==mm-1));find((A(:,1)<yy).*(A(:,2)==mm+1));find((A(:,1)<yy).*(A(:,2)==mm));find((A(:,1)<yy).*(A(:,2)==mm-1))];
end


if ~isempty(TT2)
    A=[A TT2(:,7)];
    D=A(:,30);
    D=D';
    D1=D(1,:);%D2=D(2,:);%D3=D(3,:);
    DD1=repmat(D1',1,24);%DD2=repmat(D2',1,24);%DD3=repmat(D3',1,24);
    DF1=reshape(DD1',1,24*size(DD1,1));%DF2=reshape(DD2',1,24*size(DD2,1));%DF3=reshape(DD3',1,24*size(DD3,1));
    TT=[DF1];
    TempNUM=[0,24,168];
else
    TempNUM=[];
    TT=[];
end
B=A(:,6:29);
INPUTsNUM=[1;2;3;23;24;25;167;168;169];
CC=reshape(B',1,24*size(B,1));
FLAG=0;
[Adays,daytypes,daysramezan]=DayType(InputData);

if SPECIAL==0 && mm==1 && dd==14
    IND3=find((A(:,2)==mm).*(A(:,3)==dd));
    daysnums=[];
    for I1=1:length(IND3)
        daysnums=[daysnums,[((IND3(I1)-1)*24+1):IND3(I1)*24]];
    end
    INPUTsNUM=[1;2;3;23;24;25;167;168;169];
    if ~isempty(TT2)
        TempNUM=[0,24,168];
    end
    FLAG=1;
elseif SPECIAL==0 && mm==1 && dd==5
    IND3=find((A(:,1)>min(A(:,1))).*(A(:,2)==mm).*(A(:,3)==dd));
    daysnums=[];
    for I1=1:length(IND3)
        daysnums=[daysnums,[((IND3(I1)-1)*24+1):IND3(I1)*24]];
    end
    INPUTsNUM=[1;2;3;23;24;25;47;48;49;71;72;73];
    if ~isempty(TT2)
        TempNUM=[0,24,48,72];
    end
    FLAG=1;
    
elseif Adays(k-1,1)==13     % After 21 Ramadan
    IND3=find(Adays(1:k-2,:)==Adays(k-1,1));
    IND3=IND3+1;
    daysnums=[];
    for I1=1:length(IND3)
        daysnums=[daysnums,[((IND3(I1)-1)*24+1):IND3(I1)*24]];
    end
    INPUTsNUM=[1;2;3;23;24;25;47;48;49];
    if ~isempty(TT2)
        TempNUM=[0,24,48];
    end
    FLAG=1;
% elseif SPECIAL==0 && mm==1 && dd<12 && dd>5
%     IND3=find((daytypes(1:k-1,:)==daytypes(k,1)).*(daysramezan(1:k-1,:)==daysramezan(k,1)).*(A(:,2)==mm).*(A(:,3)<dd+1).*(A(:,3)>5));
%     FLAG=1;
%     if isempty(IND3)
%         IND3=find((daytypes(1:k-1,:)==daytypes(k,1)).*(daysramezan(1:k-1,:)==daysramezan(k,1)));
%         FLAG=0;
%         IND2=[];
%         daysnums=[];
%         for I1=1:length(IND3)
%             daysnums=[daysnums,[((IND3(I1)-1)*24+1):IND3(I1)*24]];
%         end
%         for I1=1:size(daysnums,2)
%             if sum(ceil(daysnums(1,I1)/24)==IND1)
%                 IND2=[IND2,I1];
%             end
%         end
%         daysnums=daysnums(1,IND2);
%     end
%     daysnums=[];
%     for I1=1:length(IND3)
%         daysnums=[daysnums,[((IND3(I1)-1)*24+1):IND3(I1)*24]];
%     end
%     INPUTsNUM=[1;2;3;23;24;25;47;48;49];
%     if ~isempty(TT2)
%         TempNUM=[0,24,48];
%     end
else
    [Adays,daytypes,daysramezan]=DayType(InputData);
    Adays=Adays(1:k,:);
    daytypes=daytypes(1:k,:);
    daysramezan=daysramezan(1:k,:);
    daytypes2=repmat(daytypes(1:end-1),1,24);
    daytypesfinal=reshape(daytypes2',1,24*size(daytypes2,1));
    Adays2=repmat(Adays(1:end-1),1,24);
    Adaysfinal=reshape(Adays2',1,24*size(Adays2,1));
    daysramezan2=repmat(daysramezan(1:end-1),1,24);
    daysramezanfinal=reshape(daysramezan2',1,24*size(daysramezan2,1));
    
    
    if SPECIAL==0 && (Adaysfinal(end-167)~=0)||(Adaysfinal(end-168)~=0)||(Adaysfinal(end-169)~=0)
        INPUTsNUM=[1;2;3;23;24;25;47;48;49];
        [Adays,daytypes,daysramezan]=DayType2(InputData);
        Adays=Adays(1:k,:);
        daytypes=daytypes(1:k,:);
        daysramezan=daysramezan(1:k,:);
        daytypes2=repmat(daytypes(1:end-1),1,24);
        daytypesfinal=reshape(daytypes2',1,24*size(daytypes2,1));
        Adays2=repmat(Adays(1:end-1),1,24);
        Adaysfinal=reshape(Adays2',1,24*size(Adays2,1));
        daysramezan2=repmat(daysramezan(1:end-1),1,24);
        daysramezanfinal=reshape(daysramezan2',1,24*size(daysramezan2,1));
        if ~isempty(TT2)
            TempNUM=[0,24,48];
        end
    end
    
    
    if SPECIAL==0
        daysnumsaa=find((daytypesfinal==daytypes(end))&(Adaysfinal==Adays(end))&(daysramezanfinal==daysramezan(end))) ;
    else
        daysnumsaa=find(Adaysfinal==Adays(end));
    end
    daysnumsbb=find(daysnumsaa>171);
    daysnums=daysnumsaa(daysnumsbb);
    
    % II=[];
    % for I1=1:size(daysnums,2)
    %     for j=1:length(INPUTsNUM)
    %         if Adaysfinal(daysnums(1,I1)-INPUTsNUM(j))~=0
    %             II=[II,I1];
    %             break
    %         end
    %     end
    % end
    % daysnums(II)=[];
    
    
    IND2=[];
    for I1=1:size(daysnums,2)
        if sum(ceil(daysnums(1,I1)/24)==IND1)
            IND2=[IND2,I1];
        end
    end
    daysnums2=daysnums(1,IND2);
    daysnums(IND2)=[];
    if SPECIAL==1 || (Adaysfinal(end-23)~=0)||(Adaysfinal(end-24)~=0)||(Adaysfinal(end-25)~=0)
        daysnums=[daysnums2 daysnums];
    else
        daysnums=[daysnums2 ];
    end
    
end
if SPECIAL==1
    FLAG=1;
end

y1=CC(daysnums);
regrs_num=length(INPUTsNUM);
regrs_Temp=length(TempNUM);
ss=[];
for j=1:regrs_num
    ss=[ss;CC(daysnums-INPUTsNUM(j))];
end
tt=[];
if ~isempty(regrs_Temp)
    for k=1:size(TT,1)
        for j=1:regrs_Temp
            tt=[tt;TT(k,daysnums-TempNUM(j))];
        end
    end
end



ss=[ss;tt];
if FLAG==1
    [ss2,y12]=ITLMSfunction(ss,y1);
    %     if sum(sum(isnan(ss2)))>0
    %         [ss2,y12]=ITLMSfunction2(ss,y1);
    %     end
    if sum(sum(isnan(ss2)))>0
        ss=ss;y1=y1;
    else
        ss=ss2;y1=y12;
    end
end
% ss=[ss ss];
% y1=[y1 y1];
n=length(y1);
if n>max_trainingdata
    n=max_trainingdata;
    y1=y1(:,end-max_trainingdata+1:end);
    ss=ss(:,end-max_trainingdata+1:end);
end
% a=randperm(n);
a=1:n;
u=ss';
y=y1';
% n_trn = floor(0.8*n);  % 0.8 to 1

u_trn = u((rem(a,10)<6), :);
y_trn = y((rem(a,10)<6), :);

u_tst = u((rem(a,10)>5), :);
y_tst = y((rem(a,10)>5), :);
NNeuron = numberofneurons;
[Indtesta,net,mse_train,mse_test]=lolimot(TempNUM,u_trn,y_trn,NNeuron,smothing_factor, u_tst, y_tst);
% [output_train{i}]=simloly(net{i},u_trn{i});

% mape_train{i}=mean(abs((output_train{i}-y_trn{i})./y_trn{i}));

% [mintest,indtesta]=min(mse_test{i}); % ?????
% optnumneurons{i}=indtesta+1;  %??????
%
%
% NNeuron = optnumneurons{i};
% Err = 0;
% [net2{i},mse_train2{i}, mse_test2{i}]=lolimot(u_trn{i},y_trn{i},NNeuron,smothing_factor, u_tst{i}, y_tst{i});
% cd('NeuroFuzzyTrainResults');
% filename=['TrainResults',num2str(first_year),'_',num2str(N),',',corp_name];
% save(filename,'net','INPUTsNUM');
% cd('..');
% toc


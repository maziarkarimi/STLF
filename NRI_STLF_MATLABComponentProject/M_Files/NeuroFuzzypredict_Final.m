function [prediction]=NeuroFuzzypredict_Final(net,TempNUM,INPUTsNUM,A,TT,AToday)

% i=tomorrowtype;

% Special day and tomorrow of special

%Usal days
B=reshape(A(:,6:29)',1,size(A,1)*24);
uu=B(end-INPUTsNUM+1);
%15/11/94%%%%%%
if ~isempty(TT)
    D=TT(:,7);
    D=D';
    D1=D(1,:);%D2=D(2,:);%D3=D(3,:);
    DD1=repmat(D1',1,24);%DD2=repmat(D2',1,24);%DD3=repmat(D3',1,24);
    DF1=reshape(DD1',1,24*size(DD1,1));%DF2=reshape(DD2',1,24*size(DD2,1));%DF3=reshape(DD3',1,24*size(DD3,1));
    
    TT1=DF1(end-TempNUM);
    uu=[uu TT1 ];
    
end
%%%%%  15/11/94 %%%%
for jj=1:24
    if(isnan(AToday(jj)) || AToday(jj)==0)  %agar etela at bare emroz mojod nabashad
        [predictionaa(jj)]=simloly(TempNUM,net,uu);
    else
        [predictionaa(jj)] = AToday(jj);  % ??????
    end
    B=[B predictionaa(jj)];  % etelaat bar emroz  ra be B ezafe mikonad
    uu=B(end-INPUTsNUM+1);
    if ~isempty(TT)
        uu=[uu TT1];
    end
end
prediction=predictionaa;



function [corp]=LoadForecastingsimilar_new(yy,mm,dd,days,corp,InputData)
%System Short Term Load Forecasting By Neural Network Method.
%This function matlab(M) File Computes Forecasted Load for a Time Horison.
%-----------------------------------------------------------------------
%day is the prediction horizon
%L is the length of the window
%mode is the prediction mode:1=fixed window  2=gliding window
%first_year is the first year that must be used
% Example :
% LoadForecastingsimilar_new(93,5,15,2,corp,InputData)


L=7;
mode=2;

% Determining Special Shamsi Days(spshd)
shcal=[1 1; 1 2; 1 3; 1 4 ; 1 12; 1 13; 3 14; 3 15; 11 22; 12 29;6 30];
ghcal = InputData.cal.Ghcal;

% % are lsyszone for all zones equal size??
Adays=zeros(size(InputData.cal.calH,1),1);
for i=1:size(Adays,1)
    if InputData.cal.calH(i,5)~=1
        if sum((InputData.cal.calH(i,2)==shcal(:,1)).*(InputData.cal.calH(i,3)==shcal(:,2)))~=0
            ok=find((InputData.cal.calH(i,2)==shcal(:,1)).*(InputData.cal.calH(i,3)==shcal(:,2)));
            Adays(i,1)=ok+16;
        else
            ok=find((InputData.cal.calH(i,1)==ghcal(:,1))&(InputData.cal.calH(i,2)==ghcal(:,2))&(InputData.cal.calH(i,3)==ghcal(:,3)));
            if size(ok,1)~=0
                Adays(i,1)=ghcal(ok,4);
            end
        end
    end
end

% Build Ramezan Day matrix
daysramezan=zeros(1,size(InputData.cal.calH,1));
ll=find(Adays==16); % find first day of ramezan
ll2 = find(Adays==14); %find eid fetr
%if ramezan be in first month
if(ll2(1)<ll(1))
    daysramezan(1:(ll2(1)-1))=1;
end
for i=1:length(ll)
    lll = find(Adays((ll(i)+1):(ll(i)+30))==14,1,'first');
    kk=min(ll(i)+lll-1,size(daysramezan,2));
    daysramezan(ll(i))=2;
    daysramezan((ll(i)+1):kk)=1;
end

% added by m karimi 6/31 & 1 ramezan not important in this step
ll=find(InputData.cal.calH(:,5)==7 | InputData.cal.calH(:,5)==8);
InputData.cal.calH(ll,5)=1;
%
daytypes=zeros(1,size(InputData.cal.calH,1));

ll=find(InputData.cal.calH(:,5)==6);
InputData.cal.calH(ll,5)=1;
ll=find(InputData.cal.calH(:,5)~=1);
daytypes(ll)=5;
ll=find((InputData.cal.calH(:,5)==1)&(InputData.cal.calH(:,4)==1));
daytypes(ll)=1;
ll=find((InputData.cal.calH(:,5)==1)&(InputData.cal.calH(:,4)==6));
daytypes(ll)=3;
ll=find((InputData.cal.calH(:,5)==1)&(InputData.cal.calH(:,4)==7));
daytypes(ll)=4;
ll=find((InputData.cal.calH(2:end,5)==1)&(InputData.cal.calH(1:(end-1),5)~=1));
daytypes(ll+1)=6;
ll=find(daytypes==0);
daytypes(ll)=2;


% find selected day
i=find((InputData.cal.calH(:,1)==yy)&(InputData.cal.calH(:,2)==mm)&(InputData.cal.calH(:,3)==dd));

% corp = FitWeatherZone(yy,mm,dd,corp,InputData,daytypes); %% its temporary

zoneNo=length(corp.zone);

for z = 1:zoneNo
    mm2=mm;
    dd2=dd;
    yy2 =yy;
    
    corp.zone{1,z}.FittedWeather = []; %% its temporary
    
    AA = InputData.lsyszone{1,z};
    AA(:,1:5) = InputData.cal.calH;
    predictionZ=[];
    mapesZ=[];
    errorsZ=[];

    for k=i:i+days-1
        
        [prediction]=similarpredict(AA(1:k,:),yy2,mm2,dd2,daytypes(1:k),Adays(1:k),daysramezan(1:k),L,InputData.weatherzone{1,z},corp.zone{1,z}.FittedWeather);

        actual=InputData.lsyszone{1,z}(k,6:29);
        [mapes, errors] = calcError(prediction, actual,mm2);        
        AA(k,6:29)=prediction;
        
        predictionZ=[predictionZ; prediction];
        mapesZ=[mapesZ;mapes];
        errorsZ=[errorsZ;errors];
        
        if (k<size(InputData.lsyszone{1,z},1))
            dd2=AA(k+1,3);
            mm2=AA(k+1,2);
            yy2=AA(k+1,1);
        end
    end
    corp.zone{1,z}.SimilarPredict=predictionZ;
    corp.zone{1,z}.SimilarMapes = mapesZ;
    corp.zone{1,z}.SimilarErrors = errorsZ;
end
% summation of zones for corp
predictionC =[];
actualC = [];
for k=1:days
    prediction =[];
    actual = [];
    for z = 1:zoneNo
        prediction = [prediction;corp.zone{1,z}.SimilarPredict(k,:)];
        actual=[ actual; InputData.lsyszone{1,z}(i+k-1,6:29)];
    end
    predictionC =[predictionC; sum(prediction,1)];
    actualC = [actualC; sum(actual,1)];
end
mapesC=[];
errorsC=[];
for k=1:days
    [mapes, errors] = calcError(predictionC(k,:), actualC(k,:),InputData.cal.calH(i+k-1,2));      
     mapesC=[mapesC;mapes];
     errorsC=[errorsC;errors];
end
corp.SimilarPredict=predictionC;
corp.SimilarMapes = mapesC;
corp.SimilarErrors = errorsC;


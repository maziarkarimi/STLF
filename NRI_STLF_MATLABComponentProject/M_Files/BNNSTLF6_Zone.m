function [corp]=BNNSTLF6_Zone(yy,mm,dd,days,corp,InputData,nyh)
% yy is the year
% mm is month
% dd is day
% day is the number of days which will be predicted
% N is number of perivious year for training
% corp_load_name is Load name of desired corporation, for example: system
% Example:
% BNNSTLF6(84,1,10,1,2,'system',{'T_tehran','T_tabriz','T_ahvaz'},3,10)

%% Read Data
calH=InputData.cal.calH;
calD=InputData.cal.calD;
Ghcal=InputData.cal.Ghcal;
lct=find(calH(:,1) == yy & calH(:,2) ==mm & calH(:,3) == dd );

zoneNo=length(corp.zone);

for z=1:zoneNo
    mm2=mm;
    dd2=dd;
    yy2 =yy;
    lsys=InputData.lsyszone{1,z};
    weatherdata=InputData.weatherzone{1,z};

    if isempty(weatherdata.temp)
        weatherdata=weatherdata.temp;%%% must change!!!!!!
    else
        weatherdata=weatherdata.temp{1,1};%%% must change!!!!!!
    end
    predictionZ=[];
    mapesZ=[];
    errorsZ=[];
    for k=lct:lct+days-1
        [prediction]=BNNpredict(lsys(1:k-1,:),yy2,mm2,dd2,weatherdata,calH,calD,Ghcal);

        actual=InputData.lsyszone{1,z}(k,6:29);
        [mapes, errors] = calcError(prediction, actual,mm2);
        lsys(k,6:29)=prediction;

        predictionZ=[predictionZ; prediction];
        mapesZ=[mapesZ;mapes];
        errorsZ=[errorsZ;errors];

        if (k<size(InputData.lsyszone{1,z},1))
            dd2=lsys(k+1,3);
            mm2=lsys(k+1,2);
            yy2=lsys(k+1,1);
        end
    end
    corp.zone{1,z}.BNNPredict=predictionZ;
    corp.zone{1,z}.BNNMapes = mapesZ;
    corp.zone{1,z}.BNNErrors = errorsZ;
end

% summation of zones for corp
predictionC =[];
actualC = [];
for k=1:days
    prediction =[];
    actual = [];
    for z = 1:zoneNo
        prediction = [prediction;corp.zone{1,z}.BNNPredict(k,:)];
        actual=[ actual; InputData.lsyszone{1,z}(lct+k-1,6:29)];
    end
    predictionC =[predictionC; sum(prediction,1)];
    actualC = [actualC; sum(actual,1)];
end
mapesC=[];
errorsC=[];
for k=1:days
    [mapes, errors] = calcError(predictionC(k,:), actualC(k,:),InputData.cal.calH(lct+k-1,2));
    mapesC=[mapesC;mapes];
    errorsC=[errorsC;errors];
end
corp.BNNPredict=predictionC;
corp.BNNMapes = mapesC;
corp.BNNErrors = errorsC;
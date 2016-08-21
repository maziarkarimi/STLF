function PredictionMain(yy, mm, dd, days, N, Category, dbpath, flgSimilar, flgBNN, flgNeuro, flgLSQ,AppPath)

corp=CorpBuilder(Category,dbpath);

yy1=yy;
% added by m karimi for next year estimation!
if(mm==12 && dd+days>30)
    yy1 = yy+1;
    N = N+1;
end

% Read Data of corp
InputData = ReadData(yy1,N,corp,AppPath);

if(flgSimilar>0)
    corp=LoadForecastingsimilar_new(yy,mm,dd,days,corp,InputData);
end
if(flgBNN>0)
    corp=BNNSTLF6_Zone(yy,mm,dd,days,corp,InputData,12);
end
if(flgNeuro>0)
    corp=LoadForecastingNeuroFuzzy_new(yy,mm,dd,days,corp,InputData);
end
if(flgLSQ>0)            
    corp=LoadForecastingLSQ_new(yy,mm,dd,days,corp,InputData);
end

% find selected day
i=find((InputData.cal.calH(:,1)==yy)&(InputData.cal.calH(:,2)==mm)&(InputData.cal.calH(:,3)==dd));

zoneNo=length(corp.zone);
actualC = [];
for k=1:days    
    actual = [];
    for z = 1:zoneNo       
        actual=[ actual; InputData.lsyszone{1,z}(i+k-1,6:29)];
    end
    actualC = [actualC; sum(actual,1)];
end


PredictionOutput(corp,[InputData.cal.calH(i:i+days-1,1:5) actualC], days, flgSimilar, flgBNN, flgNeuro, flgLSQ);










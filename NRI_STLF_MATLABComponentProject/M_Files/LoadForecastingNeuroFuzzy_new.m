
function [corp]=LoadForecastingNeuroFuzzy_new(yy,mm,dd,days,corp,InputData)
global Indtesta

[Adays,daytypes,daysramezan]=DayType(InputData);

for I=1:length(corp.zone)
    
    A=InputData.lsyszone{1,I};
    
    weatherdata=InputData.weatherzone{1,I};
    
    if isempty(weatherdata.temp)
        TT=weatherdata.temp;
    else
        TT=weatherdata.temp{1,1};
    end
    
    i=find((A(:,1)==yy)&(A(:,2)==mm)&(A(:,3)==dd));
    
    predictionfa=[];
    mapesfa=[];
    
    for k=i:i+days-1  
        
        if Adays(k)==0   
            SPECIAL=0;
        else
            SPECIAL=1;
        end

            if isempty(TT)
                BB=[];
            else
                BB=TT(1:k-1,:);
            end
            
            
            [Indtesta,net,INPUTsNUM,TempNUM]=LoadTraining_online(SPECIAL,yy,mm,dd,A(1:k-1,:),BB,InputData,k);
            
            % etelaate bare roze morde nazar ra dar AToday migozarad , agar data
            % mojod nabod bejash NAN migozarad
            AToday = A(k,6:29);
            if sum(isnan(AToday))==0
                AToday =nan(1,24);
            end
            if ~isempty(TT)
                BB=TT(1:k,:);
            end
            [prediction]=NeuroFuzzypredict_Final(net,TempNUM,INPUTsNUM,A(1:k-1,:),BB,AToday);
            
            if sum(isnan(A(k,6:29)))==0
                mape=100*mean(abs(prediction-A(k,6:29))./A(k,6:29)); % motavaset khataye nesbi pishbini ra neshan midahad
                errors=100*(abs(prediction-A(k,6:29))./A(k,6:29));   % khataye nesbi pishbini baraye sahaye mokhtalefe roz
                
                
                if mm<7
                    mapepeak=100*mean(abs(prediction(21:24)-A(k,26:29))./A(k,26:29));
                    mapeord=100*mean(abs(prediction(9:20)-A(k,14:25))./A(k,14:25));
                    mapelow=100*mean(abs(prediction(1:8)-A(k,6:13))./A(k,6:13));
                else
                    mapepeak=100*mean(abs(prediction(18:21)-A(k,23:26))./A(k,23:26));
                    mapeord=100*mean(abs(prediction(6:17)-A(k,11:22))./A(k,11:22));
                    mapelow=100*mean(abs(prediction([1:5 22:24])-A(k,[6:10 27:29]))./A(k,[6:10 27:29]));
                end
                
                
                
                
            else
                %% agar bare roze k om dar ekhtiar bood
                mape=[];
                mapepeak=[];
                mapeord=[];
                mapelow=[];
                
            end
            predictionfa=[predictionfa; prediction];
            %     Aa(k,6:29)=prediction;
            mapes=[mape;mapepeak;mapeord;mapelow];
            mapesfa=[mapesfa mapes];
            
            
            
            
        
        
        
    end
    
    corp.zone{1,I}.NeuroPredict=predictionfa;
    corp.zone{1,I}.NeuroMapes=mapesfa';
    corp.zone{1,I}.NeuroErrors=errors;
end
zoneNo=length(corp.zone);
predictionC =[];
actualC = [];
i=find((InputData.cal.calH(:,1)==yy)&(InputData.cal.calH(:,2)==mm)&(InputData.cal.calH(:,3)==dd));

for k=1:days
    prediction =[];
    actual = [];
    for z = 1:zoneNo
        prediction = [prediction;corp.zone{1,z}.NeuroPredict(k,:)];
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
corp.NeuroPredict=predictionC;
corp.NeuroMapes = mapesC;
corp.NeuroErrors = errorsC;

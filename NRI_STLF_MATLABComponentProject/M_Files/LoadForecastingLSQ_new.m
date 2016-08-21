function corp=LoadForecastingLSQ_new(yy,mm,dd,days,corp,InputData,N,flgSimilar,flgBNN,flgNeuro)

if flgSimilar<1
    %     warndlg('Similar Prediction is not found. Wait a moment to run Similar Method','Similar Prediction');
    corp=LoadForecastingsimilar_new(yy,mm,dd,days,corp,InputData);
end
if flgBNN<1
    %     warndlg('Bayesian Neural Network Prediction is not found. Wait a moment to run Bayesian Neural Network Method','Bayesian Neural Network Prediction');
    corp=BNNSTLF6_Zone(yy,mm,dd,days,corp,InputData,12);
end
if flgNeuro<1
    %     warndlg('NeuroFuzzy Prediction is not found. Wait a moment to run NeuroFuzzy Method','NeuroFuzzy Prediction');
    corp=LoadForecastingNeuroFuzzy_new(yy,mm,dd,days,corp,InputData);
end

cd('PreviousPredictionData')
name1=['SimilarPredict','.xls'];
name2=['BNNPredict','.xls'];
name3=['NFPredict','.xls'];
SD=xlsread(name1);
BNN=xlsread(name2);
NF=xlsread(name3);
cd('..')

if ((mm==1)||(mm==7))
    IND1=[find((SD(:,1)<yy).*(SD(:,2)==mm));find((SD(:,1)<yy).*(SD(:,2)==mm+1))];
elseif ((mm==12)||(mm==6))
    IND1=[find((SD(:,1)==yy).*(SD(:,2)==mm-1));find((SD(:,1)<yy).*(SD(:,2)==mm-1));find((SD(:,1)<yy).*(SD(:,2)==mm))];
else
    IND1=[find((SD(:,1)==yy).*(SD(:,2)==mm-1));find((SD(:,1)<yy).*(SD(:,2)==mm+1));find((SD(:,1)<yy).*(SD(:,2)==mm));find((SD(:,1)<yy).*(SD(:,2)==mm-1))];
end
IND1=sort(IND1);
IND2=find(SD(IND1,1)>yy-N-1);
SD=SD(IND2,:);
BNN=BNN(IND2,:);
NF=NF(IND2,:);


if (~((mm==1)||(mm==7)))&&(isempty(find((SD(:,1)==yy).*(SD(:,2)==mm-1))))
    warndlg('The LSQ results can be improved by inserting the prediction of previous month','You can Improve the results');
end
if isempty(find((SD(:,2)==mm).*(SD(:,1)==yy-1)))
    errordlg('The prediction of last year is the most important part. Please insert it.','Empty data for previous year!');
end

[Adays,daytypes,daysramezan]=DayType(InputData);    %Specify day-type of all days (prediction year or training years)

zoneNo=length(corp.zone);
for I=1:size(InputData.lsyszone{1,1},1)
    D(I,1:29)=InputData.lsyszone{1,1}(I,1:29);
    for z = 2:zoneNo
        D(I,6:29)=D(I,6:29)+InputData.lsyszone{1,z}(I,6:29);
    end
end

I2=find((InputData.cal.calH(:,1)==yy)&(InputData.cal.calH(:,2)==mm)&(InputData.cal.calH(:,3)==dd));

for K=I2:I2+days-1
    [Weighting]=OptimumWeighting(InputData.cal.calH(K,1),InputData.cal.calH(K,2),InputData.cal.calH(K,3),D,SD,BNN,NF,Adays,daytypes,daysramezan,InputData); % provide weighting factors for LSQ
    corp.LSQPredict(K-I2+1,1:24)=Weighting(1,1)*corp.BNNPredict(K-I2+1,1:24)+Weighting(2,1)*corp.SimilarPredict(K-I2+1,1:24)+Weighting(3,1)*corp.NeuroPredict(K-I2+1,1:24);
    [corp.LSQMapes(K-I2+1,:), corp.LSQErrors(K-I2+1,:)]=calcError(corp.LSQPredict(K-I2+1,1:24),D(K,6:29),InputData.cal.calH(K,2));
end

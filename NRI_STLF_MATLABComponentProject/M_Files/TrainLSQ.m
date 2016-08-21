function TrainLSQ(yy1,mm1,dd1,yy2,mm2,dd2,Category,dbpath)

corp=CorpBuilder(Category,dbpath);
InputData = ReadData(yy2,yy2-yy1,corp);
cd('PreviousPredictionData')
name1=['SimilarPredict','.xls'];
name2=['BNNPredict','.xls'];
name3=['NFPredict','.xls'];
SD=xlsread(name1);
BNN=xlsread(name2);
NF=xlsread(name3);
cd('..')

IND1=find((InputData.cal.calH(:,1)==yy1).*(InputData.cal.calH(:,2)==mm1).*(InputData.cal.calH(:,3)==dd1));
IND2=find((InputData.cal.calH(:,1)==yy2).*(InputData.cal.calH(:,2)==mm2).*(InputData.cal.calH(:,3)==dd2));

for K=IND1:IND2
    if isempty(find((BNN(:,1)==InputData.cal.calH(K,1)).*(BNN(:,2)==InputData.cal.calH(K,2)).*(BNN(:,3)==InputData.cal.calH(K,3))))
        corp=LoadForecastingsimilar_new(InputData.cal.calH(K,1),InputData.cal.calH(K,2),InputData.cal.calH(K,3),1,corp,InputData);
        corp=BNNSTLF6_Zone(InputData.cal.calH(K,1),InputData.cal.calH(K,2),InputData.cal.calH(K,3),1,corp,InputData);
        corp=LoadForecastingNeuroFuzzy_new(InputData.cal.calH(K,1),InputData.cal.calH(K,2),InputData.cal.calH(K,3),1,corp,InputData);
        SD(end,:)=[InputData.cal.calH(K,1:5) corp.SimilarPredict];
        BNN(end,:)=[InputData.cal.calH(K,1:5) corp.BNNPredict];
        NF(end,:)=[InputData.cal.calH(K,1:5) corp.NeuroPredict];
    end
end
SD=sortrows(SD);
BNN=sortrows(BNN);
NF=sortrows(NF);
cd('PreviousPredictionData')
xlswrite(name1,SD);
xlswrite(name2,BNN);
xlswrite(name3,NF);
cd('..')

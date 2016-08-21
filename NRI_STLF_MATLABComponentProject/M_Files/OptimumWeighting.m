function [Weighting]=OptimumWeighting(yy,mm,dd,D,SD,BNN,NF,Adays,daytypes,daysramezan,InputData)
% yy=yy-N;
% yy is yy-N; In other words, yy is the first year of LSQ train.
% Special days are not totally studied. There are one-by-one.
% options = optimoptions('lsqlin');
% options = optimoptions(@lsqlin,'Algorithm','active-set');
D2=[];
D3=[];
IND1=[];
for I=1:size(BNN,1)
    IND1=[IND1;find((D(:,1)==BNN(I,1)).*(D(:,2)==BNN(I,2)).*(D(:,3)==BNN(I,3)))];
end
Dnew=D(IND1,:);
Adaysnew=Adays(IND1,:);
daytypesnew=daytypes(IND1,:);
daysramezannew=daysramezan(IND1,:);

IND2=find((InputData.cal.calH(:,1)==yy)&(InputData.cal.calH(:,2)==mm)&(InputData.cal.calH(:,3)==dd));

if Adays(IND2)~=0
    I2=find(Adaysnew==Adays(IND2));
    AdaysAllPredictions=reshape([BNN(I2,6:29)',SD(I2,6:29)',NF(I2,6:29)'],[],3);
    Actuals=reshape(Dnew(I2,6:29)',[],1);
else
    I3=find(((daysramezannew==daysramezan(IND2)).*(daytypesnew==daytypes(IND2)).*(Adaysnew==0))==1);
    AdaysAllPredictions=reshape([BNN(I3,6:29)',SD(I3,6:29)',NF(I3,6:29)'],[],3);
    Actuals=reshape(Dnew(I3,6:29)',[],1);
end

[Weighting,~,~,~] = lsqlin(AdaysAllPredictions,Actuals,[],[],ones(1,size(AdaysAllPredictions,2)),[1],zeros(size(AdaysAllPredictions,2),1),ones(size(AdaysAllPredictions,2),1));


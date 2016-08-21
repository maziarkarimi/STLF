function [dayPeakPredict nightPeakPredict]=peakpredict(AIn,Apeak,daytypesIn,prediction)
sampleNo=7;
bound = 100;
A=AIn(1:(end-1),:);
daytypes = daytypesIn(1:(end-1));

indices=find((daytypes'==1)|(daytypes'==2)|(daytypes'==3)|(daytypes'==4));
tempN=[];
tempD=[];
for i=1:sampleNo
    dayP1 = max(A(indices(end-i+1),16:22));
    dayN1 = max(A(indices(end-i+1),23:28));
    if(Apeak(indices(end-i+1),1)-dayP1>bound)
        tempD=[tempD Apeak(indices(end-i+1),1)-dayP1];
    end 
    if(Apeak(indices(end-i+1),2)-dayN1>bound)
        tempN=[tempN Apeak(indices(end-i+1),2)-dayN1];
    end
end
dayP = max(prediction(11:17));
dayN = max(prediction(18:23));
dayPeakPredict=dayP+mean(tempD);
nightPeakPredict=dayN+mean(tempN);
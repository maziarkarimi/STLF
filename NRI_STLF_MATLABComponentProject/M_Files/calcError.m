function [mapes, errors]= calcError(prediction, actual,mm)
mapes = [-1 -1 -1 -1];
errors = -1*ones(1,24);
if sum(isnan(prediction))==0
    if sum(isnan(actual(1,1:24)))==0               
        errors=100*(abs(prediction-actual)./actual);
        mape=mean(errors);
        if mm<7
            mapepeak=mean(errors(21:24));
            mapeord=mean(errors(9:20));
            mapelow=mean(errors(1:8));
        else
            mapepeak=mean(errors(18:21));
            mapeord=mean(errors(6:17));
            mapelow=mean(errors([1:5 22:24]));
        end
    else
        mape=[];
        mapepeak=[];
        mapeord=[];
        mapelow=[];
        errors=[];
    end
    
    mapes=[mape mapepeak mapeord mapelow];
end


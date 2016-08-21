function [prediction]=similarpredict(AIn,yy,mm,dd,daytypesIn,spdtypesIn,ramezanIn,L,weatherIn,FittedWeather)

% added by m karimi for today data
A=AIn(1:(end-1),:);
AToday = AIn(end,6:29);
if sum(isnan(AToday) | (AToday==0))==0
    AToday =nan(1,24);
end
DayinWeek = AIn(end,4);
ramezandays = ramezanIn(1:(end-1));
ramezan = ramezanIn(end);
tomorrowtype=daytypesIn(end);
daytypes = daytypesIn(1:(end-1));
specialtype  = spdtypesIn(end);
spdtypes = spdtypesIn(1:(end-1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ramezan==2
    sp=find(ramezandays'==ramezan);
    sp1=find(ramezandays'==ramezan &(daytypes'==tomorrowtype));
    if sp(1)<20
        op=2;
    else
        op=1;
    end
    prediction1 = Method2(A,op,sp,daytypes,AToday);
    
    if(~isempty(sp1))
        if sp1(1)<20
            op1=2;
        else
            op1=1;
        end
        prediction2 = Method2(A,op1,sp1,daytypes,AToday);
        prediction = 0.3.*prediction1+0.7.*prediction2;
    else
        prediction = prediction1;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif (ramezan==1 && tomorrowtype~=5 && tomorrowtype~=6)
    if(mm~=7)
        indices1=find((daytypes'==tomorrowtype) & (ramezandays'==ramezan));
    else
        mmm = MinusN_M(mm,A(:,2)); %Add by Gholami
        indices1=find((daytypes'==tomorrowtype) & (mmm== 0) & (ramezandays'==ramezan));%Correct by Gholami
    end
    prediction1 = Method1 (A,indices1,AToday,5,L,weatherIn,FittedWeather);
    indices2=find((daytypes'==tomorrowtype) & (yy==A(:,1)) & (ramezandays'==ramezan));
    
    if isempty(indices2)==1
        prediction = prediction1;
    else
        prediction2 = Method1 (A,indices2,AToday,3,L,weatherIn,FittedWeather);
        prediction=(0.3.*prediction1+ 0.7.*prediction2);
    end
    
else
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (mm==12)&&((dd==29)||(dd==28))
        indices1=find((A(:,2)==mm)&(A(:,3)==dd)& (A(:,1)==A(end,1)-4 | A(:,1)==A(end,1)-8)); %% for similar  new year begin
        indices2=find((A(:,2)==mm)&(A(:,3)==dd));
        
        predictionb2 = Method2(A,1,indices2,daytypes,AToday);
        predictiona2=[];
        for ind=1:min(size(indices2,1),2)
            
            if or((daytypes(indices2(end-ind+1)-1)==4),(daytypes(indices2(end-ind+1)-1)==5))
                dayholidaysp=1;
            else
                dayholidaysp=0;
            end
            if or((daytypes((end))==4),(daytypes((end))==5)) %% change (end-1) to (end) !! because daytypes is (1:k-1)
                dayholidaynow=1;
            else
                dayholidaynow=0;
            end
            %%%
            if dayholidaysp==dayholidaynow
                predict = Method1(A,indices2(end-ind+1),AToday,1,L,weatherIn,FittedWeather);
                predictiona2 =[predictiona2; predict];
            end
        end
        predictiona2=mean(predictiona2,1);
        if(isempty(predictiona2))
            predictiona2=predictionb2;
        end
        
        if(~isempty(indices1))
            predictionb1 = Method2(A,1,indices1,daytypes,AToday);

            predictiona1=[];
            for ind=1:min(size(indices1,1),2)
                
                if or((daytypes(indices1(end-ind+1)-1)==4),(daytypes(indices1(end-ind+1)-1)==5))
                    dayholidaysp=1;
                else
                    dayholidaysp=0;
                end
                if or((daytypes((end))==4),(daytypes((end))==5)) %% change (end-1) to (end) !! because daytypes is (1:k-1)
                    dayholidaynow=1;
                else
                    dayholidaynow=0;
                end
                %%%
                if dayholidaysp==dayholidaynow
                    predict = Method1(A,indices1(end-ind+1),AToday,1,L,weatherIn,FittedWeather);
                    predictiona1 =[predictiona1; predict];
                end
            end
            predictiona1=mean(predictiona1,1);
            if(isempty(predictiona1))
                predictiona1=predictionb1;
            end
            
            prediction=((0.2.*0.5.*(predictiona1+predictionb1))+(0.8.*0.5.*(predictiona2+predictionb2)));
        else
            prediction=0.5.*(predictiona2+predictionb2);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif (mm==12)&&(dd==30)
        indices=find((A(:,2)==mm)&(A(:,3)==dd));
        predictiona = Method1(A,indices,AToday,3,L,weatherIn,FittedWeather) ;
        predictionb = Method2(A,1,indices,daytypes,AToday);
        prediction=0.5.*(predictiona+predictionb);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif (mm==12)&&(dd>22) && tomorrowtype~=5
        indices=[];
        if(DayinWeek==4) %% last tuesday
            k=1;
            while size(A,1)>365*k
                ind1=find(((A((365*(k-1)+1):(365*k+1),2)==12)&(A((365*(k-1)+1):(365*k+1),4)==5)),1,'last');
                if(A(365*(k-1)+ind1-1,5)==1)
                    indices = [indices; 365*(k-1)+ind1-1];
                end
                k=k+1;
            end
            if isempty(indices)==1
                errordlg('Number of the yeas for Similar Days Forecasting is not sufficient.Please change variable "First Year".','Error!','on');
                prediction=NaN(1,24);
            else
                prediction1 = Method1(A,indices,AToday,3,L,weatherIn,FittedWeather) ;
                prediction2 = Method2(A,1,indices,daytypes,AToday);
                prediction=0.5.*prediction1+0.5.*prediction2;
            end
        else
            indices1=find((A(:,2)==12)&(A(:,3)>22)&(daytypes'==tomorrowtype)&(A(:,4)~=4) );
            if isempty(indices1)==1
                errordlg('Number of the yeas for Similar Days Forecasting is not sufficient.Please change variable "First Year".','Error!','on');
                prediction=NaN(1,24);
            else
                prediction1 = Method1 (A,indices1,AToday,3,L,weatherIn,FittedWeather);
                %prediction1 = Method2(A,1,indices1,daytypes);
                indices2=find((A(:,2)==12)&(A(:,3)>22)&(daytypes'==tomorrowtype)&(A(:,4)==DayinWeek));
                
                if (~isempty(indices2))
                    prediction2 = Method1 (A,indices2,AToday,3,L,weatherIn,FittedWeather);
                    %prediction2 = Method2(A,1,indices2,daytypes);
                    prediction=0.5.*prediction1+0.5.*prediction2;
                else
                    prediction = prediction1;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif (mm==1)&&(dd==1)
        indices2=find((A(:,2)==mm)&(A(:,3)==dd));
        if indices2(1)<20
            op=2;
        else
            op=1;
        end
        predictiona2 = Method1(A,indices2,AToday,3,L,weatherIn,FittedWeather);
        predictionb2 = Method2(A,op,indices2,daytypes,AToday);
        
        indices1=find((A(:,2)==mm)&(A(:,3)==dd)& (A(:,1)==A(end,1)-3 | A(:,1)==A(end,1)-7));  %% for similar new year begin
        if(~isempty(indices1))
            if(size(indices1,1)>1 || indices1(1)>1)
                if indices1(1)<20
                    op=2;
                else
                    op=1;
                end
                predictiona1 = Method1(A,indices1,AToday,3,L,weatherIn,FittedWeather);
                predictionb1 = Method2(A,op,indices1,daytypes,AToday);
                
                prediction=((0.7*0.5.*(0.5.*predictiona1+1.5.*predictionb1))+(0.3*0.5.*(0.5.*predictiona2+1.5.*predictionb2)));
            else
                prediction=0.5.*(0.5.*predictiona2+1.5.*predictionb2);
            end                
        else
            prediction=0.5.*(0.5.*predictiona2+1.5.*predictionb2);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif (mm==6)&&(dd==31)
        indices1=find((A(:,2)==mm)&(A(:,3)==dd));
        predictiona2 = Method1(A,indices1,AToday,3,L,weatherIn,FittedWeather);
        predictionb2 = Method2(A,1,indices1,daytypes,AToday);
        
        indices=find((A(:,2)==6)&(A(:,3)==31)& (daytypes'==tomorrowtype));
        if(~isempty(indices))
            predictiona1 = Method1(A,indices,AToday,3,L,weatherIn,FittedWeather);
            predictionb1 = Method2(A,1,indices,daytypes,AToday);
            
            prediction=0.5.*((0.5.*(predictiona1+predictionb1))+(0.5.*(predictiona2+predictionb2)));
        else
            prediction=0.5.*(predictiona2+predictionb2);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif tomorrowtype==5
        indices=find(spdtypes==specialtype);
        indices2 = find(spdtypes==specialtype & (A(:,4)==DayinWeek));
        if (isempty(indices2))
            indices2=indices;
        end
        
        if indices(1)<20
            op=2;
        else
            op=1;
        end
        predictiona = Method2(A,op,indices,daytypes,AToday);
        if indices2(1)<20
            op=2;
        else
            op=1;
        end
        predictiona2 = Method2(A,op,indices2,daytypes,AToday);

%         predictionaa = Method1J(A,sp,AToday,3,L,weatherIn)  ;
        %%%
        predictionb = [];
        for ind=1:size(indices,1)
            if(indices(end-ind+1)>2) %% for day 2 in LoadData can't operate this method!
                if or((daytypes(indices(end-ind+1)-1)==4),(daytypes(indices(end-ind+1)-1)==5))
                    dayholidaysp=1;
                else
                    dayholidaysp=0;
                end
                if or((daytypes((end))==4),(daytypes((end))==5)) %% change (end-1) to (end) !! because daytypes is (1:k-1)
                    dayholidaynow=1;
                else
                    dayholidaynow=0;
                end
                %%%
                if dayholidaysp==dayholidaynow
                    predict = Method1(A,indices(end-ind+1),AToday,1,L,weatherIn,FittedWeather);
                    predictionb =[predictionb; predict];
                end
            end
        end
        
%         if(~isempty(indices2))
%             predictionc = Method1(A,indices2,AToday,3,L,weatherIn);
%         end
       
        predictionb=mean(predictionb,1);
        if(predictionb ~=0)
            prediction=0.5.*(1*predictiona+0.5*predictionb+0.5*predictiona2);
        else
            prediction=predictiona;
        end
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif (mm==1)&&(dd==5)
        indices=find((A(:,2)==1)&(A(:,3)==5)&(daytypes'==tomorrowtype));
        if isempty(indices)==1
            errordlg('Number of the yeas for Similar Days Forecasting is not sufficient.Please change variable "First Year".','Error!','on');
            prediction=NaN(1,24);
        else
            prediction1 = Method1 (A,indices,AToday,5,L,weatherIn,FittedWeather);
            
            indices1=find((A(:,2)==1)&(A(:,3)==dd)&(daytypes'==tomorrowtype)&(A(:,4)==DayinWeek));
            if (~isempty(indices1))
                prediction2 = Method1 (A,indices1,AToday,3,L,weatherIn,FittedWeather);
                prediction=0.5.*(prediction1+prediction2);
            else
                prediction = prediction1;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif (mm==1)&&(dd<13)&&(tomorrowtype~=6)
        indices=find((A(:,2)==1)&(A(:,3)<13)&(daytypes'==tomorrowtype));
        if isempty(indices)==1
            errordlg('Number of the yeas for Similar Days Forecasting is not sufficient.Please change variable "First Year".','Error!','on');
            prediction=NaN(1,24);
        else
            prediction1 = Method1 (A,indices,AToday,5,L,weatherIn,FittedWeather);
            
            indices1=find((A(:,2)==1)&(A(:,3)==dd)&(daytypes'==tomorrowtype)&(A(:,4)==DayinWeek));
            if (~isempty(indices1))
                prediction2 = Method1 (A,indices1,AToday,3,L,weatherIn,FittedWeather);
                prediction=0.5.*(prediction1+prediction2);
            else
                prediction = prediction1;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif (mm==1)&&(dd==14)
        
        indices3=find((A(:,2)==mm)&(A(:,3)==dd));
        if indices3(1)<20
            op=2;
        else
            op=1;
        end
        predictiona3 = Method1(A,indices3,AToday,3,L,weatherIn,FittedWeather);
        predictionb3 = Method2(A,op,indices3,daytypes,AToday);
        
        indices2=find((A(:,2)==mm)&(A(:,3)==dd)& (daytypes'==tomorrowtype));
        if(~isempty(indices2))
            if indices2(1)<20
                op=2;
            else
                op=1;
            end
            predictiona2 = Method1(A,indices2,AToday,3,L,weatherIn,FittedWeather);
            if(op==2 && size(indices2,1)==1)
                predictionb2=predictiona2;
            else
                predictionb2 = Method2(A,op,indices2,daytypes,AToday);                
            end
            
            indices1=find((A(:,2)==mm)&(A(:,3)==dd)& (daytypes'==tomorrowtype) & (A(:,4)==DayinWeek));
            if(~isempty(indices1))
                if indices1(1)<20
                    op=2;
                else
                    op=1;
                end
                predictiona1 = Method1(A,indices1,AToday,3,L,weatherIn,FittedWeather);
                predictionb1 = Method2(A,op,indices1,daytypes,AToday);
                
                prediction=((0.6*0.5.*(predictiona1+predictionb1))+(0.4*0.5.*(predictiona2+predictionb2)));
            else
                prediction=((0.6*0.5.*(predictiona2+predictionb2))+(0.4*0.5.*(predictiona3+predictionb3)));
            end
        else
            prediction=0.5.*(predictiona3+predictionb3);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif (mm==1)&&(dd<22)&&(tomorrowtype~=6)
        indices=find((A(:,2)==1)&(A(:,3)<22 & A(:,3)>14)&(daytypes'==tomorrowtype)& (ramezandays'==ramezan));
        if isempty(indices)==1
            errordlg('Number of the years for Similar Days Forecasting is not sufficient.Please change variable "First Year".','Error!','on');
            prediction=NaN(1,24);
        else
            prediction = Method1 (A,indices,AToday,5,L,weatherIn,FittedWeather);
        end
    elseif (mm==1)&&(tomorrowtype~=6)
        indices=find((A(:,2)==1)& (A(:,3)>20)&(daytypes'==tomorrowtype)& (ramezandays'==ramezan));
        if isempty(indices)==1
            errordlg('Number of the years for Similar Days Forecasting is not sufficient.Please change variable "First Year".','Error!','on');
            prediction=NaN(1,24);
        else
            prediction = Method1 (A,indices,AToday,5,L,weatherIn,FittedWeather);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif and(tomorrowtype~=5,tomorrowtype~=6)
        mmm=MinusN_M(mm,A(:,2));%Add by Gholami
        if(mm~=1 && mm~=7)
            indices3=find((daytypes(3:end)'==tomorrowtype) & (daytypes(2:end-1)'==daytypesIn(end-1))& (daytypes(1:end-2)'==daytypesIn(end-2))& (mmm(3:end)== 1 | mmm(3:end)==0) & (ramezandays(3:end)'==ramezan));%Correct by Gholami
            if isempty(indices3)==1
                indices1=find((daytypes'==tomorrowtype) & (mmm== 0 | mmm==1) & (ramezandays'==ramezan));%Correct by Gholami
            else
                indices1=SumN_M(2,indices3);
            end
        else
            indices3=find((daytypes(3:end)'==tomorrowtype) & (daytypes(2:end-1)'==daytypesIn(end-1))& (daytypes(1:end-2)'==daytypesIn(end-2))& (mmm(3:end)==0) & (ramezandays(3:end)'==ramezan));%Correct by Gholami
            if isempty(indices3)==1
                indices1=find((daytypes'==tomorrowtype) & (mmm== 0) & (ramezandays'==ramezan));%Correct by Gholami
            else
                indices1=SumN_M(2,indices3);
            end
        end
        prediction1 = Method1 (A,indices1,AToday,5,L,weatherIn,FittedWeather);

        ddd= MinusM_N(A(:,3),dd);%Add by Gholami
        indices2=find((daytypes'==tomorrowtype) & (mmm==0) & (abs(ddd)<=7) & (ramezandays'==ramezan));%Correct by Gholami
        indices3=[];
        if (dd<8)
            ddd= MinusM_N(A(:,3),30+dd);%Add by Gholami
            indices3=find((daytypes'==tomorrowtype) & (mmm==1) & (abs(ddd)<=7) & (ramezandays'==ramezan));%Correct by Gholami
        end
        indices2=union(indices2,indices3);
        if isempty(indices2)==1
            prediction = prediction1;
        else
            prediction2 = Method1 (A,indices2,AToday,3,L,weatherIn,FittedWeather);
            prediction=(0.2*prediction1+ 0.8*prediction2);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif tomorrowtype==6
        ll=find((daytypes(1:(end-15))~=5));
        predictiona = MethodS(AIn,yy,mm,dd,daytypesIn,spdtypesIn,ramezanIn,L,ll,weatherIn,FittedWeather);
        %%%
        if A(end,4)==7
            daytomorrow=1;
        elseif A(end,4)==6
            daytomorrow=4;
        elseif A(end,4)==5
            daytomorrow=3;
        else
            daytomorrow=2;
        end
        
        %%%
        specialtype2=spdtypes(end);
        sp=find((spdtypes(1:(end-1))==specialtype2)&(daytypes(2:end)'==6));
        if isempty(sp)==1
            errordlg('Number of the years for Similar Days Forecasting is not sufficient.Please change variable "First Year".','Error!','on');
            prediction=NaN(1,24);
        else
            %sp=sp+1; % commented by m karimi
            predictionc = [];
            predictiond = [];
            indices=sp';
            for ind=1:size(sp,1)
                if A(sp(end-ind+1),4)==7
                    daytomorrowsp=1;
                elseif A(sp(end-ind+1),4)==6
                    daytomorrowsp=4;
                elseif A(sp(end-ind+1),4)==5
                    daytomorrowsp=3;
                else
                    daytomorrowsp=2;
                end
                if (daytomorrowsp==4 || daytomorrowsp==3)
                    dayholidaysp=1;
                else
                    dayholidaysp=0;
                end
                if (daytomorrow==4 || daytomorrow==3)
                    dayholidaynow=1;
                else
                    dayholidaynow=0;
                end
                if dayholidaysp==dayholidaynow
                    if sp(1)>20
                        op=size(sp,1);
                    else
                        op=size(sp,1)-1;
                    end
                    
                    predict = Method1(A,indices(end-ind+1),AToday,1,L,weatherIn,FittedWeather);
                    predictionc = [predictionc; predict];
                    if(ind<=op)
                        predict = Method21(A,indices(end-ind+1),daytypes,AToday);
                        predictiond = [predictiond; predict];
                    end
                end
            end
            predictionc = mean(predictionc,1);
            predictiond = mean(predictiond,1);
            
            if (isempty(predictionc))
                prediction= predictiona;
            elseif (isempty(predictiond))
                prediction=(2.5.*predictiona+0.5.*predictionc)./3;
            else
                prediction=(3.*predictiona+0.5.*predictionc+0.5.*predictiond)./4;
                %prediction=(1*predictionc+1*predictiond)/2;
                
            end
        end
    end
end

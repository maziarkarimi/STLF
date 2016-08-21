function PredictionOutput(corp, actual, days, flgSimilar, flgBNN, flgNeuro, flgLSQ)

%%% 5 columns of actual is date data and 24 columns of actual is Load Data.

        
for lct=1:days
    if(actual(lct,4)==1)
        temp = 'Saturday';
    elseif(actual(lct,4)==2)
        temp = 'Sunday';
    elseif(actual(lct,4)==3)
        temp = 'Monday';
    elseif(actual(lct,4)==4)
        temp = 'Tuesday';
    elseif(actual(lct,4)==5)
        temp = 'Wednesday';
    elseif(actual(lct,4)==6)
        temp = 'Thursday';
    elseif(actual(lct,4)==7)
        temp = 'Friday';
    end
    if sum(isnan(actual(lct,1:24))==0) && all(actual(lct,1:24)~=0)        
                
        figure();  
        hold on
        titleText = {['\bf',corp.name,' Load Forecasting,','\rm Date:',num2str(actual(lct,1)),'/',num2str(actual(lct,2)),'/',num2str(actual(lct,3)),', ',temp];};
        plot(actual(lct,6:29),'r');
        legendText={'Actual Load'};
        %
        legendText2={};
        predictError =[];
        Color = [];
        if(flgSimilar>0)
            titleText(end+1)={['SimilarDay: mape=',num2str(corp.SimilarMapes(lct,1)),'% ','maxError=',num2str(max(corp.SimilarErrors(lct,:))),'%']};
            plot(corp.SimilarPredict(lct,:),'b');
            legendText(end+1)={'SimilarDay Prediction'};
            %
            predictError=[predictError; corp.SimilarErrors(lct,:)];
            legendText2(end+1)={'SimilarDay Errors'};
            Color =[Color;'b'];
        end
        if(flgBNN>0)
            titleText(end+1)={['BNN: mape=',num2str(corp.BNNMapes(lct,1)),'% ','maxError=',num2str(max(corp.BNNErrors(lct,:))),'%']};
            plot(corp.BNNPredict(lct,:),'g');
            legendText(end+1)={'BNN Prediction'};
            %
            predictError=[predictError; corp.BNNErrors(lct,:)];
            legendText2(end+1)={'BNN Errors'};
            Color =[Color;'g'];
        end
        if(flgNeuro>0)
            titleText(end+1)={['NeuroFuuzy: mape=',num2str(corp.NeuroMapes(lct,1)),'% ','maxError=',num2str(max(corp.NeuroErrors(lct,:))),'%']};
            plot(corp.NeuroPredict(lct,:),'c');
            legendText(end+1)={'NeuroFuuzy Prediction'};
            %
            predictError=[predictError; corp.NeuroErrors(lct,:)]; 
            legendText2(end+1)={'NeuroFuuzy Errors'};
            Color =[Color;'c'];
        end
        if(flgLSQ>0)            
            titleText(end+1)={['LSQ: mape=',num2str(corp.LSQMapes(lct,1)),'% ','maxError=',num2str(max(corp.LSQErrors(lct,:))),'%']};
            plot(corp.LSQPredict(lct,:),'m');
            legendText(end+1)={'LSQ Prediction'};  
            %
            predictError=[predictError; corp.LSQErrors(lct,:)];          
            legendText2(end+1)={'LSQ Errors'};
            Color =[Color;'m'];
        end
        
        legend(legendText,'Location','NorthWest');
        title(titleText);
        grid on;
        ylabel('Load');
        xlabel('Hour');
        hold off
        
        

%         figure(lct+days);
        figure();  
        hold on;                
        hbar = bar(predictError');
        for ii=1:size(Color,1)
            set(hbar(ii),'FaceColor',Color(ii));
        end
        legend(legendText2,'Location','NorthWest');
        title(titleText);
        grid on;        
        ylabel('Error');
        xlabel('Hour');
        hold off
        
    else
%         figure(lct);  
figure();  
        hold on
        titleText = {['\bf',corp.name,' Load Forecasting,','\rm Date:',num2str(actual(lct,1)),'/',num2str(actual(lct,2)),'/',num2str(actual(lct,3)), ', ',temp];};
        legendText={};
        
        if(flgSimilar>0)
            plot(corp.SimilarPredict(lct,:),'b');
            legendText(end+1)={'SimilarDay Prediction'};            
        end
        if(flgBNN>0)
            plot(corp.BNNPredict(lct,:),'g');
            legendText(end+1)={'BNN Prediction'};            
        end
        if(flgNeuro>0)
            plot(corp.NeuroPredict(lct,:),'c');
            legendText(end+1)={'NeuroFuuzy Prediction'};            
        end
        if(flgLSQ>0)            
            plot(corp.LSQPredict(lct,:),'m');
            legendText(end+1)={'LSQ Prediction'};           
        end
        
        legend(legendText,'Location','NorthWest');
        title(titleText);
        grid on;
        ylabel('Load');
        xlabel('Hour');
        hold off
    end
end
obj= {' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '};
obj1 = obj;
obj1(1,2)={['MapePeak: ']};
obj1(1,5)={['MapeOrd: ']};
obj1(1,8)={['MapeLow: ']};
obj1(1,11)={['Mape: ']};
obj1(1,14)={['MaxError: ']};
obj1(1,17)={['Std: ']};
        
mh_xls_vector= obj;
for lct=1:days
    mh_xls_vector(end+1,:)= obj;
    mh_xls_vector(end,2)={['Date : ']};
    mh_xls_vector(end,3)={[num2str(actual(lct,1)),'/',num2str(actual(lct,2)),'/',num2str(actual(lct,3))]};
    
    mh_xls_vector(end+1,:)= obj;
    mh_xls_vector(end,1)={'Hour :'};
    for jj=1:24
        mh_xls_vector(end,1+jj)={num2str(jj)};       
    end    
    
    if sum(isnan(actual(lct,1:24)))==0 && all(actual(lct,1:24)~=0)
        mh_xls_vector(end+1,:)= obj;
        mh_xls_vector(end,1)={'Actual:'};
        for jj=1:24
            mh_xls_vector(end,1+jj)={num2str(actual(lct,5+jj))};       
        end
    end
    
    if(flgSimilar>0)
        mh_xls_vector(end+1,:)= obj;
        mh_xls_vector(end,1)={'SimilarDay:'};
        for jj=1:24
            mh_xls_vector(end,1+jj)={num2str(corp.SimilarPredict(lct,jj))};       
        end
    end
    
    if(flgBNN>0)
        mh_xls_vector(end+1,:)= obj;
        mh_xls_vector(end,1)={'BNN:'};
        for jj=1:24
            mh_xls_vector(end,1+jj)={num2str(corp.BNNPredict(lct,jj))};       
        end
    end    
    
    if(flgNeuro>0)
        mh_xls_vector(end+1,:)= obj;
        mh_xls_vector(end,1)={'NeuroFuuzy:'};
        for jj=1:24
            mh_xls_vector(end,1+jj)={num2str(corp.NeuroPredict(lct,jj))};       
        end
         
    end
    
    if(flgLSQ>0)   
        mh_xls_vector(end+1,:)= obj;
        mh_xls_vector(end,1)={'LSQ:'};
        for jj=1:24
            mh_xls_vector(end,1+jj)={num2str(corp.LSQPredict(lct,jj))};       
        end
    end
    
    
    if sum(isnan(actual(lct,1:24)))==0 && all(actual(lct,1:24)~=0)
        
        if(flgSimilar>0)
            mh_xls_vector(end+1,:)= obj1;
            mh_xls_vector(end,1)={'SimilarDay indices:'};
            mh_xls_vector(end,3)={num2str(corp.SimilarMapes(lct,2))};
            mh_xls_vector(end,6)={num2str(corp.SimilarMapes(lct,3))};
            mh_xls_vector(end,9)={num2str(corp.SimilarMapes(lct,4))};
            mh_xls_vector(end,12)={num2str(corp.SimilarMapes(lct,1))};
            mh_xls_vector(end,15)={num2str(max(corp.SimilarErrors(lct,:)))};
            mh_xls_vector(end,18)={num2str(std(corp.SimilarErrors(lct,:)))};
        end

        if(flgBNN>0)
            mh_xls_vector(end+1,:)= obj1;
            mh_xls_vector(end,1)={'BNN indices:'};
            mh_xls_vector(end,3)={num2str(corp.BNNMapes(lct,2))};
            mh_xls_vector(end,6)={num2str(corp.BNNMapes(lct,3))};
            mh_xls_vector(end,9)={num2str(corp.BNNMapes(lct,4))};
            mh_xls_vector(end,12)={num2str(corp.BNNMapes(lct,1))};
            mh_xls_vector(end,15)={num2str(max(corp.BNNErrors(lct,:)))};
            mh_xls_vector(end,18)={num2str(std(corp.BNNErrors(lct,:)))};
        end    

        if(flgNeuro>0)
            mh_xls_vector(end+1,:)= obj1;
            mh_xls_vector(end,1)={'NeuroFuuzy indices:'};
            mh_xls_vector(end,3)={num2str(corp.NeuroMapes(lct,2))};
            mh_xls_vector(end,6)={num2str(corp.NeuroMapes(lct,3))};
            mh_xls_vector(end,9)={num2str(corp.NeuroMapes(lct,4))};
            mh_xls_vector(end,12)={num2str(corp.NeuroMapes(lct,1))};
            mh_xls_vector(end,15)={num2str(max(corp.NeuroErrors(lct,:)))};
            mh_xls_vector(end,18)={num2str(std(corp.NeuroErrors(lct,:)))};
        end

        if(flgLSQ>0)   
            mh_xls_vector(end+1,:)= obj1;
            mh_xls_vector(end,1)={'LSQ indices:'};
            mh_xls_vector(end,3)={num2str(corp.LSQMapes(lct,2))};
            mh_xls_vector(end,6)={num2str(corp.LSQMapes(lct,3))};
            mh_xls_vector(end,9)={num2str(corp.LSQMapes(lct,4))};
            mh_xls_vector(end,12)={num2str(corp.LSQMapes(lct,1))};
            mh_xls_vector(end,15)={num2str(max(corp.LSQErrors(lct,:)))};
            mh_xls_vector(end,18)={num2str(std(corp.LSQErrors(lct,:)))};
        end 
        
    end
    
    mh_xls_vector(end+1,:)= obj;
    mh_xls_vector(end+1,:)= obj;
end

mh_xls_filename=['LoadForecastingResults',num2str(actual(1,1)),',',num2str(actual(1,2)),',',num2str(actual(1,3)),',',num2str(days),',',corp.name,'.xls'];
cd('ForecastingResults');
xlswrite(mh_xls_filename,mh_xls_vector);
cd('..')
  

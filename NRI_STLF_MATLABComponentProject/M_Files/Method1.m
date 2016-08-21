function prediction = Method1(A,indicesIn,AToday,N,L,weatherIn,FittedWeather)  

indicesIn(indicesIn==1)=[];

% generate weatherCompare
k=size(A,1);
weatherCompareT=[];
weatherCompareH=[];
weatherCompareN=[];
indicesT=[];
indicesH=[];
indicesN=[];

flag = ~isempty(weatherIn.temp)+ ~isempty(weatherIn.humidity)+ ~isempty(weatherIn.nebulosity);
if (flag)
    %%
    weatherT=[];
    for ii=1:length(weatherIn.temp)
        weatherT=[weatherT, weatherIn.temp{ii,1}(1:(k+1),[7])];%% mean temperature (7) is selected with trial and error
    end
    
    for i=1:(size(weatherT,1)-1)
        weatherCompareT(i,:) = weatherT(i,:)-weatherT(end,:);
    end
     %%
    weatherH=[];
    for ii=1:length(weatherIn.humidity)
        weatherH=[weatherH, weatherIn.humidity{ii,1}(1:(k+1),[6])];%% mean humidity (6) is selected with trial and error
    end
    
    for i=1:(size(weatherH,1)-1)
        weatherCompareH(i,:) = weatherH(i,:)-weatherH(end,:);
    end    
%     %% for precipitation
%     weatherP=[];
%     for ii=1:length(weatherIn.precipitation)
%         weatherP=[weatherP, weatherIn.precipitation{ii,1}(1:(k+1),[6])];%% precipitation (6) is selected with trial and error
%     end
%     
%     for i=1:(size(weatherP,1)-1)
%         if(weatherP(i,:)==0 && weatherP(end,:)==0) ||(weatherP(i,:)~=0 && weatherP(end,:)~=0)
%             weatherCompareP(i,:) = 1;
%         else
%             weatherCompareP(i,:) = 0;
%         end
%     end  
    %%
    weatherN=[];
    for ii=1:length(weatherIn.nebulosity)
        weatherN=[weatherN, weatherIn.nebulosity{ii,1}(1:(k+1),[6])];%% mean nebulosity (6) is selected with trial and error
    end
    
    for i=1:(size(weatherN,1)-1)
        weatherCompareN(i,:) = weatherN(i,:)-weatherN(end,:);
    end
end

if(~isempty(weatherCompareT))
    ind1 = find(all(abs(weatherCompareT(indicesIn,:))<=6,2));%% 6 is selected with trial and error
    if(~isempty(ind1))
        indicesT = indicesIn(ind1);
    else
        indicesT = indicesIn;
    end
end

if(~isempty(weatherCompareH))
    ind1 = find(all(abs(weatherCompareH(indicesIn,:))<=15,2));%% 10 is selected with trial and error
    if(~isempty(ind1))
        indicesH = indicesIn(ind1);
    else
        indicesH = indicesIn;
    end
end

% if(~isempty(weatherCompareP))
%     ind1 = find(weatherCompareP(indicesIn,:)==1);%%
%     if(~isempty(ind1))
%         indicesP = indicesIn(ind1);
%     else
%         indicesP = indicesIn;
%     end
% end

if(~isempty(weatherCompareN))
    ind1 = find(all(abs(weatherCompareN(indicesIn,:))<=2,2));%% 10 is selected with trial and error
    if(~isempty(ind1))
        indicesN = indicesIn(ind1);
    else
        indicesN = indicesIn;
    end
end


if(flag)
     indices1 = indicesT;
     indices = intersect(indicesT,indicesN,'rows');
     indices = intersect(indicesH,indices,'rows');
%      indices = intersect(indicesP,indices,'rows');
     if(isempty(indices))
        indices=indices1;
    end

    EukDis=zeros(size(indices));
    if(~isempty(weatherCompareT))
        nwt = size(indices,1);
        wt = ones(nwt,1)*(1./(nwt*mean(weatherCompareT(indices,:)).*mean(weatherCompareT(indices,:))));
        EukDis = EukDis + sum(weatherCompareT(indices,:).*weatherCompareT(indices,:) .* wt,2);%% 
    end
    if(~isempty(weatherCompareH))
        nwh = size(indices,1);
        wh = ones(nwh,1)*(1./(nwh*mean(weatherCompareH(indices,:)).*mean(weatherCompareH(indices,:))));
        EukDis = EukDis+ sum( weatherCompareH(indices,:).*weatherCompareH(indices,:) .* wh,2);%% 
    end 
    if(~isempty(weatherCompareN))
        nwn = size(indices,1);
        wn = ones(nwn,1)*(1./(nwn*mean(weatherCompareN(indices,:)).*mean(weatherCompareN(indices,:))));
        EukDis = EukDis+ sum( weatherCompareN(indices,:).*weatherCompareN(indices,:) .* wn,2);%% 
    end
    
    EukDis = EukDis +((MinusM_N(indices,max(indices)+1).^2)./(mean(MinusM_N(indices,max(indices)+1)).^2)./size(indices,1));%% add day value to eukDis and weghting factor (2000) is selected with trial and error
    
    [EukDis2, ind]= sort(EukDis,'descend');
    if(~isempty(ind))
        indices = indices(ind);
    else
        indices = indices;
    end
else
    indices = indicesIn;
end

if(~isempty(indices))    
    B2=A((end-1):end,:);
    C2=reshape(B2(:,6:29)',1,24*size(B2,1));

    if N>size(indices,1)
        N=size(indices,1);
    end

    for ind=1:N
        BB=A((indices(end-ind+1)-2):(indices(end-ind+1)-1),:);
        CC=reshape(BB(:,6:29)',1,24*size(BB,1));
        DD=CC((end-L+1):end);
        A22=A(indices(end-ind+1),6:29);
       
        FW=[];
        for hh=1:L
            if isempty(FittedWeather)
                wt=1;
            else
                wt=1/FittedWeather{1,24-hh+1}(weatherIn.temp{1,1}(indices(end-ind+1)-1,8+24-hh+1));
            end
            FW=[wt FW];
        end
        
        for i=1:24
            if isempty(FittedWeather)
                wt=1;
                wtT=1;
            else
                wt=1/FittedWeather{1,i}(weatherIn.temp{1,1}(indices(end-ind+1),8+i));
                wtT=1/FittedWeather{1,i}(weatherIn.temp{1,1}(k+1,8+i));
            end
            m1a(i)=WeightedMean(DD,FW)*(1+(0.04*(wtT-wt)/wtT));

%             m1a(i)=WeightedMean(DD,FW)*(1+((1-exp(-1*abs(1-(wt/wtT))))*0.1*(wtT-wt)/wtT));
%             m1a(i)=mean(DD)*(1+((1-exp(-1*abs(1-(wtT/wt))))*(wtT-wt)/wtT));

            DD=[DD(2:end) A(indices(end-ind+1),5+i)];
            FW=[FW(2:end) wt];
        end
        Anormal(ind,:)=A22./m1a;
    end

    Anormal = mean(Anormal,1);
    DD2=C2((end-L+1):end);
    FW2=[];
    for hh=1:L
        if isempty(FittedWeather)
            wt=1;
        else
            wt=1/FittedWeather{1,24-hh+1}(weatherIn.temp{1,1}(k,8+24-hh+1));
        end
        FW2=[wt FW2];
    end
        
    for i=1:24
        % added by m karimi for today data
        if isempty(FittedWeather)
            wt=1;
        else
            wt=1/FittedWeather{1,i}(weatherIn.temp{1,1}(k+1,8+i));
        end
        if(isnan(AToday(i)) || AToday(i)==0)
            m1b=WeightedMean(DD2,FW2);
            prediction(i)=Anormal(i).*m1b;
        else
            prediction(i) = AToday(i);
        end
        DD2=[DD2(2:end) prediction(i)];
        FW2=[FW2(2:end) wt];
    end
else
    prediction=NaN(1,24);
end
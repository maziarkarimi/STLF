function prediction = Method1FW(A,indicesIn,AToday,N,L,weatherIn,FittedWeather)  

indicesIn(indicesIn==1)=[];

% generate weatherCompare
k=size(A,1);
weatherCompare=[];
if (~isempty(weatherIn))
    weatherT=[];
    for ii=1:length(weatherIn.temp)
        weatherT=[weatherT, weatherIn.temp{ii,1}(1:(k+1),[7])];%% mean temperature (7) is selected with trial and error
    end
    for i=1:(size(weatherT,1)-1)
        weatherCompare(i,:) = weatherT(i,:)-weatherT(end,:);
    end
end


if(~isempty(weatherCompare))
    ind1 = find(all(abs(weatherCompare(indicesIn,:))<=6,2));%% 6 is selected with trial and error
    if(~isempty(ind1))
        indices = indicesIn(ind1);
    else
        indices = indicesIn;
    end

    nw = size(weatherCompare,2);
    w = ones(nw,1)./nw;
    EukDis = ( weatherCompare(indices,:).*weatherCompare(indices,:) * w)+(2000./(indices+mean(indices)));%% add day value to eukDis and weghting factor (2000) is selected with trial and error
    [EukDis2, ind]= sort(EukDis,'descend');
    if(~isempty(ind))
        indices = indices(ind);
    else
        indices = indices;
    end
else
    indices = indicesIn;
end
% indices = indicesIn;
    

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
        for i=1:24
            if isempty(FittedWeather)
                m1a(i)=WeightedMean(DD,ones(1, size(DD,2)));
            else
                m1a(i)=WeightedMean(DD,ones(1, size(DD,2)))*(FittedWeather{1,i}(weatherT(indices(end-ind+1),1))/FittedWeather{1,i}(weatherT(indices(end-ind+1)-1,1)));
            end
            DD=[DD(2:end) A(indices(end-ind+1),5+i)];
        end
        Anormal(ind,:)=A22./m1a;
    end

    Anormal = mean(Anormal,1);
    DD2=C2((end-L+1):end);
    for i=1:24
        % added by m karimi for today data
        if(isnan(AToday(i)) || AToday(i)==0)            
            if isempty(FittedWeather)
                m1b=WeightedMean(DD2,ones(1, size(DD2,2)));
            else
                m1b=WeightedMean(DD2,ones(1, size(DD2,2)))*(FittedWeather{1,i}(weatherT(end,1))/FittedWeather{1,i}(weatherT(end-1,1)));                
            end
            prediction(i)=Anormal(i).*m1b;
        else
            prediction(i) = AToday(i);
        end
        DD2=[DD2(2:end) prediction(i)];
    end
else
    prediction=NaN(1,24);
end
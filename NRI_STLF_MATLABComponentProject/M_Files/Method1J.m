function prediction = Method1J(A,indicesIn,AToday,N,L,weatherIn)  

% generate weatherCompare
k=size(A,1);
weatherCompare=[];
if (~isempty(weatherIn))
    weatherIn=weatherIn(1:(k+1),:);
    for i=1:size(weatherIn,1)-1
        weatherCompare(i,:) = weatherIn(i,[7])-weatherIn(end,[7]);
    end
end

if(~isempty(weatherCompare))
    ind1 = find(all(abs(weatherCompare(indicesIn,:))<=6,2));
    if(~isempty(ind1))
        indices = indicesIn(ind1);
    else
        indices = indicesIn;
    end

%     nw = size(weatherCompare,2);
%     w = ones(nw,1)/nw;
%     EukDis = ( weatherCompare(indices,:).*weatherCompare(indices,:) * w)+(1000./(indices+mean(indices)));%%add day value to eukDis
%     [EukDis2, ind]= sort(EukDis,'descend');
%     if(~isempty(ind))
%         indices = indices(ind);
%     else
%         indices = indices;
%     end
else
    indices = indicesIn;
end
% indices = indicesIn;

if(~isempty(indices))  
    indJ = find(A(1:end,4)==7,1,'last');
    B2=A(indJ-1:indJ,:);
    C2=reshape(B2(:,6:29)',1,24*size(B2,1));

    if N>size(indices,1)
        N=size(indices,1);
    end

    for ind=1:N
        indJ = find(A(1:(indices(end-ind+1)-1),4)==7,1,'last');
        BB=A((indJ-2):(indJ-1),:);
        CC=reshape(BB(:,6:29)',1,24*size(BB,1));
        DD=CC((end-L+1):end);
        A22=A(indices(end-ind+1),6:29);
        for i=1:24
           m1a(i)=WeightedMean(DD,ones(1, size(DD,2)));
            DD=[DD(2:end) A(indices(end-ind+1),5+i)];
        end
        Anormal(ind,:)=A22./m1a;
    end

    Anormal = mean(Anormal,1);
    DD2=C2(end-L+1:end);
    for i=1:24
        % added by m karimi for today data
        if(isnan(AToday(i)) || AToday(i)==0)
            m1b=WeightedMean(DD2,ones(1, size(DD2,2)));
            prediction(i)=Anormal(i).*m1b;

        else
            prediction(i) = AToday(i);
        end
        DD2=[DD2(2:end) prediction(i)];
    end
else
    prediction=NaN(1,24);
end
function [corp]=FitWeatherZone(yy,mm,dd,corp,InputData,daytypes)

% find selected day in last year
ii=find((InputData.cal.calH(:,1)==yy-1)&(InputData.cal.calH(:,2)==mm)&(InputData.cal.calH(:,3)==dd));

zoneNo=length(corp.zone);

if(ii<60)
    firstDay = 15;
else
    firstDay = ii-45;
end
lastDay = ii+45;

for z = 1:zoneNo
    corp.zone{1,z}.FittedWeather={};
    weatherno=length(corp.zone{z}.weathername);
    if(weatherno ~=0)
        WT=[];
        HD=[];
        AAA=[];
        day=[];
        for k=firstDay:lastDay
            if(daytypes(k)==2)% && InputData.weatherzone{1,z}(k,24)>0)
%                 WT = [WT; InputData.weatherzone{1,z}.temp{1,1}(k,7)]; % temp{j,1} select first city for this process
                WT = [WT; InputData.weatherzone{1,z}.temp{1,1}(k,9:32 )]; % temp{j,1} select first city for this process
%                 HD = [HD; floor(InputData.weatherzone{1,z}.humidity{1,1}(k,6))]; % temp{j,1} select first city for this process

                AAA = [AAA; InputData.lsyszone{1,z}(k,:)];
                day = [day;InputData.lsyszone{1,z}(k,1:4)];
            end
        end
        Amean={};
        [WTsorted,indW] = sort(WT);%%%%%%%%%%%%%sort(WT)
        %daySorted = day(indW,:);
        for hh=1:24
            Load(:,hh) = AAA(indW(:,hh),5+hh);
            AmeanH=[];
            for i=WTsorted(1,hh):WTsorted(end,hh)
                index = find(WTsorted(:,hh)==i | WTsorted(:,hh)==i-1 | WTsorted(:,hh)==i+1);%| WTsorted(:,hh)==i-2 | WTsorted(:,hh)==i+2);
                if(~isempty(index))
                    AmeanH =[AmeanH;i mean(Load(index,hh),1)];
                end
            end
            Amean{hh}=AmeanH;
        end
        % --- Create fit 
        fo_ = fitoptions('method','SmoothingSpline','SmoothingParam',0.1);
        ft_ = fittype('smoothingspline');


        for h=1:24
            xxx=Amean{h}(:,1);
            yyy=Amean{h}(:,2);
            ok_ = isfinite(xxx) & isfinite(yyy);
            if ~all( ok_ )
                warning( 'GenerateMFile:IgnoringNansAndInfs',...
                    'Ignoring NaNs and Infs in data.' );
            end        
            % Fit this model using new data
            corp.zone{1,z}.FittedWeather{1,h} = fit(xxx(ok_),yyy(ok_),ft_,fo_);
        end
    end
end

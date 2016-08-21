function [Data]=ReadData(yy,N,corp,AppPath)

zoneno=length(corp.zone);
corp_name=corp.name;

Data.lsyszone=cell(1,zoneno);
Data.weatherzone=cell(1,zoneno);
for zone=1:zoneno
    weatherno=length(corp.zone{zone}.weathername);
    Data.weatherzone{1,zone}.temp=cell(weatherno,1);
    humidityno=length(corp.zone{zone}.humidityname);
    Data.weatherzone{1,zone}.humidity=cell(humidityno,1);
    nebulosityno=length(corp.zone{zone}.nebulosityname);
    Data.weatherzone{1,zone}.nebulosity=cell(nebulosityno,1);
end

calH=[];calD=[];

loadDataPath=[AppPath,'\LoadData'];
weatherDataPath = [AppPath,'\WeatherData'];
calendarDataPath = [AppPath,'\Calendar'];

for i=yy-N:yy
    for zone=1:zoneno
        A=[]; 
        C=[];
        D=[];
        cd(loadDataPath);
        lsys=[];
        name0=['L_',corp_name];
        name1=[name0,num2str(i),'.xls'];
        A=xlsread(name1,corp.zone{zone}.name);
        cd('..');
        Data.lsyszone{1,zone}=[Data.lsyszone{1,zone}; A(:,1:29)];
%% temperature
        weatherno=length(corp.zone{zone}.weathername);
        if(weatherno ~=0)
            cd(weatherDataPath);
            for j=1:weatherno
                name1=['T_',corp.zone{zone}.weathername{j,1}];
                cd(name1);
                B=[];
                name2=[name1,num2str(i),'.xls'];
                if(exist(name2)>0)
                    B=xlsread(name2);
                else
                    name2=[name1,num2str(i),'.xlsx'];
                    B=xlsread(name2);
                end
                cd('..');
                Data.weatherzone{1,zone}.temp{j,1}=[Data.weatherzone{1,zone}.temp{j,1};B(:,1:8)];
            end
            cd('..');
        end        
%% humidity %%%% need to change!!!!!!!!!!
        humidityno=length(corp.zone{zone}.humidityname);
        if(humidityno ~=0)
            cd(WeatherDataPath);
            for j=1:humidityno
                name1=['T_',corp.zone{zone}.humidityname{j,1}];
                cd(name1);
                B=[];
                name2=[name1,num2str(i),'.xls'];
                if(exist(name2)>0)
                    B=xlsread(name2);
                else
                    name2=[name1,num2str(i),'.xlsx'];
                    B=xlsread(name2);
                end
                cd('..');
                Data.weatherzone{1,zone}.humidity{j,1}=[Data.weatherzone{1,zone}.humidity{j,1};B(:,1:5)  B(:,13)];%% must change
            end
            cd('..');
        end     
        
%% nebulosity %%%% need to change!!!!!!!!!!
        nebulosityno=length(corp.zone{zone}.nebulosityname);
        if(nebulosityno ~=0)
            cd(WeatherDataPath);
            for j=1:nebulosityno
                name1=['T_',corp.zone{zone}.nebulosityname{j,1}];
                cd(name1);
                B=[];
                name2=[name1,num2str(i),'.xls'];
                if(exist(name2)>0)
                    B=xlsread(name2);
                else
                    name2=[name1,num2str(i),'.xlsx'];
                    B=xlsread(name2);
                end
                cd('..');
                Data.weatherzone{1,zone}.nebulosity{j,1}=[Data.weatherzone{1,zone}.nebulosity{j,1};B(:,1:5) B(:,25)];%% must change
            end
            cd('..');
        end     

    end
    % Calendar Set Up 

    cd(calendarDataPath);
    name5=['caln',num2str(i),'.xls'];
    E=xlsread(name5);
    Egh=xlsread('ghcal');
    calD=E;
    cd('..');
    calH=[calH;calD];    
end
%% for test
% B1=xlsread('E:\m karimi\STLF\DATA havashenasi\pajoheshgah niro-moslemi1.xlsx','sari');
% B2=xlsread('E:\m karimi\STLF\DATA havashenasi\pajoheshgah niro-moslemi1.xlsx','rasht');
% B3=xlsread('E:\m karimi\STLF\DATA havashenasi\pajoheshgah niro-moslemi1.xlsx','bandarabbas');
% Data.weatherzone{1,1}.humidity{1,1}(:,6)=B1(:,10);
% Data.weatherzone{1,2}.humidity{1,1}(:,6)=B2(:,10);
% Data.weatherzone{1,3}.humidity{1,1}(:,6)=B3(:,10);
% Data.weatherzone{1,1}.nebulosity{1,1}(:,6)=B1(:,11);
% Data.weatherzone{1,2}.nebulosity{1,1}(:,6)=B2(:,11);
% Data.weatherzone{1,3}.nebulosity{1,1}(:,6)=B3(:,11);
% 
% load WD1;
% B2=reshape(B1,24,365*2)';
% Data.weatherzone{1,1}.temp{1,1}(:,9:32)=B2;
% end for test
Data.cal.calH=calH;
Data.cal.calD=calD;
Data.cal.Ghcal=Egh;
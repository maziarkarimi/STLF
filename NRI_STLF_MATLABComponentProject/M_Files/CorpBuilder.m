function corp=CorpBuilder(Category,dbpath)

corp.name=Category;
url = [['jdbc:odbc:Driver={Microsoft Access Driver (*.mdb, *.accdb)};DSN='';DBQ='] dbpath];
conn = database('','','','sun.jdbc.odbc.JdbcOdbcDriver',url); 

strQuery = sprintf('SELECT ID FROM tblCategory WHERE CategoryName=''%s''',Category);
curs = exec(conn,strQuery);
curs = fetch(curs);
data = curs.Data;
CategoryID = cell2mat(data);

strQuery = sprintf('SELECT ALL ID,ZoneName FROM tblZone WHERE CategoryID=%d',CategoryID);
curs = exec(conn,strQuery);
curs = fetch(curs);
ZoneNames = curs.Data;

for i=1:size(ZoneNames,1)
    corp.zone{1,i}.weathername={};
    corp.zone{1,i}.humidityname={};
    corp.zone{1,i}.nebulosityname={};

    corp.zone{1,i}.name=cell2mat(ZoneNames(i,2));
    ZoneID = ZoneNames{i,1};
    
    strQuery = sprintf('SELECT ALL AreaName,Temperature,Humidity FROM tblArea WHERE ZoneID=%d',ZoneID);
    curs = exec(conn,strQuery);
    curs = fetch(curs);
    ZoneData = curs.Data;
    
    if strcmp(ZoneData{1,1},'No Data')==0
        for j=1:size(ZoneData,1)
            if ZoneData{j,2}==1
                corp.zone{1,i}.weathername{j,1}=ZoneData{j,1};
            end
        end
    end
    
%     if isempty(ZoneData)==0
%         for j=1:size(ZoneData,1)
%             if ZoneData{j,3}==1
%                 corp.zone{1,i}.humidityname{j,1}=ZoneData{j,1};
%             end
%         end
%     end
end
close(conn);
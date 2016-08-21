function [Adays,daytypes,daysramezan]=DayType2(InputData);

% Determining Special Shamsi Days(spshd)
shcal=[1 1; 1 2; 1 3; 1 4 ; 1 12; 1 13; 3 14; 3 15; 11 22; 12 29;6 30];
ghcal = InputData.cal.Ghcal;

% % are lsyszone for all zones equal size??
Adays=zeros(size(InputData.cal.calH,1),1);
for i=1:size(Adays,1)
    if InputData.cal.calH(i,5)~=1
        if sum((InputData.cal.calH(i,2)==shcal(:,1)).*(InputData.cal.calH(i,3)==shcal(:,2)))~=0
            ok=find((InputData.cal.calH(i,2)==shcal(:,1)).*(InputData.cal.calH(i,3)==shcal(:,2)));
            Adays(i,1)=ok+16;
        else
            ok=find((InputData.cal.calH(i,1)==ghcal(:,1))&(InputData.cal.calH(i,2)==ghcal(:,2))&(InputData.cal.calH(i,3)==ghcal(:,3)));
            if size(ok,1)~=0
                Adays(i,1)=ghcal(ok,4);
            end
        end
    end
end

% Build Ramezan Day matrix
daysramezan=zeros(1,size(InputData.cal.calH,1));
ll=find(Adays==16); % find first day of ramezan
ll2 = find(Adays==14); %find eid fetr
%if ramezan be in first month
if(ll2(1)<ll(1))
    daysramezan(1:(ll2(1)-1))=1;
end
for i=1:length(ll)
    lll = find(Adays((ll(i)+1):(ll(i)+30))==14,1,'first');
    kk=min(ll(i)+lll-1,size(daysramezan,2));
    daysramezan(ll(i))=2;
    daysramezan((ll(i)+1):kk)=1;
end

% added by m karimi 6/31 & 1 ramezan not important in this step
ll=find(InputData.cal.calH(:,5)==7 | InputData.cal.calH(:,5)==8);
InputData.cal.calH(ll,5)=1;
%
daytypes=zeros(1,size(InputData.cal.calH,1));

ll=find(InputData.cal.calH(:,5)==6);
InputData.cal.calH(ll,5)=1;
ll=find(InputData.cal.calH(:,5)~=1);
daytypes(ll)=5;
ll=find((InputData.cal.calH(:,5)==1)&(InputData.cal.calH(:,4)==1));
daytypes(ll)=1;
ll=find((InputData.cal.calH(:,5)==1)&(InputData.cal.calH(:,4)==6));
daytypes(ll)=3;
ll=find((InputData.cal.calH(:,5)==1)&(InputData.cal.calH(:,4)==7));
daytypes(ll)=4;
ll=find((InputData.cal.calH(:,5)==1)&(InputData.cal.calH(:,4)==2));
daytypes(ll)=7;
ll=find((InputData.cal.calH(2:end,5)==1)&(InputData.cal.calH(1:(end-1),5)~=1));
daytypes(ll+1)=6;
ll=find(daytypes==0);
daytypes(ll)=2;
daytypes=daytypes';
daysramezan=daysramezan';


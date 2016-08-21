function prediction = Method21(A,sp,daytypes,AToday)            

s1=find(daytypes(1:sp)==1);
s2=find(daytypes(1:sp)==2);
s3=find(daytypes(1:sp)==3);
s4=find(daytypes(1:sp)==4);
if (isempty(s1)==1 || isempty(s2)==1 || isempty(s3)==1 || isempty(s4)==1)
    errordlg('Number of the years for Similar Days Forecasting is not sufficient.Please change variable "First Year".','Error!','on');
    prediction=NaN(1,24);
else
    Bmsp=A([s1(end);s2((end-3):end)';s3(end);s4(end)],6:29);
    pattern=A(sp,6:29)./(mean(Bmsp,1));
end

s1=find(daytypes(1:end)==1);
s2=find(daytypes(1:end)==2);
s3=find(daytypes(1:end)==3);
s4=find(daytypes(1:end)==4);
Bmsp=A([s1(end);s2((end-3):end)';s3(end);s4(end)],6:29);
for i=1:24
    % added by m karimi for today data
    if(isnan(AToday(i)) || AToday(i)==0)
        prediction(i)=pattern(i).*mean(Bmsp(:,i),1);

    else
        prediction(i) = AToday(i);
    end    
end
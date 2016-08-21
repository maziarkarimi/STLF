function prediction = MethodS(A,yy,mm,dd,daytypesIn,spdtypesIn,ramezanIn,L,ll,weatherIn,FittedWeather)  
%function prediction = MethodS(A,L,mode,daytypes,specialtype,spdtypes,mm,dd,ramezan,ramezandays,AToday,ll,DayinWeek)       

daytypesa=daytypesIn;
Aaa=A;
for i=ll(end):(length(daytypesIn)-1)
    if daytypesIn(i)==5
        if A(i,4)==1
            daytypesa(i)=1;
        elseif A(i,4)==6
            daytypesa(i)=3;
        elseif A(i,4)==7
            daytypesa(i)=4;
        else
            daytypesa(i)=2;
        end
        %[prediction1]=similarpredict(Aaa(1:i-1,:),L,mode,daytypes(1:i-1),daytypesa(i),specialtype,spdtypes,Aaa(i,2),Aaa(i,3),ramezandays(i),ramezandays(1:i-1),AToday,DayinWeek);
        [prediction1]=similarpredict(Aaa(1:i,:),Aaa(i,1),Aaa(i,2),Aaa(i,3),daytypesa(1:i),spdtypesIn(1:i),ramezanIn(1:i),L,weatherIn,FittedWeather);

        Aaa(i,6:29)=prediction1;
    end
end
if A(end-1,4)==7
    daytypesa(end)=1;
elseif A(end-1,4)==6
    daytypesa(end)=4;
elseif A(end-1,4)==5
    daytypesa(end)=3;
else
    daytypesa(end)=2;
end
%[prediction]=similarpredict(Aaa,L,mode,daytypes,daytomorrow,specialtype,spdtypes,mm,dd,ramezan,ramezandays,AToday,DayinWeek);
[prediction]=similarpredict(Aaa,yy,mm,dd,daytypesa,spdtypesIn,ramezanIn,L,weatherIn,FittedWeather);
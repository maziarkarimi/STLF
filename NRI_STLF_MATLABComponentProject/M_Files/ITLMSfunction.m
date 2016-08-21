function [Pn,Tn]=ITLMSfunction(P,T)
% XX=[PP;TT];
    X0DB=[P;T];
    XX=X0DB;
    Landa=0.01;
    stdev=std(X0DB',1);
    stdevp=stdev*sqrt(2);
    VX=0;
    VXX0=0;
    for i=1:size(XX,2)
        for k=1:size(X0DB,2)
            Gind=0;
            for t=1:size(XX,1)
                Gind=Gind+((XX(t,i)-X0DB(t,k))/stdevp(1,t))^2;
            end
            VXX0=VXX0+exp(Gind/-2);
        end
        for k=1:size(XX,2)
            Gind=0;
            for t=1:size(XX,1)
                Gind=Gind+((XX(t,i)-XX(t,k))/stdevp(1,t))^2;
            end
            VX=VX+exp(Gind/-2);
        end
    end
%     keyboard
    VX=VX/size(XX,2)^2;
    VXX0=VXX0/(size(XX,2)*size(X0DB,2));
    c1=(1-Landa)/VX;
    c2=(2*Landa)/VXX0;
    maxerror=1;
    XNEW=XX;
    Xnew=zeros(size(XX,1),size(XX,2));
    while maxerror > 1e-6
        for i=1:size(XX,2)
            S1=0;S2=0;
            S3=0;S4=0;
            for k=1:size(XX,2)
                GindS1=0;
                for t=1:size(XX,1)
                    GindS1=GindS1+((XX(t,i)-XX(t,k))/stdevp(1,t))^2;
                end
                S1=S1+exp(GindS1/-2).*XX(:,k);
                S3=S3+exp(GindS1/-2);
            end
            for k=1:size(X0DB,2)
                GindS2=0;
                for t=1:size(XX,1)
                    GindS2=GindS2+((XX(t,i)-X0DB(t,k))/stdevp(1,t))^2;
                end
                S2=S2+exp(GindS2/-2).*X0DB(:,k);
                S4=S4+exp(GindS2/-2);
            end
            Xnew(:,i)=(c1.*S1+c2.*S2)./(c1.*S3+c2.*S4);
            error=0;
            for t=1:size(XX,1)
                error=error+(Xnew(t,i)-XX(t,i))^2;
            end
            error(i,1)=sqrt(error);
        end
        XNEW=[XNEW,Xnew];
        XX=Xnew;
        maxerror=max(error);
        if size(XNEW,2)>300
            maxerror=1e-9;
        end
    end
    
    
    
    %%
    Pn=[P,XNEW(1:size(P,1),:)];
    Tn=[T,XNEW(size(P,1)+1:end,:)];
end
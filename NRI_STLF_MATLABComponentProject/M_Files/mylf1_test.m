function pred=mylf1_test(samples, net, x2)

[nsamples , col]=size(samples);
pred=0;
for k = 1:nsamples
  i=1; 
  w2 = samples(k,:);
  net2 = mlpunpak(net, w2);
  out = mlpfwd(net2, x2);
  %%%% Sum predictions
  
  pred = pred + out;
  
  %%%% generating predictive distribution
  
  %for q= -0.15:0.001:0.15
  
% %   for q=-1:.01:1
% %       y1(k,i)=sqrt(beta/(2*pi))*exp(-.5*beta*(q-out(1,1))^2);
% %       y2(k,i)=sqrt(beta/(2*pi))*exp(-.5*beta*(q-out(1,2))^2);
% %       i=i+1;
% %   end
  
end 

 pred = pred./nsamples;

%q= -0.15:0.001:0.15;

%q=-1:.01:1;

% figure
% plot(q,mean(y2))

% [a1 a2]=max(mean(y1));
% pred=q(a2);
%%% [a3 a4]=max(mean(y2));
%%% pred=[q(a2) q(a4) 0];


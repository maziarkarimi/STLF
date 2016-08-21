% Syntax :
%[output]=simloly(net,input)
% where net is a LoLiMoT netwrok trained by lolimot.m and input is the
% input of the network.

function [output]=simloly(TempNUM,net,input)

if nargin > 3  error('too many input arguments');    end;
if nargin < 3  error('not enough input arguments');  end;

[row_in col_in]=size(input);
%--------------input normalization------------------------------
SizeTemp=length(TempNUM);
MAX=max(abs(input(1:end-SizeTemp)));
input(1:end-SizeTemp)=input(1:end-SizeTemp)/MAX;
MAX2=max(abs(input(end-SizeTemp+1:end)));
if MAX2==0
    MAX2=1;
end
input(end-SizeTemp+1:end)=input(end-SizeTemp+1:end)/MAX2;

input=[input ones(row_in,1)];

if col_in+1 ~= length(net(1).weight)
    error('input and netwrok are not matched');
end;

[useless len]=size(net);
for i=1:len
    mem(:,i)=phi(input,net(i).sigma,net(i).center);
end;
sum_mem=(sum(mem'))';
for i=1:len
    mem(:,i)=mem(:,i)./sum_mem;
end;
output=out_calc(net,mem,input);
%-----------------------output denormalization----------------
output=output*MAX;

%--------Local LLNM output Calculator--------------------------
function [output]=out_calc(net,membership,input);
[row col]=size(membership);
for i=1:col  %
    weight=net(i).weight;
    out=input*weight;%17/11/93
    output(:,i)=out.*membership(:,i);
end;
output=(sum(output'))';

%----------Membership Calculation------------------------------
function [membership]=phi(input,sigma,center);
[row col]=size(input);
for j=1:row
    product=1;
    for i=1:col
        product=product*exp(-0.5*((input(j,i)-center(i))/sigma(i))^2);
    end;
    membership(j,1)=product;
end

%
% Syntax:
% 
% [net,mse,mse_test]=lolimot(input,output,max_neuron,alpha, 
%                                test_input,test_output,reg_coef,mse_goal)
%    
% "alpha" is the smothing factor and "reg_coef" is the regularization
% coeficient (optional)
% 
% net is a structure containing all LLNM data:
% 
% net=
% 1 x neurons struct array with fields:
%     cord          : LLNM cordinations
%     sigma         : sigma of Gaussian membership functions
%     center        : center of LLNM cordination
%     weight        : LLNM weights
%     in_min        : max and min of network, theses are very important
%     in_max          since they are used in data normalization during
%     out_min         training
%     out_max
%     output        : LLNM output
%     test_output   : LLNM test_outpt
%
% Use simloly.m to calculate the net output

function [Indtesta,net,mse,mse_test]=lolimot(TempNUM,input,output,max_neuron,alpha, ....
    test_input,test_output,reg_coef,mse_goal)

if nargin > 8  error('too many input arguments');    end;
if nargin < 3  error('not enough input arguments');  end;
if nargin < 4  max_neuron=10;    end;
if nargin < 5  alpha=1/3;        end;
if nargin < 8  reg_coef=0;    end;
if nargin < 9  mse_goal=1e-4;    end;

test_flag=0;
if nargin == 6 ; error('test output is needed'); end;
if nargin >= 7 ; test_flag=1; end;

output=output(:);                  
[in_row in_col]=size(input);
[out_row out_col]=size(output);

%----------data normalization-------------------------------
SizeTemp=length(TempNUM);
for I1=1:size(input,1)
    MAX=max(abs(input(I1,1:end-SizeTemp)));
    input(I1,1:end-SizeTemp)=input(I1,1:end-SizeTemp)/MAX;
    MAX2=max(abs(input(I1,end-SizeTemp+1:end)));
    if MAX2==0
        MAX2=1;
    end
    input(I1,end-SizeTemp+1:end)=input(I1,end-SizeTemp+1:end)/MAX2;
    output(I1,:)=output(I1,:)/MAX;
end

output=output(:);
input=[input ones(in_row,1)];

net=struct('cord',zeros(in_col,2),'sigma',zeros(in_col,1),'center',...
    zeros(in_col,1),'weight',zeros(in_col,1));



if in_row ~= out_row;
    error('Input and output are not matched!');
end;
if test_flag ==1
    test_output=test_output(:);
    [t_in_row t_in_col]=size(test_input);
    [t_out_row t_out_col]=size(test_output);
    
    for I1=1:size(test_input,1)
        MAX=max(abs(test_input(I1,1:end-SizeTemp)));
        test_input(I1,1:end-SizeTemp)=test_input(I1,1:end-SizeTemp)/MAX;
        MAX2=max(abs(test_input(I1,end-SizeTemp+1:end)));
        if MAX2==0
            MAX2=1;
        end
        test_input(I1,end-SizeTemp+1:end)=test_input(I1,end-SizeTemp+1:end)/MAX2;
        test_output(I1,:)=test_output(I1,:)/MAX;
        
    end

    
    test_input=[test_input ones(t_in_row,1)];
    
    if t_in_row ~= t_out_row;
        error('Test input and output are not matched!');
    end
    t_in_col=t_in_col+1;
end;
in_col=in_col+1;

dummy=struct('cord',zeros(in_col,2),'sigma',zeros(in_col,1),'center',zeros(in_col,1),'weight',zeros(in_col,1));

flag=1;

input_reserve=input;
output_reserve=output;

net(1).cord=ones(in_col,2);
net(1).cord(:,1)=-1;


[net(1).center net(1).sigma]=SiCe(net(1).cord,alpha);
mem(:,1)=phi(input_reserve,net(1).sigma,net(1).center);

index_col=1;
[mse_local(index_col),net(index_col).weight,net(index_col).output]=Lomse(input_reserve,output_reserve,mem(:,index_col),reg_coef);
mem2(:,index_col)=phi(test_input,net(index_col).sigma,net(index_col).center);
[net(index_col).test_output]=Lomse_test(test_input,net(index_col).weight,mem2(:,index_col));
% waitbar_1 = waitbar(0,'Please wait... LoLiMoT is being trained.');
for m=2:max_neuron
%     clc
    Neuron=m;
%     waitbar((m-1)/(max_neuron-1),waitbar_1)
    cord=net(index_col).cord;
%     dummy(1).cord=cord;
%     dummy(2).cord=cord;
    [len_net]=size(net,2);mem1=mem;
    for j=1:in_col-1
        dummy(1).cord=cord;
        dummy(2).cord=cord;
        dummy(1).cord(j,:)=[cord(j,1) 0.5*(cord(j,2)-cord(j,1))+cord(j,1)];
        dummy(2).cord(j,:)=[0.5*(cord(j,2)-cord(j,1))+cord(j,1) cord(j,2)];
        for k=1:2
            [dummy(k).center dummy(k).sigma]=SiCe(dummy(k).cord,alpha);
        end;
        net(index_col).sigma=dummy(1).sigma;
        net(index_col).center=dummy(1).center;
        net(len_net+1).sigma=dummy(2).sigma;
        net(len_net+1).center=dummy(2).center;
%         [len]=size(net,2);
%         mem=[];
%         for i=1:len
            mem=mem1;mem(:,index_col)=phi(input_reserve,net(index_col).sigma,net(index_col).center);
            mem(:,len_net+1)=phi(input_reserve,net(len_net+1).sigma,net(len_net+1).center);
%         end;
        sum_mem=(sum(mem'))';
        for i=1:size(net,2)
            mem(:,i)=mem(:,i)./sum_mem;
        end;
        out_halves=zeros(in_row,1);
        
        [WERT,net(index_col).weight,net(index_col).output]=Lomse(input_reserve,output_reserve,mem(:,index_col),reg_coef);
        [WEREWR,net(len_net+1).weight,net(len_net+1).output]=Lomse(input_reserve,output_reserve,mem(:,len_net+1),reg_coef);
        
        for i=1:size(net,2)
            out_halves=out_halves+net(i).output;
        end;
        mse_halves(j)=mean((out_halves-output_reserve).^2);
    end;
    [kochik index]=min(mse_halves);
    dummy(1).cord=cord;
    dummy(2).cord=cord;
    dummy(1).cord(index,:)=[cord(index,1) 0.5*(cord(index,2)-cord(index,1))+cord(index,1)];
    dummy(2).cord(index,:)=[0.5*(cord(index,2)-cord(index,1))+cord(index,1) cord(index,2)];
    net(index_col).cord=dummy(1).cord;
    [net(index_col).center net(index_col).sigma]=SiCe(net(index_col).cord,alpha);
    net(len_net+1).cord=dummy(2).cord;
    [net(len_net+1).center net(len_net+1).sigma]=SiCe(net(len_net+1).cord,alpha);

    %------------Finding the worst Neuron----------------------------
    mem=mem1;mem(:,index_col)=phi(input_reserve,net(index_col).sigma,net(index_col).center);
    mem(:,len_net+1)=phi(input_reserve,net(len_net+1).sigma,net(len_net+1).center);
    [len]=size(net,2);
%     for i=1:len
%         mem(:,i)=phi(input_reserve,net(i).sigma,net(i).center);
%     end;
    sum_mem=(sum(mem'))';
    for i=1:len
        mem3(:,i)=mem(:,i)./sum_mem;
    end;
%     out_halves=zeros(in_row,1);
    [mse_local(index_col),net(index_col).weight,net(index_col).output]=Lomse(input_reserve,output_reserve,mem3(:,index_col),reg_coef);
    [mse_local(len_net+1),net(len_net+1).weight,net(len_net+1).output]=Lomse(input_reserve,output_reserve,mem3(:,len_net+1),reg_coef);    
% for i=1:len
%         [mse_local(i),net(i).weight,net(i).output]=Lomse(input_reserve,output_reserve,mem(:,i),reg_coef);
%     end;
    mse(m-1)=kochik;

    if test_flag==1
        %------------Mse Test Calculation----------------------------------
%         mem2=[];
%         for i=1:len
            mem2(:,index_col)=phi(test_input,net(index_col).sigma,net(index_col).center);
            mem2(:,len_net+1)=phi(test_input,net(len_net+1).sigma,net(len_net+1).center);
%         end;
        sum_mem=(sum(mem2'))';
        for i=1:len
            mem4(:,i)=mem2(:,i)./sum_mem;
        end;
        [in_row_test test_col]=size(test_input);
        out=zeros(in_row_test,1);
        [net(index_col).test_output]=Lomse_test(test_input,net(index_col).weight,mem4(:,index_col));
        [net(len_net+1).test_output]=Lomse_test(test_input,net(len_net+1).weight,mem4(:,len_net+1));
        for i=1:len
            out=out+net(i).test_output;
        end;
        mse_test(m-1)=mean((out-test_output).^2);
    else
        mse_test='Not calculated';
    end;
        [oo index_col]=max(mse_local);
NET{m-1}=net;
end
[Mintest,Indtesta]=min(mse_test);
net=NET{Indtesta};
% Indtesta=Indtesta+1;
% close(waitbar_1);

%----------Membership Calculation-----------------------
function  [membership]=phi(input,sigma,center);
[row col]=size(input);
for j=1:row
    product=1;
    for i=1:col
        product=product*exp(-0.5*((input(j,i)-center(i))/sigma(i))^2);
    end;
    membership(j,1)=product;
end;

%---------Center and Sigma Calculation-------------------
function [center,sigma]=SiCe(cord,alpha);
[row col]=size(cord);
for i=1:row
    center(i)=(cord(i,1)+cord(i,2))/2;
    sigma(i)=abs((cord(i,2)-cord(i,1)))*alpha;
end;

%--------Local MSE Calculation----------------------------
function [mse_local,weights,output]=Lomse(input,output,membership,reg_coef);
[row col]=size(membership);
Q=diag(membership(:,1));
weights(:,1)=pinv(input'*Q*input+reg_coef*eye(col))*input'*Q*output;
out=input*weights(:,1);
error=out-output;
output=out.*membership;
mse_local=error'*Q*error;

%--------TEST output--------------------------------------
function [output]=Lomse_test(input,weights,membership);
out=input*weights;
output=out.*membership;

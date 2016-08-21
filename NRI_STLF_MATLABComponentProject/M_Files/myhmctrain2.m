% this program is doing HMC training for Neural Network. aw1 is a
% vector of input size, since we want to do ARD, with evidence function.
% the value of beta never changed during this process. the number of 
% hidden neuron is fixed.
% it uses evidenceH2 instead of evidenceH(in myhmctrain1)
% %% it used with myhmctest.m

function [samples, net]=myhmctrain2(x,t,nh) 

[row1, nin]=size(x);
[row2, nout]=size(t);
%nin = 15;                        % Number of inputs.
%nout = 1;                       % Number of outputs.

seed = 42;                    % Seed for random number generators.
randn('state', seed);
rand('state', seed);

% Set up network parameters.
nhidden =nh;			% Number of hidden units.
                 
aw1=2;
ab1=2; 	 
aw2=nhidden;
ab2=nhidden;
beta = 2.0;

% aw1=.01*ones(1,nin);
% ab1=.01;  
% aw2=.01;
% %aw2=.01*ones(1,nhidden);
% ab2=.01;
% beta = 2;	

prior= mlpprior(nin, nhidden, nout, aw1, ab1, aw2, ab2);
                        
% Create and initialize network model.

% Initialise weights reasonably close to 0
net = mlp(nin, nhidden, nout, 'linear', prior, beta);
net = mlpinit(net,10);

% Set up vector of options for hybrid Monte Carlo.
nsamples = 400;		% Number of retained samples.

%options = foptions;     % Default options vector.
options(1) = 1;		% Switch on diagnostics.
options(5) = 1;		% Use persistence
options(7) = 10;	% Number of steps in trajectory.
options(14) = nsamples;	% Number of Monte Carlo samples returned. 
options(15) = 100;	% Number of samples omitted at start of chain.
options(17) = 0.95;	% Alpha value in persistence
options(18) = 0.005;	% Step size.

%%%%%%% code for ARD

%%% Set up vector of options for the optimiser.

nouter = 1;			% Number of outer loops
ninner = 10;		        % Number of inner loops
options2 = zeros(1,18);		% Default options vector.

options2(1) = 0;			% This provides display of error values.
options2(2) = 1.0e-7;	% This ensures that convergence must occur
options2(3) = 1.0e-7;
options2(14) = 400;		% Number of training cycles in inner loop. 

%%% Train using scaled conjugate gradients, re-estimating alpha and beta.
for k = 1:nouter
  net = netopt(net, options2, x, t, 'scg');
  [net, gamma] = evidenceH2(net, x, t, ninner);
%   fprintf(1, '\n\nRe-estimation cycle %d:\n', k);
%   disp('The first three alphas are the hyperparameters for the corresponding');
%   disp('input to hidden unit weights.  The remainder are the hyperparameters');
%   disp('for the hidden unit biases, second layer weights and output unit')
%   disp('biases, respectively.')
%   fprintf(1, '  alpha =  %8.5f\n', net.alpha);
%   fprintf(1, '  beta  =  %8.5f\n', net.beta);
%   fprintf(1, '  gamma =  %8.5f\n\n', gamma);
%   disp(' ')
%   disp('Press any key to continue.')
%   %pause
end

net.beta=2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

w = mlppak(net);
% Initialise HMC
myhmc('state', 42);
[samples, energies, diagn] = myhmc('neterr', w, options, 'netgrad', net, x, t);


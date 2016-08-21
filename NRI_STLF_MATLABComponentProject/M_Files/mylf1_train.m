function [samples, net]=mylf1_train(x,t,nh) 

[row1, nin]=size(x);
[row2, nout]=size(t);

seed = 42;                    % Seed for random number generators.
randn('state', seed);
rand('state', seed);

% Set up network parameters.
nhidden =nh;			% Number of hidden units.

%  prior = 0.000001;   % Coefficient of weight-decay prior. 
                    % (1/prior) is variance of gaussian prior for weights.
                    
aw1=2;
%%aw1=[ones(1,nin-3) 2 2 2];    %%% if we choose 18 inputs (3 temp)

ab1=2;
aw2=nhidden;
ab2=nhidden;
prior= mlpprior(nin, nhidden, nout, aw1, ab1, aw2, ab2);
                        
beta = 2.0;	    % Coefficient of data error.
                    % (1/beta) is variance of gaussian noise model for
                    % output of network

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

%%%%%%% generating step size based on random selection of e=e0*exp(noo*C)
%%%%%%%%%     C has cauchy dist.

% e0=1e-4;
% noo=0.71;
% C=trnd(1);
%option(18)=e0*exp(noo*C);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

w = mlppak(net);
% Initialise HMC
myhmc('state', 42);
[samples, energies, diagn] = myhmc('neterr', w, options, 'netgrad', net, x, t);


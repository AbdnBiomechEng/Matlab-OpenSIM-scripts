%% Muscle force optimisation

%The elbow is actively flexed by the (1) biceps, (2) brachialis and 
%(3) brachioradialis muscles. The resultant moment is measured and we want
%to estimate the contribtutions from each muscle.

% Script uses Matlab's built-in constrained optimisation routine 'fmincon'.
% Type 'help fmincon' in the command window for details.

%% Define the measured moment (you can change this):

M_mus = 20; % measured moment in Nm

% Moment arms of the muscles are as follows:

r_mus = [0.05 0.03 0.07]; % moment arms in metres
Fmax  = [842 999 162]; % the maximum isometric force of each muscle in Nm.

% The goal is to minimise the function 'fun', which is the sum of the 
% muscle forces raised to the power 'p':

p = 2; % power to which forces / activations are raised in the cost function.

%% Call optimisation routine fmincon

fun = @(F_mus) sum((F_mus./Fmax).^p);  % anonymous function describing objective function

[F_mus, J, exitflag] = fmincon(fun, ... % 'fun' in the name of the objective function
    [0 0 0], ...  % Initial guess, or starting point
    [], [], ... % there are no linear inequality contraints
    r_mus, M_mus, ... % these are A and B in A[x] = B, the linear equality contraint
    [0 0 0], Fmax, ...  % lower and upper bounds on the values
    [], []); % there are no non-linear constraints


%% Plot results

if exitflag == 1
    figure; barh(Fmax,0.75,'FaceColor',[1 1 1]); hold on
    barh(F_mus, 0.5, 'FaceColor',[0.7 0.1 0.2])
    xlabel('Muscle force (N)')
    yticklabels({'Biceps', 'Brachialis', 'Brachioradialis'})
else 
    disp('Optimisation failed; check exitflag.');
end

%% Check results

Error = r_mus * F_mus' - M_mus
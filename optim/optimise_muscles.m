%[text] # Example optimisation script
%%
%[text] ## Set up initial values
load sEMG.mat; % fake data; in reality this will be 13 RMS values; one per sensor.
load fake_model.mat; % this is a fake 'model' that calculates 13 outputs from 7 inputs (ie just a matrix); in reality this will be replaced by the call to a real model
x0 = rand(7,1); % Initial guess for solution vector [x], which contains the muscle activation values for 7 muscles
%%
%[text] ## Run optimisation routine
[x, J, exitflag, output] = fmincon(@(x)objfun(x, sEMG, fake_model), ... % 'objfun' is the name of the objective function
    x0, ...  % Initial guess, or starting point
    [], [], ... % there are no linear inequality contraints
    [], [], ... % there are no linear equality contraints
    zeros(7,1), ones(7,1), ...  % lower and upper bounds on the values: [0 1]
    [], []); % there are no non-linear constraints

V_probes = fake_model*x; % Don't have access to variables that only exist in the objfun subroutine, so need to recalculate outputs with final x values here
%%
%[text] ## Plot results
b1 = bar(x, 'cyan'); legend('Optimal x');
set(b1, 'BarWidth', 0.6);

b2 = bar([V_probes sEMG]);
set(b2, 'BarWidth', 0.6); legend('Vprobes', 'sEMG');

fprintf('J = %.4f', J)
fprintf('RMS error: %.4f', sqrt(J/size(x,1)))
fprintf('Number of iterations: %d', output.iterations)
%%
%[text] ## Objective function definition
% for calculating objective function value at every step of the optimisation

function J = objfun(x, sEMG, fake_model) % This line passes the current value of x and the reference sEMG values and returns the objective function value.
    V_probes = fake_model*x; % <=== This line will be replaced with the real model call.
    J = sum((sEMG-V_probes).^2); % This line calculates the objective function value, J, based on the calculated probe values using latest values of x.
end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":26}
%---

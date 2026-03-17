%[text] ## Muscle force optimisation
%[text] The elbow is actively flexed by the (1) biceps, (2) brachialis and (3) brachioradialis muscles. The resultant moment is measured and we want to estimate the contribtutions from each muscle.
%[text] Script uses Matlab's built-in constrained optimisation routine 'fmincon'. Type 'help fmincon' in the command window for details.
%[text] Define the measured moment (you can change this):
M_mus =30; % measured moment in Nm %[control:slider:00e8]{"position":[8,10]}
%[text] Moment arms of the muscles are as follows:
r_mus = [0.05 0.03 0.07]; % moment arms in metres
Fmax_l0  = [842 999 162]; % the maximum isometric force of each muscle in N at optimum length.
F_L = [0.9 0.8 0.8]; % force-length scaling
Fmax = F_L.*Fmax_l0;
%[text] Create plot template
figure; 
    barh(Fmax,0.75,'FaceColor',[1 1 1]); hold on
    xlabel('Muscle force (N)')
    yticklabels({'Biceps', 'Brachialis', 'Brachioradialis'})
    legend('maxi isometric muscle force')
%[text] The goal is to minimise the function 'fun', which is the sum of the muscle activation raised to the power 'p':
p = 2; % power to which forces are raised %[control:dropdown:738f]{"position":[5,6]}
fun = @(F_mus) sum((F_mus./Fmax).^p);  % anonymous function describing objective function

[F_mus, J, exitflag] = fmincon(fun, ... % 'fun' in the name of the objective function
    [0 0 0], ...  % Initial guess, or starting point
    [], [], ... % there are no linear inequality contraints
    r_mus, M_mus, ... % these are A and B in A[x] = B, the linear equality contraint
    [0 0 0], Fmax, ...  % lower and upper bounds on the values
    [], []); % there are no non-linear constraints
%[text] Add results to plot:
if exitflag == 1
    barh(F_mus, 0.5, 'FaceColor',[0.7 0.1 0.2])
    legend('max isometric muscle force','actual muscle force')
else 
    disp('Optimisation failed!')
    exitflag
end
%[text] Check results:
disp('Cost function value'); J
F_mus
Error = r_mus * F_mus' - M_mus

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":35.5}
%---
%[control:slider:00e8]
%   data: {"defaultValue":10,"label":"Slider","max":100,"min":0,"run":"Section","runOn":"ValueChanging","step":1}
%---
%[control:dropdown:738f]
%   data: {"defaultValue":"2","itemLabels":["1","2","3"],"items":["1","2","3"],"label":"Drop down","run":"Section"}
%---

% Ed Chadwick (July 2025)
% Based on Moco examples from:
% https://opensim-org.github.io/opensim-moco-site/docs/

import org.opensim.modeling.*;

% Set the model
model = Model('arm26.osim');

% Set the Geometry folder to visualise bones
ModelVisualizer.addDirToGeometrySearchPaths('C:\OpenSim 4.5\Geometry');

% Convert muscles to DGF muscles necessary for Moco
DeGrooteFregly2016Muscle().replaceMuscles(model);

% Make problems easier to solve by strengthening the DeGrooteFregly2016Muscles 
% model and widening the active force-length curve.

for m = 0:model.getMuscles().getSize()-1
    musc = model.updMuscles().get(m);
    musc.setMinControl(0);
    musc.set_ignore_activation_dynamics(false);
    musc.set_ignore_tendon_compliance(false);
    musc.set_max_isometric_force(2 * musc.get_max_isometric_force());
    dgf = DeGrooteFregly2016Muscle.safeDownCast(musc);
    dgf.set_active_force_width_scale(1.5);
    dgf.set_tendon_compliance_dynamics_mode('implicit');
end

% Create and name an instance of the MocoStudy tool.
study = MocoStudy();
study.setName("moco_arm26_example");

% Access the MocoProblem from the study.
problem = study.updProblem();
modelProcessor = ModelProcessor(model);
problem.setModelProcessor(modelProcessor);

% Add CoordinateActuators to the model degrees-of-freedom.
modelProcessor.append(ModOpAddReserves(250, 1.0));

% Set initial time to 0; final time to 1
problem.setTimeBounds(MocoInitialBounds(0),...
MocoFinalBounds(0, 1));

% The coordinate value must be between -π and π over the phase,
% and its initial value is 0 and its final value is π/2.
problem.setStateInfo('/jointset/r_shoulder/r_shoulder_elev/value',...
[deg2rad(-10), deg2rad(80)], deg2rad(0), deg2rad(60));
problem.setStateInfo('/jointset/r_elbow/r_elbow_flex/value',...
[deg2rad(0), deg2rad(130)], deg2rad(0), deg2rad(100));


% Start and end velocities should be zero
problem.setStateInfo('/jointset/r_shoulder/r_shoulder_elev/speed',...
[-50, 50], 0, 0);
problem.setStateInfo('/jointset/r_elbow/r_elbow_flex/speed',...
[-50, 50], 0, 0);


% Minimize the sum of squared controls with weight 1.5.
problem.addGoal(MocoControlGoal('effort', 1.5));
% Add final time goal
problem.addGoal(MocoFinalTimeGoal('weight', 1.0));

% Minimise dF/dt (~jerk)
solver.set_minimize_implicit_auxiliary_derivatives(true);
solver.set_implicit_auxiliary_derivatives_weight(0.001);


% Initialize the CasADi or Tropter solver.
solver = study.initCasADiSolver();
% alternative: solver = study.initTropterSolver();

% Solve the problem on a grid of n mesh intervals.
solver.set_num_mesh_intervals(30);

% Specify initial guess
% Can use guess function, a previous solve with no goal, or a previous
% solution based on e.g. a coarse mesh
solver.setGuessFile('arm26_MocoStudy_guess.sto');
%guess = solver.createGuess();
%guess.randomizeAdd();
%solver.setGuess(guess);

% Set convergence tolerances and max iterations
solver.set_optim_convergence_tolerance(1e-2);
solver.set_optim_constraint_tolerance(1e-4);
solver.set_optim_max_iterations(500);

% Solve! Use track.solve() to skip visualizing.
solution = study.solve();

try
    study.visualize(solution);
    solution.write('arm26_MocoStudy_optimal.sto');
catch
    disp('did not solve')
end

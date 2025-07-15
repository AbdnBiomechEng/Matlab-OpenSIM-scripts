% Ed Chadwick (July 2025)
% Based on Moco examples from:
% https://opensim-org.github.io/opensim-moco-site/docs/

import org.opensim.modeling.*;

% Set the model
model = Model('simple_model.osim');


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
study.setName("simple_moco_example");

% Access the MocoProblem from the study.
problem = study.updProblem();
modelProcessor = ModelProcessor(model);
problem.setModelProcessor(modelProcessor);

% Set initial time to 0; final time to between 0 and 5
problem.setTimeBounds(MocoInitialBounds(0),...
MocoFinalBounds(0, 1));

% The coordinate value must be between -π and π over the phase,
% and its initial value is 0 and its final value is π/2.
problem.setStateInfo('/jointset/pin_joint/pin_joint_coord_0/value',...
[deg2rad(-80), deg2rad(60)], deg2rad(-30), deg2rad(30));

% Start and end velocities should be zero
problem.setStateInfo('/jointset/pin_joint/pin_joint_coord_0/speed',...
[-50, 50], 0, 0);


% Minimize the sum of squared controls with weight 1.5.
problem.addGoal(MocoControlGoal('effort', 1.5));
% Add final time goal
problem.addGoal(MocoFinalTimeGoal);


% Initialize the CasADi or Tropter solver.
solver = study.initCasADiSolver();
% alternative: solver = study.initTropterSolver();

% Solve the problem on a grid of 50 mesh intervals.
solver.set_num_mesh_intervals(20);

% Solve! Use track.solve() to skip visualizing.
solution = study.solve();

try
    study.visualize(solution);
    solution.write('example_MocoStudy_solution.sto');
catch
    disp('did not solve')
end

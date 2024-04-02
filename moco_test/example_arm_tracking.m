% Ed Chadwick (April 2024)
% Based on exampleMocoTrack.m by Nicholas Bianco
% https://opensim-org.github.io/opensim-moco-site/docs/

function example_arm_tracking()

% Solve the torque-driven marker tracking problem.
torqueDrivenMarkerTracking();

muscleDrivenStateTracking();

    function torqueDrivenMarkerTracking()

        import org.opensim.modeling.*;

        % Create and name an instance of the MocoTrack tool.
        track = MocoTrack();
        track.setName("torque_driven_marker_tracking");

        % Create the base Model by passing in the model file.
        modelProcessor = ModelProcessor("arm26.osim");

        % Remove all the muscles in the model's ForceSet.
        modelProcessor.append(ModOpRemoveMuscles());

        % Add CoordinateActuators to the model degrees-of-freedom.
        modelProcessor.append(ModOpAddReserves(250, 1.0));
        track.setModel(modelProcessor);

        % Use this convenience function to set the MocoTrack markers reference
        % directly from a TRC file. By default, the markers data is filtered at
        % 6 Hz and if in millimeters, converted to meters.
        track.setMarkersReferenceFromTRC("arm26_elbow_flex.trc");

        % There is marker data in the 'marker_trajectories.trc' associated with
        % model markers that no longer exists (i.e. markers on the arms). Set this
        % flag to avoid an exception from being thrown.
        track.set_allow_unused_references(true);

        % Increase the global marker tracking weight, which is the weight
        % associated with the internal MocoMarkerTrackingGoal term.
        track.set_markers_global_tracking_weight(1000);

        % Initial time, final time, and mesh interval. The number of mesh points
        % used to discretize the problem is computed internally using these values.
        track.set_initial_time(0.0);
        track.set_final_time(1.0);
        track.set_mesh_interval(0.02);
        % Solve! Use track.solve() to skip visualizing.
        solution = track.solveAndVisualize();

        solution.write('exampleMocoTrack_markertracking_solution.sto');

    end

    function muscleDrivenStateTracking()

        import org.opensim.modeling.*;

        % Create and name an instance of the MocoTrack tool.

        track = MocoTrack();
        track.setName("muscle_driven_state_tracking");

        % Construct a ModelProcessor and set it on the tool. 
        modelProcessor = ModelProcessor("arm26.osim");

        % The default muscles in the model are replaced with optimization-friendly
        % DeGrooteFregly2016Muscles, and adjustments are made to the default muscle
        % parameters.
        
        modelProcessor.append(ModOpIgnoreTendonCompliance());
        modelProcessor.append(ModOpReplaceMusclesWithDeGrooteFregly2016());
        % Only valid for DeGrooteFregly2016Muscles.
        modelProcessor.append(ModOpIgnorePassiveFiberForcesDGF());
        % Only valid for DeGrooteFregly2016Muscles.
        modelProcessor.append(ModOpScaleActiveFiberForceCurveWidthDGF(1.5));

        % Use a function-based representation for the muscle paths. This is
        % recommended to speed up convergence, but if you would like to use
        % the original GeometryPath muscle wrapping instead, simply comment out
        % this line. To learn how to create a set of function-based paths for
        % your model, see the example 'examplePolynomialPathFitter.m'.
        %modelProcessor.append(ModOpReplacePathsWithFunctionBasedPaths(...
         %   "subject_walk_scaled_FunctionBasedPathSet.xml"));
        
         track.setModel(modelProcessor);

        % Construct a TableProcessor of the coordinate data and pass it to the
        % tracking tool. TableProcessors can be used in the same way as
        % ModelProcessors by appending TableOperators to modify the base table.
        % A TableProcessor with no operators, as we have here, simply returns the
        % base table.
        track.setStatesReference(TableProcessor("exampleMocoTrack_markertracking_solution.sto"));
        % This setting allows extra data columns contained in the states
        % reference that don't correspond to model coordinates.
        track.set_allow_unused_references(true);

        % Since there is only coordinate position data in the states references, this
        % setting is enabled to fill in the missing coordinate speed data using
        % the derivative of splined position data.
        track.set_track_reference_position_derivatives(true);

        % Initial time, final time, and mesh interval.
        track.set_initial_time(0.0);
        track.set_final_time(1.0);
        track.set_mesh_interval(0.02);

        % Instead of calling solve(), call initialize() to receive a pre-configured
        % MocoStudy object based on the settings above. Use this to customize the
        % problem beyond the MocoTrack interface.
        study = track.initialize();

        % Get a reference to the MocoControlGoal that is added to every MocoTrack
        % problem by default.
        problem = study.updProblem();
        effort = MocoControlGoal.safeDownCast(problem.updGoal("control_effort"));
        effort.setWeight(0.1);
        
        % Constrain the muscle activations at the initial time point to equal
        % the initial muscle excitation value.
        problem.addGoal(MocoInitialActivationGoal('initial_activation'));
        
        % Update the solver tolerances.
        solver = MocoCasADiSolver.safeDownCast(study.updSolver());
        solver.set_optim_convergence_tolerance(1e-3);
        solver.set_optim_constraint_tolerance(1e-4);
        
        % Solve and visualize.
        solution = study.solve();
        study.visualize(solution);

        solution.write('exampleMocoTrack_muscledriven_solution.sto');
    end
end

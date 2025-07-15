import org.opensim.modeling.*

% Create the model
model = Model();
model.setName('simple_model');

% Create the ground and body
ground = model.getGround();
body = Body('body', 0.5, Vec3(0.5, 0, 0), Inertia(0.1));

% Create and attach geometries to the body
brick = Brick(Vec3(0.5, 0.1, 0.1));
body.attachGeometry(brick);


% Create the pin joint
locationInParent = Vec3(0);
orientationInParent = Vec3(0);
locationInBody = Vec3(-0.5, 0, 0);
orientationInBody = Vec3(0);
pinJoint = PinJoint('pin_joint', ground, locationInParent, orientationInParent, body, locationInBody, orientationInBody);


% Add the body and joint to the model
model.addBody(body);
model.addJoint(pinJoint);

% Get the coordinate of the pin joint
coord = pinJoint.updCoordinate();


% Set the range of motion (e.g., -45 to 45 degrees)
coord.setRange([deg2rad(-80), deg2rad(60)]);


% Create the muscles
muscle1 = Thelen2003Muscle('muscle1', 400, 0.7, 0.1, 0.1);
muscle2 = Thelen2003Muscle('muscle2', 400, 0.6, 0.1, 0.1);

% Attach the muscles to the body and ground
muscle1.addNewPathPoint('origin', ground, Vec3(0.1, 0.3, 0));
muscle1.addNewPathPoint('insertion', body, Vec3(0.2, 0.1, 0));
muscle2.addNewPathPoint('origin', ground, Vec3(0.1, -0.3, 0));
muscle2.addNewPathPoint('insertion', body, Vec3(0.2, 0.-0.1, 0));

% Add the muscles to the model
model.addForce(muscle1);
model.addForce(muscle2);

DeGrooteFregly2016Muscle().replaceMuscles(model);

% Add CoordinateActuators to the model degrees-of-freedom.
%modelProcessor.append(ModOpAddReserves(250, 1.0));

% Finalize the model
model.finalizeConnections();

% Save the model
model.print('simple_model.osim');

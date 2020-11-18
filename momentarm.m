import org.opensim.modeling.*
clear
%importing the model
mainpath = cd;
modelpath = "C:\Users\luldo\Documents\OpenSim\4.1\Models\WristModel";
filename = "wrist.osim";
cd(modelpath)
model = Model(filename);
cd(mainpath)

%creating the initial state
state = model.initSystem();

%Get Range (Min and Max) of all non-dependent Coordinates
cSet = model.getCoordinateSet();
nCoord = cSet.getSize();

for i = 0:nCoord-1
    if cSet.get(i).isDependent(state) == 0
        coordName(i+1,1) = cSet.get(i).getName();
        coord(i+1,1) = cSet.get(i).getRangeMin();
        coord(i+1,2) = cSet.get(i).getRangeMax();
    end
end

%generate iteration values
% for i = 0:nCoord-1
%     if cSet.get(i).isDependent(state) == 0
%         ite{i+1} = coord(i+1,1):0.001:coord(i+1,2);
%     end
% end

%Get Muscles
mSet = model.getMuscles();
nMuscles = mSet.getSize();

for i = 0:nMuscles-1
    for j = 0:nCoord-1
        if cSet.get(j).isDependent(state) == 0
            momentArmMat{i+1,j+1} = getMomentArms(state,mSet.get(i),cSet.get(j),coord(j+1,:));
        end
    end
end
% x = coord(1,1):0.001:coord(1,2);
% y = getMomentArms(state,mSet.get(0),cSet.get(0),coord(1,:));

%Get Moment Arm of a Single Muscle vs 1 Coordinate
function momentArm = getMomentArms(state,muscle,coord,MinMax);
    n = 1;
    for i = MinMax(1):0.001:MinMax(2)
        coord.setValue(state,i)
        momentArm(n) = muscle.computeMomentArm(state,coord);
        n=n+1;
    end
end

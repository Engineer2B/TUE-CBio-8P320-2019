SetFactory("OpenCASCADE");
Cylinder(1) = {0, 0, -.5, 0, 0, 1, 0.5, 2*Pi};
Cylinder(2) = {0, 0, -.5, 0, 0, 1, 0.25, 2*Pi};
BooleanDifference{ Volume{1}; Delete; }{ Volume{2}; Delete; }
Cylinder(3) = {0, 0, -.5, 0, 0, 1, 0.25, 2*Pi};
Physical Surface("Bone_1+Water_1", 1) = { 1, 2, 3 };
Physical Surface("Bone_1+Marrow_1", 2) = { 4, 5 };
Physical Surface("Marrow_1+Water_1", 3) = { 6, 7 };
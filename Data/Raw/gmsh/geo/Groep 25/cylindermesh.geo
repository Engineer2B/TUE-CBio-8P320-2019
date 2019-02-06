// Gmsh project created on Fri Dec 14 12:58:27 2018
SetFactory("OpenCASCADE");
MTPT = 2; // mean trabecular plate thickness // change these things 
MTPS = 1; // mean trabecular plate separation 
L    = 25; // length
Rt   = 15; // radius trabecular bone
Rc   = 20; // radius cortical bone 
nply =2*(Rt/(MTPT+MTPS)); //Should be an integer 
Cylinder(1) = {0,0,0,0,0,L,Rt,2*Pi};
Cylinder(2) = {0,0,0,0,0,L,Rc,2*Pi};
Cylinder(3) = {0,0,0,0,0,L,Rt,2*Pi};
BooleanDifference{ Volume{2}; Delete; }{ Volume{1}; Delete; }
Physical Surface("Markoil_1+Bone_1", 1) = {8:12};
Physical Surface("Bone_1+Marrow_1", 2) = {8, 7, 9};

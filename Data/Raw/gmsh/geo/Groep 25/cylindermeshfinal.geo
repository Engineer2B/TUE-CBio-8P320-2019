SetFactory("OpenCASCADE");
// This is a humeral bone mesh representation using a homogenous cylinder model 
L = 25;		 // Length of the bone sample
Rt = 6.05; 	 // mm, Radius of the trabecular bone cylinder
Rc = 9.65; 	 // mm, Radius of the cortical bone cylinder
Rm = 42.65; 	 // mm, Radius of the muscle cylinder  


//--------------------------------------------------------------------------------------------
// Mesh creation
//--------------------------------------------------------------------------------------------
 
Cylinder(1) = {0,0,0,0,0,L,Rt,2*Pi}; // Inner cylinder, trabecular bone
Cylinder(2) = {0,0,0,0,0,L,Rc,2*Pi}; // Middle cylinder, cortical bone
Cylinder(3) = {0,0,0,0,0,L,Rm,2*Pi}; // Outer cylinder, muscle 
//BooleanDifference{ Volume{3};}{ Volume{2};} 
Physical Surface("Markoil_1+Muscle_1", 1) = {7, 8, 9};   // Markoil Muscle interface
Physical Surface("Muscle_1+Bone_1", 2) = {4, 5, 6};      // Muscle Bone interface
Physical Surface("Bone_1+TrabecularBone_1",3) = {1, 2, 3}; // Bone Trabecular Bone interface
// Gmsh project created on Mon Dec 17 09:19:43 2018
SetFactory("OpenCASCADE");
Sphere(1) = {0, 0, 0, 0.125, -Pi/2, Pi/2, Pi};
Cylinder(2) = {0, 0, 0, 0, -.07, 0, 0.055, 2*Pi};
BooleanDifference{ Volume{1}; Delete; }{ Volume{2}; }
Physical Surface("Water_1+Air_1", 1) = { 7:9 };
Physical Surface("Water_1+Agar2Silica_1", 2) = { 6, 10:11 };
Physical Surface("Agar2Silica_1+Air_1", 3) = { 4:5 };
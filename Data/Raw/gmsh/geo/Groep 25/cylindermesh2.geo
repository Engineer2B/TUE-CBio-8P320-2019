// Gmsh project created on Fri Dec 14 12:58:27 2018
SetFactory("OpenCASCADE");
MTPT = 10; // mean trabecular plate thickness // change these things 
MTPS = 5; // mean trabecular plate separation 
L    = 25; // length
Rt   = 15; // radius trabecular bone
Rc   = 20; // radius cortical bone 
nply =2*(Rt/(MTPT+MTPS)); //Should be an integer 

rate = (MTPT+MTPS)/MTPT; 
Cylinder(1) = {0,0,0,0,0,L,Rt,2*Pi};
q = rate*nply-1;
For i In {1:rate*nply-1:rate}
	
// x direction, first plane 16
	p01[{i}]=newp; Point(p01[i]) = {Rt-MTPT*i,Sqrt(Rt^2-(Rt-MTPT*i)^2),0,Rt}; 
	p02[{i}]=newp; Point(p02[i]) = {Rt-MTPT*i-MTPS,Sqrt(Rt^2-(Rt-MTPT*i-MTPS)^2),0,Rt};
	p03[{i}]=newp; Point(p03[i]) = {Rt-MTPT*i,-Sqrt(Rt^2-(Rt-MTPT*i)^2),0,Rt}; 
	p04[{i}]=newp; Point(p04[i]) = {Rt-MTPT*i-MTPS,-Sqrt(Rt^2-(Rt-MTPT*i-MTPS)^2),0,Rt};
	l01[{i}]=newl; Line(l01[i]) = {p01[i],p03[i]}; 
	l02[{i}]=newl; Line(l02[i]) = {p02[i],p04[i]}; 
// x direction, second plane 24
	p05[{i}]=newp; Point(p05[i]) = {Rt-MTPT*i,Sqrt(Rt^2-(Rt-MTPT*i)^2),L,Rt}; 
	p06[{i}]=newp; Point(p06[i]) = {Rt-MTPT*i-MTPS,Sqrt(Rt^2-(Rt-MTPT*i-MTPS)^2),L,Rt};
	p07[{i}]=newp; Point(p07[i]) = {Rt-MTPT*i,-Sqrt(Rt^2-(Rt-MTPT*i)^2),L,Rt}; 
	p08[{i}]=newp; Point(p08[i]) = {Rt-MTPT*i-MTPS,-Sqrt(Rt^2-(Rt-MTPT*i-MTPS)^2),L,Rt};
	l03[{i}]=newl; Line(l03[i]) = {p05[i],p07[i]}; 
	l04[{i}]=newl; Line(l04[i]) = {p06[i],p08[i]};  
	BooleanIntersection(1) = { Curve{l01[i]}; Delete; }{ Curve{l02[i]}; Delete; }
// x direction, connect planes 32 
	l05[{i}]=newl; Line(l05[i]) = {p01[i],p05[i]};
	l06[{i}]=newl; Line(l06[i]) = {p02[i],p06[i]}; 
	l07[{i}]=newl; Line(l07[i]) = {p03[i],p07[i]}; 
	l08[{i}]=newl; Line(l08[i]) = {p04[i],p08[i]};  

// surface X 38
	ll01[{i}]=newll; Line Loop(ll01[i]) = {l01[i],l07[i],-l03[i],-l05[i]};
	s01[{i}]=news; Plane Surface(s01[i]) = {ll01[i]}; 
	ll02[{i}]=newll; Line Loop(ll02[i]) = {l02[i],l08[i],-l04[i],-l06[i]};
	s02[{i}]=news; Plane Surface(s02[i]) = {ll02[i]}; 
// 43
	l20[{i}]=newl; Line(l20[i]) = {p01[i],p02[i]};
	l21[{i}]=newl; Line(l21[i]) = {p03[i],p04[i]};
	ll10[{i}]=newll; Line Loop(ll10[i]) = {l01[i],l21[i],-l02[i],-l20[i]};
	s10[{i}]=news; Surface(s10[i]) = {ll10[i]}; //trabecular bone, upper plane
// 49
	l22[{i}]=newl; Line(l22[i]) = {p05[i],p06[i]};
	l23[{i}]=newl; Line(l23[i]) = {p07[i],p08[i]};
	ll11[{i}]=newll; Line Loop(ll11[i]) = {l03[i],l23[i],-l04[i],-l22[i]};
	s11[{i}]=news; Surface(s11[i]) = {ll11[i]}; //trabecular bone, lower plane
//
	//ll14[{i}]=newll; Line Loop(ll14[i]) = {l20[i],l06[i],-l22[i],-l05[i]};
	//s14[{i}]=news; Surface(s14[i]) = {ll14[i]}; //side 
	//ll15[{i}]=newll; Line Loop(ll15[i]) = {l21[i],l08[i],-l23[i],-l07[i]};
	//s15[{i}]=news; Surface(s15[i]) = {ll15[i]}; //side 
//
	//sl01[{i}]=newsl; Surface Loop(sl01[i]) = {s01[i],s15[i],-s10[i],-s02[i],-s14[i],s11[i]};
	//v01[{i}]=newv; Volume(v01[i]) = {sl01[i]};

// physical surfaces X direction 
	//Physical Surface("Marrow_1+Bone_1", 1) = {s01[i]};
	//Physical Surface("Bone_1+Marrow_1", 2) = {s02[i]};
	//Physical Surface("TrabecularBone", 3) = {s10[i],s11[i]};

// y direction, first plane 57
	p09[{i}]=newp; Point(p09[i]) = {Sqrt(Rt^2-(Rt-MTPT*i)^2),Rt-MTPT*i,0,Rt}; 
	p10[{i}]=newp; Point(p10[i]) = {Sqrt(Rt^2-(Rt-MTPT*i-MTPS)^2),Rt-MTPT*i-MTPS,0,Rt};
	p11[{i}]=newp; Point(p11[i]) = {-Sqrt(Rt^2-(Rt-MTPT*i)^2),Rt-MTPT*i,0,Rt}; 
	p12[{i}]=newp; Point(p12[i]) = {-Sqrt(Rt^2-(Rt-MTPT*i-MTPS)^2),Rt-MTPT*i-MTPS,0,Rt};
	l09[{i}]=newl; Line(l09[i]) = {p09[i],p11[i]};
	l10[{i}]=newl; Line(l10[i]) = {p10[i],p12[i]};

// y direction, second plane 
	p13[{i}]=newp; Point(p13[i]) = {Sqrt(Rt^2-(Rt-MTPT*i)^2),Rt-MTPT*i,L,Rt}; 
	p14[{i}]=newp; Point(p14[i]) = {Sqrt(Rt^2-(Rt-MTPT*i-MTPS)^2),Rt-MTPT*i-MTPS,L,Rt};
	p15[{i}]=newp; Point(p15[i]) = {-Sqrt(Rt^2-(Rt-MTPT*i)^2),Rt-MTPT*i,L,Rt}; 
	p16[{i}]=newp; Point(p16[i]) = {-Sqrt(Rt^2-(Rt-MTPT*i-MTPS)^2),Rt-MTPT*i-MTPS,L,Rt};
	l11[{i}]=newl; Line(l11[i]) = {p13[i],p15[i]};
	l12[{i}]=newl; Line(l12[i]) = {p14[i],p16[i]};

// y direction, connect planes 
	l13[{i}]=newl; Line(l13[i]) = {p09[i],p13[i]};
	l14[{i}]=newl; Line(l14[i]) = {p10[i],p14[i]}; 
	l15[{i}]=newl; Line(l15[i]) = {p11[i],p15[i]}; 
	l16[{i}]=newl; Line(l16[i]) = {p12[i],p16[i]}; 
// surface Y  
	ll03[{i}]=newll; Line Loop(ll03[i]) = {l09[i],l15[i],-l11[i],-l13[i]};
	s03[{i}]=news; Plane Surface(s03[i]) = {ll03[i]}; 
	ll04[{i}]=newll; Line Loop(ll04[i]) = {l10[i],l16[i],-l12[i],-l14[i]};
	s04[{i}]=news; Plane Surface(s04[i]) = {ll04[i]}; 

	l24[{i}]=newl; Line(l24[i]) = {p09[i],p10[i]};
	l25[{i}]=newl; Line(l25[i]) = {p11[i],p12[i]};
	ll12[{i}]=newll; Line Loop(ll12[i]) = {l09[i],l25[i],-l10[i],-l24[i]};
	s12[{i}]=news; Surface(s12[i]) = {ll12[i]}; //trabecular bone 

	l26[{i}]=newl; Line(l26[i]) = {p13[i],p14[i]};
	l27[{i}]=newl; Line(l27[i]) = {p15[i],p16[i]};
	ll13[{i}]=newll; Line Loop(ll13[i]) = {l11[i],l27[i],-l12[i],-l26[i]};
	s13[{i}]=news; Surface(s13[i]) = {ll13[i]}; //trabecular bone 

// physical surfaces Y direction 
	//Physical Surface("Marrow_1+Bone_1", 1) = {s03[i]};
	//Physical Surface("Bone_1+Marrow_1", 2) = {s04[i]};
	//BooleanUnion (1) = Surface{s10[i]} Surface{s11[i]} Surface{s12[i]} Surface{s13[i]} ;
	//Physical Surface (i) = {s10[i], s12[i]};
	//Physical Surface (q+i) = {s11[i], s13[i]};
	//sl1[{i}]=newsl; Surface Loop(sl1[i]) = {s01[i],
	
//N = #s10[]; 
	//For p In {1:N}
		//Physical Surface(20+p+N*i) = {s03[i]};  
		//Physical Surface(20+(p+N*i)) = {s04[i]};
		//Physical Surface(1000000*i+p) = {s10[i],s11[i],s12[i],s13[i]}; 
		//Physical Surface(1000000*i+p) = {s10[i],s11[i],s12[i],s13[i]}; 
		//Physical Surface(100000000*i+p) = {s02[i]};
		//Physical Surface(1000000*i+p) = {s01[i]};
	//EndFor
EndFor



//Cylinder(3) = {0,0,0,0,0,L,Rt,2*Pi};
//BooleanDifference{ Volume{2}; Delete; }{ Volume{1}; Delete; }
//Physical Surface("Markoil_1+Bone_1", 1) = {8:12};
//Physical Surface("Bone_1+Marrow_1", 2) = {8, 7, 9};
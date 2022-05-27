//Mesh.Algorithm=5;

mesh = 0.02;

base = 0.85;
z1 = 0.27;
z2 = 0.42;

zmid = (z1+z2)/2;
xmid = base/2;

xrepo = 0.60;
zrepo = 0.20;
lrepo = 0.03;
hrepo = 0.03;


Point(1) = {0, 0, 0, mesh};
Point(2) = {base, 0, 0, mesh};
Point(3) = {base, 0, z2, mesh};
Point(4) = {xmid, 0, zmid, mesh};
Point(5) = {0, 0, z1, mesh};

//point inflow
Point(8) = {0.743, 0, 0.4011, mesh};
Point(9) = {0.723, 0, 0.3976, mesh};
//Line(7) = {8,9};

Line(1) = {1,2};
Line(2) = {2,3};
Line(3) = {3,8};
Line(4) = {8,9};
Line(5) = {9,4};
Line(6) = {4,5};
Line(7) = {5,1};

Line Loop(1) = {1,2,3,4,5,6,7};

//fract
Point(6) = {0.1, 0, 0.23, mesh};
Point(7) = {0.21, 0, 0.05, mesh};
Line(8) = {6,7};






//repozitory
Point(101) = {xrepo, 0, zrepo, mesh};
Point(102) = {xrepo+lrepo, 0, zrepo, mesh};
Point(103) = {xrepo+lrepo, 0, zrepo+hrepo, mesh};
Point(104) = {xrepo, 0, zrepo+hrepo, mesh};

Line(101) = {101,102};
Line(102) = {102,103};
Line(103) = {103,104};
Line(104) = {104,101};

Line Loop(101) = {101,102,103,104};
Line Loop(102) = {6, -6};
//Line Loop(103) = {7, -7};


// bulk
Plane Surface(1) = {1, 101, 102};
// repository
Plane Surface(101) = {101};
//inflow
//Plane Surface(4) = {103};


Physical Line(".bottom") = {1};
Physical Line(".right") = {7};
Physical Line(".left") = {2};
Physical Line(".topleft1") = {3};
Physical Line(".topleft2") = {5};
Physical Line(".topright") = {6};

Physical Line("fracture") = {8};
Physical Line("inflow") = {4};

Physical Surface("bulk") = {1};
Physical Surface("repository") = {101};


Mesh 2;


//Geometry.Tolerance = 1e-9;
//Coherence Mesh;

//Save "mesh_fract30.msh";
//Exit;//+
Show "*";
//+
Show "*";

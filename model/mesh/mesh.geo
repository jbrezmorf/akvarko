Mesh.Algorithm=5;

// mesh step
mesh = 0.01;

// base length
base = 0.77;
// hight on right and left
z1 = 0.27;
z2 = 0.38;


// top boundary separation point
left_fraction = 0.01;
zmid = left_fraction * z1 + (1-left_fraction) * z2;
xmid = left_fraction * base;

// position of repository
xrepo = 0.21;
zrepo = 0.25;
// dimensions of repository
lrepo = 0.02;
hrepo = 0.02;


Point(1) = {0, 0, 0, mesh};
Point(2) = {base, 0, 0, mesh};
Point(3) = {base, 0, z1, mesh};
Point(4) = {xmid, 0, zmid, mesh};
Point(5) = {0, 0, z2, mesh};

Line(1) = {1,2};
Line(2) = {2,3};
Line(3) = {3,4};
Line(4) = {4,5};
Line(5) = {5,1};

Line Loop(1) = {1,2,3,4,5};



Point(101) = {xrepo, 0, zrepo, mesh};
Point(102) = {xrepo+lrepo, 0, zrepo, mesh};
Point(103) = {xrepo+lrepo, 0, zrepo+hrepo, mesh};
Point(104) = {xrepo, 0, zrepo+hrepo, mesh};

Line(101) = {101,102};
Line(102) = {102,103};
Line(103) = {103,104};
Line(104) = {104,101};

Line Loop(101) = {101,102,103,104};


// bulk
Plane Surface(1) = {1, 101};
// repository
Plane Surface(101) = {101};


Physical Line(".bottom") = {1};
Physical Line(".left") = {5};
Physical Line(".right") = {2};
Physical Line(".topright") = {3};
Physical Line(".topleft") = {4};

Physical Surface("bulk") = {1};
Physical Surface("repository") = {101};


Mesh 2;


//Geometry.Tolerance = 1e-9;
//Coherence Mesh;

Save "mesh2.msh";
Exit;



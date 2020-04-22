Mesh.Algorithm=5;

// mesh step
mesh = 0.005;

// base length
base = 0.85;
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


// fracture
// bottom point
xfract1 = 0.55;
zfract1 = 0.15;
// top point
xfract2 = 0.65;
// Z coord computed from the top boundary
// horni naklonena rovina: z = z1 + (tan\alpha)*x
// X=0    .. z2
// X=f2   .. (z2*(base-f2) + z1*f2) / base
// X=base .. z1
zfract2 = (z2*(base-xfract2) + z1*xfract2) / base;




// FRACTURE
Point(201) = {xfract1, 0, zfract1, mesh};
Point(202) = {xfract2, 0, zfract2, mesh};

Line(201) = {201, 202};



// REPOSITORY
Point(101) = {xrepo, 0, zrepo, mesh};
Point(102) = {xrepo+lrepo, 0, zrepo, mesh};
Point(103) = {xrepo+lrepo, 0, zrepo+hrepo, mesh};
Point(104) = {xrepo, 0, zrepo+hrepo, mesh};

Line(101) = {101,102};
Line(102) = {102,103};
Line(103) = {103,104};
Line(104) = {104,101};

Line Loop(101) = {101,102,103,104};
Plane Surface(101) = {101};



// BULK
Point(1) = {0, 0, 0, mesh};
Point(2) = {base, 0, 0, mesh};
Point(3) = {base, 0, z1, mesh};
Point(4) = {xmid, 0, zmid, mesh};
Point(5) = {0, 0, z2, mesh};

// bulk with fracture endpoint 201 inside
//Line(1) = {201,2};
Line(2) = {2,3}; // left vertical
Line(3) = {3,202}; // top left, source
Line(4) = {202,4}; // top right
Line(5) = {1,2}; // bottom line

//Line(5) = {1,201};
Line(6) = {4,5}; // top right from frac
Line(7) = {5,1};   // right vertical


// bulk loop
Line Loop(1) = {2,3,-201,201,4,6,7,5};
Plane Surface(1) = {1, 101};



//Line Loop(2) = {5,201,6,7};
//Plane Surface(2) = {2};






// PHYSICAL
Physical Line("fracture") = {201};
Physical Point(".fract_bottom") = {201};
Physical Point(".fract_top") = {202};

Physical Line(".bottom") = {5,1};
Physical Line(".left") = {7};
Physical Line(".right") = {2};
Physical Line(".topright") = {3};
Physical Line(".topleft") = {4,6};

Physical Surface("bulk") = {1};
Physical Surface("repository") = {101};


Mesh 2;


//Geometry.Tolerance = 1e-9;
//Coherence Mesh;

Save "mesh_fract.msh";
Exit;



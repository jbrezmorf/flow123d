
L      =  5.0;
W      =  1.0;
H      =  1.0;
dParam = 10;
//--------------------------------
dL     = L / dParam;
dW     = L / dParam;

//--------------------------------
// Points

Point( 1) = {  0,       0,      0,   dW};

Point( 2) = {  W/2,    -W/2,    0,   dW};
Point( 3) = {  W/2 +L, -W/2,    0,   dL};
Point( 4) = {  W/2 +L,  W/2,    0,   dL};
Point( 5) = {  W/2,     W/2,    0,   dW};
Point( 6) = {  W/2,     W/2 +L, 0,   dL};
Point( 7) = { -W/2,     W/2 +L, 0,   dL};
Point( 8) = { -W/2,     W/2,    0,   dW};
Point( 9) = { -W/2 -L,  W/2,    0,   dL};
Point(10) = { -W/2 -L, -W/2,    0,   dL};
Point(11) = { -W/2,    -W/2,    0,   dW};
Point(12) = { -W/2,    -W/2 -L, 0,   dW};
Point(13) = {  W/2,    -W/2 -L, 0,   dW};

//--------------------------------
// Lines + Arcs

Line( 1) = { 1,  2};
Line( 2) = { 2,  3};
Line( 3) = { 3,  4};
Line( 4) = { 4,  5};
Line( 5) = { 5,  2};

Line( 6) = { 1,  5};
Line( 7) = { 5,  6};
Line( 8) = { 6,  7};
Line( 9) = { 7,  8};
Line(10) = { 8,  5};

Line(11) = { 1,  8};
Line(12) = { 8,  9};
Line(13) = { 9, 10};
Line(14) = {10, 11};
Line(15) = {11,  8};

Line(16) = { 1, 11};
Line(17) = {11, 12};
Line(18) = {12, 13};
Line(19) = {13,  2};
Line(20) = { 2, 11};

//--------------------------------
// Line Loops + Plane Surfaces

Line Loop(101) = {1, -5, -6};
Plane Surface(201) = {101};
Line Loop(102) = {2, 3, 4, 5};
Plane Surface(202) = {102};

Line Loop(111) = {6, -10, -11};
Plane Surface(211) = {111};
Line Loop(112) = {7, 8, 9, 10};
Plane Surface(212) = {112};

Line Loop(121) = {11, -15, -16};
Plane Surface(221) = {121};
Line Loop(122) = {12, 13, 14, 15};
Plane Surface(222) = {122};

Line Loop(131) = {16, -20, -1};
Plane Surface(231) = {131};
Line Loop(132) = {17, 18, 19, 20};
Plane Surface(232) = {132};

//--------------------------------

Extrude {0, 0, H} {
  Surface{201, 202, 211, 212, 221, 222, 231, 232};
}

//--------------------------------
// PHYSICAL
//--------------------------------

Physical Volume("ROCK_A") = {1,2};
Physical Volume("ROCK_B") = {3,4};
Physical Volume("ROCK_C") = {5,6};
Physical Volume("ROCK_D") = {7,8};

Physical Surface(".A")    = {262}; // Left
Physical Surface(".B")    = {301}; // Top
Physical Surface(".C")    = {340}; // Right
Physical Surface(".D")    = {379}; // Bottom



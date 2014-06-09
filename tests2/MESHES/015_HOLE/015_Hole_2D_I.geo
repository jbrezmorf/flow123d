// ########## Begin of file #######################

//Include "c_CLASSIC.cfg";

cl1 = ( Width -Width_hole ) / n1;
cl2 =          Width_hole   / n2;
cl3 = 2*Width               / n3;

//--------------------------------------------
// Points

Point( 1) = { 0,                             Offset_2D_I, 0,   cl1};
Point( 2) = { L_hole,                        Offset_2D_I, 0,   cl1};
Point( 3) = { L,                             Offset_2D_I, 0,   cl3};

Point( 4) = { L,      Width                 +Offset_2D_I, 0,   cl3};
Point( 5) = { L_hole, Width                 +Offset_2D_I, 0,   cl1};
Point( 6) = { 0,      Width                 +Offset_2D_I, 0,   cl1};

Point( 7) = { 0,      Width/2 +Width_hole/2 +Offset_2D_I, 0,   cl2};
Point( 8) = { L_hole, Width/2 +Width_hole/2 +Offset_2D_I, 0,   cl2};
Point( 9) = { L_hole, Width/2 -Width_hole/2 +Offset_2D_I, 0,   cl2};
Point(10) = { 0,      Width/2 -Width_hole/2 +Offset_2D_I, 0,   cl2};

// ---------- First rotation ----------
Rotate {{Fx,Fy,Fz},    {0,0,0},   FAngle } {
  Point{1};
  Point{2};
  Point{3};
  Point{4};
  Point{5};
  Point{6};
  Point{7};
  Point{8};
  Point{9};
  Point{10};
}

// ----------- Second rotation ----------
Rotate {{Sx,Sy,Sz},    {0,0,0},   SAngle } {
  Point{1};
  Point{2};
  Point{3};
  Point{4};
  Point{5};
  Point{6};
  Point{7};
  Point{8};
  Point{9};
  Point{10};
}

//--------------------------------------------
// Lines

Line(11) = {1, 2};
Line(12) = {2, 3};
Line(13) = {3, 4};
Line(14) = {4, 5};
Line(15) = {5, 6};
Line(16) = {6, 7};
Line(17) = {10, 1};

Line(18) = {9, 2};
Line(19) = {8, 5};
Line(20) = {10, 9};
Line(21) = {9, 8};
Line(22) = {8, 7};
Line(23) = {7, 10};

//............................................
// Line Loops + Plane Surfaces

Line Loop(24) = {17, 11, -18, -20};
Plane Surface(25) = {24};

Line Loop(26) = {22, -16, -15, -19};
Plane Surface(27) = {26};

Line Loop(28) = {12, 13, 14, -19, -21, 18};
Plane Surface(29) = {28};

Line Loop(30) = {20, 21, 22, 23};
Plane Surface(31) = {30};

//============================================
//     PHYSICAL
//============================================

Physical Surface('ROCK_2D_I_LEFT')  = {25,27}; // Rock on LEFT
Physical Surface('FRACTURE_2D_I')   = {31};    // Fracture
Physical Surface('ROCK_2D_I_RIGHT') = {29};    // Rock on RIGHT

Physical Line('.BCr_2D_I_LEFT') = {16,17}; // Boundary on LEFT (rock)
Physical Line('.BCf_2D_I_LEFT') = {23};    // Boundary on LEFT (fracture)
Physical Line('.BC_2D_I_RIGHT') = {13};    // Boundary on RIGHT

// ########## End of file #########################

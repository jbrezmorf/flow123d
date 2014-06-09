// ########## Begin of file #######################

cl1 = W     / nA;
cl2 = Wfrac / nB;

//--------------------------------------------
// Points

Point(11) = { -L/2,                Offset_2D_I, 0,   cl1};
Point(12) = {  L/2,                Offset_2D_I, 0,   cl1};
Point(13) = {  L/2,             W +Offset_2D_I, 0,   cl1};
Point(14) = { -L/2,             W +Offset_2D_I, 0,   cl1};

Point(15) = { ( W/2)*Tan(aRad),    Offset_2D_I, 0,   cl2};
Point(16) = { (-W/2)*Tan(aRad), W +Offset_2D_I, 0,   cl2};

// ---------- First rotation ----------
Rotate {{Fx,Fy,Fz},    {0,0,0},   FAngle } {
  Point{11};
  Point{12};
  Point{13};
  Point{14};
  Point{15};
  Point{16};
}

// ----------- Second rotation ----------
Rotate {{Sx,Sy,Sz},    {0,0,0},   SAngle } {
  Point{11};
  Point{12};
  Point{13};
  Point{14};
  Point{15};
  Point{16};
}

//--------------------------------------------
// Lines

Line(21) = {11, 15};
Line(22) = {15, 12};
Line(23) = {12, 13};
Line(24) = {13, 16};
Line(25) = {16, 14};
Line(26) = {14, 11};

Line(27) = {15, 16};

//............................................
// Line Loops + Plane Surfaces

Line Loop(31) = {21, 27, 25, 26};
Plane Surface(32) = {31};
Line Loop(33) = {22, 23, 24, -27};
Plane Surface(34) = {33};

//============================================
//     PHYSICAL
//============================================

Physical Surface('ROCK_2D_I')   = {32,34}; // Rock
Physical Line('FRACTURE_2D_I')  = {27};    // Fracture

Physical Line('.BC_2D_I_LEFT')  = {26}; // Boundary on LEFT
Physical Line('.BC_2D_I_RIGHT') = {23}; // Boundary on RIGHT

// ########## End of file #########################


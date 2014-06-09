// ########## Begin of file #######################

cl1 = W     / nA;
cl2 = Wfrac / nB;

//--------------------------------------------
// Points

Point(51) = { -L/2            -Wfrac/(2.0*Cos(aRad)),    Offset_2D_II, 0,   cl1};
Point(52) = {  L/2            +Wfrac/(2.0*Cos(aRad)),    Offset_2D_II, 0,   cl1};
Point(53) = {  L/2            +Wfrac/(2.0*Cos(aRad)), W +Offset_2D_II, 0,   cl1};
Point(54) = { -L/2            -Wfrac/(2.0*Cos(aRad)), W +Offset_2D_II, 0,   cl1};

Point(55) = { ( W/2)*Tan(aRad)-Wfrac/(2.0*Cos(aRad)),    Offset_2D_II, 0,   cl2};
Point(56) = { (-W/2)*Tan(aRad)-Wfrac/(2.0*Cos(aRad)), W +Offset_2D_II, 0,   cl2};

Point(57) = { ( W/2)*Tan(aRad)+Wfrac/(2.0*Cos(aRad)),    Offset_2D_II, 0,   cl2};
Point(58) = { (-W/2)*Tan(aRad)+Wfrac/(2.0*Cos(aRad)), W +Offset_2D_II, 0,   cl2};

// ---------- First rotation ----------
Rotate {{Fx,Fy,Fz},    {0,0,0},   FAngle } {
  Point{51};
  Point{52};
  Point{53};
  Point{54};
  Point{55};
  Point{56};
  Point{57};
  Point{58};
}

// ----------- Second rotation ----------
Rotate {{Sx,Sy,Sz},    {0,0,0},   SAngle } {
  Point{51};
  Point{52};
  Point{53};
  Point{54};
  Point{55};
  Point{56};
  Point{57};
  Point{58};
}

//--------------------------------------------
// Lines

Line(61) = {51, 55};
Line(62) = {57, 52};
Line(63) = {52, 53};
Line(64) = {53, 58};
Line(65) = {56, 54};
Line(66) = {54, 51};

Line(67) = {55, 57};
Line(68) = {56, 58};
Line(69) = {55, 56};
Line(70) = {57, 58};

//............................................
// Line Loops + Plane Surfaces

Line Loop(81) = {61, 69, 65, 66};
Plane Surface(82) = {81};
Line Loop(83) = {62, 63, 64, -70};
Plane Surface(84) = {83};

Line Loop(85) = {67, 70, -68, -69};
Plane Surface(86) = {85};

//============================================
//     PHYSICAL
//============================================

Physical Surface('ROCK_2D_II')     = {82,84}; // Rock
Physical Surface('FRACTURE_2D_II') = {86};    // Fracture

Physical Line('.BC_2D_II_LEFT')  = {66}; // Boundary on LEFT
Physical Line('.BC_2D_II_RIGHT') = {63}; // Boundary on RIGHT

// ########## End of file #########################


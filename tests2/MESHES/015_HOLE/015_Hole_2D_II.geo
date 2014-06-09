// ########## Begin of file #######################

//Include "c_CLASSIC.cfg";

cl51 = ( Width -Width_hole ) / n1;
cl52 =          Width_hole   / n2;
cl53 = 2*Width               / n3;

//--------------------------------------------
// Points

Point(51) = { 0,                 Offset_2D_II, 0,   cl51};
Point(52) = { L_hole,            Offset_2D_II, 0,   cl51};
Point(53) = { L,                 Offset_2D_II, 0,   cl53};

Point(54) = { L,        Width   +Offset_2D_II, 0,   cl53};
Point(55) = { L_hole,   Width   +Offset_2D_II, 0,   cl51};
Point(56) = { 0,        Width   +Offset_2D_II, 0,   cl51};

Point(57) = { 0,        Width/2 +Offset_2D_II, 0,   cl52};
Point(58) = { L_hole,   Width/2 +Offset_2D_II, 0,   cl52};

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

Line(61) = {51, 52};
Line(62) = {52, 53};
Line(63) = {53, 54};
Line(64) = {54, 55};
Line(65) = {55, 56};
Line(66) = {56, 57};
Line(67) = {57, 51};

Line(68) = {58, 52};
Line(69) = {58, 55};
Line(70) = {58, 57};

//............................................
// Line Loops + Plane Surfaces

Line Loop(81) = {67, 61, -68, 70};
Plane Surface(82) = {81};

Line Loop(83) = {70, -66, -65, -69};
Plane Surface(84) = {83};

Line Loop(85) = {62, 63, 64, -69, 68};
Plane Surface(86) = {85};

//============================================
//     PHYSICAL
//============================================

Physical Surface('ROCK_2D_II_LEFT')  = {82,84}; // Rock on LEFT
Physical Line('FRACTURE_2D_II')      = {70};    // Fracture
Physical Surface('ROCK_2D_II_RIGHT') = {86};    // Rock on RIGHT

Physical Line( '.BCr_2D_II_LEFT') = {66,67};    // Boundary on LEFT (rock)
Physical Point('.BCf_2D_II_LEFT') = {57};       // Boundary on LEFT (fracture)
Physical Line( '.BC_2D_II_RIGHT') = {63};       // Boundary on RIGHT

// ########## End of file #########################


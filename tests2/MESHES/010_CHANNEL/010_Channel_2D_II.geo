// ########## Begin of file #######################

cl1 = Width_II / nLEFT;
cl2 = Width_II / nLR;
cl3 = Width_II / nRIGHT;

//--------------------------------------------
// Points

Point(51) = {  0,                     Offset_2D_II, 0,   cl1};
Point(52) = {  0,           Width_II +Offset_2D_II, 0,   cl1/3.0};

Point(53) = { Lleft,                  Offset_2D_II, 0,   cl2/3.0};
Point(54) = { Lleft,        Width_II +Offset_2D_II, 0,   cl2};

Point(55) = { Lleft+Lright,           Offset_2D_II, 0,   cl3};
Point(56) = { Lleft+Lright, Width_II +Offset_2D_II, 0,   cl3/3.0};

// ---------- First rotation ----------
Rotate {{Fx,Fy,Fz},    {0,0,0},   FAngle } {
  Point{51};
  Point{52};
  Point{53};
  Point{54};
  Point{55};
  Point{56};
}

// ----------- Second rotation ----------
Rotate {{Sx,Sy,Sz},    {0,0,0},   SAngle } {
  Point{51};
  Point{52};
  Point{53};
  Point{54};
  Point{55};
  Point{56};
}

//--------------------------------------------
// Lines

Line(61) = {51, 52};
Line(62) = {53, 54};
Line(63) = {55, 56};

Line(64) = {51, 53};
Line(65) = {52, 54};

Line(66) = {53, 55};
Line(67) = {54, 56};

//............................................
// Line Loops + Plane Surfaces

Line Loop(71) = {61, 65, -62, -64};
Plane Surface(72) = {71};

Line Loop(73) = {62, 67, -63, -66};
Plane Surface(74) = {73};

//============================================
//     PHYSICAL
//============================================

Physical Surface('ROCK_2D_II_LEFT')  = {72}; // LEFT subdomain
Physical Surface('ROCK_2D_II_RIGHT') = {74}; // RIGHT subdomain

If ( isFracBoundaryLEFT == 0 )
  Physical Line('.BC_2D_II_LEFT') = {61}; // Boundary on LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 0 )
  Physical Line('.BC_2D_II_RIGHT') = {63}; // Boundary on RIGHT subdomain
EndIf

//--------------------------------------------

If ( isFracMiddle == 1 )
  Physical Line('FRACTURE_2D_II')   = {62}; // Fracture between LEFT and RIGHT subdomains
EndIf

If ( isFracBoundaryLEFT == 1 )
  Physical Line('FRACTURE_2D_II_LEFT') = {61}; // Fracture on boundary of LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 1 )
  Physical Line('FRACTURE_2D_II_RIGHT') = {63}; // Boundary on boundary of RIGHT subdomain
EndIf

// ########## End of file #########################

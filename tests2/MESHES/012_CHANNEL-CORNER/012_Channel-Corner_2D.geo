// ########## Begin of file #######################

cl       = Width / nDiff;

//--------------------------------------------
// Points

Point(11) = {  (Width/2)*Tan(angleRad/2)                +Offset_X_2D,                 -(Width/2)               +Offset_Y_2D, 0,   cl};
Point(12) = {  L*Cos(angleRad) +(Width/2)*Sin(angleRad) +Offset_X_2D, L*Sin(angleRad) -(Width/2)*Cos(angleRad) +Offset_Y_2D, 0,   cl};
Point(13) = { -L                                        +Offset_X_2D,                 -(Width/2)               +Offset_Y_2D, 0,   cl};

Point(14) = { -(Width/2)*Tan(angleRad/2)                +Offset_X_2D,                  (Width/2)               +Offset_Y_2D, 0,   cl};
Point(15) = {  L*Cos(angleRad) -(Width/2)*Sin(angleRad) +Offset_X_2D, L*Sin(angleRad) +(Width/2)*Cos(angleRad) +Offset_Y_2D, 0,   cl};
Point(16) = { -L                                        +Offset_X_2D,                  (Width/2)               +Offset_Y_2D, 0,   cl};

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

Line(21) = {11, 12};
Line(22) = {12, 15};
Line(23) = {15, 14};

Line(24) = {11, 14};

Line(25) = {11, 13};
Line(26) = {13, 16};
Line(27) = {16, 14};

//............................................
// Line Loops + Plane Surfaces

Line Loop(31) = {25, 26, 27, -24};
Plane Surface(32) = {31};

Line Loop(33) = {21, 22, 23, -24};
Plane Surface(34) = {33};

//============================================
//     PHYSICAL
//============================================

Physical Surface('ROCK_2D_LEFT')  = {32}; // LEFT subdomain
Physical Surface('ROCK_2D_RIGHT') = {34}; // RIGHT subdomain

If ( isFracBoundaryLEFT == 0 )
  Physical Line('.BC_2D_LEFT') = {26}; // Boundary on LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 0 )
  Physical Line('.BC_2D_RIGHT') = {22}; // Boundary on RIGHT subdomain
EndIf

//--------------------------------------------

If ( isFracMiddle == 1 )
  Physical Line('FRACTURE_2D') = {24}; // Fracture between LEFT and RIGHT subdomains
EndIf

If ( isFracBoundaryLEFT == 1 )
  Physical Line('FRACTURE_2D_LEFT') = {26}; // Fracture on boundary of LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 1 )
  Physical Line('FRACTURE_2D_RIGHT') = {22}; // Boundary on boundary of RIGHT subdomain
EndIf

// ########## End of file #########################

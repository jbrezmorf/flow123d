// ########## Begin of file #######################

cl       = Width / nDiff;

//--------------------------------------------
// Points

Point(51) = {  (Width/2)*Tan(angleRad/2)                +Offset_X_3D,                 -(Width/2)               +Offset_Y_3D, 0,   cl};
Point(52) = {  L*Cos(angleRad) +(Width/2)*Sin(angleRad) +Offset_X_3D, L*Sin(angleRad) -(Width/2)*Cos(angleRad) +Offset_Y_3D, 0,   cl};
Point(53) = { -L                                        +Offset_X_3D,                 -(Width/2)               +Offset_Y_3D, 0,   cl};

Point(54) = { -(Width/2)*Tan(angleRad/2)                +Offset_X_3D,                  (Width/2)               +Offset_Y_3D, 0,   cl};
Point(55) = {  L*Cos(angleRad) -(Width/2)*Sin(angleRad) +Offset_X_3D, L*Sin(angleRad) +(Width/2)*Cos(angleRad) +Offset_Y_3D, 0,   cl};
Point(56) = { -L                                        +Offset_X_3D,                  (Width/2)               +Offset_Y_3D, 0,   cl};

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
Line(62) = {52, 55};
Line(63) = {55, 54};

Line(64) = {51, 54};

Line(65) = {51, 53};
Line(66) = {53, 56};
Line(67) = {56, 54};

//............................................
// Line Loops + Plane Surfaces

Line Loop(71) = {65, 66, 67, -64};
Plane Surface(72) = {71};

Line Loop(73) = {61, 62, 63, -64};
Plane Surface(74) = {73};

//............................................
// Extrude VOLUME

/*
   The list ext[] contains all geometric entities created by extrusion:
   ext[0] -- surface created by translating MAIN surface
   ext[1] -- volume crated by sweeping MAIN surface
   ext[2] -- surface created by extruding line 1 of MAIN surface
   ext[3] -- surface created by extruding line 2 of MAIN surface
   ext[i] -- surface created by extruding line i of MAIN surface
*/

ext32[] = Extrude {0, 0, Height} {
  Surface{72};
};

ext34[] = Extrude {0, 0, Height} {
  Surface{74};
};

//============================================
//     PHYSICAL
//============================================

Physical Volume('ROCK_3D_LEFT')  = {ext32[1]}; // LEFT subdomain
Physical Volume('ROCK_3D_RIGHT') = {ext34[1]}; // RIGHT subdomain

If ( isFracBoundaryLEFT == 0 )
  Physical Surface('.BC_3D_LEFT') = {ext32[3]}; // Boundary on LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 0 )
  Physical Surface('.BC_3D_RIGHT') = {ext34[3]}; // Boundary on RIGHT subdomain
EndIf

//--------------------------------------------

If ( isFracMiddle == 1 )
  Physical Surface('FRACTURE_3D') = {ext32[5]}; // Fracture between LEFT and RIGHT subdomains
EndIf

If ( isFracBoundaryLEFT == 1 )
  Physical Surface('FRACTURE_3D_LEFT') = {ext32[3]}; // Fracture on boundary of LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 1 )
  Physical Surface('FRACTURE_3D_RIGHT') = {ext34[3]}; // Boundary on boundary of RIGHT subdomain
EndIf

// ########## End of file #########################

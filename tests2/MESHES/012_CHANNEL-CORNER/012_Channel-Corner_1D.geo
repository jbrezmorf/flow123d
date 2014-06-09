// ########## Begin of file #######################

cl       = Width / nDiff;

//--------------------------------------------
// Points

Point(1) = {                   Offset_X_1D,                  Offset_Y_1D, 0,   cl};
Point(2) = {  L*Cos(angleRad) +Offset_X_1D, L*Sin(angleRad) +Offset_Y_1D, 0,   cl};
Point(3) = { -L               +Offset_X_1D,                  Offset_Y_1D, 0,   cl};

// ---------- First rotation ----------
Rotate {{Fx,Fy,Fz},    {0,0,0},   FAngle } {
  Point{1};
  Point{2};
  Point{3};
}

// ----------- Second rotation ----------
Rotate {{Sx,Sy,Sz},    {0,0,0},   SAngle } {
  Point{1};
  Point{2};
  Point{3};
}

//--------------------------------------------
// Lines

Line(5) = {1, 2};
Line(6) = {1, 3};

//============================================
//     PHYSICAL
//============================================

Physical Line('ROCK_1D_LEFT')  = {6}; // LEFT subdomain
Physical Line('ROCK_1D_RIGHT') = {5}; // RIGHT subdomain

If ( isFracBoundaryLEFT == 0 )
  Physical Point('.BC_1D_LEFT') = {3}; // Boundary on LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 0 )
  Physical Point('.BC_1D_RIGHT') = {2}; // Boundary on RIGHT subdomain
EndIf

//--------------------------------------------

If ( isFracMiddle == 1 )
  Physical Point('FRACTURE_1D') = {1}; // Fracture between LEFT and RIGHT subdomains
EndIf

If ( isFracBoundaryLEFT == 1 )
  Physical Point('FRACTURE_1D_LEFT') = {3}; // Fracture on boundary of LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 1 )
  Physical Point('FRACTURE_1D_RIGHT') = {2}; // Boundary on boundary of RIGHT subdomain
EndIf

// ########## End of file #########################

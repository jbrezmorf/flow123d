// ########## Begin of file #######################

cl1 = Width_I / nLEFT;
cl2 = Width_I / nLR;
cl3 = Width_I / nRIGHT;

//--------------------------------------------
// Points

Point(1) = {  0,             Offset_1D_I,  0,   cl1};
Point(2) = { Lleft,          Offset_1D_I,  0,   cl2};
Point(3) = { Lleft+Lright,   Offset_1D_I,  0,   cl3};

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

Line(4) = {1, 2};
Line(5) = {2, 3};

//============================================
//     PHYSICAL
//============================================

Physical Line('ROCK_1D_I_LEFT')  = {4}; // LEFT subdomain
Physical Line('ROCK_1D_I_RIGHT') = {5}; // RIGHT subdomain

If ( isFracBoundaryLEFT == 0 )
  Physical Point('.BC_1D_I_LEFT') = {1}; // Boundary on LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 0 )
  Physical Point('.BC_1D_I_RIGHT') = {3}; // Boundary on RIGHT subdomain
EndIf

//--------------------------------------------

If ( isFracMiddle == 1 )
  Physical Point('FRACTURE_1D_I') = {2}; // Fracture between LEFT and RIGHT subdomains
EndIf

If ( isFracBoundaryLEFT == 1 )
  Physical Point('FRACTURE_1D_I_LEFT') = {1}; // Fracture on boundary of LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 1 )
  Physical Point('FRACTURE_1D_I_RIGHT') = {3}; // Boundary on boundary of RIGHT subdomain
EndIf

// ########## End of file #########################

// ########## Begin of file #######################

cl1 = Width_I / nLEFT;
cl2 = Width_I / nLR;
cl3 = Width_I / nRIGHT;

//--------------------------------------------
// Points

Point(11) = {  0,            Offset_1D_II,  0,   cl1};
Point(12) = { Lleft,         Offset_1D_II,  0,   cl2};
Point(13) = { Lleft+Lright,  Offset_1D_II,  0,   cl3};

// ---------- First rotation ----------
Rotate {{Fx,Fy,Fz},    {0,0,0},   FAngle } {
  Point{11};
  Point{12};
  Point{13};
}

// ----------- Second rotation ----------
Rotate {{Sx,Sy,Sz},    {0,0,0},   SAngle } {
  Point{11};
  Point{12};
  Point{13};
}

//--------------------------------------------
// Lines

Line(14) = {11, 12};
Line(15) = {12, 13};

//============================================
//     PHYSICAL
//============================================

Physical Line('ROCK_1D_II_LEFT')  = {14}; // LEFT subdomain
Physical Line('ROCK_1D_II_RIGHT') = {15}; // RIGHT subdomain

If ( isFracBoundaryLEFT == 0 )
  Physical Point('.BC_1D_II_LEFT') = {11}; // Boundary on LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 0 )
  Physical Point('.BC_1D_II_RIGHT') = {13}; // Boundary on RIGHT subdomain
EndIf

//--------------------------------------------

If ( isFracMiddle == 1 )
  Physical Point('FRACTURE_1D_II') = {12}; // Fracture between LEFT and RIGHT subdomains
EndIf

If ( isFracBoundaryLEFT == 1 )
  Physical Point('FRACTURE_1D_II_LEFT') = {11}; // Fracture on boundary of LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 1 )
  Physical Point('FRACTURE_1D_II_RIGHT') = {13}; // Boundary on boundary of RIGHT subdomain
EndIf

// ########## End of file #########################

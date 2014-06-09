// ########## Begin of file #######################

cl1 = Width_I / nLEFT;
cl2 = Width_I / nLR;
cl3 = Width_I / nRIGHT;

//--------------------------------------------
// Points

Point(21) = {  0,                    Offset_2D_I, 0,   cl1};
Point(22) = {  0,           Width_I +Offset_2D_I, 0,   cl1/3.0};

Point(23) = { Lleft,                 Offset_2D_I, 0,   cl2/3.0};
Point(24) = { Lleft,        Width_I +Offset_2D_I, 0,   cl2};

Point(25) = { Lleft+Lright,          Offset_2D_I, 0,   cl3};
Point(26) = { Lleft+Lright, Width_I +Offset_2D_I, 0,   cl3/3.0};

// ---------- First rotation ----------
Rotate {{Fx,Fy,Fz},    {0,0,0},   FAngle } {
  Point{21};
  Point{22};
  Point{23};
  Point{24};
  Point{25};
  Point{26};
}

// ----------- Second rotation ----------
Rotate {{Sx,Sy,Sz},    {0,0,0},   SAngle } {
  Point{21};
  Point{22};
  Point{23};
  Point{24};
  Point{25};
  Point{26};
}

//--------------------------------------------
// Lines

Line(31) = {21, 22};
Line(32) = {23, 24};
Line(33) = {25, 26};

Line(34) = {21, 23};
Line(35) = {22, 24};

Line(36) = {23, 25};
Line(37) = {24, 26};

//............................................
// Line Loops + Plane Surfaces

Line Loop(41) = {31, 35, -32, -34};
Plane Surface(42) = {41};

Line Loop(43) = {32, 37, -33, -36};
Plane Surface(44) = {43};

//============================================
//     PHYSICAL
//============================================

Physical Surface('ROCK_2D_I_LEFT')  = {42}; // LEFT subdomain
Physical Surface('ROCK_2D_I_RIGHT') = {44}; // RIGHT subdomain

If ( isFracBoundaryLEFT == 0 )
  Physical Line('.BC_2D_I_LEFT') = {31}; // Boundary on LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 0 )
  Physical Line('.BC_2D_I_RIGHT') = {33}; // Boundary on RIGHT subdomain
EndIf

//--------------------------------------------

If ( isFracMiddle == 1 )
  Physical Line('FRACTURE_2D_I') = {32}; // Fracture between LEFT and RIGHT subdomains
EndIf

If ( isFracBoundaryLEFT == 1 )
  Physical Line('FRACTURE_2D_I_LEFT') = {31}; // Fracture on boundary of LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 1 )
  Physical Line('FRACTURE_2D_I_RIGHT') = {33}; // Boundary on boundary of RIGHT subdomain
EndIf

// ########## End of file #########################

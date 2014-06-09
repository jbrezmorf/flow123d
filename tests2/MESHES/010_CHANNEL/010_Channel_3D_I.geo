// ########## Begin of file #######################

cl1 = ( Width_I +Height_I ) / ( 2*nLEFT );
cl2 = ( Width_I +Height_I ) / ( 2*nLR );
cl3 = ( Width_I +Height_I ) / ( 2*nRIGHT );

//--------------------------------------------
// Points

Point(101) = { 0,                     Offset_3D_I, -Height_I/2,   cl1};
Point(102) = { 0,            Width_I +Offset_3D_I, -Height_I/2,   cl1/3.0};

Point(103) = { Lleft,                 Offset_3D_I, -Height_I/2,   cl2/3.0};
Point(104) = { Lleft,        Width_I +Offset_3D_I, -Height_I/2,   cl2};

Point(105) = { Lleft+Lright,          Offset_3D_I, -Height_I/2,   cl3};
Point(106) = { Lleft+Lright, Width_I +Offset_3D_I, -Height_I/2,   cl3/3.0};

// ---------- First rotation ----------
Rotate {{Fx,Fy,Fz},    {0,0,0},   FAngle } {
  Point{101};
  Point{102};
  Point{103};
  Point{104};
  Point{105};
  Point{106};
}

// ----------- Second rotation ----------
Rotate {{Sx,Sy,Sz},    {0,0,0},   SAngle } {
  Point{101};
  Point{102};
  Point{103};
  Point{104};
  Point{105};
  Point{106};
}

//--------------------------------------------
// Lines

Line(111) = {101, 103};
Line(112) = {103, 105};
Line(113) = {105, 106};
Line(114) = {106, 104};
Line(115) = {104, 102};
Line(116) = {102, 101};

Line(117) = {103, 104};

//--------------------------------------------
// Line Loops + Plane Surfaces

Line Loop(121) = {111, 117, 115, 116};
Plane Surface(122) = {121};

Line Loop(123) = {112, 113, 114, -117};
Plane Surface(124) = {123};

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

ext11[] = Extrude {0, 0, Height_I} {
  Surface{122};
};

ext12[] = Extrude {0, 0, Height_I} {
  Surface{124};
};

//============================================
//     PHYSICAL
//============================================

Physical Volume('ROCK_3D_I_LEFT')  = {ext11[1]}; // LEFT subdomain
Physical Volume('ROCK_3D_I_RIGHT') = {ext12[1]}; // RIGHT subdomain

If ( isFracBoundaryLEFT == 0 )
  Physical Surface('.BC_3D_I_LEFT') = {ext11[5]}; // Boundary on LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 0 )
  Physical Surface('.BC_3D_I_RIGHT') = {ext12[3]}; // Boundary on RIGHT subdomain
EndIf

//--------------------------------------------

If ( isFracMiddle == 1 )
  Physical Surface('FRACTURE_3D_I') = {ext11[3]}; // Fracture between LEFT and RIGHT subdomains
EndIf

If ( isFracBoundaryLEFT == 1 )
  Physical Surface('FRACTURE_3D_I_LEFT') = {ext11[5]}; // Fracture on boundary of LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 1 )
  Physical Surface('FRACTURE_3D_I_RIGHT') = {ext12[3]}; // Boundary on boundary of RIGHT subdomain
EndIf

// ########## End of file #########################

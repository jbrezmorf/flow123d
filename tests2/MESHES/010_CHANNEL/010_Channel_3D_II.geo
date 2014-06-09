// ########## Begin of file #######################

cl1 = ( Width_II +Height_II ) / ( 2*nLEFT );
cl2 = ( Width_II +Height_II ) / ( 2*nLR );
cl3 = ( Width_II +Height_II ) / ( 2*nRIGHT );

//--------------------------------------------
// Points

Point(201) = { 0,                      Offset_3D_II, -Height_II/2,   cl1};
Point(202) = { 0,            Width_II +Offset_3D_II, -Height_II/2,   cl1/3.0};

Point(203) = { Lleft,                  Offset_3D_II, -Height_II/2,   cl2/3.0};
Point(204) = { Lleft,        Width_II +Offset_3D_II, -Height_II/2,   cl2};

Point(205) = { Lleft+Lright,           Offset_3D_II, -Height_II/2,   cl3};
Point(206) = { Lleft+Lright, Width_II +Offset_3D_II, -Height_II/2,   cl3/3.0};

// ---------- First rotation ----------
Rotate {{Fx,Fy,Fz},    {0,0,0},   FAngle } {
  Point{201};
  Point{202};
  Point{203};
  Point{204};
  Point{205};
  Point{206};
}

// ----------- Second rotation ----------
Rotate {{Sx,Sy,Sz},    {0,0,0},   SAngle } {
  Point{201};
  Point{202};
  Point{203};
  Point{204};
  Point{205};
  Point{206};
}

//--------------------------------------------
// Lines

Line(211) = {201, 203};
Line(212) = {203, 205};
Line(213) = {205, 206};
Line(214) = {206, 204};
Line(215) = {204, 202};
Line(216) = {202, 201};

Line(217) = {203, 204};

//--------------------------------------------
// Line Loops + Plane Surfaces

Line Loop(221) = {211, 217, 215, 216};
Plane Surface(222) = {221};

Line Loop(223) = {212, 213, 214, -217};
Plane Surface(224) = {223};

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

ext21[] = Extrude {0, 0, Height_II} {
  Surface{222};
};

ext22[] = Extrude {0, 0, Height_II} {
  Surface{224};
};

//============================================
//     PHYSICAL
//============================================


Physical Volume('ROCK_3D_II_LEFT')  = {ext21[1]}; // LEFT subdomain
Physical Volume('ROCK_3D_II_RIGHT') = {ext22[1]}; // RIGHT subdomain

If ( isFracBoundaryLEFT == 0 )
  Physical Surface('.BC_3D_II_LEFT') = {ext21[5]}; // Boundary on LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 0 )
  Physical Surface('.BC_3D_II_RIGHT') = {ext22[3]}; // Boundary on RIGHT subdomain
EndIf

//--------------------------------------------

If ( isFracMiddle == 1 )
  Physical Surface('FRACTURE_3D_II') = {ext21[3]}; // Fracture between LEFT and RIGHT subdomains
EndIf

If ( isFracBoundaryLEFT == 1 )
  Physical Surface('FRACTURE_3D_II_LEFT') = {ext21[5]}; // Fracture on boundary of LEFT subdomain
EndIf

If ( isFracBoundaryRIGHT == 1 )
  Physical Surface('FRACTURE_3D_II_RIGHT') = {ext22[3]}; // Boundary on boundary of RIGHT subdomain
EndIf

// ########## End of file #########################

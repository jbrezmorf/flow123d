// ########## Begin of file #######################

//Include "c_CLASSIC.cfg";

cl101 = ( Width -Width_hole ) / n1;
cl102 =          Width_hole   / n2;
cl103 = 2*Width               / n3;

//--------------------------------------------
// Points

Point(101) = { 0,                             Offset_3D_I, -Height/2,   cl101};
Point(102) = { L_hole,                        Offset_3D_I, -Height/2,   cl101};
Point(103) = { L,                             Offset_3D_I, -Height/2,   cl103};

Point(104) = { L,      Width                 +Offset_3D_I, -Height/2,   cl103};
Point(105) = { L_hole, Width                 +Offset_3D_I, -Height/2,   cl101};
Point(106) = { 0,      Width                 +Offset_3D_I, -Height/2,   cl101};

Point(107) = { 0,      Width/2 +Width_hole/2 +Offset_3D_I, -Height/2,   cl102};
Point(108) = { L_hole, Width/2 +Width_hole/2 +Offset_3D_I, -Height/2,   cl102};
Point(109) = { L_hole, Width/2 -Width_hole/2 +Offset_3D_I, -Height/2,   cl102};
Point(110) = { 0,      Width/2 -Width_hole/2 +Offset_3D_I, -Height/2,   cl102};

// ---------- First rotation ----------
Rotate {{Fx,Fy,Fz},    {0,0,0},   FAngle } {
  Point{101};
  Point{102};
  Point{103};
  Point{104};
  Point{105};
  Point{106};
  Point{107};
  Point{108};
  Point{109};
  Point{110};
}

// ----------- Second rotation ----------
Rotate {{Sx,Sy,Sz},    {0,0,0},   SAngle } {
  Point{101};
  Point{102};
  Point{103};
  Point{104};
  Point{105};
  Point{106};
  Point{107};
  Point{108};
  Point{109};
  Point{110};
}

//--------------------------------------------
// Lines

Line(111) = {101, 102};
Line(112) = {102, 103};
Line(113) = {103, 104};
Line(114) = {104, 105};
Line(115) = {105, 106};
Line(116) = {106, 107};
Line(117) = {110, 101};

Line(118) = {109, 102};
Line(119) = {108, 105};
Line(120) = {110, 109};
Line(121) = {109, 108};
Line(122) = {108, 107};
Line(123) = {107, 110};

//............................................
// Line Loops + Plane Surfaces

Line Loop(124) = {117, 111, -118, -120}; // rock LEFT DOWN
Plane Surface(125) = {124};

Line Loop(126) = {122, -116, -115, -119}; // rock LEFT UP
Plane Surface(127) = {126};

Line Loop(128) = {112, 113, 114, -119, -121, 118}; // rock RIGHT
Plane Surface(129) = {128};

Line Loop(130) = {120, 121, 122, 123}; // fracture
Plane Surface(131) = {130};

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

ext31[] = Extrude {0, 0, Height} { // rock LEFT DOWN
  Surface{125};
};
ext32[] = Extrude {0, 0, Height} { // rock LEFT UP
  Surface{127};
};
ext33[] = Extrude {0, 0, Height} { // Fracture
  Surface{131};
};
ext34[] = Extrude {0, 0, Height} { // rock RIGHT
  Surface{129};
};

//============================================
//     PHYSICAL
//============================================

Physical Volume('ROCK_3D_I_LEFT')  = {ext31[1],ext32[1]}; // Rock on LEFT
Physical Volume('FRACTURE_3D_I')   = {ext33[1]};          // Fracture
Physical Volume('ROCK_3D_I_RIGHT') = {ext34[1]};          // Rock on RIGHT

Physical Surface('.BCr_3D_I_LEFT') = {ext31[2],ext32[3]}; // Boundary on LEFT (rock)
Physical Surface('.BCf_3D_I_LEFT') = {ext33[5]};          // Boundary on LEFT (fracture)
Physical Surface('.BC_3D_I_RIGHT') = {ext34[3]};          // Boundary on RIGHT

// ########## End of file #########################

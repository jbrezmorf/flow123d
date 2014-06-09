// ########## Begin of file #######################

cl1 = W     / nA;
cl2 = Wfrac / nB;

//--------------------------------------------
// Points

Point(111) = { -L/2,                Offset_3D_I, 0,   cl1};
Point(112) = {  L/2,                Offset_3D_I, 0,   cl1};
Point(113) = {  L/2,             W +Offset_3D_I, 0,   cl1};
Point(114) = { -L/2,             W +Offset_3D_I, 0,   cl1};

Point(115) = { ( W/2)*Tan(aRad),    Offset_3D_I, 0,   cl2};
Point(116) = { (-W/2)*Tan(aRad), W +Offset_3D_I, 0,   cl2};

// ---------- First rotation ----------
Rotate {{Fx,Fy,Fz},    {0,0,0},   FAngle } {
  Point{111};
  Point{112};
  Point{113};
  Point{114};
  Point{115};
  Point{116};
}

// ----------- Second rotation ----------
Rotate {{Sx,Sy,Sz},    {0,0,0},   SAngle } {
  Point{111};
  Point{112};
  Point{113};
  Point{114};
  Point{115};
  Point{116};
}

//--------------------------------------------
// Lines

Line(121) = {111, 115};
Line(122) = {115, 112};
Line(123) = {112, 113};
Line(124) = {113, 116};
Line(125) = {116, 114};
Line(126) = {114, 111};

Line(127) = {115, 116};

//............................................
// Line Loops + Plane Surfaces

Line Loop(131) = {121, 127, 125, 126};
Plane Surface(132) = {131};
Line Loop(133) = {122, 123, 124, -127};
Plane Surface(134) = {133};

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

ext11[] = Extrude {0, 0, H} {
  Surface{132};
};
ext12[] = Extrude {0, 0, H} {
  Surface{134};
};

//============================================
//     PHYSICAL
//============================================

Physical Volume('ROCK_3D_I')       = {ext11[1],ext12[1]}; // Rock
Physical Surface('FRACTURE_3D_I')  = {147};    // Fracture

Physical Surface('.BC_3D_I_LEFT')  = {155}; // Boundary on LEFT
Physical Surface('.BC_3D_I_RIGHT') = {169}; // Boundary on RIGHT

// ########## End of file #########################


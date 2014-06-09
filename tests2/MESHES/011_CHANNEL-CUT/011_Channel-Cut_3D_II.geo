// ########## Begin of file #######################

cl1 = W     / nA;
cl2 = Wfrac / nB;

//--------------------------------------------
// Points

Point(211) = { -L/2            -Wfrac/(2.0*Cos(aRad)),    Offset_3D_II, 0,   cl1};
Point(212) = {  L/2            +Wfrac/(2.0*Cos(aRad)),    Offset_3D_II, 0,   cl1};
Point(213) = {  L/2            +Wfrac/(2.0*Cos(aRad)), W +Offset_3D_II, 0,   cl1};
Point(214) = { -L/2            -Wfrac/(2.0*Cos(aRad)), W +Offset_3D_II, 0,   cl1};

Point(215) = { ( W/2)*Tan(aRad)-Wfrac/(2.0*Cos(aRad)),    Offset_3D_II, 0,   cl2};
Point(216) = { (-W/2)*Tan(aRad)-Wfrac/(2.0*Cos(aRad)), W +Offset_3D_II, 0,   cl2};

Point(217) = { ( W/2)*Tan(aRad)+Wfrac/(2.0*Cos(aRad)),    Offset_3D_II, 0,   cl2};
Point(218) = { (-W/2)*Tan(aRad)+Wfrac/(2.0*Cos(aRad)), W +Offset_3D_II, 0,   cl2};

// ---------- First rotation ----------
Rotate {{Fx,Fy,Fz},    {0,0,0},   FAngle } {
  Point{211};
  Point{212};
  Point{213};
  Point{214};
  Point{215};
  Point{216};
  Point{217};
  Point{218};
}

// ----------- Second rotation ----------
Rotate {{Sx,Sy,Sz},    {0,0,0},   SAngle } {
  Point{211};
  Point{212};
  Point{213};
  Point{214};
  Point{215};
  Point{216};
  Point{217};
  Point{218};
}

//--------------------------------------------
// Lines

Line(221) = {211, 215};
Line(222) = {217, 212};
Line(223) = {212, 213};
Line(224) = {213, 218};
Line(225) = {216, 214};
Line(226) = {214, 211};

Line(227) = {215, 217};
Line(228) = {216, 218};
Line(229) = {215, 216};
Line(230) = {217, 218};

//............................................
// Line Loops + Plane Surfaces

Line Loop(231) = {221, 229, 225, 226};
Plane Surface(232) = {231};
Line Loop(233) = {222, 223, 224, -230};
Plane Surface(234) = {233};

Line Loop(235) = {227, 230, -228, -229};
Plane Surface(236) = {235};

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

ext21[] = Extrude {0, 0, H} {
  Surface{232};
};
ext22[] = Extrude {0, 0, H} {
  Surface{234};
};
ext23[] = Extrude {0, 0, H} {
  Surface{236};
};

//============================================
//     PHYSICAL
//============================================

Physical Volume('ROCK_3D_II')     = {ext21[1],ext22[1]}; // Rock
Physical Volume('FRACTURE_3D_II') = {ext23[1]}; // Fracture

Physical Surface('.BC_3D_II_LEFT')  = {257}; // Boundary on LEFT
Physical Surface('.BC_3D_II_RIGHT') = {271}; // Boundary on RIGHT

// ########## End of file #########################


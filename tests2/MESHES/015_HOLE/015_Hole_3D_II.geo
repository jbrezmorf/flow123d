// ########## Begin of file #######################

//Include "c_CLASSIC.cfg";

cl301 = ( Width -Width_hole ) / n1;
cl302 =          Width_hole   / n2;
cl303 = 2*Width               / n3;

//--------------------------------------------
// Points

Point(301) = { 0,                 Offset_3D_II, -Height/2,   cl301};
Point(302) = { L_hole,            Offset_3D_II, -Height/2,   cl301};
Point(303) = { L,                 Offset_3D_II, -Height/2,   cl303};

Point(304) = { L,        Width   +Offset_3D_II, -Height/2,   cl303};
Point(305) = { L_hole,   Width   +Offset_3D_II, -Height/2,   cl301};
Point(306) = { 0,        Width   +Offset_3D_II, -Height/2,   cl301};

Point(307) = { 0,        Width/2 +Offset_3D_II, -Height/2,   cl302};
Point(308) = { L_hole,   Width/2 +Offset_3D_II, -Height/2,   cl302};

// ---------- First rotation ----------
Rotate {{Fx,Fy,Fz},    {0,0,0},   FAngle } {
  Point{301};
  Point{302};
  Point{303};
  Point{304};
  Point{305};
  Point{306};
  Point{307};
  Point{308};
}

// ----------- Second rotation ----------
Rotate {{Sx,Sy,Sz},    {0,0,0},   SAngle } {
  Point{301};
  Point{302};
  Point{303};
  Point{304};
  Point{305};
  Point{306};
  Point{307};
  Point{308};
}

//--------------------------------------------
// Lines

Line(311) = {301, 302};
Line(312) = {302, 303};
Line(313) = {303, 304};
Line(314) = {304, 305};
Line(315) = {305, 306};
Line(316) = {306, 307};
Line(317) = {307, 301};

Line(318) = {308, 302};
Line(319) = {308, 305};
Line(320) = {308, 307};

//............................................
// Line Loops + Plane Surfaces

Line Loop(321) = {317, 311, -318, 320}; // rock LEFT DOWN
Plane Surface(322) = {321};

Line Loop(323) = {320, -316, -315, -319}; // rock LEFT UP
Plane Surface(324) = {323};

Line Loop(325) = {312, 313, 314, -319, 318}; // rock RIGHT
Plane Surface(326) = {325};

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

ext41[] = Extrude {0, 0, Height} { // rock LEFT DOWN
  Surface{322};
};
ext42[] = Extrude {0, 0, Height} { // rock LEFT UP
  Surface{324};
};
ext43[] = Extrude {0, 0, Height} { // rock RIGHT
  Surface{326};
};

//============================================
//     PHYSICAL
//============================================

Physical Volume('ROCK_3D_II_LEFT')  = {ext41[1],ext42[1]}; // Rock on LEFT
Physical Surface('FRACTURE_3D_II')  = {ext41[5]};          // Fracture
Physical Volume('ROCK_3D_II_RIGHT') = {ext43[1]};          // Rock on RIGHT

Physical Surface('.BCr_3D_II_LEFT') = {ext41[2],ext42[3]}; // Boundary on LEFT (rock)
Physical Line(   '.BCf_3D_II_LEFT') = {333};               // Boundary on LEFT (fracture)
Physical Surface('.BC_3D_II_RIGHT') = {ext43[3]};          // Boundary on RIGHT

// ########## End of file #########################

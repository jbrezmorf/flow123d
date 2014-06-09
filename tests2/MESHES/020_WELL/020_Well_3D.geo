// ########## Begin of file #######################

Include "c_CLASSIC.cfg";

//--------------------------------
clIn    =   rIn  / dParam;
clMid   =   rMid / dParam;
clOut   =   rOut / dParam;
angleRad = Pi * angleDg / 180.0;

//--------------------------------
// Points

Point(51) = { rIn,  Offset_3D, 0,   clIn};
Point(52) = { rMid, Offset_3D, 0,   clMid};
Point(53) = { rOut, Offset_3D, 0,   clOut};

//--------------------------------
// Lines + Arcs

Line(55) = {51, 52};
Line(56) = {52, 53};

//--------------------------------
// Extrude SURFACE

If ( isFull == 1 )
   angleRad = Pi / 2.0;
EndIf

/*
   The list ext[] contains all geometric entities created by extrusion:
   ext[0] -- line created by translating MAIN line
   ext[1] -- surface crated by sweeping MAIN line
   ext[2] -- line created by extruding point 1 of MAIN line
   ext[3] -- line created by extruding point 2 of MAIN line
*/

ext111[] = Extrude {{0, 0, 1}, {0, Offset_3D, 0}, angleRad} {
  Line{55};
};
ext112[] = Extrude {{0, 0, 1}, {0, Offset_3D, 0}, angleRad} {
  Line{56};
};

If ( isFull == 1 )
  ext121[] = Extrude {{0, 0, 1}, {0, Offset_3D, 0}, angleRad} {
    Line{ext111[0]};
  };
  ext122[] = Extrude {{0, 0, 1}, {0, Offset_3D, 0}, angleRad} {
    Line{ext112[0]};
  };

  ext131[] = Extrude {{0, 0, 1}, {0, Offset_3D, 0}, angleRad} {
    Line{ext121[0]};
  };
  ext132[] = Extrude {{0, 0, 1}, {0, Offset_3D, 0}, angleRad} {
    Line{ext122[0]};
  };

  ext141[] = Extrude {{0, 0, 1}, {0, Offset_3D, 0}, angleRad} {
    Line{ext131[0]};
  };
  ext142[] = Extrude {{0, 0, 1}, {0, Offset_3D, 0}, angleRad} {
    Line{ext132[0]};
  };
EndIf

//--------------------------------
// Extrude VOLUME

/*
   The list ext[] contains all geometric entities created by extrusion:
   ext[0] -- surface created by translating MAIN surface
   ext[1] -- volume crated by sweeping MAIN surface
   ext[2] -- surface created by extruding line 1 of MAIN surface
   ext[3] -- surface created by extruding line 2 of MAIN surface
   ext[i] -- surface created by extruding line i of MAIN surface
*/

ext211[] = Extrude {0, 0, H} {
  Surface{ext111[1]};
};
ext212[] = Extrude {0, 0, H} {
  Surface{ext112[1]};
};

If ( isFull == 1 )
  ext221[] = Extrude {0, 0, H} {
    Surface{ext121[1]};
  };
  ext222[] = Extrude {0, 0, H} {
    Surface{ext122[1]};
  };

  ext231[] = Extrude {0, 0, H} {
    Surface{ext131[1]};
  };
  ext232[] = Extrude {0, 0, H} {
    Surface{ext132[1]};
  };

  ext241[] = Extrude {0, 0, H} {
    Surface{ext141[1]};
  };
  ext242[] = Extrude {0, 0, H} {
    Surface{ext142[1]};
  };
EndIf

//============================================
//     PHYSICAL
//============================================

If ( isFull == 0 )
  Physical Volume("ROCK_3D_IN")      = {ext211[1]};
  Physical Volume("ROCK_3D_OUT")     = {ext212[1]};
  If ( isFracture == 1 )
    Physical Surface("FRACTURE_3D")    = {ext211[3]};
  EndIf

  Physical Surface(".BC_3D_INSIDE")  = {ext211[5]}; // Side in well
  Physical Surface(".BC_3D_OUTSIDE") = {ext212[3]}; // Outside
  Physical Surface(".BC_3D_TOP")     = {ext211[0],ext212[0]}; // Surface of domain
EndIf

If ( isFull == 1 )
  Physical Volume("ROCK_3D_IN")      = {ext211[1],ext221[1],ext231[1],ext241[1]};
  Physical Volume("ROCK_3D_OUT")     = {ext212[1],ext222[1],ext232[1],ext242[1]};
  If ( isFracture == 1 )
    Physical Surface("FRACTURE_3D")    = {ext211[3],ext221[3],ext231[3],ext241[3]};
  EndIf

  Physical Surface(".BC_3D_INSIDE")  = {ext211[5],ext221[5],ext231[5],ext241[5]}; // Side in well
  Physical Surface(".BC_3D_OUTSIDE") = {ext212[3],ext222[3],ext232[3],ext242[3]}; // Outside
  Physical Surface(".BC_3D_TOP")     = {ext211[0],ext212[0], ext221[0],ext222[0], ext231[0],ext232[0], ext241[0],ext242[0]}; // Surface of domain
EndIf

// ########## End of file #########################

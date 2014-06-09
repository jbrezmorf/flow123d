// ########## Begin of file #######################

//Include "c_CLASSIC.cfg";

//--------------------------------
clIn    =   rIn  / dParam;
clMid   =   rMid / dParam;
clOut   =   rOut / dParam;
angleRad = Pi * angleDg / 180.0;

//--------------------------------
// Points

Point( 1) = { rIn,  Offset_2D, 0,   clIn};
Point( 2) = { rMid, Offset_2D, 0,   clMid};
Point( 3) = { rOut, Offset_2D, 0,   clOut};

//--------------------------------
// Lines + Arcs

Line(5) = {1, 2};
Line(6) = {2, 3};

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

ext111[] = Extrude {{0, 0, 1}, {0, Offset_2D, 0}, angleRad} {
  Line{5};
};
ext112[] = Extrude {{0, 0, 1}, {0, Offset_2D, 0}, angleRad} {
  Line{6};
};

If ( isFull == 1 )
  ext121[] = Extrude {{0, 0, 1}, {0, Offset_2D, 0}, angleRad} {
    Line{ext111[0]};
  };
  ext122[] = Extrude {{0, 0, 1}, {0, Offset_2D, 0}, angleRad} {
    Line{ext112[0]};
  };

  ext131[] = Extrude {{0, 0, 1}, {0, Offset_2D, 0}, angleRad} {
    Line{ext121[0]};
  };
  ext132[] = Extrude {{0, 0, 1}, {0, Offset_2D, 0}, angleRad} {
    Line{ext122[0]};
  };

  ext141[] = Extrude {{0, 0, 1}, {0, Offset_2D, 0}, angleRad} {
    Line{ext131[0]};
  };
  ext142[] = Extrude {{0, 0, 1}, {0, Offset_2D, 0}, angleRad} {
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

//============================================
//     PHYSICAL
//============================================

If ( isFull == 0 )
  Physical Surface("ROCK_2D_IN")  = {ext111[1]};
  Physical Surface("ROCK_2D_OUT") = {ext112[1]};
  If ( isFracture == 1 )
    Physical Line("FRACTURE_2D")    = {ext111[2]};
  EndIf

  Physical Line(".BC_2D_INSIDE")  = {ext111[3]}; // Side in well
  Physical Line(".BC_2D_OUTSIDE") = {ext112[2]}; // Outside
  If ( isTopSurface == 1 )
    Physical Surface(".BC_2D_TOP")  = {ext111[1],ext112[1]}; // Surface of domain
  EndIf
EndIf

If ( isFull == 1 )
  Physical Surface("ROCK_2D_IN")  = {ext111[1],ext121[1],ext131[1],ext141[1]};
  Physical Surface("ROCK_2D_OUT") = {ext112[1],ext122[1],ext132[1],ext142[1]};
  If ( isFracture == 1 )
    Physical Line("FRACTURE_2D")    = {ext111[2],ext121[2],ext131[2],ext141[2]};
  EndIf

  Physical Line(".BC_2D_INSIDE")  = {ext111[3],ext121[3],ext131[3],ext141[3]}; // Side in well
  Physical Line(".BC_2D_OUTSIDE") = {ext112[2],ext122[2],ext132[2],ext142[2]}; // Outside
  If ( isTopSurface == 1 )
    Physical Surface(".BC_2D_TOP")  = {ext111[1],ext112[1], ext121[1],ext122[1], ext131[1],ext132[1], ext141[1],ext142[1]}; // Surface of domain
  EndIf
EndIf

// ########## End of file #########################

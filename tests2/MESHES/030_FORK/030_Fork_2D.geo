
Lf      =  8.0;
Lr      =  5.0;
W       =  1.0;
alfaDec = 10.0;
dParam  = 10;
//--------------------------------
dLf     = Lf / dParam;
dLr     = Lr / dParam;
dL      = ( dLf + dLr ) / 2.0;

alfaRad =  Pi * alfaDec / 180.0;

//--------------------------------
// Points

Point( 1) = {  0, 0, 0,   dL};

Point( 2) = {  W/2*Sin(alfaRad), -W/2, 0,   dL};

Point( 3) = {  Lr, -W/2, 0,   dLr};
Point( 4) = {  Lr,  W/2, 0,   dLr};

Point( 5) = {  W/2*Sin(alfaRad),  W/2, 0,   dL};

Point( 6) = { ( -Lf*Cos(alfaRad) +W/2*Sin(alfaRad) ), (  Lf*Sin(alfaRad) +W/2*Cos(alfaRad) ), 0,   dLf};
Point( 7) = { ( -Lf*Cos(alfaRad) -W/2*Sin(alfaRad) ), (  Lf*Sin(alfaRad) -W/2*Cos(alfaRad) ), 0,   dLf};

Point( 8) = { ( -W/(2*Sin(alfaRad))), 0, 0,   dL};

Point( 9) = { ( -Lf*Cos(alfaRad) -W/2*Sin(alfaRad) ), ( -Lf*Sin(alfaRad) +W/2*Cos(alfaRad) ), 0,   dLf};
Point(10) = { ( -Lf*Cos(alfaRad) +W/2*Sin(alfaRad) ), ( -Lf*Sin(alfaRad) -W/2*Cos(alfaRad) ), 0,   dLf};

//--------------------------------
// Lines + Arcs

Line( 1) = {  2,  3};
Line( 2) = {  3,  4};
Line( 3) = {  4,  5};

Line( 4) = {  5,  6};
Line( 5) = {  6,  7};
Line( 6) = {  7,  8};

Line( 7) = {  8,  9};
Line( 8) = {  9, 10};
Line( 9) = { 10,  2};

Line(10) = {  1,  2};
Line(11) = {  1,  5};
Line(12) = {  1,  8};

//--------------------------------
// Line Loops + Plane Surfaces

Line Loop(101) = {1, 2, 3, -11, 10};
Plane Surface(201) = {101};

Line Loop(102) = {4, 5, 6, -12, 11};
Plane Surface(202) = {102};

Line Loop(103) = {7, 8, 9, -10, 12};
Plane Surface(203) = {103};

//--------------------------------
// PHYSICAL
//--------------------------------

Physical Surface("ROCK_A") = {201};
Physical Surface("ROCK_B") = {202};
Physical Surface("ROCK_C") = {203};

Physical Line(".A")     = {2}; // Left
Physical Line(".B")     = {5}; // Right-Top
Physical Line(".C")     = {8}; // Right-Bottom



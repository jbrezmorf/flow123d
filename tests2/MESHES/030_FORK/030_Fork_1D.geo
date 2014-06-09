
Lf      =  8.0;
Lr      =  5.0;
alfaDec = 30.0;
dParam  = 10;
//--------------------------------
dLf     = Lf / dParam;
dLr     = Lr / dParam;
dL      = ( dLf * dLr ) / 2.0;

alfaRad =  Pi * alfaDec / 180.0;

//--------------------------------
// Points

Point(1) = {  0,                0,               0,   dL};
Point(2) = {  Lr,               0,               0,   dLf};
Point(3) = { -Lf*Cos(alfaRad),  Lf*Sin(alfaRad), 0,   dLr};
Point(4) = { -Lf*Cos(alfaRad), -Lf*Sin(alfaRad), 0,   dLr};

//--------------------------------
// Lines

Line(1) = {1, 2};
Line(2) = {1, 3};
Line(3) = {1, 4};

//--------------------------------
// PHYSICAL
//--------------------------------

Physical Line("ROCK_A") = {1};
Physical Line("ROCK_B") = {2};
Physical Line("ROCK_C") = {3};

Physical Point(".A") = {2}; // Right
Physical Point(".B") = {3}; // Left-Top
Physical Point(".C") = {4}; // Left-Bottom



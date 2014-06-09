
L      =  5.5;
dParam = 10;
//--------------------------------
diff   = L / dParam;

//--------------------------------
// Points

Point( 1) = {  0,  0, 0,   diff};
Point( 2) = {  L,  0, 0,   diff};
Point( 3) = {  0,  L, 0,   diff};
Point( 4) = { -L,  0, 0,   diff};
Point( 5) = {  0, -L, 0,   diff};

//--------------------------------
// Lines

Line(1) = {1, 2};
Line(2) = {1, 3};
Line(3) = {1, 4};
Line(4) = {1, 5};

//--------------------------------
// PHYSICAL
//--------------------------------

Physical Line("ROCK_A") = {1};
Physical Line("ROCK_B") = {2};
Physical Line("ROCK_C") = {3};
Physical Line("ROCK_D") = {4};

Physical Point(".A") = {2}; // Right
Physical Point(".B") = {3}; // Top
Physical Point(".C") = {4}; // Left
Physical Point(".D") = {5}; // Bottom



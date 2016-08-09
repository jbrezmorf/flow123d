# FLOW123D EXAMPLES
## 1. Example 1 – “column 1D”
The first example is inspirited a real locality of a water treatment plant tunnel Bedřichov in the granite rock massif. There is the particular seepage site 23 m under the surface and it has very fast reaction on rainfall events. Real data of discharge and concentration of stable isotopes are used.

### 1.1    Geometry and boundary conditions
It is considered a pseudo one-dimensional model in the range 10 × 23 m of the atmospheric pressure on the surface and on the bottom and no flow boundary condition on the edges (Figure 1a).

![alt text](http://bacula.nti.tul.cz/~ales.balvin/ex1_mesh_bc_flux.png)


Figure 1: a) the geometry; b) the boundary condition of the example 1. c) Results of piezometric head and flux in gmsh software from file ex_1-flux.msh.

## 1.2    Flux field computation
### 1.2.2    Set of model mesh
In control file is important a sensitive of spaces from beginning of row. It is mandatory to hang the structure of spaces in control file (“flow_gmsh_flux.yaml”). The spaces divide section of problem setting.
Mesh file comes from "./input" folder.   

    mesh:
      mesh_file: ./input/mesh_ex1.msh

In this example we solve problem in Darcy flow and it is set at row-file 12 in “flow_gmsh_flux.yaml”.
    
    flow_equation: !Flow_Darcy_MH

NOTE:
The software Flow123d creates new folder for all results which consist from controlling file and appendix ".out". 

### 1.2.2    Set of model parameters
For the rock massif ("- region: rock") we prescribed the hydraulic conductivity K = 1e-8 m/s. This value is typical for the granite rock massif. The cross-section parameter is set on the 1 m width.

Code illustration: prescription of hydraulic parameters input_fields in “flow_gmsh_flux.yaml”: 

    input_fields:
      - region: rock
        conductivity: 1e-8
        cross_section: 1
      - region: .tunnel
        bc_type: total_flux
        bc_flux: 6.34E-09
      - region: .surface
        bc_type: total_flux
        bc_flux: 6.34E-09

### 1.2.3    Results
The results of computation are in the file “water_balance.txt”. The input flux on the surface is 1 × 10-7 and the output flux on the tunnel is -1 × 10-7 (Table 1).

Table 1: Results in “water_balanced.txt” (edited table, no whole file).
"time"|    "region"|    "quantity [m(3)]"|    "flux"|    "flux_in"|    "flux_out"|
----|-----------|-------------|-----|----------|------------|
0|    "rock"|    "water_volume"|    0|    0|    0|
0|    ".surface"|    "water_volume"|    1e-07|    1e-07|    0|
0|    ".tunnel"|    "water_volume"|    -1e-07|    0|    -1e-07|
0|    "IMPLICIT BOUNDARY"|    "water_volume"|    2.58e-26|    6.46e-26|    -3.87e-26|

### 1.3    Variants
In the main YAML file we can change some parameters for an investigation of the model behaviour.
### 1.3.1    Infiltration
First we change the atmospheric pressure on the surface to the more realistic infiltration 200 mm/yr (= 6.34e-9 m/s).

Code illustration: prescription of the flux on the surface from "flow_gmsh_infiltration.yaml”:

      - region: .surface
        bc_type: dirichlet
        bc_pressure: 0


The results are in the file “water_balanced.txt” again. We can see that the value of the input and output flux changed to 6.34e-8. The visual results are similar to the 


## 1.3.2    Transport model
The numerical diffusion is used for this example. The ordering equation is set at row 38 and 39 “flow_gmsh_flux.yaml”:

    solute_equation: !Coupling_OperatorSplitting
      transport: !Solute_Advection_FV


The boundary condition of concentration is prescribed on the surface region (rows 40-43). The input concentration is set as relative concentration 100%. Code illustration from "flow_gmsh_infiltration.yaml” is:

    input_fields:
      - region: .surface
        bc_conc: !FieldFormula
          value: 100

The name of substance was "O-18" for this example from "flow_gmsh_infiltration.yaml”:

    substances:
      - O-18

The output time step of printout was set in section output_stream on value 1e7 second (=3.8 months) in "flow_gmsh_infiltration.yaml”:

    output_stream:
      time_step: 1e7

And the end time of simulation was set in section time on value 1e10 second (381 years) in "flow_gmsh_infiltration.yaml”:
 
    time:
      end_time: 1e10


## 1.3.2    Transport model - results
The balanced results of the transport computation are in the output folder in the file "mass_balance.txt". The concentration is depicted on the Figure 2. Through the “.surface”, the concentration is still identical (6 × 10-6). Through the based marked “.tunnel”, the concentration is zero at the beginning and then is changed around 100 years to the opposite value of inflow -6 × 10-6. The selected part of numerical results of mass is in the Table 2. The figure 3 depicts results from file "mass_balance.txt" for mass transported through the boundaries ".surface" and ".tunnel" and in the volume of model "rock".

Note:
Each model boundary is mandatory to assign with dot in a mesh file: ".surface". 

 
![alt text](http://bacula.nti.tul.cz/~ales.balvin/transport.png "Results of transport")
Figure 2: Results of transport from “mass_balance.txt”.

Table 2: Illustration of the results in “water_balanced.txt” – selected column in two time steps (edited table, no whole file).
time|    region    |quantity [kg]|    flux|    flux_in|    flux_out|    mass|    error
----|-----------|-------------|-----|----------|------------|-------|--------
3.96E+09|    rock|    A|    0|    0|    0|    22544.1|    0|
3.96E+09|    .surface|    A|    6.34E-06|    6.34E-06|    0|    0|    0|
3.96E+09|    .tunnel|    A|    -4.88E-06|    0|    -4.88E-06|    0|    0|
3.96E+09|    IMPLICIT BOUNDARY|    A|    -1.02E-19|    0|    -1.02E-19|    0|    0|
3.96E+09|    ALL|    A|    1.46E-06|    6.34E-06|    -4.88E-06|    22544.1|    -7.39E-10|
3.97E+09|    rock|    A|    0|    0|    0|    22558.7|    0|
3.97E+09|    .surface|    A|    6.34E-06|    6.34E-06|    0|    0|    0|
3.97E+09|    .tunnel|    A|    -4.92E-06|    0|    -4.92E-06|    0|    0|
3.97E+09|    IMPLICIT BOUNDARY|    A|    -1.02E-19|    0|    -1.02E-19|    0|    0|
3.97E+09|    ALL|    A|    1.42E-06|    6.34E-06|    -4.92E-06|    22558.7|    -7.53E-10|

![alt text](http://bacula.nti.tul.cz/~ales.balvin/ex1_curves_of_transport.png "Results of transport")
Figure 3: Results of transport in four time moments (1 time step = 3.8 months)

## 1.4    Conclusion
On the naive two-dimensional model the hydraulic and the transport model computation was shown. 
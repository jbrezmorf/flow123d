#!/bin/bash	

menu() {
  echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
  echo "┃         FLOW123d - mesh generator         ┃"
  echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
  echo "  Mesh: $mesh"
  echo "  Specification: $spec"
  echo "┌───────────────────────────────────────────┐"
  echo "│ Meshes                                    │"
  echo "│   1) 010_Channel_1D_I                     │"
  echo "│   2) 010_Channel_1D_II                    │"
  echo "│   3) 010_Channel_2D_I                     │"
  echo "│   4) 010_Channel_2D_II                    │"
  echo "│   5) 010_Channel_3D_I                     │"
  echo "│   6) 010_Channel_3D_II                    │"
  echo "│   X) 010_Channel_COMPLETE                 │"
  echo "├───────────────────────────────────────────┤"
  echo "│ Specification                             │"
  echo "│   A) c_CLASSIC                            │"
  echo "│   B) c_CLASSIC_rot                        │"
  echo "│   C) c_FRACTURE                           │"
  echo "├───────────────────────────────────────────┤"
  echo "│   !) GENERATE                             │"
  echo "│   Q) QUIT                                 │"
  echo "└───────────────────────────────────────────┘"
}

mesh="010_Channel_COMPLETE"
spec="c_CLASSIC"

en=""

while [ true ];
do
  menu
  read   -p "Enter your choice: "   -n 1   en
  echo
  
  case "$en" in
    1) mesh="010_Channel_1D_I" ;;
    2) mesh="010_Channel_1D_II" ;;
    3) mesh="010_Channel_2D_I" ;;
    4) mesh="010_Channel_2D_II" ;;
    5) mesh="010_Channel_3D_I" ;;
    6) mesh="010_Channel_3D_II" ;;
    7) mesh="010_Channel_COMPLETE" ;;

    a) spec="c_CLASSIC" ;;
    A) spec="c_CLASSIC" ;;

    b) spec="c_CLASSIC_rot" ;;
    B) spec="c_CLASSIC_rot" ;;

    c) spec="c_FRACTURE" ;;
    C) spec="c_FRACTURE" ;;

    !) gmsh   -3   -merge $spec.cfg $mesh.geo   -o ../$mesh.msh ;;

    q) echo "  Good Bye ..."
       sleep 2
       break
       ;;
    Q) echo "  Good Bye ..."
       sleep 2
       break
       ;;
    *) echo
       echo "*********************************************"
       echo "*****     Wrong Option '$en' selected     *****"
       echo "*********************************************"
       ;;
  esac
done


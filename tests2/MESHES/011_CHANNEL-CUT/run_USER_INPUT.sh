#!/bin/bash	

menu() {
  echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
  echo "┃         FLOW123d - mesh generator         ┃"
  echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
  echo "  Mesh: $mesh"
  echo "  Specification: $spec"
  echo "┌───────────────────────────────────────────┐"
  echo "│ Meshes                                    │"
  echo "│   3) 011_Channel-Cut_2D_I                 │"
  echo "│   4) 011_Channel-Cut_2D_II                │"
  echo "│   5) 011_Channel-Cut_3D_I                 │"
  echo "│   6) 011_Channel-Cut_3D_II                │"
  echo "│   X) 011_Channel-Cut_COMPLETE             │"
  echo "├───────────────────────────────────────────┤"
  echo "│ Specification                             │"
  echo "│   A) c_CLASSIC                            │"
  echo "│   B) not yet          - (c_CLASSIC_rot    │"
  echo "│   C) not yet          - (c_FRACTURE)      │"
  echo "├───────────────────────────────────────────┤"
  echo "│   !) GENERATE                             │"
  echo "│   Q) QUIT                                 │"
  echo "└───────────────────────────────────────────┘"
}

mesh="011_Channel-Cut_COMPLETE"
spec="c_CLASSIC"

en=""

while [ true ];
do
  menu
  read   -p "Enter your choice: "   -n 1   en
  echo
  
  case "$en" in
    3) mesh="011_Channel-Cut_2D_I" ;;
    4) mesh="011_Channel-Cut_2D_II" ;;
    5) mesh="011_Channel-Cut_3D_I" ;;
    6) mesh="011_Channel-Cut_3D_II" ;;
    7) mesh="011_Channel-Cut_COMPLETE" ;;

    a) spec="c_CLASSIC" ;;
    A) spec="c_CLASSIC" ;;

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


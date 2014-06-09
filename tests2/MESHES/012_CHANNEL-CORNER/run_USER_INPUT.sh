#!/bin/bash	

menu() {
  echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
  echo "┃         FLOW123d - mesh generator         ┃"
  echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
  echo "  Mesh: $mesh"
  echo "  Specification: $spec"
  echo "┌───────────────────────────────────────────┐"
  echo "│ Meshes                                    │"
  echo "│   1) 012_Channel-Corner_1D                │"
  echo "│   2) 012_Channel-Corner_2D                │"
  echo "│   3) 012_Channel-Corner_3D                │"
  echo "│   X) 012_Channel-Corner_COMPLETE          │"
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

mesh="012_Channel-Corner_COMPLETE"
spec="c_CLASSIC"

en=""

while [ true ];
do
  menu
  read   -p "Enter your choice: "   -n 1   en
  echo
  
  case "$en" in
    1) mesh="012_Channel-Corner_1D" ;;
    2) mesh="012_Channel-Corner_2D" ;;
    3) mesh="012_Channel-Corner_3D" ;;
    x) mesh="012_Channel-Corner_COMPLETE" ;;
    X) mesh="012_Channel-Corner_COMPLETE" ;;

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


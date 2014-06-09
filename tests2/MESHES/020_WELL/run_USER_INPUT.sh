#!/bin/bash	

menu() {
  echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
  echo "┃         FLOW123d - mesh generator         ┃"
  echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
  echo "  Mesh: $mesh"
  echo "  Specification: $spec"
  echo "┌───────────────────────────────────────────┐"
  echo "│ Meshes                                    │"
  echo "│   1) 020_Well_2D                          │"
  echo "│   2) 020_Well_3D                          │"
  echo "│   X) 020_Well_COMPLETE                    │"
  echo "├───────────────────────────────────────────┤"
  echo "│ Specification                             │"
  echo "│   A) c_CLASSIC                            │"
  echo "├───────────────────────────────────────────┤"
  echo "│   !) GENERATE                             │"
  echo "│   Q) QUIT                                 │"
  echo "└───────────────────────────────────────────┘"
}

mesh="020_Well_COMPLETE"
spec="c_CLASSIC"

en=""

while [ true ];
do
  menu
  read   -p "Enter your choice: "   -n 1   en
  echo
  
  case "$en" in
    1) mesh="020_Well_2D" ;;
    2) mesh="020_Well_3D" ;;
    x) mesh="020_Well_COMPLETE" ;;
    X) mesh="020_Well_COMPLETE" ;;

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


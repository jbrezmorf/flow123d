#include "simplex.h"
#include <iostream>
using namespace std;

void Simplex<0,3>::toString() {
	cout << "Simplex<0>: ";
	point.toString();
}
;
//doplnit instancie



/*template<int N> void Simplex<N,3>::setSimplex(
		Simplex<N - 1, 3> Simplex_n[N + 1]) {
	for (int i = 0; i < N + 1; i++) {
		Simplices[i] = Simplex_n[i];
	}
}
;

template <int N> void Simplex<N, 3>::toString() {
	for (int i = 0; i < N + 1; i++) {
		cout << "Simplex<" << N << ">";
		Simplices[i].toString();
	}
}
;*/
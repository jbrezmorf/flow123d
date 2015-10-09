#ifndef INTERSECTIONPOINT_H_
#define INTERSECTIONPOINT_H_

#include <armadillo>
#include <array>
#include "system/system.hh"
#include "refsimplex.h"

using namespace std;
namespace computeintersection{

//class ProlongationPoint;

/**
 * Class doc.
 * Naming convention.
 *
 * Have separate class template for IntersectionPoint as it appears at output
 * and other internal class template e.g. TriangleLineIntersection for internal
 * intersections with additional info.
 *
 * Describe data attributes.
 * 
 * TODO: 
 * - comment
 * - comment template parameters M,N
 * 
 */
template<int N, int M> class IntersectionPoint {

	arma::vec::fixed<N+1> local_coords1;
	arma::vec::fixed<M+1> local_coords2;

	int side_idx1;
	int side_idx2;

	unsigned int orientation;

	bool is_vertex_;
	bool is_patological_;

	public:

	inline IntersectionPoint(){
		clear();
	};
	inline IntersectionPoint(const arma::vec::fixed<N+1> &lc1,
					  const arma::vec::fixed<M+1> &lc2,
					  int side1 = -1,
					  int side2 = -1,
					  unsigned int ori = 1,
					  bool vertex = false,
					  bool patological = false)
					  : local_coords1(lc1),
					    local_coords2(lc2),
					    side_idx1(side1),
					    side_idx2(side2),
					    orientation(ori),
					    is_vertex_(vertex),
					    is_patological_(patological){};
	inline ~IntersectionPoint(){};

	inline void clear(){
		local_coords1.zeros();
		local_coords2.zeros();
		side_idx1 = -1;
		side_idx2 = -1;
		orientation = 1;
		is_vertex_ = false;
		is_patological_ = false;
	};

	inline void print(){
		cout << "Local coords on the first element on side(" << side_idx1 << ")" << endl;
		local_coords1.print();
		cout << "Local coords on the second element on side(" << side_idx2 << ")" << endl;
		local_coords2.print();
		cout << "Orientation: " << orientation << " Vertex: " << is_vertex_ << " Patological: " << is_patological_ << endl;
	};

	inline const arma::vec::fixed<N+1> &get_local_coords1() const{
		return local_coords1;
	};
	inline const arma::vec::fixed<M+1> &get_local_coords2() const{
		return local_coords2;
	};

	inline void set_side1(int s){
		side_idx1 = s;
	};

	inline void set_side2(int s){
		side_idx2 = s;
	};

	inline void set_orientation(unsigned int o){
		orientation = o;
	};

	inline void set_is_vertex(bool iv){
		is_vertex_ = iv;
	}

	inline void set_is_patological(bool ip){
		is_patological_ = ip;
	}

	inline int get_side1() const{
		return side_idx1;
	};

	inline int get_side2() const{
		return side_idx2;
	};

	inline unsigned int get_orientation() const{
		return orientation;
	};

	inline bool is_vertex() const{
		return is_vertex_;
	};

	inline bool is_patological() const{
		return is_patological_;
	};

	bool operator<(const IntersectionPoint<N,M> &ip) const;
};

/*class TriangleLineIntersections{

	int side_idx1;
	int side_idx2;

	unsigned int orientation;

	bool is_vertex;
	bool is_patological;
};*/

} // END namespace
#endif /* INTERSECTIONPOINT_H_ */

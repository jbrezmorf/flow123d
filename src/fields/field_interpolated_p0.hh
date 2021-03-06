/*!
 *
﻿ * Copyright (C) 2015 Technical University of Liberec.  All rights reserved.
 * 
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License version 3 as published by the
 * Free Software Foundation. (http://www.gnu.org/licenses/gpl-3.0.en.html)
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * 
 * @file    field_interpolated_p0.hh
 * @brief   
 */

#ifndef FIELD_INTERPOLATED_P0_HH_
#define FIELD_INTERPOLATED_P0_HH_

#include "field_algo_base.hh"
#include "mesh/mesh.h"
#include "mesh/mesh_types.hh"
#include "system/system.hh"
#include "mesh/msh_gmshreader.h"
#include "mesh/bih_tree.hh"
#include "mesh/ngh/include/ngh_interface.hh"
#include "input/factory.hh"


template <int spacedim, class Value>
class FieldInterpolatedP0: public FieldAlgorithmBase<spacedim, Value> {
public:

    typedef typename FieldAlgorithmBase<spacedim, Value>::Point Point;
    typedef FieldAlgorithmBase<spacedim, Value> FactoryBaseType;

	/**
	 * Constructor
	 */
	FieldInterpolatedP0(unsigned int n_comp=0);

	/**
	 * Declare Input type.
	 */
	static const Input::Type::Record & get_input_type();

	/**
	 * Initialization from the input interface.
	 */
	virtual void init_from_input(const Input::Record &rec, const struct FieldAlgoBaseInitData& init_data);

    /**
     * Update time and possibly update data from GMSH file.
     */
    bool set_time(const TimeStep &time) override;

    /**
     * Returns one value in one given point. ResultType can be used to avoid some costly calculation if the result is trivial.
     */
    virtual typename Value::return_type const &value(const Point &p, const ElementAccessor<spacedim> &elm);

    /**
     * Returns std::vector of scalar values in several points at once.
     */
    virtual void value_list(const std::vector< Point >  &point_list, const ElementAccessor<spacedim> &elm,
                       std::vector<typename Value::return_type>  &value_list);

protected:
    /// Multiply @p data_ with @p unit_conversion_coefficient_
    void scale_data();

    /// mesh, which is interpolated
	Mesh* source_mesh_;

	/// mesh reader file
	FilePath reader_file_;

    /// Raw buffer of n_entities rows each containing Value::size() doubles.
	std::shared_ptr< std::vector<typename Value::element_type> > data_;

	/// vector stored suspect elements in calculating the intersection
	std::vector<unsigned int> searched_elements_;

	/// field name read from input
	std::string field_name_;

	/// tree of mesh elements
	BIHTree* bih_tree_;

	/// stored index to last computed element
	unsigned int computed_elm_idx_ = numeric_limits<unsigned int>::max();

	/// stored flag if last computed element is boundary
	unsigned int computed_elm_boundary_;

	/// 3D (tetrahedron) element, used for computing intersection
	TTetrahedron tetrahedron_;

	/// 2D (triangle) element, used for computing intersection
	TTriangle triangle_;

	/// 1D (abscissa) element, used for computing intersection
	TAbscissa abscissa_;

	/// 0D (point) element, used for computing intersection
	TPoint point_;

private:
    /// Registrar of class to factory
    static const int registrar;

};



#endif /* FUNCTION_INTERPOLATED_P0_HH_ */

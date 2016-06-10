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
 * @file    output.cc
 * @brief   The functions for all outputs (methods of classes: Output and OutputTime).
 */

#include <string>

#include "system/sys_profiler.hh"
#include "mesh/mesh.h"
#include "input/accessors.hh"
#include "output_time.impl.hh"
#include "output_vtk.hh"
#include "output_msh.hh"
#include "output_mesh.hh"
#include <fields/field_set.hh>


FLOW123D_FORCE_LINK_IN_PARENT(vtk)
FLOW123D_FORCE_LINK_IN_PARENT(gmsh)


using namespace Input::Type;

const Record & OutputTime::get_input_type() {
    return Record("OutputStream", "Parameters of output.")
		// The stream
		.declare_key("file", FileName::output(), Default::obligatory(),
				"File path to the connected output file.")
				// The format
		.declare_key("format", OutputTime::get_input_format_type(), Default::optional(),
				"Format of output stream and possible parameters.")
		.declare_key("time_step", Double(0.0),
				"Time interval between outputs.\n"
				"Regular grid of output time points starts at the initial time of the equation and ends at the end time which must be specified.\n"
				"The start time and the end time are always added. ")
		.declare_key("time_list", Array(Double(0.0)),
				Default::read_time("List containing the initial time of the equation. \n You can prescribe an empty list to override this behavior."),
				"Explicit array of output time points (can be combined with 'time_step'.")
		.declare_key("add_input_times", Bool(), Default("false"),
				"Add all input time points of the equation, mentioned in the 'input_fields' list, also as the output points.")
        .declare_key("error_control_field",String(), Default::optional(), "Name of an output field, according to which the output mesh will be refined.")
		.close();
}


Abstract & OutputTime::get_input_format_type() {
	return Abstract("OutputTime", "Format of output stream and possible parameters.")
		.close();
}


OutputTime::OutputTime()
: _mesh(nullptr), output_mesh_(nullptr)
{}



OutputTime::OutputTime(const Input::Record &in_rec)
: current_step(0),
    time(-1.0),
    write_time(-1.0),
    input_record_(in_rec),
    _mesh(nullptr), 
    output_mesh_(nullptr),
    is_output_mesh_valid_(false)
{
    // Read output base file name
    this->_base_filename = in_rec.val<FilePath>("file");
    
    // Read optional error control field name for output mesh generation
    auto it = in_rec.find<std::string>("error_control_field");
    if(it) error_control_field_name = *it;
    else error_control_field_name = "";

    DBGMSG("error control field = '%s'\n", error_control_field_name.c_str());
    
    MPI_Comm_rank(MPI_COMM_WORLD, &this->rank);

}



OutputTime::~OutputTime(void)
{
    /* It's possible now to do output to the file only in the first process */
     //if(rank != 0) {
     //    /* TODO: do something, when support for Parallel VTK is added */
     //    return;
    // }

    if (this->_base_file.is_open()) this->_base_file.close();

    if(output_mesh_ != nullptr) delete output_mesh_;
    xprintf(MsgLog, "O.K.\n");
}



void OutputTime::make_output_mesh(Mesh* mesh, FieldSet* output_fields)
{
    if(is_output_mesh_valid_) return;
    
    // possibly destroy previous output mesh
    if(output_mesh_) delete output_mesh_;
    
    output_mesh_ = new OutputMesh(mesh);
    
    FieldCommon* field =  output_fields->field(error_control_field_name);
    if( field && (typeid(*field) == typeid(Field<3,FieldValue<3>::Scalar>)) ) {
        Field<3,FieldValue<3>::Scalar>* error_control_field = static_cast<Field<3,FieldValue<3>::Scalar>*>(field);
        DBGMSG("Output mesh will be refined according to field '%s'.\n", error_control_field_name.c_str());
        // create refined output mesh according to the field
        output_mesh_->create_refined_mesh(error_control_field);
    }
    else{
        DBGMSG("Output mesh identical with the computational one.\n");
        // create output mesh identical to computational mesh
        output_mesh_->create_identical_mesh();
    }
    
    // set validity of the output mesh for the current writing time
    is_output_mesh_valid_ = true;
    _mesh = mesh;
}


void OutputTime::compute_discontinuous_output_mesh()
{
    ASSERT_PTR(output_mesh_).error("Create output mesh first!");
    output_mesh_->compute_discontinuous_data();
}



void OutputTime::fix_main_file_extension(std::string extension)
{
    if(this->_base_filename.compare(this->_base_filename.size()-extension.size(), extension.size(), extension) != 0) {
        string new_name = this->_base_filename + extension;
        xprintf(Warn, "Renaming output file: %s to %s\n",
                this->_base_filename.c_str(), new_name.c_str());
        this->_base_filename = new_name;
    }
}


/* Initialize static member of the class */
//std::vector<OutputTime*> OutputTime::output_streams;


/*
void OutputTime::destroy_all(void)
{
    // Delete all objects
    for(std::vector<OutputTime*>::iterator ot_iter = OutputTime::output_streams.begin();
        ot_iter != OutputTime::output_streams.end();
        ++ot_iter)
    {
        delete *ot_iter;
    }

    OutputTime::output_streams.clear();
}
    */


std::shared_ptr<OutputTime> OutputTime::create_output_stream(const Input::Record &in_rec)
{
	std::shared_ptr<OutputTime> output_time;

    Input::Iterator<Input::AbstractRecord> format = Input::Record(in_rec).find<Input::AbstractRecord>("format");

    if(format) {
    	output_time = (*format).factory< OutputTime, const Input::Record & >(in_rec);
        output_time->format_record_ = *format;
    } else {
        output_time = Input::Factory< OutputTime, const Input::Record & >::instance()->create("OutputVTK", in_rec);
    }

    return output_time;
}


void OutputTime::add_admissible_field_names(const Input::Array &in_array)
{
    vector<Input::FullEnum> field_ids;
    in_array.copy_to(field_ids);

    for (auto field_full_enum: field_ids) {
        /* Setting flags to zero means use just discrete space
         * provided as default in the field.
         */
        DiscreteSpaceFlags flags = 0;
        this->output_names[(std::string)field_full_enum]=flags;
    }
}




void OutputTime::mark_output_times(const TimeGovernor &tg)
{
	TimeMark::Type output_mark_type = tg.equation_fixed_mark_type() | tg.marks().type_output();

	double time_step;
	if (input_record_.opt_val("time_step", time_step)) {
		tg.add_time_marks_grid(time_step, output_mark_type);
	}

	Input::Array time_list;
	if (input_record_.opt_val("time_list", time_list)) {
		vector<double> list;
		time_list.copy_to(list);
		for( double time : list) tg.marks().add(TimeMark(time, output_mark_type));
	} else {
	    tg.marks().add( TimeMark(tg.init_time(), output_mark_type) );
	}

	bool add_flag;
	if (input_record_.opt_val("add_input_times", add_flag) && add_flag) {
		TimeMark::Type input_mark_type = tg.equation_mark_type() | tg.marks().type_input();
		vector<double> mark_times;
		// can not add marks while iterating through time marks
		for(auto it = tg.marks().begin(input_mark_type); it != tg.marks().end(input_mark_type); ++it)
			mark_times.push_back(it->time());
		for(double time : mark_times)
			tg.marks().add( TimeMark(time, output_mark_type) );

	}

}


void OutputTime::write_time_frame()
{
	START_TIMER("OutputTime::write_time_frame");
    /* TODO: do something, when support for Parallel VTK is added */
    if (this->rank == 0) {
    	// Write data to output stream, when data registered to this output
		// streams were changed
		if(write_time < time) {
			xprintf(MsgLog, "Write output to output stream: %s for time: %f\n",
			        this->_base_filename.c_str(), time);
			write_data();
			// Remember the last time of writing to output stream
			write_time = time;
			current_step++;
            
            // unset validity of the output mesh after data are written at the current write time
            is_output_mesh_valid_ = false;
		} else {
			xprintf(MsgLog, "Skipping output stream: %s in time: %f\n",
			        this->_base_filename.c_str(), time);
		}
    }
    clear_data();
}

void OutputTime::clear_data(void)
{
    for(auto &map : output_data_vec_)  map.clear();
}



#define INSTANCE_register_field(spacedim, value) \
	template  void OutputTime::register_data<spacedim, value> \
		(const DiscreteSpace ref_type, Field<spacedim, value> &field);

#define INSTANCE_register_multifield(spacedim, value) \
	template void OutputTime::register_data<spacedim, value> \
		(const DiscreteSpace ref_type, MultiField<spacedim, value> &field);


#define INSTANCE_OutputData(spacedim, value) \
	template class OutputData<value>;


#define INSTANCE_DIM_DEP_VALUES( MACRO, dim_from, dim_to) \
		MACRO(dim_from, FieldValue<dim_to>::VectorFixed ) \
		MACRO(dim_from, FieldValue<dim_to>::TensorFixed )

#define INSTANCE_TO_ALL( MACRO, dim_from) \
		MACRO(dim_from, FieldValue<0>::Enum ) \
		MACRO(dim_from, FieldValue<0>::EnumVector) \
		MACRO(dim_from, FieldValue<0>::Integer) \
		MACRO(dim_from, FieldValue<0>::Scalar) \
		MACRO(dim_from, FieldValue<0>::Vector) \
        INSTANCE_DIM_DEP_VALUES(MACRO, dim_from, 2) \
        INSTANCE_DIM_DEP_VALUES(MACRO, dim_from, 3) \

#define INSTANCE_ALL(MACRO) \
		INSTANCE_TO_ALL( MACRO, 3) \
		INSTANCE_TO_ALL( MACRO, 2)


INSTANCE_ALL( INSTANCE_register_field )
INSTANCE_ALL( INSTANCE_register_multifield )

//INSTANCE_TO_ALL( INSTANCE_OutputData, 0)


//INSTANCE_register_field(3, FieldValue<0>::Scalar)
//INSTANCE_register_multifield(3, FieldValue<0>::Scalar)
//INSTANCE_OutputData(3, FieldValue<0>::Scalar)

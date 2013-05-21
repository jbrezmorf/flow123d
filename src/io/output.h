/*!
 *
 * Copyright (C) 2007 Technical University of Liberec.  All rights reserved.
 *
 * Please make a following refer to Flow123d on your project site if you use the program for any purpose,
 * especially for academic research:
 * Flow123d, Research Centre: Advanced Remedial Technologies, Technical University of Liberec, Czech Republic
 *
 * This program is free software; you can redistribute it and/or modify it under the terms
 * of the GNU General Public License version 3 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program; if not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 021110-1307, USA.
 *
 *
 * $Id$
 * $Revision$
 * $LastChangedBy$
 * $LastChangedDate$
 *
 * @file    output.h
 * @brief   Header: The functions for all outputs.
 *
 *
 * TODO:
 * - remove Output, keep OutputTime only (done)
 * - remove parameter mesh from static method OutputTime::output_stream (done)
 * - move initialization of streams from hc_expolicit_sequantial to
 *     Aplication::Aplication() constructor (done)
 * - OutputTime::register_XXX_data - should accept iterator to output record of particular equation, ask for presence of the key
 *   that has same name as the name of the quantity to output, extract the string with stream name from this key, find the stream
 *   and perform output.
 *
 *   on input:
 *
 *   { // darcy flow
 *      output = {
 *          pressure_nodes="nodal_data",
 *          pressure_elements="el_data"
 *      }
 *   }
 *
 *   output_streams=[
 *      {name="nodal_data", ... },
 *      {name="el_data", ... }
 *   ]
 *
 *   in code:
 *
 *   Input::Record out_rec = in_rec.val<Input::Record>("output");
 *   OutputTime::register_node_data(mesh_, "pressure_nodes", "L", out_rec, node_pressure);
 *   OutputTime::register_elem_data(mesh_, "pressure_elements", "L", out_rec, ele_pressure);
 *   ...
 *
 * - use exceptions instead of returning result, see declaration of exceptions through DECLARE_EXCEPTION macro
 * - move write_data from equations into coupling, write all streams
 *
 * =======================
 * - Is it still necessary to split output into registration and write the data?
 *   Could we perform it at once? ... No, it doesn't make any sense.
 * - Support for output of corner data into GMSH format (ElementNodeData section)
 *
 */

#ifndef OUTPUT_H
#define OUTPUT_H

#include <vector>
#include <string>
#include <fstream>
#include <mpi.h>

#include "system/xio.h"
#include "mesh/mesh.h"

#include "input/accessors.hh"

class OutputFormat;

/**
 * Class of output data storing reference on data.
 *
 * This class is referenced in Output and OuputTime class. The object contains
 * only reference on data. The referenced data could not be freed or rewrite
 * until data are written to the output file.
 */
class OutputData {
private:
public:
    // Types of data, that could be written to output file
    typedef enum {
        OUT_VECTOR_INT_SCA,
        OUT_VECTOR_INT_VEC,
        OUT_VECTOR_FLOAT_SCA,
        OUT_VECTOR_FLOAT_VEC,
        OUT_VECTOR_DOUBLE_SCA,
        OUT_VECTOR_DOUBLE_VEC,
        OUT_ARRAY_INT_SCA,
        OUT_ARRAY_FLOAT_SCA,
        OUT_ARRAY_DOUBLE_SCA
    } OutDataType;

    // Types of reference data
    typedef enum {
        NODE_DATA,
        CORNER_DATA,
        ELEM_DATA
    } RefType;

    string          *name;      ///< String with name of data
    string          *units;     ///< String with units
    void            *data;      ///< Pointer at own data
    OutDataType     type;       ///< Type values in vector
    RefType         ref_type;   ///< Type of reference data
    int             comp_num;   ///< Number of components in vector
    int             num;        ///< Number of values in vector/array
    double          time;       ///< The time, where data are valid
    double          write_time; ///< The last time, when data were written to output file

    /**
     * Un-named constructor can't be called directly
     */
    OutputData() {};

    string* getName(void) { return name; };
    string* getUnits(void) { return units; };
    int getCompNum(void) { return comp_num; };
    int getValueNum(void) { return num; };

    /**
     * \brief Constructor for OutputData storing names of output data and their
     * units.
     */
    OutputData(std::string name, std::string unit, int *data, unsigned int size);

    /**
     * \brief Constructor for OutputData storing names of output data and their
     * units.
     */
    OutputData(std::string name, std::string unit, float *data, unsigned int size);

    /**
     * \brief Constructor for OutputData storing names of output data and their
     * units.
     */
    OutputData(std::string name, std::string unit, double *data, unsigned int size);

    /**
     * \brief Constructor for OutputData storing names of output data and their
     * units.
     */
    OutputData(std::string name, std::string unit, std::vector<int> &data);

    /**
     * \brief Constructor for OutputData storing names of output data and their
     * units.
     */
    OutputData(std::string name, std::string unit, std::vector< vector<int> > &data);

    /**
     * \brief Constructor for OutputData storing names of output data and their
     * units.
     */
    OutputData(std::string name, std::string unit, std::vector<float> &data);

    /**
     * \brief Constructor for OutputData storing names of output data and their
     * units.
     */
    OutputData(std::string name, std::string unit, std::vector< vector<float> > &data);

    /**
     * \brief Constructor for OutputData storing names of output data and their
     * units.
     */
    OutputData(std::string name, std::string unit, std::vector<double> &data);

    /**
     * \brief Constructor for OutputData storing names of output data and their
     * units.
     */
    OutputData(std::string name, std::string unit, std::vector< vector<double> > &data);

    /**
     * \brief Destructor for OutputData
     */
    ~OutputData() {};
};

/**
 * Definition of output data vector
 */
typedef std::vector<OutputData> OutputDataVec;

/**
 * \brief The class for outputing data during time.
 *
 * This class is descendant of Output class. This class is used for outputing
 * data varying in time. Own output to specific file formats is done at other
 * places to. See output_vtk.cc and output_msh.cc.
 */
class OutputTime {
protected:

    int             rank;               ///< MPI rank of process (is tested in methods)

    // Protected setters for descendant
    void set_mesh(Mesh *_mesh) { mesh = _mesh; };

    void set_base_file(ofstream *_base_file) { base_file = _base_file; };

    void set_base_filename(string *_base_filename) { base_filename = _base_filename; };

    void set_node_data(std::vector<OutputData> *_node_data) { node_data = _node_data; };

    void set_corner_data(std::vector<OutputData> *_corner_data) { corner_data = _corner_data; };

    void set_elem_data(std::vector<OutputData> *_elem_data) { elem_data = _elem_data; };

    OutputTime() { node_scalar = NULL; element_scalar = NULL; element_vector = NULL; };

private:
    struct OutScalar *node_scalar;      // Temporary solution
    struct OutScalar *element_scalar;   // Temporary solution
    struct OutVector *element_vector;   // Temporary solution

    ofstream        *base_file;         ///< Base output stream
    string          *base_filename;     ///< Name of base output file
    string          *data_filename;     ///< Name of data output file
    ofstream        *data_file;         ///< Data output stream (could be same as base_file)
    Mesh            *mesh;
    OutputDataVec   *node_data;         ///< The list of data on nodes
    OutputDataVec   *corner_data;       ///< The list of data on corners
    OutputDataVec   *elem_data;         ///< The list of data on elements

public:
    double          time;               ///< The newest time of registered data
    double          write_time;         ///< The last time, when data was wrote to this stream

    std::vector<OutputData> *get_node_data(void) { return node_data; };

    std::vector<OutputData> *get_corner_data(void) { return corner_data; };

    std::vector<OutputData> *get_elem_data(void) { return elem_data; };

    ofstream& get_base_file(void) { return *base_file; };

    string& get_base_filename(void) { return *base_filename; };

    ofstream& get_data_file(void) { return *data_file; };

    string& get_data_filename(void) { return *data_filename; };

    Mesh *get_mesh(void) { return mesh; };

    unsigned int get_corner_count(void) {
        unsigned int li, count = 0;
        FOR_ELEMENTS(this->mesh, ele) {
            FOR_ELEMENT_NODES(ele, li) {
                count++;
            }
        }
        return count;
    }

    void set_data_file(ofstream *_data_file) { data_file = _data_file; };

    /**
     * Enumeration of file formats supported by Flow123d
     */
    typedef enum {
        NONE = 0,
        GMSH = 1,
        VTK = 2,
    } OutFileFormat;

    OutFileFormat   file_format;
    OutputFormat    *output_format;
    string          *name;              ///< Name of output stream

    /**
     * \brief Temporary definition for storing data (C++ vector of double scalars)
     */
    typedef std::vector<double> ScalarFloatVector;

    /**
     * \brief Temporary definition for storing data (C++ vector of double vectors)
     */
    typedef std::vector< vector<double> > VectorFloatVector;

    /**
     * \brief Temporary structure for storing data (double scalars)
     */
    typedef struct OutScalar {
        ScalarFloatVector   *scalars;
        string              name;
        string              unit;
    } _OutScalar;

    /**
     * \brief Temporary structure for storing data (double vectors)
     */
    typedef struct OutVector {
        VectorFloatVector   *vectors;
        string              name;
        string              unit;
    } _OutVector;

    /**
     * \brief Temporary vectors of structures for storing data (double scalars)
     */
    typedef std::vector<OutScalar> OutScalarsVector;

    /**
     * \brief Temporary vectors of structures for storing data (double vectors)
     */
    typedef std::vector<OutVector> OutVectorsVector;

    /**
     * \brief Vector of pointers at OutputTime
     */
    static std::vector<OutputTime*> output_streams;

    /**
     * \brief Try to find output stream with this name
     */
    static OutputTime *output_stream_by_name(string name);

    /**
     * \brief Does OutputStream with same name and filename exist?
     *
     * When this record is already created, then it returns pointer at
     * corresponding OutputTime. When this record doesn't exist, then
     * it create new OutputTime object and it puts this object to the
     * array of OutputTime pointers
     *
     * \param[in] in_rec  The reference at the input record
     */
    static OutputTime *output_stream(const Input::Record &in_rec);

    /**
     * \brief This method delete all object instances of class OutputTime stored
     * in output_streams vector
     */
    static void destroy_all(void);

    /**
     * \brief Constructor of OutputTime object. It opens base file for writing.
     *
     * \param[in] in_rec The reference on the input record
     */
    OutputTime(const Input::Record &in_rec);

    /**
     * \brief Destructor of OutputTime. It doesn't do anything, because all
     * necessary destructors will be called in destructor of Output
     */
    virtual ~OutputTime();

    /**
     * \brief This method set current time for registered data array/vector
     */
    void set_data_time(void *data, double time);

    /**
     * \brief The specification of output stream
     *
     * \return This variable defines record for output stream
     */
    static Input::Type::Record input_type;


    /**
     * \brief This function register data on nodes.
     *
     * This function will add reference on this array of data to the Output object.
     * It is possible to call this function only once, when data are at the same
     * address during time. It is possible to call this function for each step, when
     * data are not at the same address, but name of the data has to be same.
     * Own data will be written to the file, when write_data() method will be called.
     *
     * \param[in] name      The name of data
     * \param[in] unit      The units of data
     * \param[in] in_rec    The reference on the input record
     * \param[in] *data     The pointer at data (array of int, float or double)
     * \param[in] size      The size of array (number of values)
     * \param[in] time      The data was computed for this time
     *
     * \return This function returns 1, when data were registered. This function
     * returns 0, when it wasn't able to register data (number of values isn't
     * same as number of nodes).
     */
    template <typename _Data>
    static OutputTime* register_node_data(Mesh *mesh,
            std::string name,
    		std::string unit,
    		const Input::Record &in_rec,
    		_Data *data,
    		unsigned int size,
    		double time);

    /**
     * \brief This function register data on corners of triangles.
     *
     * This function will add reference on this array of data to the Output object.
     * It is possible to call this function only once, when data are at the same
     * address during time. It is possible to call this function for each step, when
     * data are not at the same address, but name of the data has to be same.
     * Own data will be written to the file, when write_data() method will be called.
     *
     * \param[in] name  The name of data
     * \param[in] unit  The units of data
     * \param[in] in_rec    The reference on the input record
     * \param[in] *data The pointer at data (array of int, float or double)
     * \param[in] size  The size of array (number of values)
     * \param[in] time      The data was computed for this time
     *
     * \return This function returns 1, when data were registered. This function
     * returns 0, when it wasn't able to register data (number of values isn't
     * same as number of nodes).
     */
    template <typename _Data>
    static OutputTime* register_corner_data(Mesh *mesh,
            std::string name,
            std::string unit,
            const Input::Record &in_rec,
            _Data *data,
            unsigned int size,
            double time);

    /**
     * \brief This function register data on elements.
     *
     * This function will add reference on this array of data to the Output object.
     * It is possible to call this function only once, when data are at the same
     * address during time. it is possible to call this function for each step, when
     * data are not at the same address, but name of the data has to be same.
     * Own data will be written to the file, when write_data() method will be called.
     *
     * \param[in] name  The name of data
     * \param[in] unit  The units of data
     * \param[in] *data The pointer at data (array of int, float or double)
     * \param[in] size  The size of array (number of values)
     * \param[in] time      The data was computed for this time
     *
     * \return This function returns 1, when data were registered. This function
     * returns 0, when it wasn't able to register data (number of values isn't
     * same as number of elements).
     */
    template <typename _Data>
    static OutputTime* register_elem_data(Mesh *mesh,
            std::string name,
            std::string unit,
            const Input::Record &in_rec,
            _Data *data,
            unsigned int size,
            double time);

    /**
     * \brief This function register data on nodes.
     *
     * This function will add reference on this array of data to the Output object.
     * It is possible to call this function only once, when data are at the same
     * address during time. it is possible to call this function for each step, when
     * data are not at the same address, but name of the data has to be same.
     * Own data will be written to the file, when write_data() method will be called.
     *
     * \param[in] name  The name of data
     * \param[in] unit  The units of data
     * \param[in] *data The pointer at data (array of int, float or double)
     * \param[in] time      The data was computed for this time
     *
     * \return This function returns 1, when data were registered. This function
     * returns 0, when it wasn't able to register data (number of values isn't
     * same as number of nodes).
     */
    template <typename _Data>
    static OutputTime* register_node_data(Mesh *mesh,
            std::string name,
            std::string unit,
            const Input::Record &in_rec,
            std::vector<_Data> &data,
            double time);

    /**
     * \brief This function register data on corners of triangles.
     *
     * This function will add reference on this array of data to the Output object.
     * It is possible to call this function only once, when data are at the same
     * address during time. it is possible to call this function for each step, when
     * data are not at the same address, but name of the data has to be same.
     * Own data will be written to the file, when write_data() method will be called.
     *
     * \param[in] name  The name of data
     * \param[in] unit  The units of data
     * \param[in] *data The pointer at data (array of int, float or double)
     * \param[in] time      The data was computed for this time
     *
     * \return This function returns 1, when data were registered. This function
     * returns 0, when it wasn't able to register data (number of values isn't
     * same as number of nodes).
     */
    template <typename _Data>
    static OutputTime* register_corner_data(Mesh *mesh,
            std::string name,
            std::string unit,
            const Input::Record &in_rec,
            std::vector<_Data> &data,
            double time);

    /**
     * \brief Register vector of data on elements.
     *
     * This function will add reference on the data to the Output object. Own
     * data will be written to the file, when write_data() method will be called.
     * When the data has been already registered, then pointer at data will be
     * updated. Otherwise, new data will be registered.
     *
     * \param[in] name  The name of data
     * \param[in] unit  The unit of data
     * \param[in] &data The reference on vector (int, float, double)
     * \param[in] time      The data was computed for this time
     *
     * \return This function returns 1, when data were successfully registered.
     * This function returns 0, when number of elements and items of vector is
     * not the same.
     */
    template <typename _Data>
    static OutputTime* register_elem_data(Mesh *mesh,
            std::string name,
            std::string unit,
            const Input::Record &in_rec,
            std::vector<_Data> &data,
            double time);

    /**
     * \brief This is depreciated method. Every file format should specify its own
     * method for writing data to output file. This method will not be public
     * in the future.
     *
     * \param[in] time  The output will be done for this time
     *
     * \return This function returns result of method _write_data().
     */
    //int write_data(double time);

    /**
     * \brief This method write all registered data to output streams
     */
    static void write_all_data(void);

    int              current_step;      ///< Current step

};

template <typename _Data>
OutputTime* OutputTime::register_node_data(Mesh *mesh,
        std::string name,
        std::string unit,
        const Input::Record &in_rec,
        _Data *data,
        uint size,
        double time)
{
    // Try to find record with output stream (the key is name of data)
    Input::Iterator<string> stream_name_iter = in_rec.find<string>(name);

    // If record was not found, then exit
    if(!stream_name_iter) {
        return NULL;
    }

    // Try to find existing output stream or create new one
    OutputTime *output_time = OutputTime::output_stream_by_name(*stream_name_iter);

    /* It's possible now to do output to the file only in the first process */
    if(output_time == NULL || output_time->rank!=0) {
        /* TODO: do something, when support for Parallel VTK is added */
        return NULL;
    }

    output_time->time = time;
    output_time->set_mesh(mesh);

    int found = 0;
    std::vector<OutputData> *node_data = output_time->get_node_data();

    ASSERT(mesh->node_vector.size() == size,
            "mesh->node_vector.size(): %d != size: %d",
            mesh->node_vector.size(),
            size);

    for(std::vector<OutputData>::iterator od_iter = node_data->begin();
            od_iter != node_data->end();
            od_iter++)
    {
        if(*od_iter->name == name) {
            od_iter->data = (void*)data;
            found = 1;
            break;
        }
    }

    if(found == 0) {
        OutputData *out_data = new OutputData(name, unit, data, size);
        out_data->ref_type = OutputData::NODE_DATA;
        node_data->push_back(*out_data);
    }

    return output_time;

}

template <typename _Data>
OutputTime* OutputTime::register_corner_data(Mesh *mesh,
        std::string name,
        std::string unit,
        const Input::Record &in_rec,
        _Data *data,
        uint size,
        double time)
{
    // Try to find record with output stream (the key is name of data)
    Input::Iterator<string> stream_name_iter = in_rec.find<string>(name);

    // If record was not found, then exit
    if(!stream_name_iter) {
        return NULL;
    }

    // Try to find existing output stream or create new one
    OutputTime *output_time = OutputTime::output_stream_by_name(*stream_name_iter);

    /* It's possible now to do output to the file only in the first process */
    if(output_time == NULL || output_time->rank!=0) {
        /* TODO: do something, when support for Parallel VTK is added */
        return NULL;
    }

    output_time->time = time;
    output_time->set_mesh(mesh);

    int found = 0;
    std::vector<OutputData> *corner_data = output_time->get_corner_data();

    int corner_count = output_time->get_corner_count();
    ASSERT(corner_count == size,
            "output_time->get_corner_count(): %d != size: %d",
            corner_count,
            size);

    for(std::vector<OutputData>::iterator od_iter = corner_data->begin();
            od_iter != corner_data->end();
            od_iter++)
    {
        if(*od_iter->name == name) {
            od_iter->data = (void*)data;
            found = 1;
            break;
        }
    }

    if(found == 0) {
        OutputData *out_data = new OutputData(name, unit, data, size);
        out_data->ref_type = OutputData::CORNER_DATA;
        corner_data->push_back(*out_data);
    }

    return output_time;

}

template <typename _Data>
OutputTime* OutputTime::register_elem_data(Mesh *mesh,
        std::string name,
        std::string unit,
        const Input::Record &in_rec,
        _Data *data,
        unsigned int size,
        double time)
{
    // Try to find record with output stream (the key is name of data)
    Input::Iterator<string> stream_name_iter = in_rec.find<string>(name);

    // If record was not found, then exit
    if(!stream_name_iter) {
        return NULL;
    }

    // Try to find existing output stream or create new one
    OutputTime *output_time = OutputTime::output_stream_by_name(*stream_name_iter);

    /* It's possible now to do output to the file only in the first process */
    if(output_time == NULL || output_time->rank!=0) {
        /* TODO: do something, when support for Parallel VTK is added */
        return NULL;
    }

    output_time->time = time;
    output_time->set_mesh(mesh);

    int found = 0;
    std::vector<OutputData> *elem_data = output_time->get_elem_data();

    ASSERT(mesh->element.size() == size,
            "mesh->element.size(): %d != size: %d",
            mesh->element.size(),
            size);

    for(std::vector<OutputData>::iterator od_iter = elem_data->begin();
            od_iter != elem_data->end();
            od_iter++)
    {
        if(*od_iter->name == name) {
            od_iter->data = (void*)data;
            found = 1;
            break;
        }
    }

    if(found == 0) {
        OutputData *out_data = new OutputData(name, unit, data, size);
        out_data->ref_type = OutputData::ELEM_DATA;
        elem_data->push_back(*out_data);
    }

    return output_time;
}

template <typename _Data>
OutputTime* OutputTime::register_node_data(Mesh *mesh,
        std::string name,
        std::string unit,
        const Input::Record &in_rec,
        std::vector<_Data> &data,
        double time)
{
    // Try to find record with output stream (the key is name of data)
    Input::Iterator<string> stream_name_iter = in_rec.find<string>(name);

    // If record was not found, then exit
    if(!stream_name_iter) {
        return NULL;
    }

    // Try to find existing output stream or create new one
    OutputTime *output_time = OutputTime::output_stream_by_name(*stream_name_iter);

    /* It's possible now to do output to the file only in the first process */
    if(output_time == NULL || output_time->rank!=0) {
        /* TODO: do something, when support for Parallel VTK is added */
        return NULL;
    }

    output_time->time = time;
    output_time->set_mesh(mesh);

    int found = 0;
    std::vector<OutputData> *node_data = output_time->get_node_data();

    ASSERT(mesh->node_vector.size() == data.size(),
            "mesh->node_vector.size(): %d != size: %d",
            mesh->node_vector.size(),
            data.size());

    for(std::vector<OutputData>::iterator od_iter = node_data->begin();
            od_iter != node_data->end();
            od_iter++)
    {
        if(*od_iter->name == name) {
            od_iter->data = (void*)&data;
            found = 1;
            break;
        }
    }

    if(found == 0) {
        OutputData *out_data = new OutputData(name, unit, data);
        out_data->ref_type = OutputData::NODE_DATA;
        node_data->push_back(*out_data);
    }

    return output_time;
}

template <typename _Data>
OutputTime* OutputTime::register_corner_data(Mesh *mesh,
        std::string name,
        std::string unit,
        const Input::Record &in_rec,
        std::vector<_Data> &data,
        double time)
{
    // Try to find record with output stream (the key is name of data)
    Input::Iterator<string> stream_name_iter = in_rec.find<string>(name);

    // If record was not found, then exit
    if(!stream_name_iter) {
        return NULL;
    }

    // Try to find existing output stream or create new one
    OutputTime *output_time = OutputTime::output_stream_by_name(*stream_name_iter);

    /* It's possible now to do output to the file only in the first process */
    if(output_time == NULL || output_time->rank!=0) {
        /* TODO: do something, when support for Parallel VTK is added */
        return NULL;
    }
    
    output_time->time = time;
    output_time->set_mesh(mesh);

    int found = 0;
    std::vector<OutputData> *corner_data = output_time->get_corner_data();

    int corner_count = output_time->get_corner_count();
    ASSERT(corner_count == data.size(),
            "output_time->get_corner_count(): %d != size: %d",
            corner_count,
            data.size());

    for(std::vector<OutputData>::iterator od_iter = corner_data->begin();
            od_iter != corner_data->end();
            od_iter++)
    {
        if(*od_iter->name == name) {
            od_iter->data = (void*)&data;
            found = 1;
            break;
        }
    }

    if(found == 0) {
        OutputData *out_data = new OutputData(name, unit, data);
        out_data->ref_type = OutputData::CORNER_DATA;
        corner_data->push_back(*out_data);
    }

    return output_time;
}

template <typename _Data>
OutputTime* OutputTime::register_elem_data(Mesh *mesh,
        std::string name,
        std::string unit,
        const Input::Record &in_rec,
        std::vector<_Data> &data,
        double time)
{
    // Try to find record with output stream (the key is name of data)
    Input::Iterator<string> stream_name_iter = in_rec.find<string>(name);

    // If record was not found, then exit
    if(!stream_name_iter) {
        return NULL;
    }

    // Try to find existing output stream or create new one
    OutputTime *output_time = OutputTime::output_stream_by_name(*stream_name_iter);

    /* It's possible now to do output to the file only in the first process */
    if(output_time == NULL || output_time->rank!=0) {
        /* TODO: do something, when support for Parallel VTK is added */
        return NULL;
    }

    output_time->time = time;
    output_time->set_mesh(mesh);

    int found = 0;
    std::vector<OutputData> *elem_data = output_time->get_elem_data();

    ASSERT(mesh->element.size() == data.size(),
            "mesh->element.size(): %d != size: %d",
            mesh->element.size(),
            data.size());

    for(std::vector<OutputData>::iterator od_iter = elem_data->begin();
            od_iter != elem_data->end();
            od_iter++)
    {
        if(*od_iter->name == name) {
            od_iter->data = (void*)&data;
            found = 1;
            break;
        }
    }

    if(found == 0) {
        OutputData *out_data = new OutputData(name, unit, data);
        out_data->ref_type = OutputData::ELEM_DATA;
        elem_data->push_back(*out_data);
    }
    return output_time;

}

#if 0
template <typename _Data>
OutputTime* OutputTime::register_data(Mesh *mesh,
        OutputData::OutDataType data_type,
        std::string name,
        std::string unit,
        const Input::Record &in_rec,
        _Data *data,
        uint size,
        double time)
{
    // Try to find record with output stream (the key is name of data)
    Input::Iterator<Input::Record> stream_rec_iter = in_rec.find<Input::Record>(name);

    // If record was not found, then exit
    if(!stream_rec_iter) {
        return NULL;
    }

    // Try to find existing output stream or create new one
    OutputTime *output_time = OutputTime::output_stream(*stream_rec_iter);

    /* It's possible now to do output to the file only in the first process */
    if(output_time == NULL || output_time->rank!=0) {
        /* TODO: do something, when support for Parallel VTK is added */
        return NULL;
    }

    output_time->time = time;
    output_time->set_mesh(mesh);

    int found = 0;
    std::vector<OutputData> *vec_data;

    switch(data_type) {
    case OutputData::NODE_DATA:
        vec_data = output_time->get_node_data();
        ASSERT(mesh->node_vector.size() == size,
                "mesh->node_vector.size(): %d != size: %d",
                mesh->node_vector.size(),
                size);
        break;
    case OutputData::CORNER_DATA:
        break;
    case OutputData::ELEM_DATA:
        break;
    default:
        return NULL;
    }


    for(std::vector<OutputData>::iterator data_iter = vec_data->begin();
            data_iter != vec_data->end();
            data_iter++)
    {
        if(*data_iter->name == name) {
            data_iter->data = (void*)data;
            found = 1;
            break;
        }
    }

    if(found == 0) {
        OutputData *out_data = new OutputData(name, unit, data, size);
        out_data->ref_type = data_type;
        vec_data->push_back(*out_data);
    }

    return output_time;
}
#endif


/**
 * \brief The class used as parent class of file format classes
 */
class OutputFormat {
public:
	OutputFormat() {}
    virtual ~OutputFormat() {}
	virtual int write_data(void) { return 0; }
	virtual int write_head(void) { return 0; }
	virtual int write_tail(void) { return 0; }

	static Input::Type::AbstractRecord input_type;
};


#endif

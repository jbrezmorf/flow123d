/*
 * field_elementwise_test.cpp
 *
 *  Created on: Jan 25, 2013
 *      Author: jb
 */



#include <gtest/gtest.h>


#include "fields/field_elementwise.hh"
#include "input/input_type.hh"
#include "input/accessors.hh"
#include "input/json_to_storage.hh"

#include "mesh/mesh.h"
#include "mesh/msh_gmshreader.h"


string input = R"INPUT(
{   
   scalar={
       TYPE="FieldElementwise",
       gmsh_file="fields/simplest_cube_data.msh",
       field_name="scalar"
   },
   vector_fixed={
       TYPE="FieldElementwise",
       gmsh_file="fields/simplest_cube_data.msh",
       field_name="vector_fixed"
   },
   vector={
       TYPE="FieldElementwise",
       gmsh_file="fields/simplest_cube_data.msh",
       field_name="vector_fixed"
   },
   tensor_fixed={
       TYPE="FieldElementwise",
       gmsh_file="fields/simplest_cube_data.msh",
       field_name="tensor_fixed"
   }
}
)INPUT";


class FieldElementwiseTest : public testing::Test {
public:
    typedef FieldElementwise<3, FieldValue<3>::Scalar > ScalarField;
    typedef FieldElementwise<3, FieldValue<3>::VectorFixed > VecFixField;
    typedef FieldElementwise<3, FieldValue<3>::Vector > VecField;
    typedef FieldElementwise<3, FieldValue<2>::TensorFixed > TensorField;

    virtual void SetUp() {
        // setup FilePath directories
        FilePath::set_io_dirs(".",UNIT_TESTS_SRC_DIR,"",".");

        FilePath mesh_file( "mesh/simplest_cube.msh", FilePath::input_file);
        mesh= new Mesh;
        GmshMeshReader mesh_reader(mesh_file);
        mesh_reader.read_mesh(mesh);

        Input::Type::Record  rec_type("Test","");
        rec_type.declare_key("scalar", ScalarField::input_type, Input::Type::Default::obligatory(),"" );
        rec_type.declare_key("vector_fixed", VecFixField::input_type, Input::Type::Default::obligatory(),"" );
        rec_type.declare_key("vector", VecField::input_type, Input::Type::Default::obligatory(),"" );
        rec_type.declare_key("tensor_fixed", TensorField::input_type, Input::Type::Default::obligatory(),"" );
        rec_type.finish();

        std::stringstream ss(input);
        Input::JSONToStorage reader;
        reader.read_stream( ss, rec_type );
        rec=reader.get_root_interface<Input::Record>();

    }
    virtual void TearDown() {

    }

    Mesh *mesh;
    Input::Record rec;
    Point<3> point;

};


TEST_F(FieldElementwiseTest, scalar) {
    ScalarField field;
    field.init_from_input(rec.val<Input::Record>("scalar"));
    field.set_mesh(mesh);
    field.set_time(0.0);

    for(unsigned int i=0; i < mesh->element.size(); i++) {
        EXPECT_DOUBLE_EQ( (i+1)*0.1 , field.value(point,mesh->element_accessor(i)) );
    }
    for(unsigned int i=0; i < 4; i++) {
        EXPECT_DOUBLE_EQ( 1.0+(i+1)*0.1 , field.value(point,mesh->element_accessor(i, true)) );
    }
    EXPECT_DOUBLE_EQ( 0.0, field.value(point,mesh->element_accessor(5, true)) );

}

TEST_F(FieldElementwiseTest, vector_fixed) {
    VecFixField field;
    field.init_from_input(rec.val<Input::Record>("vector_fixed"));
    field.set_mesh(mesh);
    field.set_time(0.0);

    for(unsigned int i=0; i < mesh->element.size(); i++) {
        EXPECT_TRUE( arma::min(arma::vec3("1 2 3") == field.value(point,mesh->element_accessor(i))) );
    }
    for(unsigned int i=0; i < 4; i++) {
        EXPECT_TRUE( arma::min(arma::vec3("4 5 6") == field.value(point,mesh->element_accessor(i,true))) );
    }
    EXPECT_TRUE( arma::min(arma::vec3("0 0 0") == field.value(point,mesh->element_accessor(5,true))) );

}


TEST_F(FieldElementwiseTest, vector) {
    VecField field(3);
    field.init_from_input(rec.val<Input::Record>("vector"));
    field.set_mesh(mesh);
    field.set_time(0.0);

    for(unsigned int i=0; i < mesh->element.size(); i++) {
        EXPECT_TRUE( arma::min(arma::vec("1 2 3") == field.value(point,mesh->element_accessor(i))) );
    }
    for(unsigned int i=0; i < 4; i++) {
        EXPECT_TRUE( arma::min(arma::vec("4 5 6") == field.value(point,mesh->element_accessor(i,true))) );
    }
    EXPECT_TRUE( arma::min(arma::vec("0 0 0") == field.value(point,mesh->element_accessor(5,true))) );

}


TEST_F(FieldElementwiseTest, tensor_fixed) {
    TensorField field;
    field.init_from_input(rec.val<Input::Record>("tensor_fixed"));
    field.set_mesh(mesh);
    field.set_time(0.0);

    for(unsigned int i=0; i < mesh->element.size(); i++) {
        arma::umat match = ( arma::mat22("1 3; 2 4") == field.value(point,mesh->element_accessor(i)) );
        EXPECT_TRUE( match.min() );
    }
    for(unsigned int i=0; i < 4; i++) {
        arma::umat match = ( arma::mat22("4 6; 5 7") == field.value(point,mesh->element_accessor(i,true)) );
        EXPECT_TRUE( match.min() );
    }
    arma::umat match = ( arma::mat22("0 0; 0 0") == field.value(point,mesh->element_accessor(5,true)) );
    EXPECT_TRUE( match.min() );

}

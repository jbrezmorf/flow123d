/*
 * intersection_area_test.cpp
 *
 *  Created on: Nov 14, 2014
 *      Author: VF
 */
#define TEST_USE_MPI
#include <flow_gtest_mpi.hh>

#include "system/system.hh"
#include "system/sys_profiler.hh"
#include "system/file_path.hh"
#include "mesh/mesh.h"

#include "mesh/ngh/include/point.h"
#include "mesh/ngh/include/intersection.h"

#include "intersection/inspectelements.h"

#include <dirent.h>

using namespace std;
using namespace computeintersection;


void compute_intersection_area_23d(Mesh *mesh)
{
    double area1, area2 = 0;

    // compute intersection by NGH
    xprintf(Msg, "Computing polygon area by NGH algorithm\n");
    TTriangle ttr;
    TTetrahedron tte;
    TIntersectionType it = area;

    FOR_ELEMENTS(mesh, elm) {
        if (elm->dim() == 2) {
        ttr.SetPoints(TPoint(elm->node[0]->point()(0), elm->node[0]->point()(1), elm->node[0]->point()(2)),
                     TPoint(elm->node[1]->point()(0), elm->node[1]->point()(1), elm->node[1]->point()(2)),
                     TPoint(elm->node[2]->point()(0), elm->node[2]->point()(1), elm->node[2]->point()(2)) );
        }else if(elm->dim() == 3){
        tte.SetPoints(TPoint(elm->node[0]->point()(0), elm->node[0]->point()(1), elm->node[0]->point()(2)),
                     TPoint(elm->node[1]->point()(0), elm->node[1]->point()(1), elm->node[1]->point()(2)),
                     TPoint(elm->node[2]->point()(0), elm->node[2]->point()(1), elm->node[2]->point()(2)),
                     TPoint(elm->node[3]->point()(0), elm->node[3]->point()(1), elm->node[3]->point()(2)));
//         elm->node[0]->point().print();
//         elm->node[1]->point().print();
//         elm->node[2]->point().print();
//         elm->node[3]->point().print();
//         
//         elm->side(0)->node(0)->point().print();
//         elm->side(0)->node(1)->point().print();
//         elm->side(0)->node(2)->point().print();
        }
    }
    GetIntersection(ttr, tte, it, area2);
    
    
    // compute intersection
    xprintf(Msg, "Computing polygon area by NEW algorithm\n");
    InspectElements ie(mesh);
    ie.compute_intersections<2,3>();
    area1 = ie.polygonArea();
//     ie.print_mesh_to_file("output_intersection");
    
    xprintf(Msg,"Polygon area: (intersections) %.16e,\t(NGH) %.16e\n", area1, area2);
    EXPECT_NEAR(area1, area2, 1e-14);
//     EXPECT_DOUBLE_EQ(area1,area2);
}


void compute_intersection_area_13d(Mesh *mesh)
{
    double length1, length2 = 0;

    // compute intersection
    xprintf(Msg, "Computing intersection length by NEW algorithm\n");
    InspectElements ie(mesh);
    ie.compute_intersections<1,3>();
    
    length1 = ie.line_length();

    // compute intersection by NGH
    xprintf(Msg, "Computing intersection length by NGH algorithm\n");
    TAbscissa tabs;
    TTetrahedron tte;
    TIntersectionType it = line;

    FOR_ELEMENTS(mesh, elm) {
        if (elm->dim() == 1) {
        tabs.SetPoints(TPoint(elm->node[0]->point()(0), elm->node[0]->point()(1), elm->node[0]->point()(2)),
                       TPoint(elm->node[1]->point()(0), elm->node[1]->point()(1), elm->node[1]->point()(2)));
        }
        else if(elm->dim() == 3){
        tte.SetPoints(TPoint(elm->node[0]->point()(0), elm->node[0]->point()(1), elm->node[0]->point()(2)),
                     TPoint(elm->node[1]->point()(0), elm->node[1]->point()(1), elm->node[1]->point()(2)),
                     TPoint(elm->node[2]->point()(0), elm->node[2]->point()(1), elm->node[2]->point()(2)),
                     TPoint(elm->node[3]->point()(0), elm->node[3]->point()(1), elm->node[3]->point()(2)));
        }
    }
    GetIntersection(tabs, tte, it, length2); // get only relative length of the intersection to the abscissa
    length2 *= tabs.Length(); 
    
    xprintf(Msg,"Lenght of intersection line: (intersections) %.16e,\t(NGH) %.16e\n", length1, length2);
//     EXPECT_NEAR(length1, length2, 1e-12);
    EXPECT_DOUBLE_EQ(length1,length2);
}


TEST(area_intersections, all) {
    Profiler::initialize();
    
    // directory with testing meshes
    string dir_name = string(UNIT_TESTS_SRC_DIR) + "/mesh/site/";//notfunctional/
    std::vector<string> filenames;
    
    // read mesh file names
    DIR *dir;
    struct dirent *ent;
    if ((dir = opendir (dir_name.c_str())) != NULL) {
        /* print all the files and directories within directory */
        xprintf(Msg,"Testing mesh files: \n");
        while ((ent = readdir (dir)) != NULL) {
            string fname = ent->d_name;
            // test extension ".msh"
            if(fname.size() >= 4)
            {
                string ext = fname.substr(fname.size()-4);
//                 xprintf(Msg,"%s\n",ext.c_str());
                if(ext == ".msh"){
                    filenames.push_back(ent->d_name);
                    xprintf(Msg,"%s\n",ent->d_name);
                }
            }
        }
        closedir (dir);
    } else {
        ASSERT(0,"Could not open directory with testing meshes.");
    }
    
    // for each mesh, compute intersection area and compare with old NGH
    for(auto &fname : filenames)
    {
        unsigned int permutations[6][3] = {{0,1,2},{0,2,1},{1,0,2},{1,2,0},{2,0,1},{2,1,0}};
        for(unsigned int p=0; p<6; p++)
        {
            xprintf(Msg,"Computing intersection on mesh: %s\n",fname.c_str());
            FilePath::set_io_dirs(".","","",".");
            FilePath mesh_file(dir_name + fname, FilePath::input_file);
            
            Mesh mesh;
            // read mesh with gmshreader
            GmshMeshReader reader(mesh_file);
            reader.read_mesh(&mesh);
            
            // permute nodes:
            FOR_ELEMENTS(&mesh,ele)
            {
                if(ele->dim() == 2)
                {
                    Node* tmp[3];
                    for(unsigned int i=0; i<ele->n_nodes(); i++)
                    {
                        tmp[i] = ele->node[permutations[p][i]];
                    }
                    for(unsigned int i=0; i<ele->n_nodes(); i++)
                    {
                        ele->node[i] = tmp[i];
                        ele->node[i]->point().print(cout);
                    }
                }
            }
            mesh.setup_topology();
            
            xprintf(Msg, "==============\n");
            compute_intersection_area_23d(&mesh);
            xprintf(Msg, "==============\n");
        }
    }

    
    Profiler::uninitialize();
}


TEST(area_intersections_13d, all) {
    Profiler::initialize();
    
    // directory with testing meshes
    string dir_name = string(UNIT_TESTS_SRC_DIR) + "/mesh/site_13d/";
    std::vector<string> filenames;
    
    // read mesh file names
    DIR *dir;
    struct dirent *ent;
    if ((dir = opendir (dir_name.c_str())) != NULL) {
        /* print all the files and directories within directory */
        xprintf(Msg,"Testing mesh files: \n");
        while ((ent = readdir (dir)) != NULL) {
            string fname = ent->d_name;
            // test extension ".msh"
            if(fname.size() >= 4)
            {
                string ext = fname.substr(fname.size()-4);
//                 xprintf(Msg,"%s\n",ext.c_str());
                if(ext == ".msh"){
                    filenames.push_back(ent->d_name);
                    xprintf(Msg,"%s\n",ent->d_name);
                }
            }
        }
        closedir (dir);
    } else {
        ASSERT(0,"Could not open directory with testing meshes.");
    }
    
    // for each mesh, compute intersection area and compare with old NGH
    for(auto &fname : filenames)
    {
            xprintf(Msg,"Computing intersection on mesh: %s\n",fname.c_str());
            FilePath::set_io_dirs(".","","",".");
            FilePath mesh_file(dir_name + fname, FilePath::input_file);
            
            Mesh mesh;
            // read mesh with gmshreader
            GmshMeshReader reader(mesh_file);
            reader.read_mesh(&mesh);
            mesh.setup_topology();
            
            xprintf(Msg, "==============\n");
            compute_intersection_area_13d(&mesh);
            xprintf(Msg, "==============\n");
    }

    
    Profiler::uninitialize();
}




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
 * @file    ngh_interface.hh
 * @brief   
 */

#ifndef NGH_INTERFACE_HH_
#define NGH_INTERFACE_HH_

#include "mesh/elements.h"
#include "mesh/ngh/include/abscissa.h"
#include "mesh/ngh/include/point.h"
#include "mesh/ngh/include/triangle.h"
#include "mesh/ngh/include/tetrahedron.h"

namespace ngh {
    /**
     * Create tetrahedron from element
     */
    inline void set_tetrahedron_from_element( TTetrahedron &te, Element *ele) {
        OLD_ASSERT(( ele->dim() == 3 ), "Dimension of element must be 3!\n");

         te.SetPoints(TPoint(ele->node[0]->point()(0), ele->node[0]->point()(1), ele->node[0]->point()(2)),
                     TPoint(ele->node[1]->point()(0), ele->node[1]->point()(1), ele->node[1]->point()(2)),
                     TPoint(ele->node[2]->point()(0), ele->node[2]->point()(1), ele->node[2]->point()(2)),
                     TPoint(ele->node[3]->point()(0), ele->node[3]->point()(1), ele->node[3]->point()(2)) );
    }

    /**
     * Create triangle from element
     */
    inline void set_triangle_from_element(TTriangle &tr, const Element *ele) {
    	OLD_ASSERT(( ele->dim() == 2 ), "Dimension of element must be 2!\n");

        tr.SetPoints(TPoint(ele->node[0]->point()(0), ele->node[0]->point()(1), ele->node[0]->point()(2)),
                     TPoint(ele->node[1]->point()(0), ele->node[1]->point()(1), ele->node[1]->point()(2)),
                     TPoint(ele->node[2]->point()(0), ele->node[2]->point()(1), ele->node[2]->point()(2)) );
    }

    /**
     * Create abscissa from element
     */
    inline void set_abscissa_from_element(TAbscissa &ab, const Element *ele) {
    	OLD_ASSERT(( ele->dim() == 1 ), "Dimension of element must be 1!\n");

        ab.SetPoints(TPoint(ele->node[0]->point()(0), ele->node[0]->point()(1), ele->node[0]->point()(2)),
                     TPoint(ele->node[1]->point()(0), ele->node[1]->point()(1), ele->node[1]->point()(2)) );
    }

    /**
     * Create point from element
     */
    inline void set_point_from_element(TPoint &p, const Element *ele) {
    	OLD_ASSERT(( ele->dim() == 0 ), "Dimension of element must be 0!\n");

        p.SetCoord( ele->node[0]->point()(0), ele->node[0]->point()(1), ele->node[0]->point()(2) );
    }

} // namespace ngh

#endif /* NGH_INTERFACE_HH_ */

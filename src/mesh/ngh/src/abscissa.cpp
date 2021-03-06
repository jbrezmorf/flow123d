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
 * @file    abscissa.cpp
 * @brief   
 */

#include <cmath>

#include "mesh/ngh/include/abscissa.h"
#include "stdio.h"

int TAbscissa::numberInstance = 0;

int TAbscissa::generateId() {
    return TAbscissa::numberInstance++;
}

TAbscissa::TAbscissa() {
    id = generateId();
}

TAbscissa::TAbscissa(const TPoint& PP0, const TPoint& PP1)
: TBisector(PP0, PP1)
{
    id = generateId();

    ComputeLength();
}


TAbscissa::TAbscissa(const Element & ele)
: TBisector(ele)
{
    id = generateId();

    ComputeLength();
}



TAbscissa & TAbscissa::operator =(const TAbscissa& a) {

    *U = *(a.U);
    *X0 = *(a.X0);

    length = a.length;

    return *this;
}

TAbscissa::~TAbscissa() {
}

void TAbscissa::SetPoints(const TPoint& PP0, const TPoint& PP1) {
    TBisector::SetPoints(PP0, PP1);
    ComputeLength();
}

void TAbscissa::ComputeLength() {

    length = U->Length();
}

double TAbscissa::Length() {
    return length;
}

BoundingBox &TAbscissa::get_bounding_box() {
	arma::vec3 minCoor;
	arma::vec3 maxCoor;

	for (int i=0; i<3; ++i) {
		minCoor(i) = GetMin(i+1);
		maxCoor(i) = GetMax(i+1);
	}

	boundingBox=BoundingBox(minCoor, maxCoor);

	return boundingBox;
}

double TAbscissa::GetMin(int x) const {
    if (U == NULL ) printf("U is null!");
    if (U->Get(x) < 0 ) {
        return U->Get(x)+X0->Get(x);
    } else {
        return X0->Get(x);
    }
}

double TAbscissa::GetMax(int x) const {
    if (U->Get(x) > 0 ) {
        return U->Get(x)+X0->Get(x);
    } else {
        return X0->Get(x);
    }
}

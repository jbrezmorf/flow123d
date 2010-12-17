#!/bin/bash
# 
# Copyright (C) 2007 Technical University of Liberec.  All rights reserved.
#
# Please make a following refer to Flow123d on your project site if you use the program for any purpose,
# especially for academic research:
# Flow123d, Research Centre: Advanced Remedial Technologies, Technical University of Liberec, Czech Republic
#
# This program is free software; you can redistribute it and/or modify it under the terms
# of the GNU General Public License version 3 as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program; if not,
# write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 021110-1307, USA.
#
# $Id$
# $Revision$
# $LastChangedBy$
# $LastChangedDate$
#

#SCRIPT_DIR_PATH is defined in run_flow.sh and it's absolut path to dir wehere is flow_run.sh
#MPI_RUN is defined in run_flow.sh and its relative path to bin/mpiexec
#EXECUTABLE is defined in run_flow.sh and its relative path to bin/flow123d (.exe)

echo "
#!/bin/bash
#
#$ -cwd
#$ -j y
#$ -S /bin/bash
#
 
cd $FILE_PATH_DIR
touch lock
export OMPI_MCA_plm_rsh_disable_qrsh=1
$SCRIPT_DIR_PATH/$MPI_RUN $NSLOTS $SCRIPT_DIR_PATH/$EXECUTABLE -s $INI 2>err 1>out
rm lock" >hydra_run_pbs.qsub

chmod u+x hydra_run_pbs.qsub
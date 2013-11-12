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
# This makefile just provide main rules for: build, documentation and testing
# Build itself takes place in ../<branch>-build
#

# check and possibly set build_tree link
NULL=$(shell bin/git_post_checkout_hook)

# following depends on git_post_checkout_hook
BUILD_DIR=$(shell cd -P ./build_tree && pwd)
SOURCE_DIR=$(shell pwd)


ifndef N_JOBS
  N_JOBS=2
endif  


all:  install_hooks build_flow123d 

# this is prerequisite for evry target using BUILD_DIR variable
update_build_tree:
	bin/git_post_checkout_hook

# timing of parallel builds (on Core 2 Duo, 4 GB ram)
# N JOBS	O3	g,O0	
# 1 		51s	46s
# 2 		30s	26s
# 4 		31s	27s
# 8 		30s
build_flow123d: update_build_tree cmake
	make -j $(N_JOBS) -C $(BUILD_DIR) bin/flow123d


# This target only configure the build process.
# Useful for building unit tests without actually build whole program.
cmake:  update_build_tree
	if [ ! -d "$(BUILD_DIR)" ]; then mkdir -p $(BUILD_DIR); fi
	cd $(BUILD_DIR); cmake "$(SOURCE_DIR)"

	
# add post-checkout hook
install_hooks:
	if [ ! -e .git/hooks/post-checkout ];\
	then cp bin/git_post_checkout_hook .git/hooks/post-checkout;\
	fi	
		

# Save config.cmake from working dir to the build dir.
save_config: update_build_tree
	cp -f $(SOURCE_DIR)/config.cmake $(BUILD_DIR)
	
# Restore config.cmake from build dir, possibly overwrite the current one.	
load_config: update_build_tree
	cp -f $(BUILD_DIR)/config.cmake $(SOURCE_DIR)

	
# Remove all generated files
clean: update_build_tree cmake
	make -C $(BUILD_DIR) clean

# Remove all  build files. (not including test results)
clean-all: update_build_tree
	-make -C $(BUILD_DIR) clean-links	# ignore errors
	rm -rf $(BUILD_DIR)


# Make all tests	
testall:
	make -C tests testall

# Make only certain test (eg: make 01.tst will make first test)
%.tst :
	make -C tests $*.tst

# Clean test results
clean_tests:
	make -C tests clean


# Create doxygen documentation
online-doc:
	make -C doc/doxy doc



############################################################################################
# manual directory
DOC_DIR=$(SOURCE_DIR)/doc/reference_manual

# Generate user manual using Latex sources and input reference generted by Flow123d binary.  
gen_doc: $(DOC_DIR)/input_reference.tex

# creates the file that defins additional information 
# for input description generated by flow123d to Latex format
# this file contains one replace rule per line in format
# \add_doc{<tag>}<replace>
# 
# this replace file is applied to input_reference.tex produced by flow123d
#

# call flow123d and make raw input_reference file
$(DOC_DIR)/input_reference_raw.tex: build_flow123d	 	
	$(BUILD_DIR)/bin/flow123d --latex_doc | grep -v "DBG" | \
	sed 's/->/$$\\rightarrow$$/g' > $(DOC_DIR)/input_reference_raw.tex

# make empty file with replace rules if we do not have one
$(DOC_DIR)/add_to_ref_doc.txt: 
	touch $(DOC_DIR)/add_to_ref_doc.txt
	
# update file with replace rules according to acctual patterns appearing in input_refecence		
update_add_doc: $(DOC_DIR)/input_reference_raw.tex $(DOC_DIR)/add_to_ref_doc.txt
	cat $(DOC_DIR)/input_reference_raw.tex \
	| grep 'AddDoc' |sed 's/^.*\(\\AddDoc{[^}]*}\).*/\1/' \
	> $(DOC_DIR)/add_to_ref_doc.list
	$(DOC_DIR)/add_doc_replace.sh $(DOC_DIR)/add_to_ref_doc.txt $(DOC_DIR)/add_to_ref_doc.list	
	
# make final input_reference.tex, applying replace rules
$(DOC_DIR)/input_reference.tex: $(DOC_DIR)/input_reference_raw.tex update_add_doc
	$(DOC_DIR)/add_doc_replace.sh $(DOC_DIR)/add_to_ref_doc.txt $(DOC_DIR)/input_reference_raw.tex $(DOC_DIR)/input_reference.tex	
	
		
################################################################################################
# release packages

lbuild=linux_build
linux_package: #clean clean_tests all
	# copy bin
	rm -rf $(lbuild)
	mkdir -p $(lbuild)/bin/mpich
	mpiexec=`cat bin/mpiexec |grep mpiexec |sed 's/ ".*$$//'|sed 's/"//g'`;\
	cp "$${mpiexec}" $(lbuild)/bin/mpich/mpiexec
	cp -r bin/flow123d bin/flow123d.sh bin/ndiff bin/tests bin/ngh/bin/ngh bin/bcd/bin/bcd $(lbuild)/bin
	cp -r bin/paraview $(lbuild)/bin
	# copy doc
	mkdir $(lbuild)/doc
	cp -r doc/articles doc/reference_manual/flow123d_doc.pdf doc/petsc_options_help $(lbuild)/doc
	# copy tests
	cp -r tests $(lbuild)

linux_pack:
	cd $(lbuild); tar -cvzf ../flow_build.tar.gz .

	

# *
# * Copyright 2016 -- 2022 IBM Corporation
# *
# * Licensed under the Apache License, Version 2.0 (the "License");
# * you may not use this file except in compliance with the License.
# * You may obtain a copy of the License at
# *
# *     http://www.apache.org/licenses/LICENSE-2.0
# *
# * Unless required by applicable law or agreed to in writing, software
# * distributed under the License is distributed on an "AS IS" BASIS,
# * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# * See the License for the specific language governing permissions and
# * limitations under the License.
# *

# *****************************************************************************
# *                            cloudFPGA
# *----------------------------------------------------------------------------
# *
# * Description : A makefile to simulate, synthesize and package the current
# *   HLS core as an IP.
# * 
# * Synopsis:
# *   make help 
# *
# *****************************************************************************

# Name of the HLS IP to build
ipName =udp_app

#-- Dependencies --------------------------------------------------------------
DEPS := $(shell find ./src/ -type f)

.PHONY: all sim cosim cosim_view

assert_env: # Assert ENVIRONMENT 
	@echo "This HLS IP Core needs the cFp environment activated....checking..."
	@#We need to match the case with and without PR
	@( [ -f ../../../../cFDK/SRA/LIB/bash/assert_envs.sh ] && ../../../../cFDK/SRA/LIB/bash/assert_envs.sh ) || ../../../cFDK/SRA/LIB/bash/assert_envs.sh

${ipName}_prj/solution1/impl/ip: $(DEPS)
	@#rm -rf $@
	rm -rf ${ipName}_prj
	export hlsSim=0; export hlsCoSim=0; vivado_hls -f run_hls.tcl
	@cat ${ipName}_prj/solution1/syn/report/${ipName}_csynth.rpt
	@#touch ${ipName}_prj
	@touch $@
	@touch ../../.ip_guard

#-- Targets -------------------------------------------------------------------

all: ${ipName}_prj/solution1/impl/ip

clean:              	## Cleans this IP project
	${RM} -rf ${ipName}_prj
	${RM}     vivado*.log

project:                ## Creates an IP project for simulation, synthesis and co-simulation
	$(MAKE) clean
	export hlsCSim=0; export hlsCSynth=0; export hlsCoSim=0; export hlsRtl=0; vivado_hls -f run_hls.tcl

csim: assert_env clean	## Runs the HLS C simulation of this IP project
	export hlsCSim=1; export hlsCSynth=0; export hlsCoSim=0; export hlsRtl=0; vivado_hls -f run_hls.tcl

cosim: assert_env      	## Runs the HLS C/RTL cosimulation of this IP project 
	@#rm -rf ${ipName}_prj
	export hlsCSim=0; export hlsCSynth=0; export hlsCoSim=1; export hlsRtl=0; vivado_hls -f run_hls.tcl

cosim_view:
	@/bin/echo -e "current_fileset\nopen_wave_database $(ipName).wdb\n" > ./$(ipName)_prj/solution1/sim/verilog/open_wave.tcl
	cd ./$(ipName)_prj/solution1/sim/verilog/; vivado -source open_wave.tcl

help:					## Shows this help message
    # This target is for self documentation of the Makefile. 
    # Every text starting with '##' and placed after a target will be considered as helper text.
	@echo
	@echo 'Usage:'
	@echo '    make [target]'
	@echo
	@echo 'Targets:'
	@egrep '^(.+)\:\ .*##\ (.+)' ${MAKEFILE_LIST} | sed -n 's/\([a-zA-Z0-9]*\): \(.*\)##\(.*\)/\1 ;\3/p' | column -t -c 2 -s ';' | sed -e 's/^/    /'
	@echo

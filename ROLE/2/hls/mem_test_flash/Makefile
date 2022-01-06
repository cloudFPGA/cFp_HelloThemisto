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
# *
# * Description : A makefile to simulate, synthesize and package the current
# *   HLS core as an IP
# * 
# * Synopsis:
# *   make [target]
# *
# ******************************************************************************

# Name of the HLS core to build
ipName =mem_test_flash

DEPS := $(shell find ./src/ -type f)

.PHONY: all sim cosim cosim_view
all: ${ipName}_prj/solution1/impl/ip

${ipName}_prj/solution1/impl/ip: $(DEPS)
	@#rm -rf $@
	rm -rf ${ipName}_prj
	@cp ./src/memory_size_real.hpp ./src/dynamic.hpp
	export hlsSim=0; export hlsCoSim=0; vivado_hls -f run_hls.tcl
	@#touch ${ipName}_prj
	@rm -f ./src/dynamic.hpp
	@touch $@
	@touch ../../.ip_guard

sim: 
	@cp ./src/memory_size_debug.hpp ./src/dynamic.hpp
	export hlsSim=1; export hlsCoSim=0; vivado_hls -f run_hls.tcl
	@rm -f ./src/dynamic.hpp


cosim: 
	@#rm -rf ${ipName}_prj
	@/bin/echo -e "This CoSim runs with smaller test sizes than the synthezised design!\nSo it must be rebuild again for the synthesis.\n"
	@cp ./src/memory_size_debug.hpp ./src/dynamic.hpp
	export hlsSim=0; export hlsCoSim=1; vivado_hls -f run_hls.tcl
	@rm -rf ${ipName}_prj/solution1/impl/ip
	@rm -f ./src/dynamic.hpp

cosim_view:
	@/bin/echo -e "current_fileset\nopen_wave_database $(ipName)_main.wdb\n" > ./$(ipName)_prj/solution1/sim/verilog/open_wave.tcl
	cd ./$(ipName)_prj/solution1/sim/verilog/; vivado -source open_wave.tcl

clean:
	rm -rf ${ipName}_prj
	rm vivado*.log



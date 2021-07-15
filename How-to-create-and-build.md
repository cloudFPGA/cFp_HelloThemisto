How to create and build `cFp_Triangle`
==========================================

This is a short tutorial on how to create and build a Triangle example by yourself.
You have access to the files with via `cloudFPGA-RELEASES` folder, with the links provided to you.

## About Triangle

This example, called Triangle, is a distributed FPGA application where one CPU sends a UDP or TCP packet to FPGA 1, which forwards it to FPGA 2, which forwards it back to the CPU. For more details and "runtime instructions" please see the PDF `Triangle_example.pdf`.

## 0. Prerequisites:

We need the following archives:

1. `ROLE-Trianlge_<version>.zip`
2. `cFBuild_<version>.zip`    
3. `cFDK_<version>.zip`

Download all three and *extract the first two.*

Next, please follow the setup steps in the Requirements section of the `Readme.md` of the `cFBuild` tool, also in the PDF `cFBuild__cloudFPGA_Build_Framework.pdf`.

Finally, Vivado (either version 2017.4 or 2019.2) must be installed.


## 1. Creating a cloudFPGA project (cFp)

First, we need an empty folder where the project will be placed: `mkdir cFp_some_name` (this folder should be somewhere outside the extracted zipfiles and we just need the path to it).

Next, go to the extracted `cFBuild` folder (where also the required python virtual environment should be) and execute:

```bash
./cFBuild new --cfdk-zip=<path-to-downloaded-cFDK-zip> <path-to-a-new-but-empty-folder>
```

Answer the questions with:

1. `FMKU60`
2. `Themisto`
3. `No` (i.e. hit `n`)
4. `default`


Afterwards, the `cFp_some_name` folder should contain the basic structure:

```bash
$ tree -L 1
.
├── cFDK
├── cFp.json
├── env
├── Makefile
├── ROLE
└── TOP

4 directories, 2 files

```

However, the `ROLE` folder, where the applications will be placed, is still empty. Hence, copy the content of the Role-triangle.zip into the `cFp_some_name/ROLE/` folder (directly, for instance the top Role vhdl file should have the path `cFp_some_name/ROLE/hdl/Role.vhdl`).



## 2. Building of the cFp (creating a bitstream)

Once a cFp, its `env` folder, and its `cFp.json` are created, it can be build with:

```bash
cd cFp_some_name
source /opt/Xilinx/Vivado/2019.2/settings64.sh  # or whereever it is installed
source env/setenv.sh  # important!
make monolithic   # to build Shell and Role
```

After ~1 hour, the resulting bitfile will be in `cFp_some_name/dcps` (subsequent builds are faster).


## 3. Running cFp_Triangle

This bitfile can be uploaded via `POST /cluster` to the cloudFPGA Resource Manager (CFRM).

For further instructions, please refer to the `Triangle-example.pdf` or the `cFp_Triangle/Readme.md`.

The `Themisto_SRA.pdf` (or the `cFDK/DOC/Themisto.md`) explains the details of the cFDK network and memory interfaces.

In case you want to open the created Vivado project, execute `vivado cFp_some_name/xrp/topFMKU60.xpr`. This is not necessary to use the cFDK, but some people are curious... ;)

## Final notices

* You should not change anything inside the `cFDK` or `TOP` folders, since this is maintained by us and maybe overwritten with the next version release.
* If you want to use Git as version management system, the `--git-init` flag for the `cFBuild new` command is recommended.
* All `Makefiles` require the cFDK environment, so always run `source /env/setenv.sh` in new terminals.



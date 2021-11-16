How to create and build `cFp_Triangle`
==========================================

This is a short tutorial on how to create and build a Triangle example by yourself.
You have access to the files with via `cloudFPGA-RELEASES` folder, with the links provided to you.

## About Triangle

This example, called Triangle, is a distributed FPGA application where one CPU sends a UDP or TCP packet to FPGA 1, which forwards it to FPGA 2, which forwards it back to the CPU (see further in section 5 below).

## 0. Prerequisites:

We need the following archives:

1. `ROLE-Trianlge_<version>.zip`
2. `cFCreate_<version>.zip`    
3. `cFDK_<version>.zip`

Download all three and *extract the first two.*

Next, please follow the setup steps in the Requirements section of the `Readme.md` of the `cFCreate` tool, also in the PDF `cFCreate_Readme.pdf`.

Finally, Vivado (either version 2017.4 or 2019.2) must be installed.

## 1. Creating a cloudFPGA project (cFp)

First, we need an empty folder where the project will be placed: `mkdir cFp_some_name` (this folder should be somewhere outside the extracted zipfiles and we just need the path to it).

Next, go to the extracted `cFCreate` folder (where also the required python virtual environment should be) and execute:

```bash
./cFCreate new --cfdk-zip=<path-to-downloaded-cFDK-zip> <path-to-a-new-but-empty-folder>
```

Answer the questions with:

1. `FMKU60`
2. `Themisto`

Afterwards, the `cFp_some_name` folder should contain the basic structure:

```bash
$ tree -L 1
.
├── cFDK
├── cFp.json
├── lignin
├── env
├── Makefile
├── ROLE
└── TOP

4 directories, 3 files
```

However, the `ROLE` folder, where the applications will be placed, is still empty. Hence, copy the content of the Role-triangle.zip into the `cFp_some_name/ROLE/` folder (directly, for instance the top Role vhdl file should have the path `cFp_some_name/ROLE/hdl/Role.vhdl`).

## 2. Building of the cFp (creating a partial bitstream)

Once a cFp, its `env` folder, and its `cFp.json` are created, it can be build with:

```bash
cd cFp_some_name
source /opt/Xilinx/Vivado/2019.2/settings64.sh  # or whereever it is installed
source env/setenv.sh  # important!
./lignin config add-role ./ROLE/ "1st-role"   # add role to project config
./lignin config use-role "1st-role"  # set as active role
./lignin update-shell  # getting latest .dcp
./lignin build pr   # building partial bitfile for the 1st role
```

The command `./lignin update-shell` requires a connection to the CFRM (cloudFPGA Resource Manager inside ZYC2) and your account credentials (stored in `user.json`). However, this is only required if a new Shell version is released, so it is also suitable if this command is run on another machine (with ZYC2 access) and the downloaded files (`dcps/3_topFMKU60_STATIC.dcp` and `dcps/3_topFMKU60_STATIC.json`) are copied to the build machine (*see details below*).

After ~45min, bitfile will be in `cFp_some_name/dcps.`  With the role name `1st-role` the result should look like:

```bash
$ cd cFp_some_name
$ ls -al dcps/
 2_topFMKU60_impl_1st-role_complete_pr.dcp
 3_topFMKU60_STATIC.dcp
 3_topFMKU60_STATIC.json
 4_topFMKU60_impl_1st-role_pblock_ROLE_partial.bin
 4_topFMKU60_impl_1st-role_pblock_ROLE_partial.bin.sig
 4_topFMKU60_impl_1st-role_pblock_ROLE_partial.bit
 4_topFMKU60_impl_1st-role_pblock_ROLE_partial_clear.bin
 4_topFMKU60_impl_1st-role_pblock_ROLE_partial_clear.bit
 pr_verify.rpt
```

## ### getting latest Shell manually

1. Go to the CFRM and to the API call `GET /composablelogic/py_shell/` , and ask for `Themisto`.

2. pick the newest entry in the returned list (i.e. the highest `id`)

3. with this **cl_id**, download the dcp from the call `GET /composablelogic/{cl_id}/dcp` and save it as `3_topFMKU60_STATIC.dcp` in the `dcp` folder (and maybe somewhere else, to copy it again after a `make clean`).

4. proceed similarly with `GET /composablelogic/{cl_id}/meta` and save the returning JSON as `3_topFMKU60_STATIC.json` in the same place

5. continue with `./lignin build pr`

## 3. Uploading partial bitfile as app image

Navigate to the CFRM (`https://10.12.0.132:8080/ui`) and the API call `POST /images/app_logic` (in the **Images** section) to upload the partial bitfile.

As `image_details` , submit something like:

```json
{
  "cl_id": "<t.b.a>",
  "fpga_board": "FMKU60",
  "shell_type": "Themisto",
  "comment" : "my first role"  
}
```

The `cl_id` must be the same as in the `dcps/3_topFMKU60_STATIC.json` file. 

As `image_file` attach the partial bitfile, so `4_topFMKU60_impl_1st-role_pblock_ROLE_partial.bin` in the example. 

To ensure integrity of the build (and to protect the FPGAs), two more files from the `dcps` directory are required:

1. `4_topFMKU60_impl_1st-role_pblock_ROLE_partial.bin.sig` containing hashes from the build process

2. `pr_verify.rpt` containing the output of the automatically run `pr_verify` command.

Finally, execute the API command.

The returning data contains an `id` field, which is the **image-id** used in subsequent steps.

## 4. Deploying cFp_Triangle

Once this image is available, a cluster can be created via the `POST /cluster` command. 

As `cluster_details` , submit something like:

```
[
  {
    "image_id": "<the-image-id-of-step-3>",
    "node_id": 1
  },{
    "image_id": "<the-image-id-of-step-3>",
    "node_id": 2
  },{
    "image_id": "NON_FPGA",
    "node_ip":  "<the-associated-floating-ip-of-your-VM>",
    "node_id": 0
  }
]
```

## 5. Running cFp_Triangle

### Idea:

```
   CPU  (... -->  FPGA ... ) -->  FPGA 
    /\_____________________________|
```

### Bash example

All communication goes over the *UDP/TCP port 2718*. Hence, the CPU should run:

```bash
$ ping <FPGA 1>
$ ping <FPGA 2>
# Terminal 1
nc -u <FPGA 1> 2718   # without -u for TCP
# Terminal 2
nc -lu 2718           # without -u for TCP
```

Then the packets will be send from Terminal 1 to 2. 

For more details, `tcpdump -i <interface> -nn -s0 -vv -X port 2718` could be helpful. 

The *Role* is the same for both FPGAs, because which destination the packets will have is determined by the `node_id`/`node_rank` and `cluster_size`
(VHDL ports`piFMC_ROLE_rank` and `piFMC_ROLE_size`).

The **Role forwards the packet always to `(node_rank + 1) % cluster_size`** (for UDP and TCP packets), so this example works also for more or less then two FPGAs, actually.

### Firewall issues

Some firewalls may block network packets if there is not a connection to the remote machine/port. 
Hence, to get the Triangle example to work, the following commands may be necessary to be executed (as root):

```
$ firewall-cmd --zone=public --add-port=2718-2750/udp --permanent
$ firewall-cmd --zone=public --add-port=2718-2750/tcp --permanent
$ firewall-cmd --reload
```

Also, ensure that the network security group settings are updated (e.g. in case of the ZYC2 OpenStack).

## Final notices

* You should *not* change anything inside the `cFDK` , `env`, or `TOP` folders, since this is maintained by us and maybe overwritten with the next version release.

* If you want to use Git as version management system, the `--git-init` flag for the `cFCreate new` command is recommended.

* All scripts and Makefiles  require the cFDK environment, so always run `source env/setenv.sh` in new terminals.

* The `Themisto_SRA.pdf` (or the `cFDK/DOC/Themisto.md`) explains the details of the cFDK network and memory interfaces.

* In case you want to open the created Vivado project, execute `vivado cFp_some_name/xpr/topFMKU60.xpr`. This is not necessary to use the cFDK, but some people are curious... ;) Also, debug probes can be inserted that way.
  
  (However, debugging with partial bitfiles is not yet supported).
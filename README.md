# cFp_HelloThemisto

A cloudFPGA project built upon the shell **Themisto**.

| :information_source: | The cloudFPGA documentation is available at [https://cloudfpga.github.io/Doc](https://cloudfpga.github.io/Doc/pages/INTRODUCTION/introduction.html)  |
|:--------------------:|----------------------------------------------------------------------------------------------------------------------------------------------------- |

## Overview

The integration of a user application and a cloudFPGA shell into a top-level design is what 
constitutes a [cloudFPGA project](https://cloudfpga.github.io/Doc/pages/PROJECTS/cfprojects.html#).

This project builds on the shell [Themisto](https://github.com/cloudFPGA/cFDK/blob/main/DOC/Themisto.md)
which is a shell with enhanced routing support for node-to-node communications. It exemplifies
the creation of a cluster consisting of one CPU and two FPGAs organized in a ring topology.

This setup is shown in the figure below and the scenario is as follows: a **virtual machine** (VM) 
sends data to a 1st FPGA (F1) via a UDP and/or a TCP network connection. When F1 is done with the 
processing of the incoming data, it forwards them to the next FPGA in the ring (i.e. F2), using 
the same network protocol as the incoming traffic. Finally, F2 which is the last FPGA of the 
ring, sends the data back to the VM after applying its own processing. 

![Setup-of-the cFp_HelloThemisto project](./DOC/imgs/Fig-HelloThemisto-Setup.png)

The shell [Themisto](https://github.com/cloudFPGA/cFDK/blob/main/DOC/Themisto.md) uses the
concept of *MPI communicator* in which each cloudFPGA role application is assigned a unique 
number to identify itself. This number is called the `node_rank` (or `rank` for short), its value 
always ranges from 0 to *cluster-size-1* and that value does not change once the cluster is created.

The two FPGA applications of this project leverage both their `node_rank` and the `cluster_size`
to determine the address of the next node in the following manner: 
  ```
      next_node_rank = (curr_node_rank + 1) % cluster_size
  ```
As a result, the rudimentary size of the proposed ring-based cluster can be extended by simply 
inserting more such FPGA application nodes into the ring.

## Shell-Role-Architecture
In **cloudFPGA** (cF), a user application is referred to as a **ROLE** and is integrated
along with a **SHELL** that abstracts the hardware components of the FPGA module.
The combination of a specific ROLE and its associated SHELL into a top-level design (**TOP**) is
referred to as a **Shell-Role-Architecture** (SRA).

The shell-role-architecture used by the project *cFp_HelloThemisto* is shown in the following 
figure. It consists of:
- a SHELL of type [_**Themisto**_](https://github.com/cloudFPGA/cFDK/blob/main/DOC/Themisto.md).
  This is the current default cloudFPGA shell because it supports **Partial Reconfiguration** (PR) 
  and can therefore be paired with a dynamically configured user role application. Additionally, the
  reconfiguration of such a role is performed by the *Themisto* shell itself, upon reception of a 
  new partial bitstream for the application via the TCP/IP network of the data center. The shell 
  *Themisto* includes the following building blocks:
  * a [10 Gigabit Ethernet (ETH)](https://github.com/cloudFPGA/cFDK/blob/main/DOC/ETH/ETH.md) sub-system,
  * a [Network Transport Stack (NTS)](https://github.com/cloudFPGA/cFDK/blob/main/DOC/NTS/NTS.md),
  * a [Network Abstraction Layer (NAL)](https://github.com/cloudFPGA/cFDK/blob/main/DOC/NAL/NAL.md),
  * a [FPGA Management Core (FMC)](https://github.com/cloudFPGA/cFDK/blob/main/DOC/FMC/FMC.md),
  * a [DDR4 Memory sub-system (MEM)](https://github.com/cloudFPGA/cFDK/blob/main/DOC/MEM/MEM.md),
  * a [Memory Mapped IO (MMIO)](https://github.com/cloudFPGA/cFDK/blob/main/DOC/MMIO/MMIO.md) sub-system.
- a ROLE of type [_**HelloThemisto**_](./DOC/README.md) which implements the set of TCP- and 
  UDP- applications used by this project.

![Block diagram of the HelloThemistoTop](./DOC/imgs/Fig-TOP-HelloThemisto.png#center)
<p align="center">Toplevel block diagram of the cFp_HelloThemisto project</p>

**Info/Warning**
  * You will be able to generate the FPGA bitstreams of this cluster example project on your 
    computer but you won't be able to deploy and access the cluster without connecting to the 
    cloudFPGA infrastructure via VPN. To get such an access granted, you need to request a cloudFPGA 
    account [here](https://github.com/cloudFPGA/Doc/tree/master/imgs/COMING_SOON.md).  
  * Next, please note that the following PR build procedure is only compatible with *Vivado* 
    **2019.2** to **2020.1** versions included (for the time being).

## How to build the project

The current directory contains the `sra` build script which handles all the required steps to 
generate the *partial bitstreams* needed for this project. During the build, both SHELL and 
ROLE dependencies are analyzed to solely re-compile and re-synthesize the components that 
must be recreated.
```
  $ SANDBOX=`pwd`           # (a short for your working directory)
```

### Step-1: Clone and configure the project
```
  $ cd ${SANDBOX}

  $ git clone --recursive git@github.com:cloudFPGA/cFp_HelloThemisto.git
      (if you don't have a GitHub account and/or SSH keys set up, use the command: 
       git clone --recursive https://github.com/cloudFPGA/cFp_HelloThemisto.git)
  
  $ cd cFp_HelloThemisto/cFDK
  $ git checkout main
  $ cd ..
```

### Step-2: Setup your environment
```
    $ cd ${SANDBOX}/cFp_HelloThemisto
    $ source env/setenv.sh
```

### Step-3: Add your cloudFPGA credentials

Create a file called `user.json` and add your cloudFPGA credentials in it. The credentials 
consist of the `username`, the `password` and the `projectname` that were provided to you when 
you registered.
```
  $ echo "{\"credentials\": {\"user\": \"YOUR_USERNAME\", \"pw\": \"YOUR_PASSWORD\" }, \"project\": \"YOUR_PROJECTNAME\"}" > user.json
```

### Step-4: Retrieve the latest static shell

Use the command `./sra update-shell` to download the latest DCP shell from the *cloudFPGA Resource 
Manager* (cFRM).
```
  $ cd ${SANDBOX}/cFp_HelloThemisto
  
  $ ./sra update-shell
  [cFBuild] Updated dcp of Shell 'Themisto' to latest version (2) successfully. DONE.
      (downloaded dcp to ${SANDBOX}/cFp_HelloThemisto/dcps/3_topFMKU60_STATIC.dcp)
```

### Step-5: Activate the 1st role (optional) and generate corresponding partial bitstream

This project contains two roles but only one role can be active at a time. So we need to specify 
the current active role to build and implicitly deactivate the other one. This step is optional if 
you just cloned this project because the default active role is already set to `msg-ring-app`. 
```
  $ cd ${SANDBOX}/cFp_HelloThemisto
  
  $ ./sra config use-role "msg-ring-app"
```
Now, generate a partial bitstream for the current active role (i.e `msg-ring-app`):
```
  $ cd ${SANDBOX}/cFp_HelloThemisto
  
  $ ./sra build pr
```
The build is successful if you get the following message after ~40 minutes, indicating that a 
partial bitstream was generated.
```
  <cloudFPGA> ################################################################################
  <cloudFPGA> ##  DONE WITH BITSTREAM GENERATION RUN 
  <cloudFPGA> ################################################################################
  <cloudFPGA> End at: HH:MM:SS Day Month Day Year
```
You will find this newly created bitstream together with other generated files in the folder 
`${SANDBOX}/cFp_HelloThemisto/dcps` under the name  
`4_topFMKU60_impl_msg-ring-app_pblock_ROLE_partial.<bin|sig|bit|rtp>` as shown below: 
 ```
  $ ls -al ${SANDBOX}/cFp_HelloThemisto/dcps/
  2_topFMKU60_impl_msg-ring-app_complete_pr.dcp
  3_topFMKU60_STATIC.dcp
  3_topFMKU60_STATIC.json
  4_topFMKU60_impl_msg-ring-app_pblock_ROLE_partial.bin
  4_topFMKU60_impl_msg-ring-app_pblock_ROLE_partial.bin.sig
  4_topFMKU60_impl_msg-ring-app_pblock_ROLE_partial.bit
  4_topFMKU60_impl_msg-ring-app_pblock_ROLE_partial_clear.bin
  4_topFMKU60_impl_msg-ring-app_pblock_ROLE_partial_clear.bit
  5_topFMKU60_impl_msg-ring-app_pblock_ROLE_partial.rpt
  pr_verify.rpt
```

### Step-6: Activate and generate a partial bitstream for the 2nd role

You can check the currently active role as well as the list of defined roles for this project with
the command:
```
  $ cd ${SANDBOX}/cFp_HelloThemisto
  
  $ ./sra config show
  [sra:INFO] The following roles are currently defined:
  Role msg-ring-app in directory ${SANDBOX}/cFp_HelloThemisto/ROLE/1
  Role invertcase-ring-app in directory ${SANDBOX}/cFp_HelloThemisto/ROLE/2
  Current active role: msg-ring-app
```
Now select and activate the role `invertcase-ring-app`, and generate a partial bitstream for 
this 2nd role:
```
  $ cd ${SANDBOX}/cFp_HelloThemisto
  $ ./sra config use-role "invertcase-ring-app"
  
  $ ./sra build pr
```
After another ~40 minutes, the following files will be added to the `./dcps` directory:
```
  $ ls -al ${SANDBOX}/cFp_HelloThemisto/dcps/*invertcase*
  2_topFMKU60_impl_invertcase-ring-app_complete_pr.dcp
  4_topFMKU60_impl_invertcase-ring-app_pblock_ROLE_partial.bin
  4_topFMKU60_impl_invertcase-ring-app_pblock_ROLE_partial.bin.sig
  4_topFMKU60_impl_invertcase-ring-app_pblock_ROLE_partial.bit
  4_topFMKU60_impl_invertcase-ring-app_pblock_ROLE_partial_clear.bin
  4_topFMKU60_impl_invertcase-ring-app_pblock_ROLE_partial_clear.bit
  5_topFMKU60_impl_invertcase-ring-app_pblock_ROLE_partial.rpt
```

## How to deploy the cluster

### Step-7: Upload the generated PR bitstreams

Before we can deploy this cluster consisting of one CPU and two FPGAs, we first need to upload the 
newly generated PR bitfiles of our two roles. We refer to such PR bitfiles as *application image*
or **app_image** for short. The below step-7a and step-7b cover the two possible options for 
uploading these two generated application images.  

#### Step-7a: Upload the application images with the GUI-API

The cloudFPGA resource manager provides a web-based graphical user interface to its API. It is 
available as a [Swagger UI](https://swagger.io/tools/swagger-ui/) at 
```http://10.12.0.132:8080/ui/#/```.

To upload the *app_image* corresponding to the role `msg-ring-app`, expand the Swagger menu 
**Images** and the operation `[POST] /images/app_logic - Upload an image of type app_logic`. 
Then, fill in the fields 1 to 6 as exemplified below:
  1) with your **username** for accessing the cloudFPGA infrastructure
  2) with your **password**
  3) with specific **image_details** about the *app_image* to upload
     * INFO: You must submit this information in a dictionary format, similar to the following example:
       ```
           { 
             "cl_id"      : "2",
             "fpga_board" : "FMKU60",
             "shell_type" : "Themisto",
             "comment"    : "The 1st app_image (msg-ring-app)"  
           }
       ```
     * **WARNING**: The "cl_id" field stands for _composable_logic_id_ and its value **MUST BE THE SAME** as the `id` specified in the `dcps/3_topFMKU60_STATIC.json` file **!!**
  4) with the **image_file.bin** corresponding to the partial bitfile of the 1st role
     * With respect to the `msg-ring-app` example --> `4_topFMKU60_impl_msg-ring-app_pblock_ROLE_partial.bin`
  5) with the **signature_file.bin.sig** corresponding to the current _imagefile.bin_    
     * With respect to the `msg-ring-app` example --> `4_topFMKU60_impl_msg-ring-app_pblock_ROLE_partial.bin.sig` 
  6) with the **pr_verify.rpt** file containing the output of *pr_verify* command for this build.
     * With respect to the `msg-ring-app` example --> `4_topFMKU60_impl_msg-ring-app_pblock_ROLE_partial.rpt`
  
![Swagger-Images-Post-Upload-Req](./DOC/imgs/Img-Swagger-Images-POST-Upload-Req.png#center)

Next, scroll down to the *Response body* section of the server and write down the image `id` for
use in the next step.

![Swagger-Images-Post-Upload-Res](./DOC/imgs/Img-Swagger-Images-POST-Upload-Res.png#center)

Repeat step-7a for the second bitstream called `invertcase_ring_app`.

#### Step-7b: Upload image with the cFSP-API

The second option for uploading a PR bitstream is based on a command-line interface to the cFRM API.
This method is provided by the **cloudFPGA Support Package** (cFSP) which must be installed
beforehand as follows:
```
  $ cd ${SANDBOX}
   
  $ git clone https://github.com/cloudFPGA/cFSP.git
  $ cd cFSP
  $ which python3     # (we recommend python 3.6 or higher) 
  /usr/bin/python3
  $ virtualenv -p /usr/bin/python3 cfenv
  $ source cfenv/bin/activate
  $ pip install -r requirements.txt
``` 
Once cFSP is installed, add your cloudFPGA credentials. This process creates a file called 
`user.json` which has your cloudFPGA credentials in it. The credentials consist of the `username`, 
the `password` and the `projectname` that were provided to you when you registered.
```
  $ cd ${SANDBOX}/cFSP
    
  $ ./cfsp user load --username=<YOUR_USERNAME> --password=<YOUR_PASSWORD> --project=<YOUR_PROJECTNAME>
    
  $ ./cfsp user show
```
The output of these two commands will look like this:
```
  0%|                                                                                                                | 0/1 [00:00<?, ?it/s]INFO: Repeat #0
  Writing credentials template to ./user.json
  ['load']
  100%|██████████████████████████████████████████████████████████████████████████████████████████████████████| 1/1 [00:00<00:00, 3305.20it/s]
  
  0%|                                                                                                                | 0/1 [00:00<?, ?it/s]INFO: Repeat #0
  User     : YOUR_USERNAME
  Password : YOUR_PASSWORD
  Project  : YOUR_PROJECTNAME
  ['show']
  100%|██████████████████████████████████████████████████████████████████████████████████████████████████████| 1/1 [00:00<00:00, 5801.25it/s]    
```
Finally, upload the generated bitstreams located in the `dcps` folder of the 
`${SANDBOX}/cFp_HelloThemisto` project as follows:
```
  $ cd ${SANDBOX}/cFSP
    
  $ ./cfsp image post-app-logic --image_file=${SANDBOX}/cFp_HelloThemisto/dcps/4_topFMKU60_impl_msg-ring-app_pblock_ROLE_partial.bin
  $ ./cfsp image post-app-logic --image_file=${SANDBOX}/cFp_HelloThemisto/dcps/4_topFMKU60_impl_invertcase-ring-app_pblock_ROLE_partial.bin
```
Similarly to the GUI-API procedure, do not forget to write down the image `id` returned by the server 
(e.g. 'dcd9bb0a-7888-4613-a9d3-319c80fcf6e3'). 
```
  0%|                                                                                                                                                                        | 0/1 [00:00<?, ?it/s]INFO: Repeat #0
  INFO: This json file will be used: ${SANDBOX}/cFp_HelloThemisto/dcps/3_topFMKU60_STATIC.json
  INFO: No --sig_file provided. Assuming ${SANDBOX}/cFp_HelloThemisto/dcps/4_topFMKU60_impl_msg-ring-app_pblock_ROLE_partial.bin.sig
  INFO: No --pr_verify_rpt provided. Assuming ${SANDBOX}/cFp_HelloThemisto/dcps/5_topFMKU60_impl_msg-ring-app_pblock_ROLE_partial.rpt
  {'breed': None,
   'comment': None,
   'fpga_board': None,
   'id': 'dcd9bb0a-7888-4613-a9d3-319c80fcf6e3',
   'shell_type': None}
  100%|████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 1/1 [00:04<00:00,  4.21s/it]
```
```
  0%|                                                                                                                                                                        | 0/1 [00:00<?, ?it/s]INFO: Repeat #0
  INFO: This json file will be used: ${SANDBOX}/cFp_HelloThemisto/dcps/3_topFMKU60_STATIC.json
  INFO: No --sig_file provided. Assuming ${SANDBOX}/cFp_HelloThemisto/dcps/4_topFMKU60_impl_invertcase-ring-app_pblock_ROLE_partial.bin.sig
  INFO: No --pr_verify_rpt provided. Assuming ${SANDBOX}/cFp_HelloThemisto/dcps/5_topFMKU60_impl_invertcase-ring-app_pblock_ROLE_partial.rpt
  {'breed': None,
   'comment': None,
   'fpga_board': None,
   'id': 'c5e09074-78fa-4585-8621-d7dd4095d749',
   'shell_type': None}
  100%|████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 1/1 [00:03<00:00,  3.81s/it
```

### Step-8: Request a cloudFPGA cluster and deploy it

Now that your FPGA images have been uploaded to the cFRM, you can request a cloudFPGA cluster to
be programmed and deployed with your images. The below step-8a and step-8b will cover the two 
available options for creating a new cF cluster.

#### Step-8a: Create a cluster with the GUI-API

To create a new cluster via the GUI-API, point your web browser at
```http://10.12.0.132:8080/ui/#/``` and expand the *Swagger* operation 
`[POST] /clusters - Request a cluster` of the menu `Clusters`.

Then, fill in the fields 1 to 4 as exemplified below:
1) with your **username** for accessing the cloudFPGA infrastructure
2) with your **password**
3) with the name of the **OpenStack project** to use (if you own multiple projects), otherwise leave the field setting to "*default*". 
4) with specific **cluster_details** about the mapping of node-IDs to images
   * INFO: You must submit this information in a dictionary format similar to the following example (note that the CPU is not provided with an *image_id* and is flagged as "NON_FPGA" instead):
     ```
     [
       {
         "image_id" : "<the-image-id-retrived-at-step-8a>",  # E.g. "7891e291-8847-4302-9b07-248c4feefd69"
         "node_id"  : 1
       },{
         "image_id" : "<the-image-id-retrived-at-step-8a>",  # E.g. "f23b8025-7beb-4662-8d73-30563593ffbe"
         "node_id"  : 2
       },{
         "image_id" : "NON_FPGA",
         "node_ip"  : "<the-floating-ip-of-your-VM>",        # E.g. "10.12.2.53"
         "node_id"  : 0
       }
     ]
     ```

![Swagger-Clusters-Post-Request-Req](./DOC/imgs/Img-Swagger-Clusters-POST-Request-Req.png#center)

Next, scroll down to the server's response and write down the two "*role_ip*" addresses for later 
accessing your FPGA instances.

![Swagger-Instances-Post-Request-Res](./DOC/imgs/Img-Swagger-Clusters-POST-Request-Res.png#center)

#### Step-8b: Create a cluster with the cFSP-API

To create a similar cluster via the cFSP-API, enter the following command:
```
  $ cd ${SANDBOX}/cFSP
  
  $ ./cfsp cluster post --image_id=7891e291-8847-4302-9b07-248c4feefd69 --image_id=f23b8025-7beb-4662-8d73-30563593ffbe --node_ip=10.12.2.53
```
Next, and similarly to the GUI-API procedure, do not forget to write down the two "*role_ip*" 
returned by the server (see example below). 
```
  0%|                                                                                                                                                                        | 0/1 [00:00<?, ?it/s]INFO: Repeat #0
  {'cluster_id': 265,
   'instances': [{'fpga_board': 'FMKU60',
                  'image_id': '7891e291-8847-4302-9b07-248c4feefd69',
                  'instance_id': 88,
                  'project_name': 'cf_ALL',
                  'role_ip': '10.12.200.8',
                  'shell_type': 'NO_SRA',
                  'slot_num': 26,
                  'status': 'USED',
                  'user_id': 'cfdummy'},
                 {'fpga_board': 'FMKU60',
                  'image_id': 'f23b8025-7beb-4662-8d73-30563593ffbe',
                  'instance_id': 41,
                  'project_name': 'cf_ALL',
                  'role_ip': '10.12.200.236',
                  'shell_type': 'NO_SRA',
                  'slot_num': 21,
                  'status': 'USED',
                  'user_id': 'cfdummy'}],
   'nodes': [{'image_id': '7891e291-8847-4302-9b07-248c4feefd69',
              'inst_id': 88,
              'node_id': 0,
              'node_ip': '10.12.200.8',
              'slot_num': 26},
             {'image_id': 'f23b8025-7beb-4662-8d73-30563593ffbe',
              'inst_id': 41,
              'node_id': 1,
              'node_ip': '10.12.200.236',
              'slot_num': 21},
             {'image_id': 'NON_FPGA', 'node_id': 2, 'node_ip': '10.12.2.53'}],
   'user_id': 'cfdummy'}
  100%|███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 1/1 [02:58<00:00, 178.31s/it]
```

### Step-9: How to test the deployed cluster

As mentioned above, the role `msg-ring-app` always forwards the incoming traffic to the 
next node in the cluster ring without modifying it, while the role `invertcase-ring-app` toggles 
the character case of the received data before forwarding them to the next node. 

An easy way to exercise this traffic scenario is to open two terminals on the VM of the created 
cluster, and to use the *netcat* network utility (often abbreviated as `nc`) for reading from and 
writing to the cluster using TCP or UDP connections. With all the communications of this cluster 
going over the **UDP/TCP port 2718**, enter the following commands in the two terminals:  

Terminal 1 - Set `nc` in TCP transmission mode
```  
  $ ping <role_ip_1>         # w/ role_ip_1 = the IP address of the 1st FPGA (retrieve at step-8)
  $ nc   <role_ip_1> 2718    # Add `-u` for a UDP connection 
```
Terminal 2 - Set `nc` in TCP listen mode
```  
  $ ping <role_ip_2>         # w/ role_ip_2 = the IP address of the 2nd FPGA (retreived at step-8)
  $ nc -l 2718               # Add `-u` for a UDP connection
```

You can now type in some text in the 1st terminal, and this text should be echoed back with all its
characters inverted in the 2nd terminal as the following example shows.

![Demo-of-the cFp_HelloThemisto project](./DOC/imgs/Img-HelloThemisto-Demo.JPG)

:Info: Some firewalls may block network packets if there is not a connection to the remote machine/port. Hence, to get the *HelloThemisto* example to work, the following commands might be necessary to be executed (as root):
```
  $ firewall-cmd --zone=public --add-port=2718-2750/udp --permanent
  $ firewall-cmd --zone=public --add-port=2718-2750/tcp --permanent
  $ firewall-cmd --reload
```

### Step-10: For further experiments

Now that your cluster with one CPU and two FPGAs is operational, you may want to try and deploy a 
larger cluster at step-9 or extend the size of the current cluster with the 
`[PUT] /clusters/{cluster_id}/extend - Add nodes to an existing cluster` menu of the GUI-API.

Depending on the combination of `msg-ring-app` and `invertcase-ring-app` roles in your extended 
cluster, the text of the 2nd terminal will have its characters inverted or not.

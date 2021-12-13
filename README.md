# cFp_HelloThemisto
A *Hello world* project built on the basis of the **Themisto** shell.

## Description of the Project
In a cloudFPGA system, a user application is referred to as a **ROLE** and is integrated 
along with a **SHELL** that abstracts the hardware components of the FPGA module. 
The combination of a specific ROLE and its associated SHELL into a toplevel design is
referred to as a **Shell-Role-Architecture (SRA)**. 

This project exemplifies the generation of partial bitstreams for a cluster of FPGAs.
The idea is to build a communication ring between a host CPU and two FPGAs as depicted
in the following scenario.
```
        +---> CPU --->--- FPGA --->--- FPGA --->---+ 
        |                                          |
        +------<------------<------------<---------+
```

## How to build the project

#### Step-1: Clone and Configure the project
```
$ git clone -recurse-submodules git@github.com:cloudFPGA/cFp_HelloThemisto.git
$ cd cFp_HelloThemisto
```

#### Step-2: TODO
The current directory contains a _Makefile_ which handles all the required steps to generate 
a _bitfile_ (a.k.a bitstream). 

During the build, both SHELL and ROLE dependencies are analyzed to solely re-compile and 
re-synthesize the components that must be recreated.



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



For distributing the routing tables, **`POST /cluster`** must be used.
The following depicts an example API call, assuming that the cFp_Triangle bitfile was uploaded as image`d8471f75-880b-48ff-ac1a-baa89cc3fbc9`:
![POST /cluster example](./doc/post_cluster.png)

## Firewall issues

Some firewalls may block network packets if there is not a connection to the remote machine/port. 
Hence, to get the Triangle example to work, the following commands may be necessary to be executed (as root):
```
$ firewall-cmd --zone=public --add-port=2718-2750/udp --permanent
$ firewall-cmd --zone=public --add-port=2718-2750/tcp --permanent
$ firewall-cmd --reload
```

Also, ensure that the network secuirty group settings are updated (e.g. in case of the ZYC2 OpenStack).



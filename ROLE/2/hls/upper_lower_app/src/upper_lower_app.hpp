/*******************************************************************************
 * Copyright 2016 -- 2022 IBM Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *******************************************************************************/

//  *
//  *                       cloudFPGA
//  *    =============================================
//  *     Created: May 2019
//  *     Authors: FAB, WEI, NGL
//  *
//  *     Description:
//  *        The Role for an ASCII case invert application (UDP or TCP)
//  *

#ifndef _ROLE_UPPERLOWER_H_
#define _ROLE_UPPERLOWER_H_

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>
#include <math.h>
#include <hls_stream.h>
#include "ap_int.h"
#include <stdint.h>

//#include "../../../../../cFDK/SRA/LIB/hls/network.hpp"
#include "network.hpp"

using namespace hls;



#define WAIT_FOR_META 0
#define WAIT_FOR_STREAM_PAIR 1
#define WRITE_META 2
#define PROCESSING_PACKET 3
#define PacketFsmType uint8_t

#define FSM_WRITE_NEW_DATA 0
#define FSM_DONE 1
#define PortFsmType uint8_t

#define DEFAULT_TX_PORT 2718
#define DEFAULT_RX_PORT 2718


void upper_lower_app(
    ap_uint<32>             *pi_rank,
    ap_uint<32>             *pi_size,
    //------------------------------------------------------
    //-- SHELL / This / UDP/TCP Interfaces
    //------------------------------------------------------
    stream<NetworkWord>         &siNrc_data,
    stream<NetworkWord>         &soNrc_data,
    stream<NetworkMetaStream>   &siNrc_meta,
    stream<NetworkMetaStream>   &soNrc_meta,
    ap_uint<32>                 *po_rx_ports
);

#endif


/*
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
 */

/*******************************************************************************
 * @file     : tcp_app.hpp
 * @brief    : TCP Application (TCP_APP)
 *
 * System:   : cloudFPGA
 * Component : cFp_HelloThemisto/ROLE/TCP Application (TCP_APP)
 * Language  : Vivado HLS
 *
 *----------------------------------------------------------------------------
 *
 * @details  : This application implements a set of TCP-oriented functions for
 *  the test of the TCP communication channel between the HOST and a cloudFPGA
 *  module.
 *
 * \ingroup tcp_app
 * \addtogroup tcp_app
 * \{
 *******************************************************************************/

#ifndef _TCP_APP_H_
#define _TCP_APP_H_

#include "../../../../cFDK/SRA/LIB/SHELL/LIB/hls/NTS/nts.hpp"
#include "../../../../cFDK/SRA/LIB/SHELL/LIB/hls/NTS/nts_utils.hpp"

//OBSOLETE #include <stdio.h>
//OBSOLETE #include <iostream>
#include <fstream>
//OBSOLETE #include <string>
//OBSOLETE #include <math.h>
//OBSOLETE #include <hls_stream.h>
//OBSOLETE #include <stdint.h>

//#include "ap_int.h"
#include "network.hpp"


//-------------------------------------------------------------------
//-- DEFAULT TODO/FIXME
//-------------------------------------------------------------------
#define WAIT_FOR_META 0
#define WAIT_FOR_STREAM 1
#define PROCESSING_PACKET 2
//#define WRITE_META 2
#define PacketFsmType uint8_t

#define FSM_WRITE_NEW_DATA 0
#define FSM_DONE 1
#define PortFsmType uint8_t

#define DEFAULT_TX_PORT 2718
#define DEFAULT_RX_PORT 2718


/*******************************************************************************
 *
 * ENTITY - TCP APPLICATION (TCP_APP)
 *
 *******************************************************************************/
void tcp_app(
    //------------------------------------------------------
    //-- SHELL / Clock and Reset
    //------------------------------------------------------
    ap_uint<32>                 *piSHL_CluRank,
    ap_uint<32>                 *piSHL_CluSize,
    //------------------------------------------------------
    //-- SHELL / Listen Ports
    //------------------------------------------------------
    ap_uint<32>                 *poSHL_LsnPorts,
    //--------------------------------------------------------
    //-- SHELL / RxP Data Flow Interfaces
    //--------------------------------------------------------
    stream<NetworkWord>         &siSHL_Data,
    stream<NetworkMetaStream>   &siSHL_Meta,
    //------------------------------------------------------
    //-- SHELL / TxP Data Flow Interfaces
    //------------------------------------------------------
    stream<NetworkWord>         &soSHL_Data,
    stream<NetworkMetaStream>   &soSHL_Meta
);

#endif

/*! \} */

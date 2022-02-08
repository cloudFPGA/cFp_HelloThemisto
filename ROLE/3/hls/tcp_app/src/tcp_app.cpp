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
 * @file     : tcp_app.cpp
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
 *          +-------+  +---------------------+
 *          |       |  |   +-------------+   |
 *          |       <------+             |   |
 *          | SHELL |  |   |   TCP_APP   |   |
 *          |       +------>             |   |
 *          |       |  |   +-------------+   |
 *          +-------+  +---------------------+
 *
 * \ingroup tcp_app
 * \addtogroup tcp_app
 * \{
 *******************************************************************************/

#include "tcp_app.hpp"

using namespace hls;
using namespace std;

/************************************************
 * HELPERS FOR THE DEBUGGING TRACES
 *  .e.g: DEBUG_LEVEL = (TRACE_RXP | TRACE_TXP)
 ************************************************/
#ifndef __SYNTHESIS__
  extern bool gTraceEvent;
#endif

#define THIS_NAME "TCP_APP"  // TcpApplication

#define TRACE_OFF  0x0000
//OBSOLETE #define TRACE_ESF 1 <<  1  // EchoStoreForward
//OBSOLETE #define TRACE_RXP 1 <<  2  // RxPath
//OBSOLETE #define TRACE_TXP 1 <<  3  // TxPath
//OBSOLETE #define TRACE_ALL  0xFFFF
#define DEBUG_LEVEL (TRACE_OFF)



void pPAd(
    ap_uint<32>             *pi_rank,
    ap_uint<32>             *pi_size,
    stream<NodeId>          &sDstNode_sig,
    ap_uint<32>             *po_rx_ports
    )
{
    //-- DIRECTIVES FOR THIS PROCESS ------------------------------------------
    #pragma HLS INLINE off
    //#pragma HLS pipeline II=1 //not necessary

  //-- STATIC VARIABLES (with RESET) ------------------------------------------
    static PortFsmType port_fsm = FSM_WRITE_NEW_DATA;
    #pragma HLS reset variable=port_fsm

    switch(port_fsm) {
    default:
    case FSM_WRITE_NEW_DATA:
        //Triangle app needs to be reset to process new rank
        if(!sDstNode_sig.full()) {
            NodeId dst_rank = (*pi_rank + 1) % *pi_size;
              printf("rank: %d; size: %d; \n", (int) *pi_rank, (int) *pi_size);
              sDstNode_sig.write(dst_rank);
              port_fsm = FSM_DONE;
        }
        break;
    case FSM_DONE:
        *po_rx_ports = 0x1; //currently work only with default ports...
        break;
    }
}

/*******************************************************************************
 * @brief   TCP Receive Path (RXp) - From SHELL->THIS-ROLE
 *
 * @param[in]  siSHL_Data      TCP data stream from SHELL (SHL).
 * @param[in]  siSHL_Meta      TCP data stream from [SHL].
 * @param[out] soTXp_Data      TCP data stream to TxPath (TXp).
 * @param[out] soTXp_Meta      TCP meta stream to [TXp].
 *******************************************************************************/
void pRXp(
    stream<NetworkWord>     &siSHL_Data,
    stream<NetworkMeta>     &siSHL_Meta,
    stream<NetworkWord>     &soTXp_Data,
    stream<NetworkMeta>     &soTXp_Meta)
{
    //-- DIRECTIVES FOR THIS PROCESS -------------------------------------------
    #pragma HLS INLINE off
    #pragma HLS pipeline II=1

    const char *myName  = concat3(THIS_NAME, "/", "RXp");

    //-- STATIC VARIABLES (with RESET) -----------------------------------------
    static enum FsmStates { RXP_WAIT_4_META=0, RXP_FORWARD_SEGMENT } \
                                    rxp_fsmState=RXP_WAIT_4_META;
    #pragma HLS reset variable=rxp_fsmState

    //-- LOCAL VARIABLES ------------------------------------------------------
    NetworkWord appData = NetworkWord();
    NetworkMeta appMeta = NetworkMeta();

    switch(rxp_fsmState) {
    default:
    case RXP_WAIT_4_META:
        if ( !siSHL_Meta.empty() && !soTXp_Meta.full() ) {
            appMeta = siSHL_Meta.read();
            soTXp_Meta.write(appMeta);
            rxp_fsmState = RXP_FORWARD_SEGMENT;
        }
        break;
    case RXP_FORWARD_SEGMENT:
        if ( !siSHL_Data.empty() && !soTXp_Data.full() ) {
            appData = siSHL_Data.read();
            soTXp_Data.write(appData);
            if(appData.tlast == 1) {
                rxp_fsmState = RXP_WAIT_4_META;
            }
        }
        break;
    }
}

/*******************************************************************************
 * @brief   TCP Transmit Path (TXp) - From THIS-ROLE->SHELL
 *
 * @param[in]  siRXp_Data      TCP data stream from RxPath (RXp).
 * @param[in]  siRXp_Meta      TCP data stream from [RXp].
 * @param[in]  siPAd_DstRank   The destination rank from PortAndDestination (PAd)
 * @param[out] soSHL_Data      TCP data stream to SHELL (SHL).
 * @param[out] soSHL_Meta      TCP meta stream to [SHL].
 *******************************************************************************/
void pTXp(
    stream<NetworkWord>         &siRXp_Data,
    stream<NetworkMeta>         &siRXp_Meta,
    stream<NodeId>              &siPAd_DstRank,
    stream<NetworkWord>         &soSHL_Data,
    stream<NetworkMeta>         &soSHL_Meta)
{
    //-- DIRECTIVES FOR THIS PROCESS -------------------------------------------
    #pragma HLS INLINE off
    #pragma HLS pipeline II=1

    const char *myName  = concat3(THIS_NAME, "/", "TXp");

    //-- STATIC VARIABLES (with RESET) -----------------------------------------
    static enum FsmStates { TXP_WAIT_4_RANK=0, TXP_WAIT_4_META,
                            TXP_FORWARD_SEGMENT } txp_fsmState=TXP_WAIT_4_RANK;
    #pragma HLS reset variable=txp_fsmState

    //-- STATIC VARIABLES ------------------------------------------------------
    static NodeId txp_dstRank;

    //-- LOCAL VARIABLES -------------------------------------------------------
    NetworkWord appData = NetworkWord();

    switch(txp_fsmState) {
    default:
    case TXP_WAIT_4_META:
        if(!siPAd_DstRank.empty()) {
            // pTXp needs to be reset to process new rank
            txp_dstRank = siPAd_DstRank.read();
            txp_fsmState = TXP_WAIT_4_META;
        }
        break;
    case TXP_WAIT_4_META:
        if ( !siRXp_Meta.empty() && !soSHL_Meta.full() ) {
             NetworkMeta meta_in  = siRXp_Meta.read();
             NetworkMeta meta_out = NetworkMeta();
             meta_out.dst_rank = txp_dstRank;
             meta_out.dst_port = DEFAULT_TX_PORT;
             meta_out.src_rank = NAL_THIS_FPGA_PSEUDO_NID; //will be ignored, it is always this FPGA...
             meta_out.src_port = DEFAULT_RX_PORT;
             meta_out.len      = meta_in.len;
             soSHL_Meta.write(NetworkMeta(meta_out));
             txp_fsmState = TXP_FORWARD_SEGMENT;
        }
        break;
   case TXP_FORWARD_SEGMENT:
        if( !siRXp_Data.empty() && !soSHL_Data.full() ) {
            appData = siRXp_Data.read();
            soSHL_Data.write(appData);
            if(appData.tlast == 1) {
                txp_fsmState = TXP_WAIT_4_META;
            }
        }
        break;
    }
}

/*******************************************************************************
 * @brief   Main process of the TCP Application (TCP_APP).
 *
 * @param[in]  piSHL_CluRank   The cluster rank assigned to this role.
 * @param[in]  piSHL_CluSize   The cluster size this role belongs to.
 * @param[out] poSHL_LsnPorts  The ports opened in listen mode (as a vector).
 * @param[in]  siSHL_Data      TCP data stream from SHELL (SHL).
 * @param[in]  siSHL_Meta      TCP data stream from [SHL].
 * @param[out] soSHL_Data      TCP data stream to [SHL].       
 * @param[out] soSHL_Meta      TCP meta stream to [SHL].
 *******************************************************************************/
void tcp_app(

    //------------------------------------------------------
    //-- From SHELL / Clock and Reset
    //------------------------------------------------------
    ap_uint<32>             *piSHL_CluRank,
    ap_uint<32>             *piSHL_CluSize,
    //------------------------------------------------------
    //-- To SHELL / Listen Ports
    //------------------------------------------------------
    ap_uint<32>             *poSHL_LsnPorts,
    //--------------------------------------------------------
    //-- From SHELL / RxP Data Flow Interfaces
    //--------------------------------------------------------
    stream<NetworkWord>     &siSHL_Data,
    stream<NetworkMeta>     &siSHL_Meta,
    //------------------------------------------------------
    //-- To SHELL / TxP Data Flow Interfaces
    //------------------------------------------------------
    stream<NetworkWord>     &soSHL_Data,
    stream<NetworkMeta>     &soSHL_Meta)
{
    //-- DIRECTIVES FOR THE INTERFACES -----------------------------------------
    #pragma HLS INTERFACE ap_ctrl_none port=return

    #pragma HLS INTERFACE ap_vld register port=piSHL_CluRank  name=piFMC_ROL_rank
    #pragma HLS INTERFACE ap_vld register port=piSHL_CluSize  name=piFMC_ROL_size
    #pragma HLS INTERFACE ap_vld register port=poSHL_LsnPorts name=poROL_NRC_Rx_ports

    #pragma HLS INTERFACE axis   register both port=siSHL_Data
    #pragma HLS INTERFACE axis   register both port=siSHL_Meta

    #pragma HLS INTERFACE axis   register both port=soSHL_Data
    #pragma HLS INTERFACE axis   register both port=soSHL_Meta

    //-- DIRECTIVES FOR THIS PROCESS ------------------------------------------
    #pragma HLS DATAFLOW

    //--------------------------------------------------------------------------
    //-- LOCAL STREAMS (Sorted by the name of the modules which generate them)
    //--------------------------------------------------------------------------

    //-- Rx Path (RXp) ---------------------------------------------------------
    static stream<NetworkWord>       ssRXpToTXp_Data    ("ssRXpToTXp_Data");
    #pragma HLS STREAM      variable=ssRXpToTXp_Data    depth=256
    static stream<NetworkMeta>       ssRXpToTXp_Meta    ("ssRXpToTXp_Meta");
    #pragma HLS STREAM      variable=ssRXpToTXp_Meta    depth=32

    //-- Port and Destination (PAd) --------------------------------------------
    static stream<NodeId>            ssPAdToTXp_DstRank ("ssPAdToTXp_DstRank");
    #pragma HLS STREAM      variable=ssPAdToTXp_DstRank depth=1

    //-- PROCESS FUNCTIONS -----------------------------------------------------
    //
    //                     +----------+
    //           +-------->|   pPAd   |----------+
    //           |         +----------+          |
    //           |          ---------+           |
    //           |  +--------> sEPt  |--------+  |
    //           |  |       ---------+        |  |
    //     +--+--+--+--+                   +--+--+--+--+
    //     |   pRXp    |                   |   pTXp    |
    //     +------+----+                   +-----+-----+
    //          /|\                              |
    //           |                               |
    //           |                               |
    //           |                              \|/
    //
    //--------------------------------------------------------------------------

    pPAd(  // [FIXME-pPortAndDestination]
        piSHL_CluRank,
        piSHL_CluSize,
        ssPAdToTXp_DstRank,
        poSHL_LsnPorts);

    pRXp(
        siSHL_Data,
        siSHL_Meta,
        ssRXpToTXp_Data,
        ssRXpToTXp_Meta);

    pTXp(
        ssRXpToTXp_Data,
        ssRXpToTXp_Meta,
        ssPAdToTXp_DstRank,
        soSHL_Data,
        soSHL_Meta);

}

/*! \} */


//  *
//  *                       cloudFPGA
//  *     Copyright IBM Research, All Rights Reserved
//  *    =============================================
//  *     Created: May 2019
//  *     Authors: FAB, WEI, NGL
//  *
//  *     Description:
//  *        The Role for a Triangle Example application
//  *

#include "udp_app_flash.hpp"


stream<UdpWord>      sRxpToTxp_Data("sRxpToTxP_Data");
stream<NrcMetaStream> sRxtoTx_Meta("sRxtoTx_Meta");
//  #pragma HLS STREAM variable=sRxpToTxp_Data off depth=1500 TODO: necessary?



/*****************************************************************************
 * @brief   Main process of the UDP Application Flash
 * @ingroup udp_app_flash
 *
 * @return Nothing.
 *****************************************************************************/
void udp_app_flash (

    //------------------------------------------------------
    //-- SHELL / This / Mmio / Config Interfaces
    //------------------------------------------------------
    //ap_uint<2>          piSHL_This_MmioEchoCtrl,
    //[TODO] ap_uint<1> piSHL_This_MmioPostPktEn,
    //[TODO] ap_uint<1> piSHL_This_MmioCaptPktEn,

    ap_uint<32>             *pi_rank,
    ap_uint<32>             *pi_size,
    //------------------------------------------------------
    //-- SHELL / This / Udp Interfaces
    //------------------------------------------------------
    stream<UdpWord>     &siSHL_This_Data,
    stream<UdpWord>     &soTHIS_Shl_Data,
    stream<NrcMetaStream>   &siNrc_meta,
    stream<NrcMetaStream>   &soNrc_meta,
    ap_uint<32>             *po_udp_rx_ports
    )
{

  //-- DIRECTIVES FOR THE BLOCK ---------------------------------------------
  //TODO? #pragma HLS INTERFACE ap_ctrl_none port=return

  //#pragma HLS INTERFACE ap_stable     port=piSHL_This_MmioEchoCtrl

#pragma HLS INTERFACE axis register both port=siSHL_This_Data
#pragma HLS INTERFACE axis register both port=soTHIS_Shl_Data

#pragma HLS INTERFACE axis register both port=siNrc_meta
#pragma HLS INTERFACE axis register both port=soNrc_meta

#pragma HLS INTERFACE ap_vld register port=po_udp_rx_ports name=poROL_NRC_Udp_Rx_ports
#pragma HLS INTERFACE ap_vld register port=pi_rank name=piSMC_ROL_rank
#pragma HLS INTERFACE ap_vld register port=pi_size name=piSMC_ROL_size


  //-- DIRECTIVES FOR THIS PROCESS ------------------------------------------
  #pragma HLS DATAFLOW interval=1


  // ====== INIT ==== 

  if ( *pi_size != 3)
  {
    //works only with size 3
    return; 
  }

  NodeId target = 2;
  if ( *pi_rank >= 2)
  {
    target = 0;
  }

  *po_udp_rx_ports = 0x1; //currently work only with default ports...

  //-- LOCAL VARIABLES ------------------------------------------------------
  UdpWord udpWord;
  UdpWord  udpWordTx;
  NrcMeta  meta_in = NrcMeta();
  NrcMeta  meta_out = NrcMeta();

  //-- Read incoming data chunk
  if ( !siSHL_This_Data.empty() && !siNrc_meta.empty() 
      && !sRxpToTxp_Data.full() && !sRxtoTx_Meta.full() )
  {
    sRxpToTxp_Data.write(udpWord);
    udpWord = siSHL_This_Data.read();

    sRxtoTx_Meta.write(siNrc_meta.read());
  }


  //-- Forward incoming chunk to SHELL

  if ( !sRxpToTxp_Data.empty() && !sRxtoTx_Meta.empty() 
      && !soTHIS_Shl_Data.full() &&  !soNrc_meta.full() ) 
  {
    udpWordTx = sRxpToTxp_Data.read();
    soTHIS_Shl_Data.write(udpWordTx);

    meta_in = sRxtoTx_Meta.read().tdata;
    //meta_out = NrcMeta(target, meta_in.src_port, (NodeId) *pi_rank, meta_in.dst_port);
    meta_out.dst_rank = target;
    meta_out.dst_port = DEFAULT_TX_PORT;
    meta_out.src_rank = (NodeId) *pi_rank;
    meta_out.src_port = meta_in.dst_port;
    soNrc_meta.write(NrcMetaStream(meta_out));
  }

}


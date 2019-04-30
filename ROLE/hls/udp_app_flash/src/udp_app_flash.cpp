/*****************************************************************************
 * @file       : udp_app_flash.cpp
 * @brief      : UDP Application Flash (UAF)
 *
 * System:     : cloudFPGA
 * Component   : Role
 * Language    : Vivado HLS
 *
 * Copyright 2009-2015 - Xilinx Inc.  - All rights reserved.
 * Copyright 2015-2018 - IBM Research - All Rights Reserved.
 *
 *----------------------------------------------------------------------------
 *
 * @details    : This application implements a set of UDP-oriented tests and
 *  functions which are embedded into the Flash of the cloudFPGA role.
 *
 * @note       : For the time being, we continue designing with the DEPRECATED
 *				  directives because the new PRAGMAs do not work for us.
 * @remark     :
 * @warning    :
 *
 * @see        :
 *
 *****************************************************************************/

#include "udp_app_flash.hpp"

//#define USE_DEPRECATED_DIRECTIVES

#define MTU		1500	// Maximum Transmission Unit in bytes [TODO:Move to a common place]

/*****************************************************************************
 * @brief Echo loopback between the Rx and Tx ports of the UDP connection.
 *         The echo is said to operate in "store-and-forward" mode because
 *         every received packet is stored into the DDR4 memory before being
 *         read again and and sent back.
 * @ingroup udp_app_flash
 *
 * @param[in]  siRxp_Data,	data from pRXPath
 * @param[in]  soTxp_Data,	data to pTXPath.
 *
 * @return Nothing.
 ******************************************************************************/
/*
void pEchoStoreAndForward( // [TODO - Implement this process as store-and-forward]
		stream<UdpWord>		&siRxp_Data,
		stream<UdpWord>     &soTxp_Data)
{
    //-- DIRECTIVES FOR THIS PROCESS ------------------------------------------
    #pragma HLS DATAFLOW interval=1

    //-- LOCAL VARIABLES ------------------------------------------------------
	static stream<UdpWord>	sFifo ("sFifo");
	#pragma HLS stream      variable=sFifo depth=8

	//-- FiFo Push
	if ( !siRxp_Data.empty() && !sFifo.full() )
		sFifo.write(siRxp_Data.read());

	//-- FiFo Pop
	if ( !sFifo.empty() && !soTxp_Data.full() )
		soTxp_Data.write(sFifo.read());
}
*/

/*****************************************************************************
 * @brief Transmit Path - From THIS to SHELL.
 * @ingroup udp_app_flash
 *
 * @param[in]  piSHL_MmioEchoCtrl, configuration of the echo function.
 * @param[in]  siEpt_Data,         data from pEchoPassTrough.
 * @param[in]  siEsf_Data,         data from pEchoStoreAndForward.
 * @param[out] soSHL_Data,         data to SHELL.
 *
 * @return Nothing.
 *****************************************************************************/
/*
void pTXPath(
		ap_uint<2>           piSHL_MmioEchoCtrl,
        stream<UdpWord>     &siEpt_Data,
		stream<UdpWord>     &siEsf_Data,
		stream<UdpWord>     &soSHL_Data)
{
    //-- DIRECTIVES FOR THIS PROCESS ------------------------------------------
    #pragma HLS DATAFLOW interval=1

    //-- LOCAL VARIABLES ------------------------------------------------------
	UdpWord	udpWord;

   	//-- Forward incoming chunk to SHELL
    switch(piSHL_MmioEchoCtrl) {

        case ECHO_PATH_THRU:
        	// Read data chunk from pEchoPassThrough
        	if ( !siEpt_Data.empty() ) {
        		udpWord = siEpt_Data.read();
        	}
        	else
        		return;
        	break;

        case ECHO_STORE_FWD:
        	// Read data chunk from pEchoStoreAndForward
        	if ( !siEsf_Data.empty() )
        		udpWord = siEsf_Data.read();
        	break;

        case ECHO_OFF:
        	// Read data chunk from TBD
            break;

        default:
        	// Reserved configuration ==> Do nothing
            break;
    }

    //-- Forward data chunk to SHELL
    if ( !soSHL_Data.full() )
        soSHL_Data.write(udpWord);
}
*/

/*****************************************************************************
 * @brief Receive Path - From SHELL to THIS.
 * @ingroup udp_app_flash
 *
 * @param[in]  piSHL_MmioEchoCtrl, configuration of the echo function.
 * @param[in]  siSHL_Data,         data from SHELL.
 * @param[out] soEpt_Data,         data to pEchoPassTrough.
 * @param[out] soEsf_Data,         data to pEchoStoreAndForward.
 *
 * @return Nothing.
 ******************************************************************************/
/*
void pRXPath(
        ap_uint<2>            piSHL_MmioEchoCtrl,
        stream<UdpWord>      &siSHL_Data,
        stream<UdpWord>      &soEpt_Data,
		stream<UdpWord>      &soEsf_Data)
{
    //-- DIRECTIVES FOR THIS PROCESS ------------------------------------------
    #pragma HLS DATAFLOW interval=1

    //-- LOCAL VARIABLES ------------------------------------------------------
	UdpWord	udpWord;

    //-- Read incoming data chunk
    if ( !siSHL_Data.empty() )
    	udpWord = siSHL_Data.read();
    else
    	return;

   	// Forward data chunk to Echo function
    switch(piSHL_MmioEchoCtrl) {

        case ECHO_PATH_THRU:
        	// Forward data chunk to pEchoPathThrough
        	if ( !soEpt_Data.full() )
        		soEpt_Data.write(udpWord);
            break;

        case ECHO_STORE_FWD:
        	// Forward data chunk to pEchoStoreAndForward
        	if ( !soEsf_Data.full() )
        		soEsf_Data.write(udpWord);
        	break;

        case ECHO_OFF:
        	// Drop the packet
            break;

        default:
        	// Drop the packet
            break;
    }
}
*/

/*****************************************************************************
 * @brief   Main process of the UDP Application Flash
 * @ingroup udp_app_flash
 *
 * @param[in]  piSHL_This_MmioEchoCtrl,  configures the echo function.
 * @param[in]  piSHL_This_MmioPostPktEn, enables posting of UDP packets.
 * @param[in]  piSHL_This_MmioCaptPktEn, enables capture of UDP packets.
 * @param[in]  siSHL_This_Data           UDP data stream from the SHELL.
 * @param[out] soTHIS_Shl_Data           UDP data stream to the SHELL.
 *
 * @return Nothing.
 *****************************************************************************/
void udp_app_flash (

        //------------------------------------------------------
        //-- SHELL / This / Mmio / Config Interfaces
        //------------------------------------------------------
        ap_uint<2>          piSHL_This_MmioEchoCtrl,
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

    /*********************************************************************/
    /*** For the time being, we continue designing with the DEPRECATED ***/
    /*** directives because the new PRAGMAs do not work for us.        ***/
    /*********************************************************************/

#if defined(USE_DEPRECATED_DIRECTIVES)

	//-- DIRECTIVES FOR THE BLOCK ---------------------------------------------
	#pragma HLS INTERFACE ap_ctrl_none port=return

    #pragma HLS INTERFACE ap_stable 	 port=piSHL_This_MmioEchoCtrl
    //[TODO] #pragma HLS INTERFACE ap_stable 	 port=piSHL_This_MmioPostPktEn
	//[TODO] #pragma HLS INTERFACE ap_stable     port=piSHL_This_MmioCaptPktEn

    #pragma HLS resource core=AXI4Stream variable=siSHL_This_Data metadata="-bus_bundle siSHL_This_Data"
    #pragma HLS resource core=AXI4Stream variable=soTHIS_Shl_Data metadata="-bus_bundle soTHIS_Shl_Data"

#else

	//-- DIRECTIVES FOR THE BLOCK ---------------------------------------------
	#pragma HLS INTERFACE ap_ctrl_none port=return

    #pragma HLS INTERFACE ap_stable     port=piSHL_This_MmioEchoCtrl
	//[TODO] #pragma HLS INTERFACE ap_stable     port=piSHL_This_MmioPostPktEn
	//[TODO] #pragma HLS INTERFACE ap_stable     port=piSHL_This_MmioCaptPktEn

	// [INFO] Always add "register off" because (default value is "both")
    #pragma HLS INTERFACE axis register off port=siSHL_This_Data
    #pragma HLS INTERFACE axis register off port=soTHIS_Shl_Data

#pragma HLS INTERFACE axis register both port=siNrc_meta
#pragma HLS INTERFACE axis register both port=soNrc_meta

#pragma HLS INTERFACE ap_vld register port=po_udp_rx_ports name=poROL_NRC_Udp_Rx_ports
#pragma HLS INTERFACE ap_vld register port=pi_rank name=piSMC_ROL_rank
#pragma HLS INTERFACE ap_vld register port=pi_size name=piSMC_ROL_size

#endif

    //-- DIRECTIVES FOR THIS PROCESS ------------------------------------------
    #pragma HLS DATAFLOW interval=1

    //-- LOCAL STREAMS --------------------------------------------------------
    //OBSOLETE-20180918 static stream<UdpWord>      sRxpToEpt_Data("sRxpToEpt_Data");
	//OBSOLETE-20180918 static stream<UdpWord>      sEptToTxp_Data("sEptToTxp_Data");

	static stream<UdpWord>      sRxpToTxp_Data("sRxpToTxP_Data");
  static stream<NrcMetaStream> sRxtoTx_Meta("sRxtoTx_Meta");

    static stream<UdpWord>      sRxpToEsf_Data("sRxpToEsf_Data");
    static stream<UdpWord>      sEsfToTxp_Data("sEsfToTxp_Data");

    //OBSOLETE-20180918 #pragma HLS STREAM    variable=sRxpToEpt_Data depth=512
    //OBSOLETE-20180918 #pragma HLS STREAM    variable=sEptToTxp_Data depth=512

    #pragma HLS STREAM variable=sRxpToTxp_Data off depth=1500
	#pragma HLS STREAM variable=sRxpToEsf_Data depth=2
    #pragma HLS STREAM variable=sEsfToTxp_Data depth=2


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

    //-- PROCESS FUNCTIONS ----------------------------------------------------
    //pRXPath(piSHL_This_MmioEchoCtrl,
    //        siSHL_This_Data, sRxpToTxp_Data, sRxpToEsf_Data);

    //-- LOCAL VARIABLES ------------------------------------------------------
    UdpWord udpWord;

    //-- Read incoming data chunk
    if ( !siSHL_This_Data.empty() )
    {
      udpWord = siSHL_This_Data.read();
    }
    else {
      return;
    }

    // Forward data chunk to Echo function
    switch(piSHL_This_MmioEchoCtrl) {

      case ECHO_PATH_THRU:
        // Forward data chunk to pEchoPathThrough
        if ( !sRxpToTxp_Data.full() )
        {
          sRxpToTxp_Data.write(udpWord);
        }
        if ( !sRxtoTx_Meta.full() && !siNrc_meta.empty() )
        {
          sRxtoTx_Meta.write(siNrc_meta.read());
        }
        break;

      case ECHO_STORE_FWD:
        // Forward data chunk to pEchoStoreAndForward
        if ( !sRxpToEsf_Data.full() )
        {
          sRxpToEsf_Data.write(udpWord);
        }
        //TODO: latency?
        if ( !sRxtoTx_Meta.full() && !siNrc_meta.empty() )
        {
          sRxtoTx_Meta.write(siNrc_meta.read());
        }
        break;

      case ECHO_OFF:
        // Drop the packet
        break;

      default:
        // Drop the packet
        break;
    }

    //OBSOLETE-20180918 pEchoPassThrough(sRxpToEpt_Data, sEptToTxp_Data);

    //pEchoStoreAndForward(sRxpToEsf_Data, sEsfToTxp_Data);
    //-- LOCAL VARIABLES ------------------------------------------------------
    static stream<UdpWord>	sFifo ("sFifo");
#pragma HLS stream      variable=sFifo depth=8

    //-- FiFo Push
    if ( !sRxpToEsf_Data.empty() && !sFifo.full() )
    {
      sFifo.write(sRxpToEsf_Data.read());
    }

    //-- FiFo Pop
    if ( !sFifo.empty() && !sEsfToTxp_Data.full() )
    {
      sEsfToTxp_Data.write(sFifo.read());
    }

    //pTXPath(piSHL_This_MmioEchoCtrl,
    //    sRxpToTxp_Data, sEsfToTxp_Data, soTHIS_Shl_Data);
    //-- LOCAL VARIABLES ------------------------------------------------------
    UdpWord  udpWordTx;
    NrcMeta  meta_in = NrcMeta();
    NrcMeta  meta_out = NrcMeta();

    //-- Forward incoming chunk to SHELL
    switch(piSHL_This_MmioEchoCtrl) {

      case ECHO_PATH_THRU:
        // Read data chunk from pEchoPassThrough
        if ( !sRxpToTxp_Data.empty() ) {
          udpWordTx = sRxpToTxp_Data.read();
        }
        else {
          return;
        }
        break;

      case ECHO_STORE_FWD:
        // Read data chunk from pEchoStoreAndForward
        if ( !sEsfToTxp_Data.empty() )
        {
          udpWordTx = sEsfToTxp_Data.read();
        }
        break;

      case ECHO_OFF:
        // Read data chunk from TBD
        break;

      default:
        // Reserved configuration ==> Do nothing
        break;
    }

    //-- Forward data chunk to SHELL
    if ( !soTHIS_Shl_Data.full() )
    {
      soTHIS_Shl_Data.write(udpWordTx);
    }

    if ( !soNrc_meta.full() && !sRxtoTx_Meta.empty() )
    {
      meta_in = sRxtoTx_Meta.read().tdata;
      //meta_out = NrcMeta(target, meta_in.src_port, (NodeId) *pi_rank, meta_in.dst_port);
      meta_out.dst_rank = target;
      meta_out.dst_port = DEFAULT_TX_PORT;
      meta_out.src_rank = (NodeId) *pi_rank;
      meta_out.src_port = meta_in.dst_port;
      soNrc_meta.write(NrcMetaStream(meta_out));
    }

}


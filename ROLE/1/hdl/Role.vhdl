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

-- *****************************************************************************
-- *
-- * Title : Role template for the 'Themisto' shell of the FMKU60.
-- *
-- * File    : Role.vhdl
-- *
-- * Tools   : Vivado v2016.4, v2017.4, v2019.2 (64-bit)
-- *
-- * Description : In cloudFPGA, the user application is referred to as a 'role'
-- *   and is integrated along with a 'shell' that abstracts the HW components
-- *   of the FPGA module.
-- *   The current role implements 2 typical UDP and TCP applications and pairs
-- *   paires them with the shell 'Themisto'.
-- *
-- *****************************************************************************

--******************************************************************************
--**  CONTEXT CLAUSE  **  FMKU60 ROLE(Flash)
--******************************************************************************
library IEEE;
use     IEEE.std_logic_1164.all;
use     IEEE.numeric_std.all;

library UNISIM;
use     UNISIM.vcomponents.all;


--******************************************************************************
--**  ENTITY  **  ROLE_THEMISTO
--******************************************************************************

entity Role_Themisto is
  port (

    --------------------------------------------------------
    -- SHELL / Global Input Clock and Reset Interface
    --------------------------------------------------------
    piSHL_156_25Clk             : in    std_ulogic;
    piSHL_156_25Rst             : in    std_ulogic;
    -- LY7 Enable and Reset
    piMMIO_Ly7_Rst              : in    std_ulogic;
    piMMIO_Ly7_En               : in    std_ulogic;

    ------------------------------------------------------
    -- SHELL / Role / Nts0 / Udp Interface
    ------------------------------------------------------
    ---- Input AXI-Write Stream Interface ----------
    siNRC_Udp_Data_tdata        : in    std_ulogic_vector( 63 downto 0);
    siNRC_Udp_Data_tkeep        : in    std_ulogic_vector(  7 downto 0);
    siNRC_Udp_Data_tvalid       : in    std_ulogic;
    siNRC_Udp_Data_tlast        : in    std_ulogic;
    siNRC_Udp_Data_tready       : out   std_ulogic;
    ---- Output AXI-Write Stream Interface ---------
    soNRC_Udp_Data_tdata        : out   std_ulogic_vector( 63 downto 0);
    soNRC_Udp_Data_tkeep        : out   std_ulogic_vector(  7 downto 0);
    soNRC_Udp_Data_tvalid       : out   std_ulogic;
    soNRC_Udp_Data_tlast        : out   std_ulogic;
    soNRC_Udp_Data_tready       : in    std_ulogic;
    -- Open Port vector
    poROL_Nrc_Udp_Rx_ports      : out    std_ulogic_vector( 31 downto 0);
    -- ROLE <-> NRC Meta Interface
    soROLE_Nrc_Udp_Meta_TDATA   : out   std_ulogic_vector( 63 downto 0);
    soROLE_Nrc_Udp_Meta_TVALID  : out   std_ulogic;
    soROLE_Nrc_Udp_Meta_TREADY  : in    std_ulogic;
    soROLE_Nrc_Udp_Meta_TKEEP   : out   std_ulogic_vector(  7 downto 0);
    soROLE_Nrc_Udp_Meta_TLAST   : out   std_ulogic;
    siNRC_Role_Udp_Meta_TDATA   : in    std_ulogic_vector( 63 downto 0);
    siNRC_Role_Udp_Meta_TVALID  : in    std_ulogic;
    siNRC_Role_Udp_Meta_TREADY  : out   std_ulogic;
    siNRC_Role_Udp_Meta_TKEEP   : in    std_ulogic_vector(  7 downto 0);
    siNRC_Role_Udp_Meta_TLAST   : in    std_ulogic;

    ------------------------------------------------------
    -- SHELL / Role / Nts0 / Tcp Interface
    ------------------------------------------------------
    ---- Input AXI-Write Stream Interface ----------
    siNRC_Tcp_Data_tdata        : in    std_ulogic_vector( 63 downto 0);
    siNRC_Tcp_Data_tkeep        : in    std_ulogic_vector(  7 downto 0);
    siNRC_Tcp_Data_tvalid       : in    std_ulogic;
    siNRC_Tcp_Data_tlast        : in    std_ulogic;
    siNRC_Tcp_Data_tready       : out   std_ulogic;
    ---- Output AXI-Write Stream Interface ---------
    soNRC_Tcp_Data_tdata        : out   std_ulogic_vector( 63 downto 0);
    soNRC_Tcp_Data_tkeep        : out   std_ulogic_vector(  7 downto 0);
    soNRC_Tcp_Data_tvalid       : out   std_ulogic;
    soNRC_Tcp_Data_tlast        : out   std_ulogic;
    soNRC_Tcp_Data_tready       : in    std_ulogic;
    -- Open Port vector
    poROL_Nrc_Tcp_Rx_ports      : out    std_ulogic_vector( 31 downto 0);
    -- ROLE <-> NRC Meta Interface
    soROLE_Nrc_Tcp_Meta_TDATA   : out   std_ulogic_vector( 63 downto 0);
    soROLE_Nrc_Tcp_Meta_TVALID  : out   std_ulogic;
    soROLE_Nrc_Tcp_Meta_TREADY  : in    std_ulogic;
    soROLE_Nrc_Tcp_Meta_TKEEP   : out   std_ulogic_vector(  7 downto 0);
    soROLE_Nrc_Tcp_Meta_TLAST   : out   std_ulogic;
    siNRC_Role_Tcp_Meta_TDATA   : in    std_ulogic_vector( 63 downto 0);
    siNRC_Role_Tcp_Meta_TVALID  : in    std_ulogic;
    siNRC_Role_Tcp_Meta_TREADY  : out   std_ulogic;
    siNRC_Role_Tcp_Meta_TKEEP   : in    std_ulogic_vector(  7 downto 0);
    siNRC_Role_Tcp_Meta_TLAST   : in    std_ulogic;

    --------------------------------------------------------
    -- SHELL / Mem / Mp0 Interface
    --------------------------------------------------------
    ---- Memory Port #0 / S2MM-AXIS ----------------
    ------ Stream Read Command ---------
    soMEM_Mp0_RdCmd_tdata       : out   std_ulogic_vector( 79 downto 0);
    soMEM_Mp0_RdCmd_tvalid      : out   std_ulogic;
    soMEM_Mp0_RdCmd_tready      : in    std_ulogic;
    ------ Stream Read Status ----------
    siMEM_Mp0_RdSts_tdata       : in    std_ulogic_vector(  7 downto 0);
    siMEM_Mp0_RdSts_tvalid      : in    std_ulogic;
    siMEM_Mp0_RdSts_tready      : out   std_ulogic;
    ------ Stream Data Input Channel ---
    siMEM_Mp0_Read_tdata        : in    std_ulogic_vector(511 downto 0);
    siMEM_Mp0_Read_tkeep        : in    std_ulogic_vector( 63 downto 0);
    siMEM_Mp0_Read_tlast        : in    std_ulogic;
    siMEM_Mp0_Read_tvalid       : in    std_ulogic;
    siMEM_Mp0_Read_tready       : out   std_ulogic;
    ------ Stream Write Command --------
    soMEM_Mp0_WrCmd_tdata       : out   std_ulogic_vector( 79 downto 0);
    soMEM_Mp0_WrCmd_tvalid      : out   std_ulogic;
    soMEM_Mp0_WrCmd_tready      : in    std_ulogic;
    ------ Stream Write Status ---------
    siMEM_Mp0_WrSts_tdata       : in    std_ulogic_vector(  7 downto 0);
    siMEM_Mp0_WrSts_tvalid      : in    std_ulogic;
    siMEM_Mp0_WrSts_tready      : out   std_ulogic;
    ------ Stream Data Output Channel --
    soMEM_Mp0_Write_tdata       : out   std_ulogic_vector(511 downto 0);
    soMEM_Mp0_Write_tkeep       : out   std_ulogic_vector( 63 downto 0);
    soMEM_Mp0_Write_tlast       : out   std_ulogic;
    soMEM_Mp0_Write_tvalid      : out   std_ulogic;
    soMEM_Mp0_Write_tready      : in    std_ulogic;

    --------------------------------------------------------
    -- SHELL / Mem / Mp1 Interface
    --------------------------------------------------------
    moMEM_Mp1_AWID              : out   std_ulogic_vector(7 downto 0);
    moMEM_Mp1_AWADDR            : out   std_ulogic_vector(32 downto 0);
    moMEM_Mp1_AWLEN             : out   std_ulogic_vector(7 downto 0);
    moMEM_Mp1_AWSIZE            : out   std_ulogic_vector(2 downto 0);
    moMEM_Mp1_AWBURST           : out   std_ulogic_vector(1 downto 0);
    moMEM_Mp1_AWVALID           : out   std_ulogic;
    moMEM_Mp1_AWREADY           : in    std_ulogic;
    moMEM_Mp1_WDATA             : out   std_ulogic_vector(511 downto 0);
    moMEM_Mp1_WSTRB             : out   std_ulogic_vector(63 downto 0);
    moMEM_Mp1_WLAST             : out   std_ulogic;
    moMEM_Mp1_WVALID            : out   std_ulogic;
    moMEM_Mp1_WREADY            : in    std_ulogic;
    moMEM_Mp1_BID               : in    std_ulogic_vector(7 downto 0);
    moMEM_Mp1_BRESP             : in    std_ulogic_vector(1 downto 0);
    moMEM_Mp1_BVALID            : in    std_ulogic;
    moMEM_Mp1_BREADY            : out   std_ulogic;
    moMEM_Mp1_ARID              : out   std_ulogic_vector(7 downto 0);
    moMEM_Mp1_ARADDR            : out   std_ulogic_vector(32 downto 0);
    moMEM_Mp1_ARLEN             : out   std_ulogic_vector(7 downto 0);
    moMEM_Mp1_ARSIZE            : out   std_ulogic_vector(2 downto 0);
    moMEM_Mp1_ARBURST           : out   std_ulogic_vector(1 downto 0);
    moMEM_Mp1_ARVALID           : out   std_ulogic;
    moMEM_Mp1_ARREADY           : in    std_ulogic;
    moMEM_Mp1_RID               : in    std_ulogic_vector(7 downto 0);
    moMEM_Mp1_RDATA             : in    std_ulogic_vector(511 downto 0);
    moMEM_Mp1_RRESP             : in    std_ulogic_vector(1 downto 0);
    moMEM_Mp1_RLAST             : in    std_ulogic;
    moMEM_Mp1_RVALID            : in    std_ulogic;
    moMEM_Mp1_RREADY            : out   std_ulogic;

    ---- [APP_RDROL] -------------------
    -- to be use as ROLE VERSION IDENTIFICATION --
    poSHL_Mmio_RdReg            : out   std_ulogic_vector( 15 downto 0);

    --------------------------------------------------------
    -- TOP : Secondary Clock (Asynchronous)
    --------------------------------------------------------
    piTOP_250_00Clk             : in    std_ulogic;  -- Freerunning

    ------------------------------------------------
    -- FMC Interface
    ------------------------------------------------
    piFMC_ROLE_rank             : in    std_logic_vector(31 downto 0);
    piFMC_ROLE_size             : in    std_logic_vector(31 downto 0);

    ------------------------------------------------
    -- DEBUG PORTS (see UG909)
    ------------------------------------------------
    dpBSCAN_drck              : IN    std_logic;
    dpBSCAN_shift             : IN    std_logic;
    dpBSCAN_tdi               : IN    std_logic;
    dpBSCAN_update            : IN    std_logic;
    dpBSCAN_sel               : IN    std_logic;
    dpBSCAN_tdo               : OUT   std_logic;
    dpBSCAN_tms               : IN    std_logic;
    dpBSCAN_tck               : IN    std_logic;
    dpBSCAN_runtest           : IN    std_logic;
    dpBSCAN_reset             : IN    std_logic;
    dpBSCAN_capture           : IN    std_logic;
    dpBSCAN_bscanid_en        : IN    std_logic;

    poVoid                      : out   std_ulogic

  );

end Role_Themisto;


-- *****************************************************************************
-- **  ARCHITECTURE  **  FLASH of ROLE_THEMISTO
-- *****************************************************************************

architecture Flash of Role_Themisto is

  constant cUSE_DEPRECATED_DIRECTIVES       : boolean := false;

  --============================================================================
  --  DEBUG SIGNALS ATTRIBUTE DECLARATIONS (see UG909)
  --============================================================================
  attribute X_INTERFACE_INFO : string;
  attribute DEBUG : string;
  attribute X_INTERFACE_INFO of dpBSCAN_drck: signal is "xilinx.com:interface:bscan:1.0 S_BSCAN drck";
  attribute DEBUG of dpBSCAN_drck: signal is "true";
  attribute X_INTERFACE_INFO of dpBSCAN_shift: signal is "xilinx.com:interface:bscan:1.0 S_BSCAN shift";
  attribute DEBUG of dpBSCAN_shift: signal is "true";
  attribute X_INTERFACE_INFO of dpBSCAN_tdi: signal is "xilinx.com:interface:bscan:1.0 S_BSCAN tdi";
  attribute DEBUG of dpBSCAN_tdi: signal is "true";
  attribute X_INTERFACE_INFO of dpBSCAN_update: signal is "xilinx.com:interface:bscan:1.0 S_BSCAN update";
  attribute DEBUG of dpBSCAN_update: signal is "true";
  attribute X_INTERFACE_INFO of dpBSCAN_sel: signal is "xilinx.com:interface:bscan:1.0 S_BSCAN sel";
  attribute DEBUG of dpBSCAN_sel: signal is "true";
  attribute X_INTERFACE_INFO of dpBSCAN_tdo: signal is "xilinx.com:interface:bscan:1.0 S_BSCAN tdo";
  attribute DEBUG of dpBSCAN_tdo: signal is "true";
  attribute X_INTERFACE_INFO of dpBSCAN_tms: signal is "xilinx.com:interface:bscan:1.0 S_BSCAN tms";
  attribute DEBUG of dpBSCAN_tms: signal is "true";
  attribute X_INTERFACE_INFO of dpBSCAN_tck: signal is "xilinx.com:interface:bscan:1.0 S_BSCAN tck";
  attribute DEBUG of dpBSCAN_tck: signal is "true";
  attribute X_INTERFACE_INFO of dpBSCAN_runtest: signal is "xilinx.com:interface:bscan:1.0 S_BSCAN runtest";
  attribute DEBUG of dpBSCAN_runtest: signal is "true";
  attribute X_INTERFACE_INFO of dpBSCAN_reset: signal is "xilinx.com:interface:bscan:1.0 S_BSCAN reset";
  attribute DEBUG of dpBSCAN_reset: signal is "true";
  attribute X_INTERFACE_INFO of dpBSCAN_capture: signal is "xilinx.com:interface:bscan:1.0 S_BSCAN capture";
  attribute DEBUG of dpBSCAN_capture: signal is "true";
  attribute X_INTERFACE_INFO of dpBSCAN_bscanid_en: signal is "xilinx.com:interface:bscan:1.0 S_BSCAN bscanid_en";
  attribute DEBUG of dpBSCAN_bscanid_en: signal is "true";

  --============================================================================
  --  SIGNAL DECLARATIONS
  --============================================================================

  -- I hate Vivado HLS
  signal sReadTlastAsVector        : std_logic_vector(0 downto 0);
  signal sWriteTlastAsVector       : std_logic_vector(0 downto 0);
  signal sResetAsVector            : std_logic_vector(0 downto 0);

  signal sMetaOutTlastAsVector_Udp : std_logic_vector(0 downto 0);
  signal sMetaInTlastAsVector_Udp  : std_logic_vector(0 downto 0);
  signal sMetaOutTlastAsVector_Tcp : std_logic_vector(0 downto 0);
  signal sMetaInTlastAsVector_Tcp  : std_logic_vector(0 downto 0);

  signal sUdpPostCnt : std_ulogic_vector(9 downto 0);
  signal sTcpPostCnt : std_ulogic_vector(9 downto 0);

  --signal sMemTestDebugOut : std_logic_vector(15 downto 0);

  signal sResetApps_n : std_logic;

  --============================================================================
  --  VARIABLE DECLARATIONS
  --============================================================================

  --===========================================================================
  --== COMPONENT DECLARATIONS
  --===========================================================================
  component TriangleApplication is
    port (
      ------------------------------------------------------
      -- From SHELL / Clock and Reset
      ------------------------------------------------------
      ap_clk                  : in  std_logic;
      ap_rst_n                : in  std_logic;
      -- rank and size
      piFMC_ROL_rank_V        : in std_logic_vector (31 downto 0);
      piFMC_ROL_rank_V_ap_vld : in std_logic;
      --piSMC_ROL_rank_V_ap_vld : in std_logic;
      piFMC_ROL_size_V        : in std_logic_vector (31 downto 0);
      piFMC_ROL_size_V_ap_vld : in std_logic;
      --piSMC_ROL_size_V_ap_vld : in std_logic;
      --------------------------------------------------------
      -- From SHELL / Udp Data Interfaces
      --------------------------------------------------------
      siNrc_data_TDATA        : in  std_logic_vector( 63 downto 0);
      siNrc_data_TKEEP        : in  std_logic_vector(  7 downto 0);
      siNrc_data_TLAST        : in  std_logic;
      siNrc_data_TVALID       : in  std_logic;
      siNrc_data_TREADY       : out std_logic;
      --------------------------------------------------------
      -- To SHELL / Udp Data Interfaces
      --------------------------------------------------------
      soNrc_data_TDATA        : out std_logic_vector( 63 downto 0);
      soNrc_data_TKEEP        : out std_logic_vector(  7 downto 0);
      soNrc_data_TLAST        : out std_logic;
      soNrc_data_TVALID       : out std_logic;
      soNrc_data_TREADY       : in  std_logic;
      -- NRC Meta and Ports
      siNrc_meta_TDATA        : in std_logic_vector (63 downto 0);
      siNrc_meta_TVALID       : in std_logic;
      siNrc_meta_TREADY       : out std_logic;
      siNrc_meta_TKEEP        : in std_logic_vector (7 downto 0);
      siNrc_meta_TLAST        : in std_logic_vector (0 downto 0);

      soNrc_meta_TDATA        : out std_logic_vector (63 downto 0);
      soNrc_meta_TVALID       : out std_logic;
      soNrc_meta_TREADY       : in std_logic;
      soNrc_meta_TKEEP        : out std_logic_vector (7 downto 0);
      soNrc_meta_TLAST        : out std_logic_vector (0 downto 0);

      poROL_NRC_Rx_ports_V        : out std_logic_vector (31 downto 0);
      poROL_NRC_Rx_ports_V_ap_vld : out std_logic
    );
  end component TriangleApplication;

  component ila_role_0 is
    port (
      clk : IN STD_LOGIC;
      probe0    : in  std_logic_vector( 63 downto 0);
      probe1    : in  std_logic_vector(  7 downto 0);
      probe2    : in  std_logic_vector(  0 downto 0);
      probe3    : in  std_logic_vector(  0 downto 0);
      probe4    : in  std_logic_vector(  0 downto 0);
      probe5    : in  std_logic_vector( 63 downto 0);
      probe6    : in  std_logic_vector(  7 downto 0);
      probe7    : in  std_logic_vector(  0 downto 0);
      probe8    : in  std_logic_vector(  0 downto 0);
      probe9    : in  std_logic_vector(  0 downto 0);
      probe10   : in  std_logic_vector( 63 downto 0);
      probe11   : in  std_logic_vector(  7 downto 0);
      probe12   : in  std_logic_vector(  0 downto 0);
      probe13   : in  std_logic_vector(  0 downto 0);
      probe14   : in  std_logic_vector(  0 downto 0);
      probe15   : in  std_logic_vector( 63 downto 0);
      probe16   : in  std_logic_vector(  7 downto 0);
      probe17   : in  std_logic_vector(  0 downto 0);
      probe18   : in  std_logic_vector(  0 downto 0);
      probe19   : in  std_logic_vector(  0 downto 0);
      probe20   : in  std_logic_vector( 63 downto 0);
      probe21   : in  std_logic_vector(  7 downto 0);
      probe22   : in  std_logic_vector(  0 downto 0);
      probe23   : in  std_logic_vector(  0 downto 0);
      probe24   : in  std_logic_vector(  0 downto 0);
      probe25   : in  std_logic_vector( 63 downto 0);
      probe26   : in  std_logic_vector(  7 downto 0);
      probe27   : in  std_logic_vector(  0 downto 0);
      probe28   : in  std_logic_vector(  0 downto 0);
      probe29   : in  std_logic_vector(  0 downto 0);
      probe30   : in  std_logic_vector( 63 downto 0);
      probe31   : in  std_logic_vector(  7 downto 0);
      probe32   : in  std_logic_vector(  0 downto 0);
      probe33   : in  std_logic_vector(  0 downto 0);
      probe34   : in  std_logic_vector(  0 downto 0);
      probe35   : in  std_logic_vector( 63 downto 0);
      probe36   : in  std_logic_vector(  7 downto 0);
      probe37   : in  std_logic_vector(  0 downto 0);
      probe38   : in  std_logic_vector(  0 downto 0);
      probe39   : in  std_logic_vector(  0 downto 0);
      probe40   : in  std_logic_vector( 31 downto 0);
      probe41   : in  std_logic_vector( 31 downto 0)
    );
  end component ila_role_0;


  --===========================================================================
  --== FUNCTION DECLARATIONS  [TODO-Move to a package]
  --===========================================================================
  function fVectorize(s: std_logic) return std_logic_vector is
    variable v: std_logic_vector(0 downto 0);
  begin
    v(0) := s;
    return v;
  end fVectorize;

  function fScalarize(v: in std_logic_vector) return std_ulogic is
  begin
    assert v'length = 1
    report "scalarize: output port must be single bit!"
    severity FAILURE;
    return v(v'LEFT);
  end;


--################################################################################
--#                                                                              #
--#                          #####   ####  ####  #     #                         #
--#                          #    # #    # #   #  #   #                          #
--#                          #    # #    # #    #  ###                           #
--#                          #####  #    # #    #   #                            #
--#                          #    # #    # #    #   #                            #
--#                          #    # #    # #   #    #                            #
--#                          #####   ####  ####     #                            #
--#                                                                              #
--################################################################################

begin

  -- to be use as ROLE VERSION IDENTIFICATION --
  poSHL_Mmio_RdReg <= x"BEEF";

  sResetApps_n <= (not piMMIO_Ly7_Rst) and (piMMIO_Ly7_En);

  --################################################################################
  --#                                                                              #
  --#    #     #  #####    ######     #####                                        #
  --#    #     #  #    #   #     #   #     # #####   #####                         #
  --#    #     #  #     #  #     #   #     # #    #  #    #                        #
  --#    #     #  #     #  ######    ####### #####   #####                         #
  --#    #     #  #    #   #         #     # #       #                             #
  --#    #######  #####    #         #     # #       #                             #
  --#                                                                              #
  --################################################################################

  sMetaInTlastAsVector_Udp(0) <= siNRC_Role_Udp_Meta_TLAST;
  soROLE_Nrc_Udp_Meta_TLAST   <=  sMetaOutTlastAsVector_Udp(0);

  UAF: TriangleApplication
    port map (
      ------------------------------------------------------
      -- From SHELL / Clock and Reset
      ------------------------------------------------------
      ap_clk                    => piSHL_156_25Clk,
      --ap_rst_n                  => (not piMMIO_Ly7_Rst),
      ap_rst_n                  => sResetApps_n,

      piFMC_ROL_rank_V          => piFMC_ROLE_rank,
      piFMC_ROL_rank_V_ap_vld   => '1',
      piFMC_ROL_size_V          => piFMC_ROLE_size,
      piFMC_ROL_size_V_ap_vld   => '1',
      --------------------------------------------------------
      -- From SHELL / Udp Data Interfaces
      --------------------------------------------------------
      siNrc_data_TDATA          => siNRC_Udp_Data_tdata,
      siNrc_data_TKEEP          => siNRC_Udp_Data_tkeep,
      siNrc_data_TLAST          => siNRC_Udp_Data_tlast,
      siNrc_data_TVALID         => siNRC_Udp_Data_tvalid,
      siNrc_data_TREADY         => siNRC_Udp_Data_tready,
      --------------------------------------------------------
      -- To SHELL / Udp Data Interfaces
      --------------------------------------------------------
      soNrc_data_TDATA          => soNRC_Udp_Data_tdata,
      soNrc_data_TKEEP          => soNRC_Udp_Data_tkeep,
      soNrc_data_TLAST          => soNRC_Udp_Data_tlast,
      soNrc_data_TVALID         => soNRC_Udp_Data_tvalid,
      soNrc_data_TREADY         => soNRC_Udp_Data_tready,

      siNrc_meta_TDATA          =>  siNRC_Role_Udp_Meta_TDATA    ,
      siNrc_meta_TVALID         =>  siNRC_Role_Udp_Meta_TVALID   ,
      siNrc_meta_TREADY         =>  siNRC_Role_Udp_Meta_TREADY   ,
      siNrc_meta_TKEEP          =>  siNRC_Role_Udp_Meta_TKEEP    ,
      siNrc_meta_TLAST          =>  sMetaInTlastAsVector_Udp,

      soNrc_meta_TDATA          =>  soROLE_Nrc_Udp_Meta_TDATA  ,
      soNrc_meta_TVALID         =>  soROLE_Nrc_Udp_Meta_TVALID ,
      soNrc_meta_TREADY         =>  soROLE_Nrc_Udp_Meta_TREADY ,
      soNrc_meta_TKEEP          =>  soROLE_Nrc_Udp_Meta_TKEEP  ,
      soNrc_meta_TLAST          =>  sMetaOutTlastAsVector_Udp,

      poROL_NRC_Rx_ports_V      => poROL_Nrc_Udp_Rx_ports
    );

  --################################################################################
  --#                                                                              #
  --#    #######    ####   ######     #####                                        #
  --#       #      #       #     #   #     # #####   #####                         #
  --#       #     #        #     #   #     # #    #  #    #                        #
  --#       #     #        ######    ####### #####   #####                         #
  --#       #      #       #         #     # #       #                             #
  --#       #       ####   #         #     # #       #                             #
  --#                                                                              #
  --################################################################################

  sMetaInTlastAsVector_Tcp(0) <= siNRC_Role_Tcp_Meta_TLAST;
  soROLE_Nrc_Tcp_Meta_TLAST   <=  sMetaOutTlastAsVector_Tcp(0);

  TAF: TriangleApplication
    port map (

      ------------------------------------------------------
      -- From SHELL / Clock and Reset
      ------------------------------------------------------
      ap_clk                    => piSHL_156_25Clk,
      --ap_rst_n                  => (not piMMIO_Ly7_Rst),
      ap_rst_n                  => sResetApps_n,

      piFMC_ROL_rank_V          => piFMC_ROLE_rank,
      piFMC_ROL_rank_V_ap_vld   => '1',
      piFMC_ROL_size_V          => piFMC_ROLE_size,
      piFMC_ROL_size_V_ap_vld   => '1',
      --------------------------------------------------------
      -- From SHELL / Udp Data Interfaces
      --------------------------------------------------------
      siNrc_data_TDATA          => siNRC_Tcp_Data_tdata,
      siNrc_data_TKEEP          => siNRC_Tcp_Data_tkeep,
      siNrc_data_TLAST          => siNRC_Tcp_Data_tlast,
      siNrc_data_TVALID         => siNRC_Tcp_Data_tvalid,
      siNrc_data_TREADY         => siNRC_Tcp_Data_tready,
      --------------------------------------------------------
      -- To SHELL / Udp Data Interfaces
      --------------------------------------------------------
      soNrc_data_TDATA          => soNRC_Tcp_Data_tdata,
      soNrc_data_TKEEP          => soNRC_Tcp_Data_tkeep,
      soNrc_data_TLAST          => soNRC_Tcp_Data_tlast,
      soNrc_data_TVALID         => soNRC_Tcp_Data_tvalid,
      soNrc_data_TREADY         => soNRC_Tcp_Data_tready,

      siNrc_meta_TDATA          =>  siNRC_Role_Tcp_Meta_TDATA    ,
      siNrc_meta_TVALID         =>  siNRC_Role_Tcp_Meta_TVALID   ,
      siNrc_meta_TREADY         =>  siNRC_Role_Tcp_Meta_TREADY   ,
      siNrc_meta_TKEEP          =>  siNRC_Role_Tcp_Meta_TKEEP    ,
      siNrc_meta_TLAST          =>  sMetaInTlastAsVector_Tcp,

      soNrc_meta_TDATA          =>  soROLE_Nrc_Tcp_Meta_TDATA  ,
      soNrc_meta_TVALID         =>  soROLE_Nrc_Tcp_Meta_TVALID ,
      soNrc_meta_TREADY         =>  soROLE_Nrc_Tcp_Meta_TREADY ,
      soNrc_meta_TKEEP          =>  soROLE_Nrc_Tcp_Meta_TKEEP  ,
      soNrc_meta_TLAST          =>  sMetaOutTlastAsVector_Tcp,

      poROL_NRC_Rx_ports_V      => poROL_Nrc_Tcp_Rx_ports
    );


  --################################################################################
  --  Debug Core instantiation
  --################################################################################

  DBG: ila_role_0
    port map (
      clk => piSHL_156_25Clk,
      probe0      =>   siNRC_Udp_Data_tdata       ,
      probe1      =>   siNRC_Udp_Data_tkeep       ,
      probe2(0)   =>   siNRC_Udp_Data_tlast       ,
      probe3(0)   =>   siNRC_Udp_Data_tvalid      ,
      probe4(0)   =>   siNRC_Udp_Data_tready      ,
      probe5      =>   soNRC_Udp_Data_tdata       ,
      probe6      =>   soNRC_Udp_Data_tkeep       ,
      probe7(0)   =>   soNRC_Udp_Data_tlast       ,
      probe8(0)   =>   soNRC_Udp_Data_tvalid      ,
      probe9(0)   =>   soNRC_Udp_Data_tready      ,
      probe10     =>   siNRC_Role_Udp_Meta_TDATA  ,
      probe11     =>   siNRC_Role_Udp_Meta_TKEEP  ,
      probe12(0)  =>   siNRC_Role_Udp_Meta_TREADY ,
      probe13(0)  =>   siNRC_Role_Udp_Meta_TVALID ,
      probe14(0)  =>   siNRC_Role_Udp_Meta_TLAST  ,
      probe15     =>   soROLE_Nrc_Udp_Meta_TDATA  ,
      probe16     =>   soROLE_Nrc_Udp_Meta_TKEEP  ,
      probe17(0)  =>   soROLE_Nrc_Udp_Meta_TREADY ,
      probe18(0)  =>   soROLE_Nrc_Udp_Meta_TVALID ,
      probe19(0)  =>   soROLE_Nrc_Udp_Meta_TLAST  ,
      probe20     =>   siNRC_Tcp_Data_tdata        ,
      probe21     =>   siNRC_Tcp_Data_tkeep        ,
      probe22(0)  =>   siNRC_Tcp_Data_tlast        ,
      probe23(0)  =>   siNRC_Tcp_Data_tvalid       ,
      probe24(0)  =>   siNRC_Tcp_Data_tready       ,
      probe25     =>   soNRC_Tcp_Data_tdata        ,
      probe26     =>   soNRC_Tcp_Data_tkeep        ,
      probe27(0)  =>   soNRC_Tcp_Data_tlast        ,
      probe28(0)  =>   soNRC_Tcp_Data_tvalid       ,
      probe29(0)  =>   soNRC_Tcp_Data_tready       ,
      probe30     =>   siNRC_Role_Tcp_Meta_TDATA   ,
      probe31     =>   siNRC_Role_Tcp_Meta_TKEEP   ,
      probe32(0)  =>   siNRC_Role_Tcp_Meta_TREADY  ,
      probe33(0)  =>   siNRC_Role_Tcp_Meta_TVALID  ,
      probe34(0)  =>   siNRC_Role_Tcp_Meta_TLAST   ,
      probe35     =>   soROLE_Nrc_Tcp_Meta_TDATA   ,
      probe36     =>   soROLE_Nrc_Tcp_Meta_TKEEP   ,
      probe37(0)  =>   soROLE_Nrc_Tcp_Meta_TREADY  ,
      probe38(0)  =>   soROLE_Nrc_Tcp_Meta_TVALID  ,
      probe39(0)  =>   soROLE_Nrc_Tcp_Meta_TLAST   ,
      probe40     =>    poROL_Nrc_Udp_Rx_ports,
      probe41     =>    poROL_Nrc_Tcp_Rx_ports
    );


  --################################################################################
  --  1st Memory Port dummy connections
  --################################################################################
  soMEM_Mp0_RdCmd_tdata   <= (others => '0');
  soMEM_Mp0_RdCmd_tvalid  <= '0';
  siMEM_Mp0_RdSts_tready  <= '0';
  siMEM_Mp0_Read_tready   <= '0';
  soMEM_Mp0_WrCmd_tdata   <= (others => '0');
  soMEM_Mp0_WrCmd_tvalid  <= '0';
  siMEM_Mp0_WrSts_tready  <= '0';
  soMEM_Mp0_Write_tdata   <= (others => '0');
  soMEM_Mp0_Write_tkeep   <= (others => '0');
  soMEM_Mp0_Write_tlast   <= '0';
  soMEM_Mp0_Write_tvalid  <= '0';

  --################################################################################
  --  2nd Memory Port dummy connections
  --################################################################################
  moMEM_Mp1_AWVALID       <= '0';
  moMEM_Mp1_WVALID        <= '0';
  moMEM_Mp1_BREADY        <= '0';
  moMEM_Mp1_ARVALID       <= '0';
  moMEM_Mp1_RREADY        <= '0';

end architecture Flash;


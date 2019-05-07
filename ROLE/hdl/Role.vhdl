-- *****************************************************************************
-- *
-- *                             cloudFPGA
-- *            All rights reserved -- Property of IBM
-- *
-- *----------------------------------------------------------------------------
-- *
-- * Title : Flash for the FMKU2595 when equipped with a XCKU060.
-- *
-- * File    : roleFlash.vhdl
-- *
-- * Created : Feb 2018
-- * Authors : Francois Abel <fab@zurich.ibm.com>
-- *           Beat Weiss <wei@zurich.ibm.com>
-- *           Burkhard Ringlein <ngl@zurich.ibm.com>
-- *
-- * Devices : xcku060-ffva1156-2-i
-- * Tools   : Vivado v2016.4, 2017.4 (64-bit)
-- * Depends : None
-- *
-- * Description : In cloudFPGA, the user application is referred to as a 'ROLE'    
-- *    and is integrated along with a 'SHELL' that abstracts the HW components
-- *    of the FPGA module. 
-- *    The current module contains the boot Flash application of the FPGA card
-- *    that is specified here as a 'ROLE'. Such a role is referred to as a
-- *    "superuser" role because it cannot be instantiated by a non-priviledged
-- *    cloudFPGA user. 
-- *
-- *    As the name of the entity indicates, this ROLE implements the following
-- *    interfaces with the SHELL:
-- *      - one UDP port interface (based on the AXI4-Stream interface), 
-- *      - one TCP port interface (based on the AXI4-Stream interface),
-- *      - two Memory Port interfaces (based on the MM2S and S2MM AXI4-Stream
-- *        interfaces described in PG022-AXI-DataMover).
-- *
-- * Parameters: None.
-- *
-- * Comments:
-- *  [FIXME] - Why is 'sROL_Shl_Nts0_Udp_Axis_tdata[63:0]' only active every 
-- *            second clock cycle?
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

-- library XIL_DEFAULTLIB;
-- use     XIL_DEFAULTLIB.all;


--******************************************************************************
--**  ENTITY  **  FMKU60 ROLE
--******************************************************************************

entity Role_Themisto is
  port (

    ------------------------------------------------------
    -- SHELL / Global Input Clock and Reset Interface
    ------------------------------------------------------
    piSHL_156_25Clk                     : in    std_ulogic;
    piSHL_156_25Rst                     : in    std_ulogic;
    piSHL_156_25Rst_delayed             : in    std_ulogic;

    --------------------------------------------------------
    -- SHELL / Role / Nts0 / Udp Interface
    --------------------------------------------------------
    ---- Input AXI-Write Stream Interface ----------
    piSHL_Rol_Nts0_Udp_Axis_tdata       : in    std_ulogic_vector( 63 downto 0);
    piSHL_Rol_Nts0_Udp_Axis_tkeep       : in    std_ulogic_vector(  7 downto 0);
    piSHL_Rol_Nts0_Udp_Axis_tlast       : in    std_ulogic;
    piSHL_Rol_Nts0_Udp_Axis_tvalid      : in    std_ulogic;  
    poROL_Shl_Nts0_Udp_Axis_tready      : out   std_ulogic;
    ---- Output AXI-Write Stream Interface ---------
    piSHL_Rol_Nts0_Udp_Axis_tready      : in    std_ulogic;
    poROL_Shl_Nts0_Udp_Axis_tdata       : out   std_ulogic_vector( 63 downto 0);
    poROL_Shl_Nts0_Udp_Axis_tkeep       : out   std_ulogic_vector(  7 downto 0);
    poROL_Shl_Nts0_Udp_Axis_tlast       : out   std_ulogic;
    poROL_Shl_Nts0_Udp_Axis_tvalid      : out   std_ulogic;
    -- Open Port vector
    poROL_Nrc_Udp_Rx_ports              : out    std_ulogic_vector( 31 downto 0);
    -- ROLE <-> NRC Meta Interface
    poROLE_Nrc_Meta_TDATA               : out   std_ulogic_vector( 47 downto 0);
    poROLE_Nrc_Meta_TVALID              : out   std_ulogic;
    poROLE_Nrc_Meta_TREADY              : in    std_ulogic;
    poROLE_Nrc_Meta_TKEEP               : out   std_ulogic_vector(  5 downto 0);
    poROLE_Nrc_Meta_TLAST               : out   std_ulogic;
    piNRC_Role_Meta_TDATA               : in    std_ulogic_vector( 47 downto 0);
    piNRC_Role_Meta_TVALID              : in    std_ulogic;
    piNRC_Role_Meta_TREADY              : out   std_ulogic;
    piNRC_Role_Meta_TKEEP               : in    std_ulogic_vector(  5 downto 0);
    piNRC_Role_Meta_TLAST               : in    std_ulogic;
   
    --------------------------------------------------------
    -- SHELL / Role / Nts0 / Tcp Interface
    --------------------------------------------------------
    ---- Input AXI-Write Stream Interface ----------
    piSHL_Rol_Nts0_Tcp_Axis_tdata       : in    std_ulogic_vector( 63 downto 0);
    piSHL_Rol_Nts0_Tcp_Axis_tkeep       : in    std_ulogic_vector(  7 downto 0);
    piSHL_Rol_Nts0_Tcp_Axis_tlast       : in    std_ulogic;
    piSHL_Rol_Nts0_Tcp_Axis_tvalid      : in    std_ulogic;
    poROL_Shl_Nts0_Tcp_Axis_tready      : out   std_ulogic;
    ---- Output AXI-Write Stream Interface ---------
    piSHL_Rol_Nts0_Tcp_Axis_tready      : in    std_ulogic;
    poROL_Shl_Nts0_Tcp_Axis_tdata       : out   std_ulogic_vector( 63 downto 0);
    poROL_Shl_Nts0_Tcp_Axis_tkeep       : out   std_ulogic_vector(  7 downto 0);
    poROL_Shl_Nts0_Tcp_Axis_tlast       : out   std_ulogic;
    poROL_Shl_Nts0_Tcp_Axis_tvalid      : out   std_ulogic;
    
    --------------------------------------------------------
    -- SHELL / Role / Mem / Mp0 Interface
    --------------------------------------------------------
    ---- Memory Port #0 / S2MM-AXIS ----------------   
    ------ Stream Read Command -----------------
    piSHL_Rol_Mem_Mp0_Axis_RdCmd_tready : in    std_ulogic;
    poROL_Shl_Mem_Mp0_Axis_RdCmd_tdata  : out   std_ulogic_vector( 79 downto 0);
    poROL_Shl_Mem_Mp0_Axis_RdCmd_tvalid : out   std_ulogic;
    ------ Stream Read Status ------------------
    piSHL_Rol_Mem_Mp0_Axis_RdSts_tdata  : in    std_ulogic_vector(  7 downto 0);
    piSHL_Rol_Mem_Mp0_Axis_RdSts_tvalid : in    std_ulogic;
    poROL_Shl_Mem_Mp0_Axis_RdSts_tready : out   std_ulogic;
    ------ Stream Data Input Channel -----------
    piSHL_Rol_Mem_Mp0_Axis_Read_tdata   : in    std_ulogic_vector(511 downto 0);
    piSHL_Rol_Mem_Mp0_Axis_Read_tkeep   : in    std_ulogic_vector( 63 downto 0);
    piSHL_Rol_Mem_Mp0_Axis_Read_tlast   : in    std_ulogic;
    piSHL_Rol_Mem_Mp0_Axis_Read_tvalid  : in    std_ulogic;
    poROL_Shl_Mem_Mp0_Axis_Read_tready  : out   std_ulogic;
    ------ Stream Write Command ----------------
    piSHL_Rol_Mem_Mp0_Axis_WrCmd_tready : in    std_ulogic;
    poROL_Shl_Mem_Mp0_Axis_WrCmd_tdata  : out   std_ulogic_vector( 79 downto 0);
    poROL_Shl_Mem_Mp0_Axis_WrCmd_tvalid : out   std_ulogic;
    ------ Stream Write Status -----------------
    piSHL_Rol_Mem_Mp0_Axis_WrSts_tdata  : in    std_ulogic_vector(  7 downto 0);
    piSHL_Rol_Mem_Mp0_Axis_WrSts_tvalid : in    std_ulogic;
    poROL_Shl_Mem_Mp0_Axis_WrSts_tready : out   std_ulogic;
    ------ Stream Data Output Channel ----------
    piSHL_Rol_Mem_Mp0_Axis_Write_tready : in    std_ulogic; 
    poROL_Shl_Mem_Mp0_Axis_Write_tdata  : out   std_ulogic_vector(511 downto 0);
    poROL_Shl_Mem_Mp0_Axis_Write_tkeep  : out   std_ulogic_vector( 63 downto 0);
    poROL_Shl_Mem_Mp0_Axis_Write_tlast  : out   std_ulogic;
    poROL_Shl_Mem_Mp0_Axis_Write_tvalid : out   std_ulogic;
    
    --------------------------------------------------------
    -- SHELL / Role / Mem / Mp1 Interface
    --------------------------------------------------------
    ---- Memory Port #1 / S2MM-AXIS ----------------   
    ------ Stream Read Command -----------------
    piSHL_Rol_Mem_Mp1_Axis_RdCmd_tready : in    std_ulogic;
    poROL_Shl_Mem_Mp1_Axis_RdCmd_tdata  : out   std_ulogic_vector( 79 downto 0);
    poROL_Shl_Mem_Mp1_Axis_RdCmd_tvalid : out   std_ulogic;
    ------ Stream Read Status ------------------
    piSHL_Rol_Mem_Mp1_Axis_RdSts_tdata  : in    std_ulogic_vector(  7 downto 0);
    piSHL_Rol_Mem_Mp1_Axis_RdSts_tvalid : in    std_ulogic;
    poROL_Shl_Mem_Mp1_Axis_RdSts_tready : out   std_ulogic;
    ------ Stream Data Input Channel -----------
    piSHL_Rol_Mem_Mp1_Axis_Read_tdata   : in    std_ulogic_vector(511 downto 0);
    piSHL_Rol_Mem_Mp1_Axis_Read_tkeep   : in    std_ulogic_vector( 63 downto 0);
    piSHL_Rol_Mem_Mp1_Axis_Read_tlast   : in    std_ulogic;
    piSHL_Rol_Mem_Mp1_Axis_Read_tvalid  : in    std_ulogic;
    poROL_Shl_Mem_Mp1_Axis_Read_tready  : out   std_ulogic;
    ------ Stream Write Command ----------------
    piSHL_Rol_Mem_Mp1_Axis_WrCmd_tready : in    std_ulogic;
    poROL_Shl_Mem_Mp1_Axis_WrCmd_tdata  : out   std_ulogic_vector( 79 downto 0);
    poROL_Shl_Mem_Mp1_Axis_WrCmd_tvalid : out   std_ulogic;
    ------ Stream Write Status -----------------
    piSHL_Rol_Mem_Mp1_Axis_WrSts_tvalid : in    std_ulogic;
    piSHL_Rol_Mem_Mp1_Axis_WrSts_tdata  : in    std_ulogic_vector(  7 downto 0);
    poROL_Shl_Mem_Mp1_Axis_WrSts_tready : out   std_ulogic;
    ------ Stream Data Output Channel ----------
    piSHL_Rol_Mem_Mp1_Axis_Write_tready : in    std_ulogic; 
    poROL_Shl_Mem_Mp1_Axis_Write_tdata  : out   std_ulogic_vector(511 downto 0);
    poROL_Shl_Mem_Mp1_Axis_Write_tkeep  : out   std_ulogic_vector( 63 downto 0);
    poROL_Shl_Mem_Mp1_Axis_Write_tlast  : out   std_ulogic;
    poROL_Shl_Mem_Mp1_Axis_Write_tvalid : out   std_ulogic;
    
    --------------------------------------------------------
    -- SHELL / Role / Mmio / Flash Debug Interface
    --------------------------------------------------------
    -- MMIO / CTRL_2 Register ----------------
    piSHL_Rol_Mmio_UdpEchoCtrl          : in    std_ulogic_vector(  1 downto 0);
    piSHL_Rol_Mmio_UdpPostPktEn         : in    std_ulogic;
    piSHL_Rol_Mmio_UdpCaptPktEn         : in    std_ulogic;
    piSHL_Rol_Mmio_TcpEchoCtrl          : in    std_ulogic_vector(  1 downto 0);
    piSHL_Rol_Mmio_TcpPostPktEn         : in    std_ulogic;
    piSHL_Rol_Mmio_TcpCaptPktEn         : in    std_ulogic;

    --------------------------------------------------------
    -- ROLE EMIF Registers
    --------------------------------------------------------
    poROL_SHL_EMIF_2B_Reg               : out  std_logic_vector( 15 downto 0);
    piSHL_ROL_EMIF_2B_Reg               : in   std_logic_vector( 15 downto 0);
    --------------------------------------------------------
    -- DIAG Registers for MemTest
    --------------------------------------------------------
    piDIAG_CTRL                         : in  std_logic_vector(1 downto 0);
    poDIAG_STAT                         : out std_logic_vector(1 downto 0);
    --------------------------------------------------------
    -- TOP : Secondary Clock (Asynchronous)
    --------------------------------------------------------
    piTOP_250_00Clk                     : in    std_ulogic;  -- Freerunning
    
    ------------------------------------------------
    -- SMC Interface
    ------------------------------------------------ 
    piSMC_ROLE_rank                      : in    std_logic_vector(31 downto 0);
    piSMC_ROLE_size                      : in    std_logic_vector(31 downto 0);
    
    poVoid                              : out   std_ulogic

  );
  
end Role_Themisto;


-- *****************************************************************************
-- **  ARCHITECTURE  **  FLASH of ROLE 
-- *****************************************************************************

architecture Flash of Role_Themisto is

  constant cUSE_DEPRECATED_DIRECTIVES       : boolean := true;

  --============================================================================
  --  SIGNAL DECLARATIONS
  --============================================================================  

  ------------------------------------------------------
  -- UDP AXIS READ Register
  ------------------------------------------------------
  signal sUdpAxisReadReg_tdata              : std_ulogic_vector( 63 downto 0);
  signal sUdpAxisReadReg_tkeep              : std_ulogic_vector(  7 downto 0);
  signal sUdpAxisReadReg_tlast              : std_ulogic;
  signal sUdpAxisReadReg_tvalid             : std_ulogic;
   
  ------------------------------------------------------
  -- UDP PASS-THROUGH Register
  ------------------------------------------------------
  signal sUdpPassThruReg_tdata              : std_ulogic_vector( 63 downto 0);
  signal sUdpPassThruReg_tkeep              : std_ulogic_vector(  7 downto 0);
  signal sUdpPassThruReg_tlast              : std_ulogic;
  signal sUdpPassThruReg_tvalid             : std_ulogic;
   
  signal sUdpPassThruReg_isFull             : boolean;

  ------------------------------------------------------
  -- ROLE / Nts0 / Udp Interfaces
  ------------------------------------------------------
  ------ Input AXI-Write Stream Interface         ------
  signal sROL_Shl_Nts0_Udp_Axis_tready      : std_ulogic;
  signal sSHL_Rol_Nts0_Udp_Axis_tdata       : std_ulogic_vector( 63 downto 0);
  signal sSHL_Rol_Nts0_Udp_Axis_tkeep       : std_ulogic_vector(  7 downto 0);
  signal sSHL_Rol_Nts0_Udp_Axis_tlast       : std_ulogic;  
  signal sSHL_Rol_Nts0_Udp_Axis_tvalid      : std_ulogic;
  ------ Output AXI-Write Stream Interface        ------
  signal sROL_Shl_Nts0_Udp_Axis_tdata       : std_ulogic_vector( 63 downto 0);
  signal sROL_Shl_Nts0_Udp_Axis_tkeep       : std_ulogic_vector(  7 downto 0);
  signal sROL_Shl_Nts0_Udp_Axis_tlast       : std_ulogic;
  signal sROL_Shl_Nts0_Udp_Axis_tvalid      : std_ulogic;
  signal sSHL_Rol_Nts0_Udp_Axis_tready      : std_ulogic;

  --============================================================================
  -- TEMPORARY PROC: ROLE / Nts0 / Tcp Interface to AVOID UNDEFINED CONTENT
  --============================================================================
  ------ Input AXI-Write Stream Interface --------
  signal sROL_Shl_Nts0_Tcp_Axis_tready      : std_ulogic;
  signal sSHL_Rol_Nts0_Tcp_Axis_tdata       : std_ulogic_vector( 63 downto 0);
  signal sSHL_Rol_Nts0_Tcp_Axis_tkeep       : std_ulogic_vector(  7 downto 0);
  signal sSHL_Rol_Nts0_Tcp_Axis_tlast       : std_ulogic;
  signal sSHL_Rol_Nts0_Tcp_Axis_tvalid      : std_ulogic;
  ------ Output AXI-Write Stream Interface -------
  signal sROL_Shl_Nts0_Tcp_Axis_tdata       : std_ulogic_vector( 63 downto 0);
  signal sROL_Shl_Nts0_Tcp_Axis_tkeep       : std_ulogic_vector(  7 downto 0);
  signal sROL_Shl_Nts0_Tcp_Axis_tlast       : std_ulogic;
  signal sROL_Shl_Nts0_Tcp_Axis_tvalid      : std_ulogic;
  signal sSHL_Rol_Nts0_Tcp_Axis_tready      : std_ulogic;
  
  --============================================================================
  -- TEMPORARY PROC: ROLE / Mem / Mp0 Interface to AVOID UNDEFINED CONTENT
  --============================================================================
  ------  Stream Read Command --------------
  signal sROL_Shl_Mem_Mp0_Axis_RdCmd_tdata  : std_ulogic_vector( 71 downto 0);
  signal sROL_Shl_Mem_Mp0_Axis_RdCmd_tvalid : std_ulogic;
  signal sSHL_Rol_Mem_Mp0_Axis_RdCmd_tready : std_ulogic;
  ------ Stream Read Status ----------------
  signal sROL_Shl_Mem_Mp0_Axis_RdSts_tready : std_ulogic;
  signal sSHL_Rol_Mem_Mp0_Axis_RdSts_tdata  : std_ulogic_vector(  7 downto 0);
  signal sSHL_Rol_Mem_Mp0_Axis_RdSts_tvalid : std_ulogic;
  ------ Stream Data Input Channel ---------
  signal sROL_Shl_Mem_Mp0_Axis_Read_tready  : std_ulogic;
  signal sSHL_Rol_Mem_Mp0_Axis_Read_tdata   : std_ulogic_vector(511 downto 0);
  signal sSHL_Rol_Mem_Mp0_Axis_Read_tkeep   : std_ulogic_vector( 63 downto 0);
  signal sSHL_Rol_Mem_Mp0_Axis_Read_tlast   : std_ulogic;
  signal sSHL_Rol_Mem_Mp0_Axis_Read_tvalid  : std_ulogic;
  ------ Stream Write Command --------------
  signal sROL_Shl_Mem_Mp0_Axis_WrCmd_tdata  : std_ulogic_vector( 71 downto 0);
  signal sROL_Shl_Mem_Mp0_Axis_WrCmd_tvalid : std_ulogic;
  signal sSHL_Rol_Mem_Mp0_Axis_WrCmd_tready : std_ulogic;
  ------ Stream Write Status ---------------
  signal sROL_Shl_Mem_Mp0_Axis_WrSts_tready : std_ulogic;
  signal sSHL_Rol_Mem_Mp0_Axis_WrSts_tdata  : std_ulogic_vector(  7 downto 0);
  signal sSHL_Rol_Mem_Mp0_Axis_WrSts_tvalid : std_ulogic;
  ------ Stream Data Output Channel --------
  signal sROL_Shl_Mem_Mp0_Axis_Write_tdata  : std_ulogic_vector(511 downto 0);
  signal sROL_Shl_Mem_Mp0_Axis_Write_tkeep  : std_ulogic_vector( 63 downto 0);
  signal sROL_Shl_Mem_Mp0_Axis_Write_tlast  : std_ulogic;
  signal sROL_Shl_Mem_Mp0_Axis_Write_tvalid : std_ulogic;
  signal sSHL_Rol_Mem_Mp0_Axis_Write_tready : std_ulogic;
  
  ------ ROLE EMIF Registers ---------------
  -- signal sSHL_ROL_EMIF_2B_Reg               : std_logic_vector( 15 downto 0);
  -- signal sROL_SHL_EMIF_2B_Reg               : std_logic_vector( 15 downto 0);

  signal EMIF_inv   : std_logic_vector(7 downto 0);

  -- I hate Vivado HLS 
  signal sReadTlastAsVector : std_logic_vector(0 downto 0);
  signal sWriteTlastAsVector : std_logic_vector(0 downto 0);
  signal sResetAsVector : std_logic_vector(0 downto 0);

  signal sMetaOutTlastAsVector : std_logic_vector(0 downto 0);
  signal sMetaInTlastAsVector : std_logic_vector(0 downto 0);

  --============================================================================
  --  VARIABLE DECLARATIONS
  --============================================================================  
  signal sUdpPostCnt : std_ulogic_vector(9 downto 0);
  signal sTcpPostCnt : std_ulogic_vector(9 downto 0);
 
  --===========================================================================
  --== COMPONENT DECLARATIONS
  --===========================================================================
  component UdpApplicationFlash is
    port (
      ------------------------------------------------------
      -- From SHELL / Clock and Reset
      ------------------------------------------------------
      ap_clk                      : in  std_logic;
      ap_rst_n                    : in  std_logic;
      ap_start                    : in  std_logic;
      --------------------------------------------------------
      -- From SHELL / Mmio Interfaces
      --------------------------------------------------------       
      --piSHL_This_MmioEchoCtrl_V : in  std_logic_vector(  1 downto 0);
      --[TODO] piSHL_This_MmioPostPktEn  : in  std_logic;
      --[TODO] piSHL_This_MmioCaptPktEn  : in  std_logic;

      -- rank and size
      piSMC_ROL_rank_V        : in std_logic_vector (31 downto 0);
      piSMC_ROL_rank_V_ap_vld : in std_logic;
      piSMC_ROL_size_V        : in std_logic_vector (31 downto 0);
      piSMC_ROL_size_V_ap_vld : in std_logic;
      --------------------------------------------------------
      -- From SHELL / Udp Data Interfaces
      --------------------------------------------------------
      siSHL_This_Data_tdata     : in  std_logic_vector( 63 downto 0);
      siSHL_This_Data_tkeep     : in  std_logic_vector(  7 downto 0);
      siSHL_This_Data_tlast     : in  std_logic;
      siSHL_This_Data_tvalid    : in  std_logic;
      siSHL_This_Data_tready    : out std_logic;
      --------------------------------------------------------
      -- To SHELL / Udp Data Interfaces
      --------------------------------------------------------
      soTHIS_Shl_Data_tdata     : out std_logic_vector( 63 downto 0);
      soTHIS_Shl_Data_tkeep     : out std_logic_vector(  7 downto 0);
      soTHIS_Shl_Data_tlast     : out std_logic;
      soTHIS_Shl_Data_tvalid    : out std_logic;
      soTHIS_Shl_Data_tready    : in  std_logic;
      -- NRC Meta and Ports
      siNrc_meta_TDATA          : in std_logic_vector (47 downto 0);
      siNrc_meta_TVALID         : in std_logic;
      siNrc_meta_TREADY         : out std_logic;
      siNrc_meta_TKEEP          : in std_logic_vector (5 downto 0);
      siNrc_meta_TLAST          : in std_logic_vector (0 downto 0);
      
      soNrc_meta_TDATA          : out std_logic_vector (47 downto 0);
      soNrc_meta_TVALID         : out std_logic;
      soNrc_meta_TREADY         : in std_logic;
      soNrc_meta_TKEEP          : out std_logic_vector (5 downto 0);
      soNrc_meta_TLAST          : out std_logic_vector (0 downto 0);
   
      poROL_NRC_Udp_Rx_ports_V        : out std_logic_vector (31 downto 0);
      poROL_NRC_Udp_Rx_ports_V_ap_vld : out std_logic
    );
  end component UdpApplicationFlash;
 
 
  
  component TcpApplicationFlash is
    port (
      ------------------------------------------------------
      -- From SHELL / Clock and Reset
      ------------------------------------------------------
      aclk                      : in  std_logic;
      aresetn                   : in  std_logic;    
      --------------------------------------------------------
      -- From SHELL / Mmio Interfaces
      --------------------------------------------------------       
      piSHL_This_MmioEchoCtrl_V : in  std_logic_vector(  1 downto 0);
      --[TODO] piSHL_This_MmioPostPktEn  : in  std_logic;
      --[TODO] piSHL_This_MmioCaptPktEn  : in  std_logic;
      --------------------------------------------------------
      -- From SHELL / Udp Data Interfaces
      --------------------------------------------------------
      siSHL_This_Data_tdata     : in  std_logic_vector( 63 downto 0);
      siSHL_This_Data_tkeep     : in  std_logic_vector(  7 downto 0);
      siSHL_This_Data_tlast     : in  std_logic;
      siSHL_This_Data_tvalid    : in  std_logic;
      siSHL_This_Data_tready    : out std_logic;
      --------------------------------------------------------
      -- To SHELL / Udp Data Interfaces
      --------------------------------------------------------
      soTHIS_Shl_Data_tdata     : out std_logic_vector( 63 downto 0);
      soTHIS_Shl_Data_tkeep     : out std_logic_vector(  7 downto 0);
      soTHIS_Shl_Data_tlast     : out std_logic;
      soTHIS_Shl_Data_tvalid    : out std_logic;
      soTHIS_Shl_Data_tready    : in  std_logic
    );
  end component TcpApplicationFlash;
 

  component TcpApplicationFlashFail is
    port (
      ------------------------------------------------------
      -- From SHELL / Clock and Reset
      ------------------------------------------------------
      ap_clk                    : in  std_logic;
      ap_rst_n                  : in  std_logic;
      ------------------------------------------------------
      -- BLock-Level I/O Protocol
      ------------------------------------------------------
      --ap_start                  : in  std_logic;
      --ap_ready                  : out std_logic;
      --ap_done                   : out std_logic;
      --ap_idle                   : out std_logic;
      --------------------------------------------------------
      -- From SHELL / Mmio Interfaces
      --------------------------------------------------------       
      piSHL_This_MmioEchoCtrl_V : in  std_logic_vector(  1 downto 0);
      --[TODO] piSHL_This_MmioPostPktEn  : in  std_logic;
      --[TODO] piSHL_This_MmioCaptPktEn  : in  std_logic;
      --------------------------------------------------------
      -- From SHELL / Udp Data Interfaces
      --------------------------------------------------------
      siSHL_This_Data_tdata     : in  std_logic_vector( 63 downto 0);
      siSHL_This_Data_tkeep     : in  std_logic_vector(  7 downto 0);
      siSHL_This_Data_tlast     : in  std_logic_vector(  0 downto 0);
      siSHL_This_Data_tvalid    : in  std_logic;
      siSHL_This_Data_tready    : out std_logic;
      --------------------------------------------------------
      -- To SHELL / Udp Data Interfaces
      --------------------------------------------------------
      soTHIS_Shl_Data_tdata     : out std_logic_vector( 63 downto 0);
      soTHIS_Shl_Data_tkeep     : out std_logic_vector(  7 downto 0);
      soTHIS_Shl_Data_tlast     : out std_logic_vector(  0 downto 0);
      soTHIS_Shl_Data_tvalid    : out std_logic;
      soTHIS_Shl_Data_tready    : in  std_logic
    );
  end component TcpApplicationFlashFail; 

  component MemTestFlash is
    port (
           ap_clk                     : IN STD_LOGIC;
           ap_rst_n                   : IN STD_LOGIC;
           ap_start                   : IN STD_LOGIC;
           ap_done                    : OUT STD_LOGIC;
           ap_idle                    : OUT STD_LOGIC;
           ap_ready                   : OUT STD_LOGIC;
           piSysReset_V               : IN STD_LOGIC_VECTOR (0 downto 0);
           piSysReset_V_ap_vld        : IN STD_LOGIC;
           piMMIO_diag_ctrl_V         : IN STD_LOGIC_VECTOR (1 downto 0);
           piMMIO_diag_ctrl_V_ap_vld  : IN STD_LOGIC;
           poMMIO_diag_stat_V         : OUT STD_LOGIC_VECTOR (1 downto 0);
           poMMIO_diag_stat_V_ap_vld  : OUT STD_LOGIC;
           poDebug_V                  : OUT STD_LOGIC_VECTOR (15 downto 0);
           poDebug_V_ap_vld           : OUT STD_LOGIC;
           soMemRdCmdP0_TDATA         : OUT STD_LOGIC_VECTOR (79 downto 0);
           soMemRdCmdP0_TVALID        : OUT STD_LOGIC;
           soMemRdCmdP0_TREADY        : IN STD_LOGIC;
           siMemRdStsP0_TDATA         : IN STD_LOGIC_VECTOR (7 downto 0);
           siMemRdStsP0_TVALID        : IN STD_LOGIC;
           siMemRdStsP0_TREADY        : OUT STD_LOGIC;
           siMemReadP0_TDATA          : IN STD_LOGIC_VECTOR (511 downto 0);
           siMemReadP0_TVALID         : IN STD_LOGIC;
           siMemReadP0_TREADY         : OUT STD_LOGIC;
           siMemReadP0_TKEEP          : IN STD_LOGIC_VECTOR (63 downto 0);
           siMemReadP0_TLAST          : IN STD_LOGIC_VECTOR (0 downto 0);
           soMemWrCmdP0_TDATA         : OUT STD_LOGIC_VECTOR (79 downto 0);
           soMemWrCmdP0_TVALID        : OUT STD_LOGIC;
           soMemWrCmdP0_TREADY        : IN STD_LOGIC;
           siMemWrStsP0_TDATA         : IN STD_LOGIC_VECTOR (7 downto 0);
           siMemWrStsP0_TVALID        : IN STD_LOGIC;
           siMemWrStsP0_TREADY        : OUT STD_LOGIC;
           soMemWriteP0_TDATA         : OUT STD_LOGIC_VECTOR (511 downto 0);
           soMemWriteP0_TVALID        : OUT STD_LOGIC;
           soMemWriteP0_TREADY        : IN STD_LOGIC;
           soMemWriteP0_TKEEP         : OUT STD_LOGIC_VECTOR (63 downto 0);
           soMemWriteP0_TLAST         : OUT STD_LOGIC_VECTOR (0 downto 0) 
         );
  end component MemTestFlash;

  
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

--  -- write constant to EMIF Register to test read out 
--  --poROL_SHL_EMIF_2B_Reg <= x"EF" & EMIF_inv; 
--  poROL_SHL_EMIF_2B_Reg( 7 downto 0)  <= EMIF_inv; 
  poROL_SHL_EMIF_2B_Reg(11 downto 8) <= piSMC_ROLE_rank(3 downto 0) when (unsigned(piSMC_ROLE_rank) /= 0) else 
                                      x"F"; 
  poROL_SHL_EMIF_2B_Reg(15 downto 12) <= piSMC_ROLE_size(3 downto 0) when (unsigned(piSMC_ROLE_size) /= 0) else 
                                      x"E"; 

--  EMIF_inv <= (not piSHL_ROL_EMIF_2B_Reg(7 downto 0)) when piSHL_ROL_EMIF_2B_Reg(15) = '1' else 
--              x"BE" ;
--
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

  gUdpAppFlashDepre : if cUSE_DEPRECATED_DIRECTIVES generate --TODO
    
    begin 

      sMetaInTlastAsVector(0) <= piNRC_Role_Meta_TLAST;
      poROLE_Nrc_Meta_TLAST <=  sMetaOutTlastAsVector(0);

      --==========================================================================
      --==  INST: UDP-APPLICATION_FLASH for FMKU60
      --==   This version of the 'udp_app_flash' has the following interfaces:
      --==    - one bidirectionnal UDP data stream and one streaming MemoryPort. 
      --==========================================================================
      UAF : UdpApplicationFlash
        port map (
        
          ------------------------------------------------------
          -- From SHELL / Clock and Reset
          ------------------------------------------------------
          ap_clk                      => piSHL_156_25Clk,
          ap_rst_n                    => (not piSHL_156_25Rst),
          ap_start                    => '1',
           --------------------------------------------------------
           -- From SHELL / Mmio Interfaces
           --------------------------------------------------------       
          --piSHL_This_MmioEchoCtrl_V => piSHL_Rol_Mmio_UdpEchoCtrl,
          --[TODO] piSHL_This_MmioPostPktEn  => piSHL_Rol_Mmio_UdpPostPktEn,
          --[TODO] piSHL_This_MmioCaptPktEn  => piSHL_Rol_Mmio_UdpCaptPktEn,
          
          piSMC_ROL_rank_V         => piSMC_ROLE_rank,
          piSMC_ROL_rank_V_ap_vld  => '1',
          piSMC_ROL_size_V         => piSMC_ROLE_size,
          piSMC_ROL_size_V_ap_vld  => '1',
          --------------------------------------------------------
          -- From SHELL / Udp Data Interfaces
          --------------------------------------------------------
          siSHL_This_Data_tdata     => piSHL_Rol_Nts0_Udp_Axis_tdata,
          siSHL_This_Data_tkeep     => piSHL_Rol_Nts0_Udp_Axis_tkeep,
          siSHL_This_Data_tlast     => piSHL_Rol_Nts0_Udp_Axis_tlast,
          siSHL_This_Data_tvalid    => piSHL_Rol_Nts0_Udp_Axis_tvalid,
          siSHL_This_Data_tready    => poROL_Shl_Nts0_Udp_Axis_tready,
          --------------------------------------------------------
          -- To SHELL / Udp Data Interfaces
          --------------------------------------------------------
          soTHIS_Shl_Data_tdata     => poROL_Shl_Nts0_Udp_Axis_tdata,
          soTHIS_Shl_Data_tkeep     => poROL_Shl_Nts0_Udp_Axis_tkeep,
          soTHIS_Shl_Data_tlast     => poROL_Shl_Nts0_Udp_Axis_tlast,
          soTHIS_Shl_Data_tvalid    => poROL_Shl_Nts0_Udp_Axis_tvalid,
          soTHIS_Shl_Data_tready    => piSHL_Rol_Nts0_Udp_Axis_tready, 

          siNrc_meta_TDATA          =>  piNRC_Role_Meta_TDATA    ,
          siNrc_meta_TVALID         =>  piNRC_Role_Meta_TVALID   ,
          siNrc_meta_TREADY         =>  piNRC_Role_Meta_TREADY   ,
          siNrc_meta_TKEEP          =>  piNRC_Role_Meta_TKEEP    ,
          siNrc_meta_TLAST          =>  sMetaInTlastAsVector,
          
          soNrc_meta_TDATA          =>  poROLE_Nrc_Meta_TDATA  ,
          soNrc_meta_TVALID         =>  poROLE_Nrc_Meta_TVALID ,
          soNrc_meta_TREADY         =>  poROLE_Nrc_Meta_TREADY ,
          soNrc_meta_TKEEP          =>  poROLE_Nrc_Meta_TKEEP  ,
          soNrc_meta_TLAST          =>  sMetaOutTlastAsVector,
                                     
          poROL_NRC_Udp_Rx_ports_V        => poROL_Nrc_Udp_Rx_ports
          --poROL_NRC_Udp_Rx_ports_V_ap_vld => '1'
        );
    
  end generate;

--  gUdpAppFlash : if cUSE_DEPRECATED_DIRECTIVES=false generate
--    begin
--      --==========================================================================
--      --==  INST: UDP-APPLICATION_FLASH for FMKU60
--      --==   This version of the 'udp_app_flash' has the following interfaces:
--      --==    - one bidirectionnal UDP data stream and one streaming MemoryPort. 
--      --==========================================================================
--      UAF : UdpApplicationFlashFail
--        port map (
--        
--          ------------------------------------------------------
--          -- From SHELL / Clock and Reset
--          ------------------------------------------------------
--          ap_clk                    => piSHL_156_25Clk,
--          ap_rst_n                  => (not piSHL_156_25Rst),
--          
--          ------------------------------------------------------
--          -- BLock-Level I/O Protocol
--          ------------------------------------------------------
--          --ap_start                  => (not piSHL_156_25Rst),
--          --ap_ready                  => open,
--          --ap_done                   => open,
--          --ap_idle                   => open,
--          
--          --------------------------------------------------------
--          -- From SHELL / Mmio Interfaces
--          --------------------------------------------------------       
--          piSHL_This_MmioEchoCtrl_V => piSHL_Rol_Mmio_UdpEchoCtrl,
--          --[TODO] piSHL_This_MmioPostPktEn  => piSHL_Rol_Mmio_UdpPostPktEn,
--          --[TODO] piSHL_This_MmioCaptPktEn  => piSHL_Rol_Mmio_UdpCaptPktEn,
--          
--          --------------------------------------------------------
--          -- From SHELL / Udp Data Interfaces
--          --------------------------------------------------------
--          siSHL_This_Data_tdata     => piSHL_Rol_Nts0_Udp_Axis_tdata,
--          siSHL_This_Data_tkeep     => piSHL_Rol_Nts0_Udp_Axis_tkeep,
--          siSHL_This_Data_tlast     => fVectorize(piSHL_Rol_Nts0_Udp_Axis_tlast),
--          siSHL_This_Data_tvalid    => piSHL_Rol_Nts0_Udp_Axis_tvalid,
--          siSHL_This_Data_tready    => poROL_Shl_Nts0_Udp_Axis_tready,
--          --------------------------------------------------------
--          -- To SHELL / Udp Data Interfaces
--          --------------------------------------------------------
--          soTHIS_Shl_Data_tdata     => poROL_Shl_Nts0_Udp_Axis_tdata,
--          soTHIS_Shl_Data_tkeep     => poROL_Shl_Nts0_Udp_Axis_tkeep,
--          fScalarize(soTHIS_Shl_Data_tlast) => poROL_Shl_Nts0_Udp_Axis_tlast,
--          soTHIS_Shl_Data_tvalid    => poROL_Shl_Nts0_Udp_Axis_tvalid,
--          soTHIS_Shl_Data_tready    => piSHL_Rol_Nts0_Udp_Axis_tready
--          
--        );
--
--  end generate;

  
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

  gTcpAppFlashDepre : if cUSE_DEPRECATED_DIRECTIVES generate
    
    begin
      --==========================================================================
      --==  INST: UDP-APPLICATION_FLASH for FMKU60
      --==   This version of the 'tcp_app_flash' has the following interfaces:
      --==    - one bidirectionnal TCP data stream and one streaming MemoryPort. 
      --==========================================================================
      TAF : TcpApplicationFlash
        port map (
        
          ------------------------------------------------------
          -- From SHELL / Clock and Reset
          ------------------------------------------------------
          aclk                      => piSHL_156_25Clk,
          aresetn                   => (not piSHL_156_25Rst),
          
           --------------------------------------------------------
           -- From SHELL / Mmio Interfaces
           --------------------------------------------------------       
          piSHL_This_MmioEchoCtrl_V => piSHL_Rol_Mmio_TcpEchoCtrl,
          --[TODO] piSHL_This_MmioPostPktEn  => piSHL_Rol_Mmio_TcpPostPktEn,
          --[TODO] piSHL_This_MmioCaptPktEn  => piSHL_Rol_Mmio_TcpCaptPktEn,
          
          --------------------------------------------------------
          -- From SHELL / Tcp Data Interfaces
          --------------------------------------------------------
          siSHL_This_Data_tdata     => piSHL_Rol_Nts0_Tcp_Axis_tdata,
          siSHL_This_Data_tkeep     => piSHL_Rol_Nts0_Tcp_Axis_tkeep,
          siSHL_This_Data_tlast     => piSHL_Rol_Nts0_Tcp_Axis_tlast,
          siSHL_This_Data_tvalid    => piSHL_Rol_Nts0_Tcp_Axis_tvalid,
          siSHL_This_Data_tready    => poROL_Shl_Nts0_Tcp_Axis_tready,
          --------------------------------------------------------
          -- To SHELL / Tcp Data Interfaces
          --------------------------------------------------------
          soTHIS_Shl_Data_tdata     => poROL_Shl_Nts0_Tcp_Axis_tdata,
          soTHIS_Shl_Data_tkeep     => poROL_Shl_Nts0_Tcp_Axis_tkeep,
          soTHIS_Shl_Data_tlast     => poROL_Shl_Nts0_Tcp_Axis_tlast,
          soTHIS_Shl_Data_tvalid    => poROL_Shl_Nts0_Tcp_Axis_tvalid,
          soTHIS_Shl_Data_tready    => piSHL_Rol_Nts0_Tcp_Axis_tready
        );
    
  end generate;

  gTcpAppFlash : if cUSE_DEPRECATED_DIRECTIVES=false generate
    begin
      --==========================================================================
      --==  INST: TCP-APPLICATION_FLASH for FMKU60
      --==   This version of the 'tcp_app_flash' has the following interfaces:
      --==    - one bidirectionnal TCP data stream and one streaming MemoryPort. 
      --==========================================================================
      TAF : TcpApplicationFlashFail
        port map (
        
          ------------------------------------------------------
          -- From SHELL / Clock and Reset
          ------------------------------------------------------
          ap_clk                    => piSHL_156_25Clk,
          ap_rst_n                  => (not piSHL_156_25Rst),
          
          ------------------------------------------------------
          -- BLock-Level I/O Protocol
          ------------------------------------------------------
          --ap_start                  => (not piSHL_156_25Rst),
          --ap_ready                  => open,
          --ap_done                   => open,
          --ap_idle                   => open,
          
          --------------------------------------------------------
          -- From SHELL / Mmio Interfaces
          --------------------------------------------------------       
          piSHL_This_MmioEchoCtrl_V => piSHL_Rol_Mmio_TcpEchoCtrl,
          --[TODO] piSHL_This_MmioPostPktEn  => piSHL_Rol_Mmio_TcpPostPktEn,
          --[TODO] piSHL_This_MmioCaptPktEn  => piSHL_Rol_Mmio_TcpCaptPktEn,
          
          --------------------------------------------------------
          -- From SHELL / Tcp Data Interfaces
          --------------------------------------------------------
          siSHL_This_Data_tdata     => piSHL_Rol_Nts0_Tcp_Axis_tdata,
          siSHL_This_Data_tkeep     => piSHL_Rol_Nts0_Tcp_Axis_tkeep,
          siSHL_This_Data_tlast     => fVectorize(piSHL_Rol_Nts0_Tcp_Axis_tlast),
          siSHL_This_Data_tvalid    => piSHL_Rol_Nts0_Tcp_Axis_tvalid,
          siSHL_This_Data_tready    => poROL_Shl_Nts0_Tcp_Axis_tready,
          --------------------------------------------------------
          -- To SHELL / Tcp Data Interfaces
          --------------------------------------------------------
          soTHIS_Shl_Data_tdata     => poROL_Shl_Nts0_Tcp_Axis_tdata,
          soTHIS_Shl_Data_tkeep     => poROL_Shl_Nts0_Tcp_Axis_tkeep,
          fScalarize(soTHIS_Shl_Data_tlast) => poROL_Shl_Nts0_Tcp_Axis_tlast,
          soTHIS_Shl_Data_tvalid    => poROL_Shl_Nts0_Tcp_Axis_tvalid,
          soTHIS_Shl_Data_tready    => piSHL_Rol_Nts0_Tcp_Axis_tready
          
        );

  end generate;
  

  
  sReadTlastAsVector(0) <= piSHL_Rol_Mem_Mp0_Axis_Read_tlast;
  poROL_Shl_Mem_Mp0_Axis_Write_tlast <= sWriteTlastAsVector(0);
  --sResetAsVector(0) <= piSHL_156_25Rst;
  --sResetAsVector(0) <= piSHL_ROL_EMIF_2B_Reg(0);
  sResetAsVector(0) <= piSHL_156_25Rst_delayed;

  MEM_TEST: MemTestFlash 
    port map(
           ap_clk                     => piSHL_156_25Clk,
           ap_rst_n                   => (not piSHL_156_25Rst),
           --ap_rst_n                   => '1',
           ap_start                   => '1',
           piSysReset_V               => sResetAsVector,
           piSysReset_V_ap_vld        => '1',
           piMMIO_diag_ctrl_V         => piDIAG_CTRL,
           piMMIO_diag_ctrl_V_ap_vld  => '1',
           poMMIO_diag_stat_V         => poDIAG_STAT,
           --poMMIO_diag_stat_V_ap_vld  => ,
           --poDebug_V                  => poROL_SHL_EMIF_2B_Reg, --TODO?
           --poDebug_V_ap_vld           => ,
           soMemRdCmdP0_TDATA         => poROL_Shl_Mem_Mp0_Axis_RdCmd_tdata ,
           soMemRdCmdP0_TVALID        => poROL_Shl_Mem_Mp0_Axis_RdCmd_tvalid,
           soMemRdCmdP0_TREADY        => piSHL_Rol_Mem_Mp0_Axis_RdCmd_tready,
           siMemRdStsP0_TDATA         => piSHL_Rol_Mem_Mp0_Axis_RdSts_tdata ,
           siMemRdStsP0_TVALID        => piSHL_Rol_Mem_Mp0_Axis_RdSts_tvalid,
           siMemRdStsP0_TREADY        => poROL_SHL_Mem_Mp0_Axis_RdSts_tready,
           siMemReadP0_TDATA          => piSHL_Rol_Mem_Mp0_Axis_Read_tdata ,
           siMemReadP0_TVALID         => piSHL_Rol_Mem_Mp0_Axis_Read_tvalid,
           siMemReadP0_TREADY         => poROL_SHL_Mem_Mp0_Axis_Read_tready,
           siMemReadP0_TKEEP          => piSHL_Rol_Mem_Mp0_Axis_Read_tkeep ,
           siMemReadP0_TLAST          => sReadTlastAsVector,
           soMemWrCmdP0_TDATA         => poROL_Shl_Mem_Mp0_Axis_WrCmd_tdata ,
           soMemWrCmdP0_TVALID        => poROL_Shl_Mem_Mp0_Axis_WrCmd_tvalid,
           soMemWrCmdP0_TREADY        => piSHL_Rol_Mem_Mp0_Axis_WrCmd_tready,
           siMemWrStsP0_TDATA         => piSHL_Rol_Mem_Mp0_Axis_WrSts_tdata ,
           siMemWrStsP0_TVALID        => piSHL_Rol_Mem_Mp0_Axis_WrSts_tvalid,
           siMemWrStsP0_TREADY        => poROL_SHL_Mem_Mp0_Axis_WrSts_tready,
           soMemWriteP0_TDATA         => poROL_Shl_Mem_Mp0_Axis_Write_tdata ,
           soMemWriteP0_TVALID        => poROL_Shl_Mem_Mp0_Axis_Write_tvalid,
           soMemWriteP0_TREADY        => piSHL_Rol_Mem_Mp0_Axis_Write_tready,
           soMemWriteP0_TKEEP         => poROL_Shl_Mem_Mp0_Axis_Write_tkeep ,
           soMemWriteP0_TLAST         => sWriteTlastAsVector
         );
  



end architecture Flash;
  

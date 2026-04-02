// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Sun Mar 22 20:10:13 2026
// Host        : soyorin running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ cbuf_sim_netlist.v
// Design      : cbuf
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu7ev-ffvc1156-2-i
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "cbuf,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clka,
    ena,
    wea,
    addra,
    dina,
    clkb,
    enb,
    addrb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [9:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [63:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [9:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [63:0]doutb;

  wire [9:0]addra;
  wire [9:0]addrb;
  wire clka;
  wire clkb;
  wire [63:0]dina;
  wire [63:0]doutb;
  wire ena;
  wire enb;
  wire [0:0]wea;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [63:0]NLW_U0_douta_UNCONNECTED;
  wire [9:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [9:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "10" *) 
  (* C_ADDRB_WIDTH = "10" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "2" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     7.798177 mW" *) 
  (* C_FAMILY = "zynquplus" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "1" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "cbuf.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "1024" *) 
  (* C_READ_DEPTH_B = "1024" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "64" *) 
  (* C_READ_WIDTH_B = "64" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "1024" *) 
  (* C_WRITE_DEPTH_B = "1024" *) 
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "64" *) 
  (* C_WRITE_WIDTH_B = "64" *) 
  (* C_XDEVICEFAMILY = "zynquplus" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_8 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(NLW_U0_douta_UNCONNECTED[63:0]),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[9:0]),
        .regcea(1'b1),
        .regceb(1'b1),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[9:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[63:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2024.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
RSqbsRZSIb+QlYJMfFv1T7uHQ7PiCEXQkl687MHGm2LgPB15GIYcPmqKUSXgtkLsIFes91PTAyyB
9H9cyY4ZUxedcRg/9ZOB5pm3zPqAbcvGPmg1ivMhr/MlS19t5lYKM2tQo+0Yd+arJXlVZu2BMnvn
+I3G9t9tJuWUIWKjI+I=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
VRSQ05ZaB6bIhFIQ823mTvlJaG9+5iW5C3+KxGjq0sq9ziCshKOLpOGPDMmOWDqA4uBaxC5IKISr
w8+A8mqbYjXo5m1g8sGjNaETS0HKJsK+l5Y++tN4IEUs+DwxgrPR/+LWtChuOzVkfC7BG3LVUEMj
zM3GAyGcXGJ3sdBItZAfsevyiy7kr4Fw+nk2hWytGteu1NZk3VzPE7KQHLkOlHBPXf6P0j8LpKcr
2oNDgQ/WaEmg6OOvFeJuaWDaee8Sn6wKP/caMyoGdSeczsPtRrJeoSRlbNHlxhCv7zg+Cn2AgwrR
PTqGsMrkhv9U0sq+waS0CmwChsk4WB7RspGYUg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
tNziOjCznlvIl4dadmB9r23Duf+HQHWOuHmupEU3PJxrazHVtZdNKspG9sRXhF9mjbpnSiKYCdFK
Jr9W/dxUid36faFIPKQazVTuOiE0hkzVQAGpYxXjT/ITB/9EFBvgvP5L3EAhHv32x6MA1vkFSI7x
HrZ09YNFEF6T7DPTZE4=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
QCYfxgkUHlX1cre1q9aS3sVDIOX36YBK4ZwJXAVUwA6f1OQ77XibjpWJHt5FK9F0PcYp/j21pqzO
BRdkDcFLVAjxER4J5t5iMVhoeMk+3fpiKfYrm4WFl1ygsJsfFJP0jqO1OkjC8iFBtm3n6b7CTl1o
cjBbcBp8UgW6E8rf5inXA0dRqybnyxKJSnMFYLinvpVU6QEc4OKO7mi/i/s9p/efiP+CdQf0yDRU
Fw7o7x0D7tjBv943g5L+4wGZ2JYU+ISqn4Ajxy/bWTTJDe6T/15evhngS61MC8Xjamzc4YLZBP8o
ShfSLoeZeO+Hk5n3xzJRghM0DQ6Sj7NqXFY68w==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Uy8FDDy3dZQGAnMQV0HBesEs+/oZdaq35Kj1PGhy9J/+EBZm0nhhQgYtku8tWABW2jKAC1GtNTvo
uReQyr1hteMxTbD5OIuqv86eb1hXZVENlZ7ichG8auUjkeHAkaSYNbHOuDLIhSqHEL67XbcZ9zPG
1JOY3+VONSww0KYPcQbGSo/2DaC5C0Y+mZODRfJ4+b0WXjce6UaJetilBc3VtqqmodIM2d3HDawF
R0xVJfHj86rXmUkY+SNUw60zsV6raCY6G3k/rXpei1d6zn8tCThkKG5fwiWY8zA7kRdTFIlVKP9h
fb6kfzRBRT/BgVQ8d4RgEcEVV8m3u/Mf4KIlTw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2023_11", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Pk1GeRlkUK9lt6DVXYVdtOABlzDEWQDcBsP/p+Wo5HaglDLG5b8gk08xTP3IcJ1RKcfuARPMGO2s
/VqFbnVADV90T1rhjIuWMcBnzYQK/ALUvwv11Uju9Gn0fvPIz52l3QBnpjHI1nlsFB7WeqkzVfHZ
tg9gO9bPHjHLjVd9BzH6McrEWY5RkZ0UBy0Fmh/SownJX1b0YGE7LdwKydEMEpyvb28bwTOwfEv/
4RtsfYtEvTjo6e1ZBm66D9IQmKUu32wzTfn5bFZHdyjZg6+HcTzvHMtQX2+AggXfP6FsO2/83qkb
0bfj226fnLhr32dJxtsaJS5OR63GYtzDJ05ITA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
LCfWqKmUoUSVOTKNAl5p8n1hfz7SMU2kDOUMBjsDncgSFqiu2zUy1I6GSDrVnF/2umJG5/mWcpvi
rQaFJOlrJ8DNctSuavdlopRAwTMsVi6dAlNGrAawSiDIxtI3tN3MDVdMiH5H+pJMqMt59yXneyCf
2RRSRz2sUQK/aj0lXlqKjVJzVbk8HaBQ8akBJF4iWSMK4foIzJ6iO1EupYovuW6uEiO7jQRWezlW
pbbDenOHHWbfinuX5cbkjpTKHGsEKct65q+ZXJp60m3sconSK3Y2eLQxusuJ1FHDJ4GGKO8mEzCv
3cfGdXX3pVL81OfGO/JD1aMs9H98CO5ssbHqlw==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
A4S1e3DHcTeWzaDVuWDRb3Yf1BjiEsR1RtAeL0BJ7J/oPWMNj96MeGsUiHtZoiYqteTZxqax2cyZ
PV0cMLoBK4Ya8CyM+BTnkFA2ablsGt5Es4TgG/nFS9VEhmeKxu8boAsqW5697aiqOATJf/LucQh5
GOnPXHAuPrDj0A/fu8N2QduqGyysWUSc1KsoJ0/0noJYvLJ2yOhFi4uIUYQfG5LOuOrca5P43pqA
iwUKW/RrFXal2acJdFeXIKffZpKanSV97urdzKyBvf9EPV/M8g9uPFJJ1z6aS+FbknhVPs0pt6eD
+J/qib4gVp/HGnRo4YlxauUMv6Yv9wxiaObY6ttDfYf5p3uzWZMlf3i7YOzZwcd4aS/6+vkD28LG
L9piBIpLx2dvQy74RdvCVdvaP1LC6RMju9RfuXJhuX4ZAmDxRi0zQyRda838ikzwYeOCSKLIvRPb
nuJ8Zx2ot8EFqSeGaaRFaEMU6Zf5SptCUuVMHvSkinBewcwrLB5uiJTJ

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
gj+uMxV+tK4Di7pgSOE82FOBeWmUB1A7OKFOSMUW3qrmQ4/YhryfHMlWPxfAq8avQL7tnBTnRFEg
czbErdIcNzYjrM7Qq00QC/mTqmeQX4/apbqGvN+rwK4RR5oj22wfTib/UQNEQX6fbpi6PtmAeUR9
eShsfq+YWcf7z2Zw4Q+o4+E6m4/3CzU68vglNpzNsJ8S9/8XpdIrvAA/WRAX6OEOC4wlNIKDZsq/
+zMbFgSzN1rP844I/CDmxYM0NIzBWWhYBkPfJyQyigmUoXb84lDip0/Dmnq4EHvu7D/tZNnDl5st
JpftRfEpT6S8e/5MBeKUuhbfg6etHo/oFZvPKQ==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
aWTy3xv6SqKsldtLS2gY4KrTS8U+KtFNRHS314f6EYZy1MHE9t7oICJ8eNB8up8A+odoE23N3fJb
1alhaadeRWU2GjlIiK1LjZ5PQw+jb1u1GWtRiY+TcTlD75XUlqwykVBrCDfm565DmgZjZle9T3/t
WEfLo+m/8GfBe8trVnoftsk/XI00BMFXRzw8doPGDhNECS1NUrLebryb9iO5Hf4A/40dtslTARsR
nicN0KoIIyiQ+QzliqyXU/8VjS45inON8R0Kv9Qx46EXUp7bds5uQ7QycRhpLG0IPnMIweudU67w
eQmpHJzvZKBCZks/R0OafZx44H6Jib2+QazBCw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
UGdPiChIPj1lSozqzCQx17Bi+8FWSuMUMzXUkDLH5zcP1t8tZLzh4CU4WAR8lmJxn8gH763fLp5c
RYU6zA0yxHzl2ksc5YRU1XEfQQT9ha8fQnz+18wVKcsa5UIOfMbGDwnS9yfX59ntG8CB0uF8bJKE
y1CS6U/1Stfs1w2mF94iDxI2n2GJlb1UPtWpmxMBI88hY0GktTPXP2Y7JKl8zRl/Lq0wIF8pHwXk
B4nOgKm6hfzPj0xZ6E/TuER/JE3fy8RSm24IlL/CUgpReEslEOYjQ4EKKZRG9/fxg26utQWW9p+G
fWVU53qrFGzBhKQ96Paj1ROkv6hDHyUb6n7uSw==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 52800)
`pragma protect data_block
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
R+crufYqTOzVpKCo21abLUcs
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif

// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Wed Mar 25 19:12:56 2026
// Host        : soyorin running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ cbuf_sim_netlist.v
// Design      : cbuf
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z100ffg900-2
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     10.50945 mW" *) 
  (* C_FAMILY = "zynq" *) 
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
  (* C_XDEVICEFAMILY = "zynq" *) 
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 49296)
`pragma protect data_block
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
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

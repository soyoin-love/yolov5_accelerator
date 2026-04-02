// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Wed Mar 25 19:12:55 2026
// Host        : soyorin running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ bbuf_sim_netlist.v
// Design      : bbuf
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z100ffg900-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bbuf,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
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
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [8:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [63:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [8:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [63:0]doutb;

  wire [8:0]addra;
  wire [8:0]addrb;
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
  wire [8:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [8:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "9" *) 
  (* C_ADDRB_WIDTH = "9" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     6.966099 mW" *) 
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
  (* C_INIT_FILE = "bbuf.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "512" *) 
  (* C_READ_DEPTH_B = "512" *) 
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
  (* C_WRITE_DEPTH_A = "512" *) 
  (* C_WRITE_DEPTH_B = "512" *) 
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
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[8:0]),
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
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[8:0]),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 31280)
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

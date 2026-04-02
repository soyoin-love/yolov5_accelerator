// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Sun Mar 22 18:22:13 2026
// Host        : soyorin running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ bbuf_sim_netlist.v
// Design      : bbuf
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu7ev-ffvc1156-2-i
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.327111 mW" *) 
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 33072)
`pragma protect data_block
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
DqCuNnfMKNgiJlP8
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

// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Wed Mar 25 19:12:56 2026
// Host        : soyorin running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim e:/IEEE2027/yolov5_accelerator/ip/bbuf/bbuf_sim_netlist.v
// Design      : bbuf
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z100ffg900-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bbuf,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module bbuf
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
  bbuf_blk_mem_gen_v8_4_8 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 31168)
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

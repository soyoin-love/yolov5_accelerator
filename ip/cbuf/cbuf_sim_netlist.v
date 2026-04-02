// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Wed Mar 25 19:12:57 2026
// Host        : soyorin running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim e:/IEEE2027/yolov5_accelerator/ip/cbuf/cbuf_sim_netlist.v
// Design      : cbuf
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z100ffg900-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "cbuf,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module cbuf
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
  cbuf_blk_mem_gen_v8_4_8 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 49024)
`pragma protect data_block
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
E5UfgQ==
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

// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Wed Apr  8 22:03:59 2026
// Host        : soyorin running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim e:/IEEE2027/yolov5_accelerator/ip/rbuf/rbuf_sim_netlist.v
// Design      : rbuf
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z100ffg900-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "rbuf,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module rbuf
   (clka,
    ena,
    wea,
    addra,
    dina,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [8:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [63:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [63:0]douta;

  wire [8:0]addra;
  wire clka;
  wire [63:0]dina;
  wire [63:0]douta;
  wire ena;
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
  wire [63:0]NLW_U0_doutb_UNCONNECTED;
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     6.700549 mW" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "1" *) 
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
  (* C_INIT_FILE = "rbuf.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "0" *) 
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
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "64" *) 
  (* C_WRITE_WIDTH_B = "64" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  rbuf_blk_mem_gen_v8_4_8 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[63:0]),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(1'b0),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 29968)
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

// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Wed Mar 25 19:12:55 2026
// Host        : soyorin running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top rbuf -prefix
//               rbuf_ bbuf_sim_netlist.v
// Design      : bbuf
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z100ffg900-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bbuf,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module rbuf
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
  rbuf_blk_mem_gen_v8_4_8 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 30880)
`pragma protect data_block
OK6tAsL2TPALUkw0xFrkL1a6fI254fJ8wXZmi42P7ihPVDNV0h+RJqVs2DnyaVX8Znr6JQRIjYQz
oxCmQc2izftEiezEGXRUI/YSYiyP+0YHxF7MaktSYOUwMMP/jmjIXVfxuihYOgd3UjNiFev2qpeR
aAmGaEMNSkkcP+5S/l7rocwGst2XPKl2lSAiMTR0OCBFDd4V+BzehQLfC7Z0YoExzi0pZsAphYgT
p9niUPFiQj1xy+u2fWMP8OhVLnAVC1G/UtHgw1LvgKmUWOvSMFPBbjIRG7rTUVhnAuJ3zisO2k7n
aod+eATmJVtHZpLyp+pqLCDT1tO9UPLaBAOxBsKIOWenPlp/XwfbzZWyxA3mGH3K327WIUFSkiTp
hL3TRYp4otYCar1aZHM2aPrb4V3J1kTKJUfa4C4qwOTkoSdOS5vSmiXbacjlx33UZFiybdm2CONy
hpgOY6IUscQR7VKuZQ9q1rYXPnaKsX/EvUAEZNpFa0U/FoRhilP7hOTzjcMZ8XZtt0/78CEEiqLh
UXBEAdW5jhZ9jxGG20BSqKVEzuFrIfju2jC7WSJ/RfuVkPB5pXOUwxIs9IH8oCZj/CTfKUJcubMo
Fu9G//i2LtffhGHsmPE9UnKfYwQ4yn3/nkR8cZhukz85dBqFf3/8HFwxifNhTVdi8Na4jf87O3cH
IUpdG2D6s2ig8lXXVzQUO0mfCOoIHGRe8nRayyBHoxhzS6xNWN1O1Bu5zck8xMfQ5zigPlTLbxAi
qeEIdEuC15+psscipvJzWeZcoLbcRLf59S1uR5p+DDKEeS+GVhjG97/wggKYSbAPV+bxHKCe6T00
ydMdmf+ue9l97h+ofK6QU4KUpfZJsq74AeLl98IF3MvDyhfVDXlQ2AluRULn8egm4YuooUk2sr0g
aoFc5S0fsD/f/iaKAZ0MR6la8MWs4k08xdVumMfr2mPFiJh+/280ke5AiqcFdbx6W6Fjc/agJsM4
TrKSY8aGmGr9Bb8ToRzFGuzYnGloIl9PL4GwsYYz6HJhbKy0JZ/wdOtp8/6u8iZKOr7Bn3e48z3u
f+1zd5plqaeA9rWUtp4yhDHTum4FA5wBBXZK2U3ehQmXHmpAqH/BRuu1gdO6u04tiHIBLZxtjeSk
usM4mrB2TOBr7ELhQKM+UY7WLFxKUWYWptBUl7GT1U5+YSkr0PRhLzXf430u+B7fJks6VskctFoI
gcrPcOg3qShWU3+Slv3ZZiPXW/P1+/9ZvoTchuLTKuykyI7Un3WkE5VF0XO+bZ4hlNro+5GhKp9D
kyvh6Gnco7TiEgU7Zi0TjkOqc9FGm3MBJ8jKOtmViHHCoZTAYEH24/2Jt3j8E/uqOugBgPZ/9KBP
OOy/1CiHCTalRwPuBB5rG0yEQ2YTT8KukXpj3TaFYv4Q83isalQuyBkJN7td1wx3tia57nlh63j0
ymbm++wUHVK/KO0W9VZPlhQ8Xa57tI4gxl8WFrMtpFEj1mLtrzJkWiwCdbiMoz/zz4htAS+1+6GJ
d0GeeboR0m/BIPaOmXzu6l5zY2nR4muJrA/G3RC3ZSeFs84LBMprUNHNuEWUNMQGNxy7yv3kAaV2
ZqivGFb1mW15VRNY7LVhxrO/xzcoTxzWO7tCcFZNniGo4ZoHMvlL9szG59ozjH13QSqeMTNJVAbB
I4P5F4GgPkzXGCCOGaTZQRcYjt+UCcxi/E3X0aFAGrbmcVEf0JkU4asn8JWg+Tuc7L2a5C9PmoUx
d50w7vymuMDQqlERLuCp3OqxmIjhVkbk0jFTw0CJ05CVEQnlGzAOWq70KAMn3CHVtoR1o/581e9i
8vk12G3sfSI6ytyK9F2Chkq4cWQwbdoazvaypfzfimqz7cXG32HEnlxqECaAc4/daxNaJK4OXAC6
KY8gaLAmeF0fd0wD1tkaHUNQ5o6H/nFZnZiQlw8xTMvhOw1jjnbciglKKSAAxU/FvZNAQrpOQc6O
016BGIhN/611KPap3QQOr9qbonoDEOueCTkGnebdPXsk6zHwHdBLX8pxGOfX0UpDQkPI9TjD3DyI
k7R05Z4aWmlWh6d9MxytKDBxo7VIt6zuRRoc/3xEX2OJ1wugxG95St+TB31awmZJma0c8C6sbW7a
WE5rc8SBV3PseC1ah7Uooumz+WuVoO3pNXOG9FQTr1hqykyfADEf7PbNzCXNLS1jkU36Xwvn4Fj1
HrHTMCK5ACO88xxlmqPygp0pxii+Z8PPJpLWLyF1PjqVe9j5B7tuStvLXNIddVQb4CPplvewvlax
lqanvkNhCZCIQ6q6os58J3LRrjitzST0Jt8IxfCchdvuFCYffoKGK9mOlywZJmHbqzdVKFJS4UVQ
1cqc9ktCp2QXBfWKTcFzk6KvH3fu/yQeRQFjvv/EnjRX6LiFE+N11EeIegTK1wgoH2scWy2xMHgo
p3q/oarmcCbJ3qbSv8yhZQE8zgGucMstPGPfid1/dI9vTp3fsR9qXUtmLpd1Ls0iI58zNGxJ1Oro
9CHOEtsv0hMHdVrM6dXB/8GyUN/2pC97zQqebGgxluZyA83F65+HD6PaYtRsHcx7x5mQXGs+BomH
FaDtyBtUuqk8JjkQaSAoAG9yMJXDru8hR4O39pe1hHFPJfCMVhvTeHMwBxrjfnn9VMiUqxXxUOnB
xhUF1oUEdOAdKDKRQzzwsskwYvOnhBK373I8lv5b0U/Q4BJ2e9x2MpJ6ny/7o7rCDAyvoVZdzxZv
dj9qztptX8VBxGXbQNzfmNjtPQ1P0VVDbJl1lNHsx/Ete0dZavKcc1Go/mwTVMfVa30YabNLqbMO
zDsbOmEmT3uLv0hYyemi63DkHkRNfGa829IJv8P7ROLXis606b42aq+sFZmlCU40W5txKmCVIcM6
A3kY07q/3X8/ak/HOaHzW0kbBSP9N9dcw4Jbx9Ss/PbfJ8bCA6EcNUXvwIghoJayzLACJ/DrwlHw
B0sj8ldnIeaeYvT9zFhSDyD87IAGvpjYzSrSPTNIBQS3W0yDWwWmsSrO3DBMv+iMLbTc9TNjjgzu
Lhe4n4RzK9ULCLMnZ62igNlYnOLn/WHOhOxca0MwlQSHDrB0TJC/Xapm3PUvz3dfVBb46ML7CeNT
W3/piWGaYK6SvD/XHjJ5ybXLp7m02ZcffT3Kz7y3/25g9MujMeVhcWMOwW6oxMU63EwqYyagZX95
yTaKOlybwNnyQLbu5Qjlxrz5/M8mVMbP2w5lXTQ1yoDgoq7cFLg2X1E8aRD71tdd9lKbEUjdT3TJ
WTBl7GbzuRdGERsasywymx7OEJr5f2iHbIbVXwjdlfKBRDWfd0SFPR8/Zh5XGdfCefYDsEcKx0CT
KCA0bnv7Afx8aVJD56lEdxpmccjHz+QQqrifhR5QUX1DjYMiZMR1qRPv+R0kBdrZ6JTWAwC07ggT
8D4ELZuAHJR+WO7rwUc5fONtxYQAWQPYIWrO1/RIbZ4F4cDLqtHtL7AitsvxwblHMfuDroWkvAtK
wTQ6d+2KN4NMPbcBrjaZCiJuH76zt+XVFcpm2dy46NP0gS9Uoe4LXk2Ctkdf4P2jsHRmp0bD5K6s
19/d1uYX0icq8KIHzs0T1lU306CDETIM8HuDhWBGKOuY1ugiHiHxxRiKdjAtmTPesfuwMfwXu//q
8DvhGYB7vr4h3KuANKwqZt5KkiDNdyMRbqjVunNOIByBCoqolOff8mkpDUIY9BkmjcP4TI2+7ryI
VW8VpubvmvGMJypQMOqGceL6hXiX12e7AvfAEVd4enfjo6RARLrkAXAFLhnQPPJeBXg7sP1631C/
gY0rOlIxRIiYk6ZfW13UnurauppVv++47UzQi3d7Df6zCO6M9W0T4LZQaLCzRZyDQiKV3OHlwv0z
b9t2Z02J527nYRvtz0sps4lSpLLocmHhQKsHdrNXQ4V9Qnx9w5T1SPGxzXUZaPWYe7ju4Qcn2xhP
YEEKeCaNcd4F6TgL5t7Q9e93yQt/f0jqfHL0ksE+ychAz++OQ1+sShVpFfiOhyBN73d7+Dz4s6qB
VUNLAKmFezm/ILVW4lIIbAR7wYC3+VRjIge0BF5quiEDKz+7szSoHxbdkPSriaevKy82jD4uMPps
oUwzSkX8Ul8ElhJXHRuCIU7o2inmDuSPKJjjOPE2YfAmotKP260dJWp/FEQ00zLfLIlIwCpi63wH
d7Swd7sxBh446frVuS4o+tnMMRLVpDMSt/IjkN3IMf8QF4uTRBT/V54uGd9MCNHYr5K4K8geTB4c
157csqD7QRbX8GOycSc7YhybEaw8s0R7NZ1S04IX1jP8w3eRWEJl2kEEi1EgEdBcNloI4qRgL9N0
YuyEo5iWgwRVmG/kf2XSBtuNNWqURjjNPtQTmrU9teNZpzLvbTr/1dHhHpJDEmntIjuXgD4yr/sE
iMvKhwp0/g/50rMyVodGOnKR1xICLXubTdvekampgW0OSwotpymowwzXPBzOvWmW1RktxtYMmcy/
3lig8LQG5z9mmEeosYGbgF5h1Rw5EI52uw+SJBssAECB8eQ/fkDxc5pXDahRAUiXP6LvH3x4BtF5
yQfjh/n73lWpSXRV33mCby05uiP4QNkln/glWB/mTKr3duUWQXpHKkU+S13/N0qN1TNTBzgogCzM
E3YIL1Fo1FN890yDxbbG5vsCh/uZgK3V4g1hFXcEYzBS/X15PVm7HWEcTEYTSWAGk8ZBexiw0FIW
dAeSd1h6sRnjAlRLACpukdNUmZQfXEHmh2Yec5Kg9ZIXyh0hTzXPTRqEky75J3DHQUR8erZv/NEs
PKcHvWGPwot1hurSaKZlkJUa8BagwwaD2PMFXC2xek+2HcgsvfrC5o4kL8KIxKRvX2TihoKJalMg
nED49W0Lr3ZkTAMaK8mcMK0E4/IbqEfIl//mvwTmJTvVfX8VZIsxcyrLPm/97vLQnpZ/hRX1NgpV
EZ7nc8iyxatMJLHaK+OMUyVCLszNUpKHD3+5FGbs8xTIITe6KAo78zREFlsVeA0U3oIneZ4khvCc
vhaTOaSNBu5V8O0omRXbWZzFKZv2Sjjpc79wblsjK2PQ+zXDrU1DkGkjLVy1w0ItMpL55YgzLj/0
idjCnYPfAwAreUx/j9xZ/CzT+qJ3++b7+g4bccGDBwkSriUMBEInAxPnpI0w0er1Jy4Bb5SmkpQb
0KnKEovDEp/1/eGfAeCwTLgsYJL9fyBCGHbpm5Dp2eMmEmGZCUlfCg6wG8pxwygTEEp2Gi329XJl
rSgVAN5UQFNGRydlM2NX4dEzlCU01rsM0RJEYE5Q/OWn+p2KmnLPqkwdVNC+nCgI3mEu0+S9biC2
u4/XDBoG7fs0wLWsT1ZqQqGTlKsbwx9eeyDGgtVYb0DFQXojfUps4I4TbLu2v600Fa0vphh2Gm8k
4ip1tpEd5HfaQYRwCNHCl0MPwTN/Vxvb1yui+wwyU/COU4ES6W3Nutq9oAHq5/9/wEPP5xQef0ls
6WjtjP7XlMFqFjVdo5hm/cZTo68e5LXg/BCc1tz3/AZgBdVMZtXuXSjCFAnDdmOuC7JWpXdF5ycF
8SHU2A8u8YG4QTylPgC1CPR6CxbmdP6FBLd+dOHkJec1txoT10yL+K6vHuNI9s2o8jxwgx1MiVda
JorKi5qjjFsVzNDK653i0d5STy9DF3TqITN/rYMCH4ecFbLlPPqStA0IIsggdH5DNnpDMsGf/n8c
n/DuAPZC735mwOvLTQI5959E7cKPjqT71Oy1N7ZpEL3dpLWqiXMKUkP2OjgzbsFdXfYP7jqRX12f
jDK5kbGooFecQSSNUEG1RispyMu1vot15wX1x3/Jh7hToV0sKo04rhEKhc+ZOCy8JEmyErVZ1rYz
z/Qb6MK7KzOpc8dMMiRFA4P/V/GI3qwJ3cDzsx2K0cnUAFJOPT/aulsq1WhixFQnbQr13fBB51kv
pPeR1jvDyw0M1vfjPhBKQDC6VlkLQVrx18FDK424IQJ0UNF6DFj8pb94Z/HqlZlsdD/AJK+CZOGE
j4o+QbUu8pd8I9ZsvlfsndSGaNlxBTNUDeb3IcgpUYxb70ZLn8rpBPqZ9hmX6p1GqqQx2Mllvqcl
ovoiSIeGKfDSb2C5EZn2tgjzu271qVi5P1s4Ne0P0do3eiB+U98e//+IPIYkhQuh/QD1j4qmFrUG
TWNl39YwOhx1mkc7jDOMXbY0HBxdmo3jG1PB5b8GQI7vtw7gyPbB5BrksEHjF+n42CxwWDs64HEF
LbbPqgIM589X+RHfp6fXu+t3ABbiBXdnJ+JbeSL8bC4Zi2X/6cHP9cAjWcQEC1EGxXoEav1xm/C/
yTvtNPTOS9DP+FSmxvG7g1lLHffes6AG102nrkuQA2a2F8ii0aBsHOUO0f1qmB5XpE1PFTy+Yzvi
HxYhvuaPNOH7+gYttXVYB/wVdhGnKvaY+7+EApSxCtfaJifcwNLj8l+9ZxiHAs5O3Up4fUk5xQQW
8Lj94rPPOpz3TZL25U+JDz9HN1jxPMLiPAub7KWCkJlaYKHrBy4eUu5HYcSFWGtswQQ+PXIugwC+
kIhh6ZpWpk+uyzn+L4oelJo9vobWU7dFjFnAFiEQx9CRwcgZgwvWMpthVG8V9Bix75Pfv1t+xAv/
WYtK621acx39bVPOj0+0d6rBDFZbJn3Q3vW0jUZu26Bi7+twlC5r9Mc0q+lh/pF7FBDDBEQ8e65i
K1891jsZRg82c0OFaM6AVptpTG8oi7XxjXhlYvkylLaGUkqjFa2/dB2VKXlO+bk+/6Ye1Q2kIvTb
FqMLZ/sus2BBX5gZTu2DVsrid4u7bYwVjMLQ4Ef4ygaodWRlgUV+Q9cXqr5ZGvjF5wPhG/66YRH1
3Aobu23mpetJkKL1294gL59s0KAYywGKkpM4dUDvWKl0XJXJ5cj1zNJZlPRw0xVDUzCi27Xldw6L
qJ4+zr9Yt2iKHTUJYK3Zoo2EGVdvs7DPunSstTwgoH7QhsQwrMRMDhTgVRldX9Yhd2pAaELiQWKw
dmJ/4cQqR/yQ/lQxfVHSMg6I2NUSkJMEw0qZitvVyEFYSkyU2ZvZqQGTYWcCvD0XBDTqHzcY59QQ
dqb96IM26gAB6prT8mpxPtqPol4t5PwQkGPOoRtX9ztFs4mYV8QKDCzxE0PxuSZoiLE9F952bgwB
zS8/6FO7y6aKrK/jcy8cG/UuYRcB9nsZnZRgiv46+z+5alttgGISyDtlnkt017oZhyxbXOYYc69l
aOl8jdp24GXcGP/1jq2Zi7Zetu0AzdNHmA6YfSfsLU7d+/gkFi9H8QAE8B37yPAyuHtVoNaTWlaU
/Xur81J9Fujj8naN01N5539MMm2MIwMwDeGqY/U+XmziOahLFa9KNSQKZeMP5Ak90l+DO6YSJY7m
4rl2UiZ5hdYCaXk+LEFIHyJ4fNS6fEHwQWJBapbmOeYD6IsUbYfQSxVZwPbtLnHvTIwT5UNK92fd
otokuNPIkdWqSeNMiCrL+OeJ8xAPWa1u31ljYnHLNK5KGPgALRMfkoaNKnYWr0S+Nz0Li5ui+sL+
hT1Rbe8uSRBzDLBPClhMhjcmrSrcLqd4T4srCDI9HYxWHBqj3BTYMLL1eDV6etrbroZn3no7Vwiw
SLjzOuD1XM7PgCluJsz1uG/AnKW83/PduFiUDrO0SvI6RxKyxf/7C6M2FLRDMeV3FCprbpFyDtXo
7cWaxHemflsScT/RNTtQgpKL/hkjewcdhc0/9cxQGwBOm+uvfr5/z73rF73gfdlOYY5gz507m4Zt
Xe3uikd6DwxHWKf+H3nrcxppolc3jDu2hUt/pVByTr+WkjVnI+AB8MEox0TZHO6TUKEtWzCbKb8N
VtWtUmVEc35OJGXv4/DTX6gkJaASZ4YzCHLWLCjeQogIjJ8Ma1zeZvdx5yreeo70S0XCXl2ZrKXI
fHpzAMc30QSoY5/uutH9h1OqeeclZuNTLDSZ3leh+K5dIfRTZDblc3ryLPMZ6emPALnu5XCGwAjW
Ctqv5qEDVcuVSLOF7Y8Ng9N7DYrEPc/zU7a9a/URq6r49Y0L5Qwo1KtSmYt9ENS8ANwNmCurOsm1
Zl6rFCfLkme0eMhJrCCswNsqdmpDxnVsJmNLyTvF5l1p/Cr9Ak2GE6YXR1Ri3Zj9OloDTMIAIzY4
cCZYXdoQkvb0x/TAOD0ttPktDOig/DON4MoL3VXp5RJgfGKByqmdbsRS+XbXdRcS9cVx0BSD41xJ
4aMMlHGY5l+gu3XsksPKEVqnoz6aDVx9ub+me/uzPO4NfKKmXBv+5qxrhTiq/Zao2fMUG5tNgB5T
z9mvnu8vFP7LfUH4RlsLRo0pZQLiu1/rz5YEZ4ijGFWTm4zIk8OL5fIPJnxYoZ+Ahpqepf/EKZBu
ZJPucVsoa11VmuEFrAi1n0KO7ZV9IJGWNW22a0qBtCK8SrTBkBGonPuCXXyXo4eDNSA5EnHMe1gq
5U+IXZHBoX2sZ9dJiIZLGWifAGMhK+cy8LFS5H0+sIpT3qxJeqzUSeDGDq4gBhZaHrJzrmTDJKjv
EX51I/texb3L8wjwNQrOds+IgTYAjAcdSQ+IIBBSXeztRe1oeNYKbr9H36ojPO7nGRNw2oKdjZpO
CkgWsmc6rpT05zk+PfwhZq32o841uOLAPmAnKP1pJS/e0UL02XDvO2yM22QaGRG5pmoK9IAq3m59
YUkH4xgemoX+mspm5Rwyn94KjEllfi4mzT2V7hRAkJHJJduRE2jgbVRLCLBiI9UwhOEpHXRR+q6D
v35EAu7b7ic7Rp3cKTdulGCetc5rWlq8xmiOdymcRI1CFYk/bI0zaoD3EM1xWxkNQ3u6Jk6bR61d
5FeCItH6JwWTelQzp3yyApHr07vAxcmXtIq4Ixqtl2C49zshgiYyg6K0URp49yacOpEnzPVCrM1S
QBae7VrDN9gmYCxozg9cYvQBU8UGqVWWoVwcNUPA4wK+KQnl6KMHegycbVMkx0nJxk90GUVhXZiG
leo3FOUjaOn5J7nXEgwfHgtscU7j99Au3uSWkiexg3biR3Yn0IYS39Tfl1MvAgFo2ncQ7a0Vi/co
ZF7TIPfrClp0YDbNCUkrFtHmentm8vDTnbNEHj3F1hUJ19n/5fxFcG8IXN57qhXPPWlYzUU79hf9
fsUvaASXLAmYpehht5lnFsQJPw4L34zYfNVqnbNZymvLO8B6Lb87Ry5RnBHU52FUs39aJylp7ZU2
HXbXxM8dAd9JdbbaAapzXT9XNfdnML9np/2SUBAXinhpN2k34rORWVVMlV/qphJByBJ8WJ8WSzPW
BLZ2glp39/fG82zaM/3vW5LWKmVhl6WvDNR6d6WC46llwhVav2Ck5qBsGx6NVw599S2Y2Slj0Q5g
7Nm9jOMOkcPtmdF7fdZ6nptmTQDLjCg5ZLsABsV2frEESKEL3yKCmulbdq7EorkGAHO57QAhi74i
KAUvOA+xO8JcS0mglOei+QdNTVhvc9vgrzoPWdNL+B8Ibojtaqkd5AuHPKiFRCQcJ12IWAnpnnPe
tO/CiaopI5LKIgWbtiJrt6s5mzd+qSbgg3+DY7HD8NssksI0cOsTNx0+hiYWi3iwkfTVEPsMFnNR
y1gT714/7p/CTxxG8Hh3WQ++azU2NrXbiC28fnwUJyW7R7FYPdt8gFfenHZKdvzoPuX3Tgxp0L1U
IDn7uM7yu13rFSO+oZOE24GUBilVNXwItyd+BVEE1cInll41sdQwo3bEeQYbVpvq5+ct4phrYhsH
jov9LDAF0e+58ofzvP/TzyJkyafPFBIthI4rOTH+1HOz0UEvXP2uvIPq2vouS7uR8XS8Y/3bq37U
JmiqeI1NKixBrC7gkORXjGgsbQrHs43+ZY7Ueony1xCZjOreoVP48Nl4LFRUcqFcnpkVzJePeVqu
e5ErcI0Xk82sRtH3kDKrR8cN80qp097j+NxJs8O4VV94zPRT4XrX44Q8zdWABCsmFHNqKymwbzh5
SM40rH7MI0tRSyWglbwDkZFCduiIB5q2PzDKBgmshPLth32dl+peAyFFaPj3fMagAVnWFf+BbAZb
YKaMIkFHrzYAFWw1jeom4qhFv+FuJR3sFacWTlGW05i4zl08ush4c9tqdJOdDZC6mEpsTxDTmpIa
2cutup2DRZE9TaK1rtSxYha/GIw+YD+6Du3bNvQ0OWNn61rLZZYBR3adnc9dJgTF6//kAlRNtgTP
OaOoHRjf9RIXTlKTiqxuKo2vKf41HyOD1HOSwgpMDrI3RmQN8WcpmRZFTqY+Rn0VyyUYs62sfd0a
3juVKnQarFvnUamLAoNmI+WladlzbPvkUxGo9VZkxEhltPvB7M2kSoNi2RRs6oQkc5jbTS7S19u9
XJs+kwk551GYleX2AGohHwZDnqK6cLXl50RMumnlmONiDfiNlMBamG0vqiK76XAhfaLizCdndRTo
glWigZDP9wpHSae7frWGbYfLNfj8ZZ7UWGPKcdbf1uuUAaacDWCaEdFnTAUCwpXCj3c2PulC1VVI
C4L46dW8pFqPALWsM+3grIWM0XTyR64xB9554RCUljm5xBvZDXHoMmg1qgtFeI2Q6Qv/Qrv1/ydi
BupOqbVFb/Hax+66AWcXgijX7cvmyaHrr1Am27ZyGHTIXe7d1PizfcI9VJdYGmOcDFzIszhMFdWb
Tt97NeziEJdaaviOof2bSwDvMilFB0qYABbo4Q7eoEDhsJ3NWim07bM8usgZegOAq3oYxAOzWErj
e6WmCYL7YHnNt8uMcASS1aQj36TBYzSaqfSn1wjsF3D1NotcH9e/0UZi4ncpIeR4g+7SCpiRKPHt
mm82qEFGxzX11aEf1CbpiLzFufih0gwPtlvbTlb4q2NlyQpr+VaaK9t1lIbM9Ax9IqvHMkFA19SG
q7CbNCd5jvJDrVDNcZFWkRZgW2Bc3r7FPk+yacAxvoZLmRU/zVX1AttZiHV/IrMGpJYsL58i19y4
q4NlUOcurf9hX3gP4OTY8LuuiLbav4KN5tTjrw7D6heSnET4PetziTa+aaNlOQ/vYud7tQvuOl9A
MzW1as9EN5QloskPL11mLxu2MHJEkmjnMOSaJyWLAN6+Jm4KfmITgKchhkjpHLfMz0h4Ur6DZjqI
y3WAzQSqRZou6d9BHJA0bufZUYjKWjs3mXbRaAxtY3DZ4ftEWHc7AigCK6B9zu2nTTkVECj4y5DT
G0Am6SWw9jdS+io6Cq551mHYgRx1at1BgELD1oGCdYOe8IX9SdXqugA0UEI6Pg9VIwACw+UYPYxa
EZZaMC8edpcPshwY8tTJLuikJ9qwPqtLmXzLf4Cvsqd2sa6ZhgFUSX77X+a+A/v+nSDhjiySC4ls
amnon2q9TS2oQ4AQmuJuxBVX8rNhT0EhYwt26PquWVrfLp5nuGwdus+YYAqsoYnXrLhDT/FSwMe5
ENUirqulnyJw5yzh1HVg5uUHTRVbY/MFOeHpROjgztD4AMcKdAoM6lmLUawD+Xaz5gB4Jy0A8sM9
CaAu/Ah0T6h2HFE2vG+E4CRJNda+p1iKQbnyu52GqKzaTpi/AT4GEQvqk1FonqrlfxHIHwuEgQ0v
OV03JwwOFlH5rN8iZFAnYRdMQcnbCVQlNa7hTHBYh7BPGfAle14CKEKlhwMUkk/EcmQasAixUgEC
wbQHBjvzQSa/NMDLlLPJL2ThzgjEzOh6pYKrCcHBvykLHQW01fFmjKoYvE91gkRKp8xI5FcDyFV0
PEzC3/Vw1wCSvd8t3dW95YtUQMWo61VfEjzQ9roEBJAtjOA3DWp5ON22+S/RfNfXnuM1wkYHazF3
Bl/uChpGRoz2MG+7zDkrh6UkQG9TfN/dSAHkfLJoj03MyshRjHV+bf/gSuBui9ksoJhx36vz2IeF
J0MZ+HFboINuGZDC3PMOoWLLYLMvgRaZ7Ar8A/2JrvxccC7+mVgNom/q12CuV8kDgYuupY2u4X2P
dpwDNWPUQNyBkR8GmryuIDGiELXIlKZBAaBzir1B9kTK8dQ5+eAuAtvGDtpNvvdmo8fPMSHMt2Jy
Hg5Ix/BIpMJ735BUg0Mxnzls0Izwcno1qqZgH+fMncpyKdrA2D3GcEEmUfhTAfdA8EX89GD8OdzC
FZLGOxdkVdexquf9ra+nh+EMqcw+7KIpESG6ZfAWSvT5VXVy1UeeT/mMh//O9ywyVqX3D1stKB4a
zwDbWZpqSIpwsvt0jR0Z+IlqsJWVngIxHfkxcyn4gCBfjkyKxnfuLSfdRgsErqktqMdB8cZWTosh
fNmieWkYbVGGM+2lGOgO4np+5IvjT8WJNK5cRVN2JrYeLECH3suN8fjWdOv1UFPjda5bdVO7F0nW
vKacZdTFOMQ1FwGT6+iTn+HH9DLQLP4+MhkXyjpITLpEsDXs6efF6Y8m+0o0iO9x0d/U23LlemZX
W4VHcSKct9DvWDd62GRigdmvwdWQ3XVOODU7lJ2TLUgnbsNmtHj6qEGJw22Z87yQLVPkV1kZ0kR9
1Ccnq+curtJV9XXSw1NhOnHW2j3iVVsAtYSB8uyxanK6VSWhJ1gkkfEa3BvaC1vz4PlA3qVo9QT4
ashK5KCBct3bM6EGMr4oAtJv7gAgdMl0doHJEF80gyRz0VkFaNbCSUpUQeE05UZqMlx6g3i4SS6j
1h4QiZ9zInXtJad9FwW3qkkY4u4t2VFLBFc1rTIeOr/x7yixv1B2QdldHyQMoIIAy58i5I6IQrY+
2Mx4E0gzXCuCwyAwR98fo0OzFQvW5OMnou+kv1krGf3x13agCF0/RNvuz0igNxTz2V4JpGyaBYvI
2CvzZ1pAvZvy8MDOOr3WtXgWQeNZ/lZTkFQhkuAgzdeDrvM8iCJZfnPb2AQPVcdGnbFVdf60xevT
Vm3LJ6TKaAOPGK6jii6UziWywyQ1zsRFRfKPMSYjH8n+uvKx5qx5012vQlhB64IOVH1XmlkU0Aj+
jLXezvxtaxxMLZjuDYo1XGnPGbSnHaDrXp0kOujeO+6r0iOXQrrQY+EuAjSnfYzms6l9lu4k/rOp
5Agat8KZNk0c1w3Uq+vQOcZhiO1Sea9VidtEC/kNT5wYJw0+lRPJ4z1NcuA536stMwmxikeLGOEn
SsnA/jlFcyx0bOuU0gnIDvHFT7yy5Jmw35Xj5RsHs7msVmy+MB67HkF1u4DjGu5oJe8DuBLt86j9
B7DJFc88QWSoU2uYuE7iHRJBY7RkxXFhI+vVkOzhNEFiWKHkE2ZHYEn6ZIUqW2r93HDsPiac+5Xx
HtEA9LTEAkyJsjhvlXxQMsLX2446oVZ55T7A1pkIs+gQhOrqWCQSI0xQA1n8xllkL6VUu9MGCo8W
DdwM3f439TeZR5UvU7vOB+wKtI/hFf64YlNUJlIMBHxkPpIypAOg+v2mFpnRoN8LruRrrBPy3kbw
/v+PBIfgMSJaCm14DayEFljzfsSXbHK2of5Yg1eWjV4IzrOJcoPxhvjhVVsNrpaTRtJAfliTiKSL
yeesy/o7dJ+demuhE+ydMIYEpuWR4BVOTBdU7TMmvR5xl1wE58Hofi3v3V1BeoU2V8g8FuStM8HC
1+fza4Xver+uwLQ6DGCcVeYOCO6fl80oof3gfl5ZNGqjnkmAJsDhU7hIqBSZG0eT3oETndYpEQel
1uAmNJ53VL3hWj0FnY+wKcoM3paoSfxnK8ycnyLw432hNbSYEvZjrca645Q+5Ws8CR70AROpyU6M
ewTiRIQzO+O3YDA3x0k+ujzYtiK9DC9q1OpB0ZlYx7vDOZcJfRfWlu6oF0uqU09zDCvHNTpVgvX+
vwW6S4DBqeLUpgScbVcBHKIAJKWH5M+JkaY753xwx82tnh3mfQswTgGcJo05+L+JOmRWTRe3WpDC
4cSS4tiowz8nLygM8WK4+KgSaSWVTWv/JfQHM1TibYOlXiqalTKohJQtl9DmCJcOULs+NZK9BVlM
R+xecIMUhOEDgOzx8x3k0E8LpV0a5WKKQJALWAnWO76HuBmAD1K5gqGD38nuX2DOofVBDTj5l5w2
ZZBJgCvyTAybM3YIPYdfe6bS4izJrPd5JOFBW167saoGmCGj4aI15/JtmxEwj0Tp1PRKhMI5RnpY
3eB2vYMgLtZPv9tu79UY3i8/NCUXjAbTInUapDNlbXoPG/BT+STmZ1PMp3lAT3pxDsVy0UGNwMim
TZk8s4jxRznnnHrssi/WS4Nfz2n/srcZppdOTiFhvvqH+eEJn4Akyzt7w9iu2G2hmtk+/Nhea2Jq
LpncSCYypmlaLINrGtdr2t1wJpZNJe6ceWEP/NFDCMKlgKGPDXLZSfRkfAEtCjbk0yoeJll+CLYQ
0qVjaR2yoV+y49AJRqPr6YPYaesieO7jRUWVxyMNL7HPpX/WrbOuGNtKyErwaAmfKKW5+uRhChiv
HhvtYpwWMiWluu4cqTg2DacXMsHjjh85HR7tN2nS22N9Ko3mKNV5uGRWD6QPNaJssDBCydSBg5lr
LKbUFFEJzVPwfD6sQnhUUyo3bi2xvDhPWuhQc7ED+TLCq4Z/CZeE6e2vYgkSkXZ5feH0u49FChRT
8WI/i+ME3uElda3cVqGDwCCUf0zsqI/mN1KSFrZ4N9eMSHAGsTRRiYOL24rEi83Fhh2T8NbqFKP3
NsijALUoGJoNiVlZTnya0fUeG6TGurb/eVOo1LB7/rfw1JdfnHFzLyYM27P4c5S/RWuIg+WhuKQU
ROYLMvyWq+lBI9FUzAGQByrrufJl4/2PRkoIrGEVWdQJhqPCYvL6BhHbd0+IlcObtZL5nCVM6uyP
Jz/Sz2qNhvf5zbUslJoM3Rl1C99xZmFrLHaWXtwN86fwCItsKa2QKwTH7zXnJATk2VhKHrk6mbmY
z5QIeGkPhxID8sxWrcR8m1j7BiKsUcX2CQnWZz45i3A7VT5ulNggNbSMKN0l4gOQIluiKgaGg1AF
1L3yy1qRiP5AzFawGVNQj4kj3qLo3emjAWLO3CLwjY/6HdObSry8Tg4SGquE6mjCMqEkos4cFqnu
3GdtVpUk3dZSmMjoWBNSGg2taVOb14Mt080MRJxHKOE2QzxdMUA3W5MTgxIq15amqFPCKJc7yorh
TZU3se4XX6YYMS0XlX8JO/JaPgCaTrAapvdpoo5CTKRxORUE3jzjyMCCqm3fmYG6Ns6rUm5gNiFL
MKahhkLDcf53TrdtLw1XuhAWqvSIIrXE908fFCn7SvE9mGN5NXX0/WFisUygCUcUdmZ7oqMCFYOx
bSbt0i4UcgfGSFnw3ATAFHD3bUNy1EA56+9gcPnn9RxWuzhv17EDLc0QSf8X4Kbe4j7a+uWAPkOE
WutnTnlF7cy9/86kJLbuHC+IlJeNyq40w1fm44Wq7eyyaGDPwd22KkoEbmT3LZ4kan+oG/m9Z15I
dz/PUemrzz13/mRCq47J1/1iSixzRGiFKoD4QAOHIX7GUlLRgkXWEs3H5ZjjO7WxB2Ew5YWfKEqS
WKYwG+6h32LEPw+skI+JF77ZoOMx9f1NPG/KdzSeAyg01qQgqJouxTAqWOog1lcWuyh/1X4iD6K2
hq2ajpYcVJE2h5otC58RiX2q6nyWLuE3jiM/oQlEzzL8+utb88nqOA9dXqNcgMAKINTjs2Ec61Fv
Mh64AS/XxTJDRG7D8eBD5uHbRa3WyQPJ4ihvD/3agA2krR1vYOswpLY1xSN9K8KrLTKeBSiDHxrR
F/P1YI22vfDxy1vopOIn/0C/qfq7RzwphkdR2MxRRATokPmLrzWxHPea/bjrPTbTZJNkR5nCq5Kp
l+c/B51adcnoJVDPC7KrMAUXL3SirtSSGh5B0Raw9iPho26u4WleILbLZZy2KGDeyOhyrTOnBVZt
1vPyQZjp/dnkrNV2pXRyv1AN5gicK+bsVAoCWrbKjSkQYdMqaIi4yHXD8tM1k2sdzVWGhzrz5zpt
eDhALjIKnr3kLpm3BZeTqH/dif8NuNS/aRDarLQ50M4zk9WhV2B4oEpNzV6Vbr4kr6dMB8N6Sy6b
gMpNbEZR/YSA/RAedYVJDTPXXOQQbgjShyMVXmbGa18jg+9xUk6qRRn4X5KUyygbXvqlf4qJaPMA
5YAUcnHn/aPhGJUZKhyRa3wbQ6zmTQqe9KYfkJcuDKoc5AWKhCl82R9RvuAwTed2BZKupARajfKe
liiSEpd+iWUPsTaBrP7Oodzw5kaAW4bX1Ugr6Vv5S6euh63NCtb7lPQvGrx8srRVhj8+UO0+mT6X
OSmIz1suays1kNxgg+xRb7xwsdZ2W513cjARuj+3Xb7auZXNfNSLXnm9X/BBUbAAI32IEshUK15e
xTSygBQl5Tf39SBMmsz/SfknLxnyk6sA2YcqV5d4DvRPsaMrAYSOzzwclA5xZ0Jgw1u6fwoeN2Fv
SfGDgDEzu6HR2MWW39NQx76aKsTVUxmTStoeMjnc8hlNbXR9H3FSf/61EVtRDCktsxLWkG2PZty/
BadrOci7d/c1ATaFHXzSxzoLge5bFAgU31BCn8qLGj/Q6yFTKaeN2WL/IyUU0JwnQ+FPveKOzRcv
10EvIXbmEiGepXCTXRIhXeBBL4jVxSogmSnAxjy9VjbiuabRPUSGJncnbUTbtnEhx0zFj9B1h1lr
hIlQ/BhZCZ2dY2OnT36teFrTd6OpBX3I44z3ZGuT6mo/XPl4mlJ28I5VM0E9ZGa3W7hXjau6sIds
il7NJHgRPMitXL4MpTQakOV+Py7lQbnCa7/VaPFFDRa7siUNuyjud2nojt2IJ3AgZ3zB/OkBjb6g
AzGmLdBHEOt/RDq3FPHEfETNX0XT6UkcUi+A7TawjqVxWEOwTBdxn99im+zNu3VKCbwjVWMMo2mu
NtULwKMjlnblpyk/szbNksuewc0ZXACgwudtyHf28CT/OYQ/2zbQYHK20b7xKuJ4kmsR6Sdf7lQ2
NODP0sWzvH9wnASC5reXYL0TFFUSjxnuOsvNEIg+qtzhLvfxzqNd1OnZMSnkQOKDwmHOGGXG39Nz
B1d0yT/bK1qMKPehc/il1Pie4a6ZDQq8AsvSKaWRwZ2q4ch+GDTyZaHZnFmSG+yFDS8HENW1Iz2u
/DX9iherby2owxTRJlra3C/Ex+gT+tYgXLUqPhotHnduwBQFAXhUdTrCeTGzKlhmBATugcBWvJeE
72IyG8IiK6EBZB9tOGW+29JR8sgBmRdt4RfH5+NUnBUEPMp9v6TCvrs5SiMkGRIl6Pyzw2gBelGG
j+iJJ6jt8FQLWNpLfjYgxy1dsSNO0lS2+4unmJ95//zvI87BxlxKWYwzSvcVDuX/ESkmehp6em+E
Uefzcd4UztSOwNSq/TYjT+LUcpQrPLjwFGzjxyalfAQlr+OdIM5Ef6IYqjQYi9bXt3Z/w6FYiTot
WA+LCpz9ECKQ6DVlUH0svgsNvVoR+Sp8UZrqH/zHz6rKsKDBP1Chle09GMIdMexwFJt493n25d1B
pfc7CZDRZweyvilghzdAgcC75nxJKA960dYlaUC/oKbiqzdCJz0iRMQxUWQ7UX1ngt3mg6kUjEoB
/qay00BfCa2IBq03S8Ui4Jhxo+/pslO/ZUHyVdBeePjF2qZ49U6QxpVP6hdNQLU2jEq5Yd8yj6Bm
5nhMsYRxBE5KNag6Yw7t8tribUi4s7VrbkPiyFzrk2LDrIT6iePWi25mIe1DqAT6gzPj5BcJpOxA
J/w48AKTGEEJ06CrAEsaXYc+KQ9ersWRgaUpXF4hvN0q9ocb5cwqC6d34ywxpJ0wEHGFpDjLOWeN
HPuayldYJs3qQz1peaormEbYQRy7HeNJ2hee8ugvY68vpQIXP9hheUfmOHdFPO/4RMgtuTNKI/3D
wkhQtpFCfi107YnSVaKBvNkyxr3TQG+SqLfFOnfNB62XzeUlZ6riDE8C5dWG3MOq2yuJ+7dGydmB
oyU3ZAr3VeZE21rKvSHP3hL3dSuXHUDKmq5l1gmW+PHdnETlB3Vw8IqlDWyaaxlE64R72A+wUfhc
OuDX3ujvHPfGuaaUTizK2lsJvfTCGBQ+Ere/UbUCOwq0MDJ15Dz3dnaUdYMcQIFm4fgb++7IyEcE
Imf7sPFaiPCMpQhYhi062Extei4tjihz+jaTxTJ28EnZRnD1o9bRVHHH4vP2+iRPe4kHNS2/bgcN
Jh5dtzoBSZ1gqwwCJVyxlnZ/vvO1goF5yIGBklm8KguE2+KYZSreFbMR/KrFHEtglUt3BboAvPst
0zAoqadZ1bW4Iiqo25JRmOPcZKZFHjzvF0UgV5Z4vFQko4n+HeJxtP5yNU+HDLhvNTOriTeAal8x
7RHJ63I6Bm0+Ci0u4MfZlSC5vrDY9BhXJ0deBEqhxT7m7drd9ny21b/iWVRGMPp377x1bW3COrSB
v1uvh8dscwyAiOzQo1+eAy6qXm8v7uyiwUJNRwj22xF8xXjdcl/3FhAFfdRBPol+Q2oWuZhq+v1f
GfF5IDbiO4bUjIjropRhvj3TuMk26Sb5B7NBXClnmggWSlYzmLryTLfoRRRZ3J/m3u/GJX1zFckV
rfxljR6NB6u0uZyA94yayDhSivyEwtzsLaTcipitzPKK6TrDpA0nTjs4XpVo0Fmpd34Q7sX8tLvM
7NomuSFkFq73O6ideyuEaT8XXRWWCtnYxWpPQ/jhfVfajAkVEGm3jbsQjHxx9Z5MbwDdMtCaq6ck
vDVWMUCgkg9xd4+XqOkuy1R6c5hKHJgU9L7e8CEkwFvKpHBROry2xIZVI/Ontrv+ktsNEX/NPWs9
6SPPstkBc4F5gzHwDVINZix5BD9qC/PQ34QOIftqzXbuBe8YeeYxLfw4BP9D7djV+jqpJaMpotF/
uzk/aWNCAAD4tD3sMk8sqcMmr33n+6BRRxGE4EqR+t81w7awx3bNmBGO0w++WxtNS+ETIjYVAfdP
HyMe7JZxSiL5Py59hxHSMcjK+lqnckvurR+v7tcHRudovUhs04OO4JGI504IarMA1sOHq7hUcMc/
P0dMhBI7HCyWkvH86+tzWV0GmJztdhm78V1+zibfGbo9oXDYMZ7G0x0jACU+UOW2Th58HLTcP+Gg
M3nQnzLTpq1tZJEgqjji6Drbdb5Tpq1p6bWIRVFSffKILzQC/zBAikSWz0SE9jk0f5R5WHH+e9nR
xP3r/XKEslyfIbcm9CawVZA+4TkebcJrlgUToaDkmAh1ZmsXLbcfMMYveN3JmZrrBZwLR+ksIWtN
q/6T+UBGhYQXoiELuqogIfy9eIyNXCwrBlGzbdEUNGwZUfzEe4BhCZsNmuVz4zv3kZrU950nfNrO
o2pvWyt6Gb1YxAA/dLDHOJwtUykI5Q/RHur7OtfEacBvFHGsUiBxbAQThjF887mW8j9IVmeOXpD7
M+WLozuSqIDw+O4eucs+XfEEMPhPIh2afnCG1nTwB7T/lyNZSY5Cpyf6Wq+g1DVcTqDkabUJTV8T
2h83wzx/FTcw/LQ9Dah5lOzyhocwHT67Dq0kQhUkSag8fZchi0sjrcV3drnQEPCS1a0xdCJlxX5D
tSJLo5atiWLX/1nacSl4gXnIK1yRiDc9dJsTCPTyJtdJTETygRmPyh6GZDqlQOYENuVo3E9/h7Fq
yUVASPFl5c5FBO4EZYOQDN4muEdnu6OHQGM/JpCha3bnmUO7ZUiqlg+VFPkRvibMHOrctt4pNmyk
fOnqyajtGKSipxFKodU0miicXCAnLK4XUKEEnU9FvHnHYmEhwXtNdKcuTjVdHuiIldBvrfknJTVv
ByLTe7Mdq1fQ/cMTF0zR7zwU+JfcI1aDbBw/TwI1CXIRYZPGq4Yku5ePy+PvQtVo+vNcOSUZUxG/
ZdSWfb6r397I/RCqzQXCTUMViCs3zcJJmbbefwJUqpf0Q5Af0ZsNpbwYzAhePHg7e/9UroA4XzTA
F2lEEOwUDkm4Y0Q3yKbD+6KblOY3BCOf60hbOBqTg/YoD7Oyo6CwuuDMX0G5T+Tbv/3RgxRBpsVS
PMIV/FBsHS6jC7W1NTvO7cdRI72MTe88KmVAzYbrmftFMobZ71AqKkhGLiy8k9mr1LNVdUAjlNC8
m5lzZo06bX4bluN2QXBo9/bxhnfV7Xq6pPZM+w6EainY2DfGhYrOavTsjrqxkkPcjDHleBAVpYNt
LvAFGeT0VtIAnObhHUry+uNeuiIoXtk5uZBOJJp0QHdMAd/FLyqSfjMOmIJgragsgtLYUjIckPQb
SvcL8ibBnoy2rxkqLHFalocZJLGDC1HxItOfDb877pDdJECyxeb3IR4RghNXdPm4fZAGVlwv/rSS
82sne3Z+tYFFze0bm8qPNybyE0WCUKohuQvO4WnRsEK/ID/3j9c6h/Hhn56VTjx8zxHM0Jp38+A2
5ffvf9h5PpFwxvJDoZ3shyyMwDJo0V1Fig/0o5DSQicYLPnmlDAa/jOfa0rmWQ4BVSzPHmWB9J4n
AQTTBV/wTa1mnpQNIP3e/5XEXbTqNcbA6aXl2Tey4kbLh7y1T6Uxv7Q7MHp6tIKhUzreOwyRIKAs
x0DUIxs8Um+7Ze3QXW8jHh0HHECm0oAtHsqg49wwn4Tslxnu3gX/59JB3LIG9QKf3PxgQvlV4sKu
/PXw322NLIGpxfr9fBSRR2AqeG2GrkLYEXEpiSPWNOrj3E7R5fQp+tfkRJSJ9Io8hINWAyWu/XZI
8p9mp8OhRd/esluVBTnnQkXrBU7orECV990YaLKfW28dXUlwR4ItG+U/Upum9753tZkN1xiqvvoJ
pbEjjG8ZG+Xd5ywOLk6CzxDWXmXtRYaKUkrdKi7ayrVlJP+FhVBaazS4AoIz9FY3Ezq2khppCm3L
/udq6OYOWN7xi1Dm3yXx2NcYYULh+GCd2tA7C6exYFOChFtAxsiPicBJQgohyphM//YVBjoTarej
DYQjbBYd4JVJnAsbBbZa1x6umON3nL03oAR/dD2l9ov+DvZ7h1LkmsmyLEFcnQHa6w5uWOYbymEO
atikrMOBkJGGpQorf2oLkUx95G9GweRNonByf0Ro1ULPrImFEoCNT/+RmbkJUxPNlCfr87UgT7rY
xPsX7KKE0Rg72J7W60/Ey4xIrM5UqTojS9Xce/z+j7p3II6SuE70wNWpTx2Rqe88/C1fplcqQ8h+
D5FehHaWTAqw9iBGYlEq4ENzWHEjsp+ngP0on6+73sd33/2sy3r4O6ZHjEZRYFXdX0eoPGkTjbyM
cvRHRZHoZMfODBzsM2mkbyz29/VqGZ9siXqUqVKnD/YJHOUVlrO4ShNlgrhqTMul57Po63kUnkgs
Z/PnO77OgpcklqXcVOquYpA1fB+c+1pjbj+QYdw59FTdG0WhZTggUNBAxGOsV9DlufiAZioxMKKj
dqXXaUdxe2mG/ueYbrBWSVlJUgOv6x/u007Wt+/fpUz1RspDwuvs54cUq85g1xmHMEtnTLRSORlA
GAm39BqrmyvM8sMWa2wK4yO5atYWS7avGS/aVZBlLGXmRufsylOZr/AWqL1jkXFXDQShz1jMZIqh
NJy0O2Csi7vlSRB9Pv+SF6OehMwqAaIdPXPrwNTankb1aDm/Xn2E2dgbOhqhYPDsh3M7eOJf1crY
qbOZVQ5KJ38hc0DnvQvJO7QyQ1sXdIeVwgj5U+grjHFdufQVJe2ARee1abmWukY1iQ4s1zC7YMyY
jsr1Hqyf0Y8xSi/Pe0ZDD3HieVCTRNdcRXsIATCc70HFiuwR/3JqSLEu9VGZGjoVx4YKHJlW+kaO
MIBBe7NHKNSWQtxll/6dZ++zQPrtgaCUvUFp6xxTaZySv8jg3RV63y3cww0bAozXUOrpjWcrNlrN
WbKMkV1UvgH1iaqK5rn6yCGXvR3niC4Rh/Gbt8KFrgXRWtvtPzkGP71xabTMMKvG7MyIhbK8chZB
xMuyi7fTBkAMbuQXqf2O1/zVNsTNmCN6XhyZXeeWZ8MsVZ9fKHNHgRwoIbeRx+5G9l1eBbULvSdv
3u+oogRYdm2BXlfRXWXCzwP0d26WZi6VqwOwA9pCg0W0wcdSw/l3ATPHu7MkvIVish2HVKeHkhKW
rHF+G3nHakaqAOj+i2egXJGRW+xnh0tH7jvCc/yu56jciKbpS6zHR+h3XhaEVzgLsSjVJ6eJK0N9
oRekd5SfbTW5VzuC9bSuiRVRTGm29CMO3y8Te1as5ev2iqsqbI7m5UKByOgoEeZq+NEZQpU1BCxO
/k3DNOUsrkz1Gcj/l+flrz83aYqOfls/DoGMH0O658PG4g7Bq8DGE3Z/0s6lgvP+13FMAolo9JT6
KXdW5I/JJ0tMRX9gMiBZ7tvaW3sPrVBwgnJ0LgQEUwQkbpxPSYGhUf1XoRhVQR2umNc0oYNwS76R
pKlX/4YBo+7FxhiGty2+42iYhlqIWytD3AgppTw/gjxu4fd0PzOoCQla1cNn0L+NvQwwgzqc3zET
LfQysaa4F4cMFKI//t6E8w3k+rJxB5MATsPN60p6Hz1K4y+pvv7iFMj2+vjZQfBlsNPehNczhay+
BHhILIA1cTEi2Qyd74wvsX9zKoUd+YK+tPSvWU8c3UKoTTqM196FpSOPBcSSUQsmm1qJwUdzeavv
5/Ld3IRFrkY0JY5G51GpXqwtLHgG2FXbDyZSe9o0TYavGWboo2lrgkY8NaMycClNCWKh1u8WMhKv
q3IaeVteAETdaErhHqaoqaX12+lRWUVSPAJrCiNEpqMKZxFhtOIA6tZAwYzHC3YOcEIpNKduVKY9
BaG68i5sb3IlF8jdSKtBj1lNDoWTe2ebN/h4pqJhqcyG66d9QgdqIQ0Q3539NtkjfMZI0fIra6nD
X+ifvQWaxeXVV96ljcRfFywW2kSpsox/hk2Z98OTN0wtasCxgO8KgespHqHnuvdTM+NwN9IHvHZ+
Jz8gqWDeX8zSK7TUERrNYdFYMGC6fqb52vFamHLRkWIq9eZG7yGduE4KdsuvsghWdF5x0ohfaavJ
w1qF2+C7lq5bZ2Y64MAClGksMX6tnCxP5j02x7dp5qVHNHh63PMAoroqkSJeg9b3M+NlP4C7D+O2
xhnxWLslTuXDgfSqJJDQsL7ChD3PvyBgV7lSDIGd9SWvY9ZsbouiyntOiElLZpgiXbZJPALJhrZh
+a3RLAdvKDareQQkmc60Q/qynnBlGH4rDOxhkBzq61qEzIpyk9Oe6DnMzzvK3a36eTCYmjo0++cE
s/jtoheqKHXVSZirQlYKwYEf7/J0tuZdiftwh5pswfkf6sIDZBbROGTLgBfQ+FlPXejqeGDzZZHi
FeyUOCdFe9b3LBLEZZM+ov58l498+5kkjtgvcUoQKJIQ7wfrfs3Vom1p7TPPs6VaA0BxSjbZ4gMT
Ml5JXAM/CD+KkJyGGFnt/dxDWT8ccZs8Si3SZdcL1niuird8UoZrDbuvJOmOf1XfQndU9xqFOlC6
cN0CJtDFVe0B8cXMb/o0h1pWhxsA0RNxLGsxIYE4VPaLz5sTQLwBQTjY8JmVgME/O6IfL+PXdxnT
OOcZ4e1O/KOhg0gQHRt9BaCWHBOvyXk7X+oGuPYBC2NxX1B4a4zsgsCDuu/7ZLia4f/iyRkg6q3x
9VxZKtchMmLhGKF/MJfzPaWiq9aADvwh/Ji+CPMwCauJRkT/qy9ux0Z17oO4B4oTYY6M9RcVL692
HE5+rSber4bQwlVCHmtc3ewyCI7EQbPwJ9d7heXg5qYglke7o+0Lzy2xzJ/z2h8MGYwCEEvsn7Pu
aBHXeCkoeimmGiX+juuiysWC8RVKE+j8abekhzX9+kJyKlufXIcajZlvkxvvoT6rg0DQ+t3BN1jd
fx5ibNeu268/tktlW/BzugUrXwCGs+tWTuKAWYiNWsCfk4FiPPdZbuYh7IULjp06PLHdjNXJKJYI
sWJBmvolM1UJMsaKIeXShr6AJTlHGk4aJ7ck4mfmhqX3KVvkNHE9UNZtD80J6dA9yGQZPnqqsb4k
WNN/CVp691Bqc6GD/sYm1Q3wgzsBvTi1byvB85rpsDqdP4wM8K2Qtxz+Oc+qj2Dr2UNhakFs5tYW
dWukKwSyCLAPa+gcSbBIGMiUAzacPp1hUbG8q/suoJaRwsAh5sVnxBbm553mvSfPXv7OxZT0Y74j
Iuq4UAksyaTTlbWG3cXer7EliLSgpXuhDF/RxHjU64OMpgFRmQUdVGZHZp+v4mmhmlqKwHoJ8vv5
AxObnX/935AtJka73n7ileszrr6BX0ZVxVunhM1oC0P8N8bMARy6Fj6EcSvJ2o9/A0BKVaGah1EO
3BOb+FVNX9Pv01+Pp66F5YDXPyBovfM45ZI/bsgK6f6jDz9q/D3suq/ZCHEdQHJUuWX4rvSwas/T
qZ8zToLOztg1+Fi1fvk65euCmlkVWZoT1SId2hPSNYv6P9Je3dgl9AqoHp1TiAfjWjgdF1xUcTPj
AUoiSI+yiTSiuQL51TzYFiqLO/c6BAFO7UdOHlugcwh8QUi1IcmoaCAf3+WARLlelU3/hvw2Oo7y
i+OJTvBowxypmwe1G4MCd0hI9zcjKXArfLMzgOTzIlNa/KfEL/q2o31BPYVwAj4FIuG5NDA0+PNK
QKY2rXOPtiu8qiBT1R2lPdmgrzpNT/RQ38LYmeo8xnOBGFHbXZSmkVc8Yt5NpeiRjgobNo6UArz8
qt0dYZOFj9SUfOyoNo+gCEItTEnZEv0y6qd13BeVFSG31Iwek9HmKaIi2ZaZsKO2o1OH8kGxKHyM
fNN5g6WkLARlsu532pndD++Dlej0ZOhdgDEIZDPDGtM6Uw1msnuA9opugeDfksrAWhHBWk+cbo/f
ZQhHPZFcxLuwVCrsavAymQNyJ8jkCm7oPI/mOg4so2CdKcv9BEGGE6M6owd+yaxHvhX2D1NBnJXK
HcvIOnuvYWfyPtAa08zbFsoTxjdxm8DBleLbftjAbtuaYQZC5H9qkn1qffWldkJMQu84PrARRcys
8qqBv6vG0eoJmzRR5WIk/jxGxVgMXNImmjvsk6NVmCJm1xNbGVR+S5TPz1i4HKAXZ58u1QnCGuBC
dpOGY2G9u96A7BIWj2AesyhC0NpRpVcGKm09lPqwizPV8s2mQHIe6iDTceULVSwQtmskiiHTuQYY
jrwqaJhbehnN54qbyB2Tvdzjf2LMekqooClafIXNaXINqWSMt2lgYb7NhoflvWQg1ANqiSMSfgLK
9fmE27fJ//s0iT0KsdvF1jSGJLL+T4RQdFdXv7QjGmE2eP0zt/Kdx2bpYvoIrMLLc7ZetB0Y1NRN
UCN3ip2677q7K7qnuQJMqe0y0HyfDT0tcqWPVkVmR0bgYk3ArUQVIgBsrAsqoFLVXGukRwxXvvt+
zBa/N2EPuzr2ebW2hdHlKP9JNMY8oEbZ/5c/rmh7WKZbKDZCwAPjar2x+k6AZyEZriP7tp2hNj0v
rDDL3aQ06uS+8QX5Yoi1A16qQew/7CWpFoXrHBrM6XUgK2X0ldEcwp707Knwtt+p8Vg4evHl0Jgq
AETMPyY0dDQNX3QmV5qwBeVZJyjQy4q7hdKUjUj1GB4GUfgxqmIRc+X6CShG8vPIJ6xmu6dfGjwy
vsnNN1UHtEqHK+FIh6kKUhIgG9AcMEwwj4EWwyaiqkYha8vNm/qTd5ZJTh02rOWLs5vhMLoT3/mC
cRpYsJK4wCvoXHHBmXYeWEkKeA83R3rA5rxSPxgPcXo9YNopThuM/85wI65r0YMpes6ePfI9JYUK
Bf6rMgu/11TAtQbpP2WEQFtlSOPcizv2VWdkc1ye/XQoNWMwpAuXvpK9mdwMomOVDjzA8uc/tMll
ui/iskwAG52MxcnlL4MtI5TPBNwtn1Anb/coh4Q5gwPA8n4SEFEEKE0aFcQJaaZaVOBHF/ZQ9HxM
fH/EXKj+NYSwOfVrkmZDYqP6TiybZK6u2eGGiQB7VK4NkRnwGgW7wD1dAn+jc2gMBa+SY/qeWlgU
Kv18KjB6nK7Cp2m6BdKV5hUOyj/cAtGp31fr4gj4xgJQBRH1+pAL8S5r9f9f6vLHgzJUOTrOF94B
XBHAOXVxEbj6JwLw41bJ4dmlGtSlDHPaMDqeXOREyK+ZMb0OhF5LCbirJWpRMAqdxR2zOJbrMIaK
OdfaASO5qGXXwHS7auf0oFHO9hSk1+Bpr2NPG1BVcDSu20Gvw5r9oATLkF0RX2UV9ATgRwGTV62T
KuQ4pSgbj+/xoktQ9UI+nTrxjM0Plcwgo0hSCrEE4D1rDNFVJxW1NyFqOnrzh5Rs2myWEJfLZaks
ksi/g51JdXzbHbYM8hP4EdXvD2LXZs4xotxES9dLKdKZ8DUB+jk1azXf3BTVH5NE8dMexR28USMj
bbE6E5pRRAaaSVzIx4bGDW0FQFG//vVWWPsuLwNT2aX8jyfEkP784mqVcQWBISapKCM5Ie0Jm+FF
ooWzGAurd90INwoS60jTCWBW5kl5Fw/61I9CYwCi7N1EiBfQ10tVqW0MEGc0Cdv9iHl6BFVXpoFw
CEUX8nSrXk7xQmg0oG/PQ7qLFbQdREzyw8YxzlyibWMtN73/L9rD72/VY+F2BUqMC7/hvoXdnyP9
8cT8TuVpJ8R1Nrm2tN6IkbTb4ZWniWdYK8gB3DExsel/HLJSy52bRYBRws5BwzSJqsfiXPKe4hI0
zEVqpJo9qAMZHprP1XExaE0sg1LgkHXrcQc6OkB6BPx/kDK4DSm//ajRyB9iIreVNaKZ2iWnyEU2
ouw19AmVa3LDVEi8iWvMnbaAu1gMB1l5Lc7paiZWTYg5cwfNKs5HhFa8dnSXA3nGGDCGiYqIO862
g1WbrMc22xqdRys2LpQivGj5/KhZS+GURDnVmLiBQ7hYmFfHt6tqVGciMUf4613qlRSMVeYQAwHi
rwvkMy+KkzEMVg2WRsNKEopqqFNrZiBSWO9Js0grZwLxASRIkSQUL/2rDWuuDPM43TW/wW5mXCAD
YnxUWsxDlpVW7bVrzM4lHPBsYTCSpA84P4P0mHZBEN/Dmakk3fN8xuPgC4QJpP6ZEb9sFLTE+u18
unvrvYGa1oAdT8syixxGSrQzWl4k4jtFYXFAxD68pidRbY1Uww4RnIFiSeRpdm6aHxZ6YC9pFAti
fmHzGE/4CGNondpCWdsmNlQIaim9MiKg9K5cYYYgRHhoGrTbB83blMOQMKxE59JWC1r0iw87t4vU
7zfyZcYiMShc3d/XlHPO4yjsoUrm/HMFm49fLwS6jsOJaa4+1j1ATO0d9sM2AsOTv7J11mYSVqAt
q+aCsd0bGE52oIkht6q71Xv1gHkEt3lvd7dutEXfgpFZC3li42M9NzgYPrJF5S8cFyH4Tcvp98d0
F7nOeRniu6nMWAm3jN3l+V810MNV04YynBAvxVf6AnENqYA8XuBouwIczqnvdp5Wnc4kIBKVoqlL
wrkyY714zxnQqR6U21+bVNepjCkW2YrpEGrVXwz9wPh+cpUBO78SlCm7ZPis6f9g+1BiJjHoxJJ8
I/ZPe1zio4MtQK6qWtWWrd7vSV9nkcWT1Hha8quM8MTtVJT3PpJWCCa81Gfw2cptsUFiKtOhWcUN
pskXD9rfycBLf+kN8qn5nptYlNUH7r8K46WSij2mWjExWAK4flhbkbc20nD9Cq+CMRW5eXQSL1iV
diDMLa9cv4zZhX1gmP5TTUFmMGCSxjdL8JDSX/shMU/yhFHHJ5U5zD/JFTuZYiICK+Rct3S/TVvy
25SgqhxlZu4mxZu/Sow6xDCPHISKgVmaNbMCmXKmK1LDWXPfQjD7JzAexNSKbA9drVdvz0kvQL5n
NBwUeybvRseMy0fmo6BuQik1N4y9qupcP8ce3WL916m675I6auMi8aPkSspriTCQeoNR4ptOt7IA
IXW8RqLmkMhcZMIy/4xI/FaPmbLYeK6okhxvpg1wrLGT8alW0V3DkYmrR5Wkvv6ftN6n+yk2PLt7
P6XOsEQKNuIN8yrgy0wQid7c+042tv+jpU5b+e7O+Bux7qrjrzm0KKAOs4xgsh5KjqYuvPLqpPrt
NEBqHBDDrJa+3+g4tQGkBPfEN3RBT3yo0f3aNl4IMpVE6Ie/vqaPXHI1g9E47BOSqpn2kp/Em6t6
vwdWzH36As8fcW9iOnKgHNsYlAhIyGW88rJ6t9NRvCUbV5p+ro+XdtsyFF+IAHAsGMNvBBnnjfyK
WlRkzeGr+ql3w+sBpPi/gNL9nH0MxYt3JovDdUk+yNuaEKPGUBWc5A84sQkgPJKrpIVzpglYObCP
ZaLgLFkqAInXXiThyfOWR5Bs6DB11kTue31woz9qvAHK2xQvViK/GU4T2BFRbQwgCtmxFJYHa+Bo
NcWhCg0/Uo7bEU0k1bGki17uSTUPntJ8EO3Ri0DAVAQpHVvV34H9UBZ+AqggJRnPThkIabVboTQU
gDTsfWWadeTTlODuiCnC+j8UqPnRMxJmYupR8XAx0OM6pQkxs9e6lbNs3KQjNy5fjI8lZ16Ehb1A
+TBWOy8fABXxD56HfQ8bl/36oUbX2uAmPk7yHjLBUuJ7H/aGbE48VC4Kxhc3WvJ30ezJ1No2CAyT
86s6uQEZaXZ/8UR80xvPm2pGETfr79rbIW3HiuycgPy+QiNg7/fRDaJX62ImmfKCuMIDj2PGPEKP
krBv77wgPyQGD0+lzH2kokA3lyULpAVEQjEBbA6rd+y95yDMVNu/MLkNw8WK0WPrH1Gc439lnxGZ
gqxtHYaYi3hFzkZ7SOgepWBku+Ikq/PjLN2LgOID+l85XitKnhU734wtqpKBocHQar8fF0jExloi
Wl3Vw50il5Q5UEpQmUK1be6DoVtaKnXOpNEHtRIWgG/xkSXUcc6rYV+EcfZOX/UzXyC2BEQ3EJGA
AzAfYnquFmqbCXJqeaCa9vWAv3cJ/8QNBpEef2a5VSyAeCx5kex/SBOWLY6QqCqfT6xzW5nQMKV+
g4Zr5YB9YdpQwHggEifJMBLOxn/qZW4gL0LbfntcaKoHaHXSExAi4KB+0Xafe4trhXk1v977BGLt
5o/KKZ2R2CAASTBDar9muksw9c3Vo416/xrnLXtaOLshbFC6r1eyPK8c7qCS2bpWX/TXsf6oEKnM
g7PXE28JV8/RIrgPNTT/HCAfbb9PEHoR8oMjZfCX+ZDJgez7T8/Ez9BGNBlVlHF3ukpeXxbb+J0y
F8InYPVzfhJBrJR2BBp8mLeFuHQAC+GsBUXNm0r+Ls8QGMdCHuIrkX8oSAbSHFMwBDBYQv5ld1ND
yHMs4WWNJjgN2kRUEFfLTbf3TDbKx4P6j3e09YQLYWN4iVAsN3FYLuw2/jAmmhl4EB4kYQU1879w
xIc1ttmh6Wce780F9DKUJKjjysFPuYXT/ldUPxKjKsOm2kFtUzZh4yH1yNW2SJhwZC8vHYPD53jT
RB4UvEq8Og4pVbQyiVnTXaC7/SDOamvnDoQnsK2K6CSDYohvTlQbNejCV/Ggks7L0KRG6HkZ2nRQ
rOa2gkrJ8PsdIoAXBtBhAPVmxXyJa/IhwW33BlfG6TPAzgZ4Kb9eEUzRoNICEVpGnsx76kGj/dtG
q18TVec9zvDvzAP/A+g0wNtfCGfsyL4TKo01OepRFdVBd0LbZ6Tgmo3pZIoTsOiPrAXtNGrVX0ea
dz65qBbu18CAmUoeRX15C2vr032BBjM3EtUsee5CObxMMjGW2BPKHtDsRVAh7Xj5UOudmStjhiGd
cwQGv8zIz7N2dDdPCYM2cMUQo4M9KTBiV46b4xZ0f9Pec0o9yryvKjW9Qz2AoON0zjQwPMWf56Qc
XkLQu3NDaT18RMcD8UFs22DTYMXaASj745YHN4/t5TlXR7dBc/Q54JQDfjYW3beLcmNJq0FTox6u
GYbePe55WeXZnW4Af0sTTDPGzL1/7JDdDzuhBig0FvfHDrL9XHQAVGinyR/xih8xwB47SjcJ8ZX+
1lGuWzvo8LUh75dKWs+c38uxFp0cl8eOYzEpBZLCwACON4f12rGjjeq8EJ+d3yrAueOW2CVRUQro
7e/NM1qaTTlw75iPJ+0U50sM4CgeftuRHVGuGLeBWHQ68oIGmHH+PISIka+tUfUxpNxuhcvguPQX
DES050jE2zlixmcoIVkIfc1vM4XIt1KwmKVVzJp5Et2MYR9uqjtjBdBkoKCQU5a4C6MXj7X509Qw
dOU2EygLM40YL/8PC8ajkWbWk7YYwb7e0X9Wvro7Gu52W2b0oybytaMGrekgZAml/cVDuIJfa2TY
VSSR5CT7Q6fQ83jI3cyJi8dfvhjQP5aykWTMEgp2fxo5KMl8aOO481jaegrfaIv0uPBJTLtPvJdT
M9qOP0sEl02ULXrxIGbxWwqIW+QlHm/4pr872xHyNwv1lgfFL9uwL1G7yla7ddl3vELx38MVgWso
3DWau4o/1wS9JjTcdIEwz8RhmjSVS64lx3ESMvrNwne3TdQ8IQyTObuvJS2wMWIgnFhvTQ5WGudU
WQtYuGUcJ7fBN6SalbSGcAU40dZI9AjtAuLxgMqwrxl2YPCymH5GFuPnc0oba9ZKGxJuQzurRK8m
u2nshvApwPWtS3HHBUaxA2uMXxw9Klic/lhYi57kugZk8A/QW6vkh/BViiaGuZjcj3ls/PooBstA
quywcO5p1DmxM2ANgI/telSbYaeDedfbYXIqLzMuVRaG5kJBukOFmTvLfMYXxVvRHcJ6P9sgJb5T
vJHgF5ySIr4LwTdN7Rx3Ru4Uy8bHcJOibQ930JVvP558BgCxXYV6dFvysqh1hJz9sI8tgXumSe/S
zmC6opl23FP7M2CGQJ5AV6YSANUz+VTVK7xW0cxUk0OcsNsl6TOqmncVHz9erQW+Ya1/nbXz9xaw
4NxE2gYXxDSGOEBhOCA0I6m+vRG8irUnAmlHunSsMlE6lPsoDrOImX89Fe+9EhAMo/7tx+Gbt34X
fJptPwCBuk9FT0vBCcBkNgvZH0Ojxkk/qdMwCdBrCqYBuXGV0VfIfBS/Rrurxtlw2rceZTtXGjd+
i8s8ns6E7oX7lbg6SnwJk6vUHrgEwKi4bMv0ovxMw0WwJpZauZWLMXo8NyQ/8fAdIBwCZ2ABVjdD
1HZNvUoLSz8y8AuY25rritq1Y0HUz/PM/yxhjT9two8Ve7VwFP8cVMsalfaM0NTBbu51YAYxvSgZ
E/N06Q02aQ7o8quvnSNVINw70FNk62VinB2FbiRhS7u0EvVzmyUoDCMNznhxGiYuNoqMcb4q+QKW
0tjyK1wPXz2hq0zXBnUpgpcucIf5gHnFFEiuKwwLYaWd6YZTDCUaNHYaIzNEJidQxZDaH/lNQLxf
IaQbfhucAayWYvzDHnNMtmdLLhMPCIpzw6RQE1H/4IfPMctUL4hRRdq52ga+KjZUTwYtKU/wEGCo
O9U4pmSymoxI3PQPXc3DNH9s3ckvxIagmZ+VauhxY8HLA6j1wq3aU8NH8vAM6zPbEC1rMeWg0rCx
VB9SNnIyAkZ5b/un3U1QK1osDWt06+gFUbxHjnCIn7c3oFVBkaX5DMJyazkefGluGYW1m7tk/AfS
j8x3twxSEADLRGCkZMq1smr0JOShMZI/ZgAErtoyh2T727DvYgHcLIa031DlFjvYy3lUI8kvWjZU
xH3A7CxHqediFHiPvxJHzNWbo7TkpOVHRg1wENeUsDE2S4BHhP9ogKMwC+HmEjNFZ4GivLurgRUG
dElBSWqBawZ09SVi1gSfE6eqRcfmMnZVEb+YNnqv7GcVaxNWGT9Fcw0Sr7XXKNK/kAcLiJOdsGD9
BEj0IXTiYmd0ES6xrrojDenm1NIKbjGI2UudEJgWUcqmB4UQ8rq1nV4bWrd3S/fVtmmH/YNjtFdb
YDlK+BJvE2ui7/OiMUed753WqpS67AJOrSwGpumvW49OdyNURxRy83w4661uLJJyLGv1l+/cQp9z
wkZrRX3EedliV/CtfZOLrwcVG3Z7dya3eBhgNMvWyM4P6BcOucKoaqgxSXA7bHZU5hI5knNKcGSu
JcTTQSGJOaTnS8fz9mOtCpV18CQI3KaJ1ZNcrusnHqkVWeLkbZVNuWeIvSNGyJmBwgRwqIB0ZOA3
QwWSuRcDsu+lLjxysA2YIA5w+g954W38WcOqGgSfthmfmEc+DDkjaMouc/ZUQ6w1TJySgran3YXt
PX5UBg9yjZyEHMz+QYwudT6WCzpZGnuV4UPmg0tAFUG0Kh19XMyJ1eKs1nJg8L17XxWQdrF59wCB
Ml+sBURWk9UbZNJo0YGvxvXZHqRWEHHMBau81abtOL3JW4FmNRap4zf2T9oOw7yk4VPXEIdWUGDY
3rfAhOe1SCdFznFEJK7dVrdiCQ3ssTtp1oahv1qFGR8d/6ekClQbqERXlZ9CPDKXNruc+qmoh6yL
fDSBlNjU9Sv28WF2ua7AqMITWpY3mtlIyB9kC2POLG/gFEcPLTAcG+WSAgAPe7zHgH9H69jZMMNa
h8EPJwK2HBs3vKGi8a1pOLhNyKWeUJ6P4+VCe50GvCS1Iy76H2viCpHOdYYa+SH8lJsA+ftzWfOZ
THXy0TIGbTwhIsBD2oEbpIeNGp1z7raeuI1fn5SSFPOk8MlnRyrFa9/o+unFa/Yet6N7d8y0Iizy
Rlmp/M0nN4WjILSrTnUacW6LQpX2QZdK6wAysgIHXTpIgwEG5T0FBzoj75sUpgaPpbEEnMCwoy0J
136WwyMt3GzWjs3XZpWCXQk6vUzqxxKmRenCt85Z8bsdbK5PazMRpSXMKRi8PLkGkZDKc1IXqSjL
kSqNH0/tLKneIThw6nP6vsjk/q7j2QLU3c1N8pjSD7ulluAgj7w0P4f/P0cyA3UzjJPsWMDnWMJP
e8NKj8R/joBTiOIszW3h5a0M2DePTPGxzpx/FZsexNvPcMTum4Rfc6f+WI5+e3FE2hymbpqmgrMs
ZsjfM8ycyYgRVj0EtFGJZ9bHzm3Uk4Ik5D4gERj0cYin0FSFEhFU1If4aOMyDNVl8KSfkgPlPivH
Wvcb64vIkHKLP2KY0noRc78DTxDNJsOtqiGSGsuRvTXusNOtMXtEz8QB+81QSSNVkw205nlSj7Kd
rKM+HVm2ZyxBaMcM9kt/FKqWtixFdwj4yz7dvZwqHRcetq9ID5/rwSGuGxPgV6qV5Fystg7/HnxC
WpWmDPTIX8NBw87736JwDNOj2UNob54zxn5npNusMhSoV4YBgzzjQnVLaKdDSZNc9ew4JOWc4NgP
0Ft3F/FtwrEgHY6fWhAzHeQtTnufv3WeFi0fPi7AvPvhvulxdITzaqL2vUpBxYYgDPzswFBI3m0c
sPhpoJq8nJOdvELbpDJE1kYpR/AWXZQT8GrqEY84HPASRcEZBcpewv+DIy4V1k2LzgE0arQRmj7d
5cOzDaeq5mtHntzLOoNW5yvRz7WJxX2zpFfZ80AlDbN7SBoGYLMVXFkVheAApvxzje9rDm7wIedl
qRL6EgcupnZTb/vVMFMZbT/5A97efsovZ8E07sg/sG8TI5vKeIz61KVAeWfjdsemF2FFL39zPA5L
rUXU3d3JX2cU/Kt2zKOEmjNnkpY8yQwaFS7oXUNfgZW1ZbwSPFAYtyWrf4ZIvJ9m+/0Rx3GurKLU
W1OKRZioEVFQJ0ozhPKJ4LfwzYDr1qOC4oEbSP49odOADM/QvyW1HwMi8eC/lSzEsRhHawkpv+3t
3NL+Y6s+uRxM9Yamxl2DtqJcGnzgUyqTBnEgaJjD2o/cOsgMWvKu6MgiRqPrLAL1oPrdfgTtCqZw
KTcBdNL3xxaASvRlwr8Fcy+ByNHjxosB/frhsLO9rnjcWCx1EVL+1Cil/2XTPaLNiglDdSb8+H/t
GyTn1PSiUHKoejD0n4RmRb7imAl7tSUrcdqDnVg28efTiI6hspwewEfSfVfMJEWlCY5wfnd2Y8BS
2tpD/l6qTHdt/puFrIb98+NUlJRulPV/lru5yK4cgM5quM6YYl6nQ9/iGwZEaWDfq/3v3fzxfkbo
HWxZ/bk1WE2ssi8+afg4YfubiPOhR7cFA0eH7ZxgVNweV5RYe74yUXzpJAITA2RdBOxa4i+0xHfD
KH3j4bKkbm44dVXM47GckLGSa/B81gEfAVTEnX4ba0paCVYxwTRUS8jOl3XF6vnOrn43fuf2UGaX
9/1igbhQgqA7Dq8GEyHjQHu9pmzJh34vJgcWGH92IlnlEbcoMMBhijwEFRx+lxynhAEOgGW6yeoB
UgiZvQhLRauAZ/M47mP5KK9wOi42iuJtxnS337cwshm9xYrej8YOFs1WZKKjM4YC0ytHnk71WXeG
PgKbwpdf5WPGGJTxLI1iTWQnkRI+jVGspq4lo7IhZxaecUtw0j8MTSdectEyvt6ZWyJgpx4/bUc9
/IMTUEeX0hGEbcIR5gWh394dPab0TMsBY1j+gV3LGveMWdaOPwh8l9Cl7aN9hUrFdO6Hu/Hsoj+h
mCSX5jJrLfFhRHrpz1FjgFN855ETMMrq/QeTh1Uezr36z69d6XPOSCzfLQUFQVveB5jQO0LQea/3
lyUc+8MV1VwoWvz+ozRkJd30q1fXvzLYV3ssfZfCIzG0BHlHh2ZPdOjeSc9QlZYh9osDogf7k/s9
cUwWELVQAyY/gfgR+/sbAIYjV2E2ydMc9qugDDfvcTivtKH2HS6+NgIiFipC8jQXKXhUKDSbp+7I
u3LNi+6S1tyA6X9O66tAST8Nr/p/nPzPeMPHhvAsTWTef0WAE8D3QshbdiskjZtwX36k2Zd2aWMo
WHGeFjbB1IQTtVf75dzTopqkrORn5VlDsLeDo1YbJNCy4X5ywX2++2dgm5Nwzte/Csg+vbWvso95
75JECIFL1mtMkxBRmUToWkPf91iIrGcnE8aKYyFv74A89deU3nSHYYlvpIFNIIz9Pah0NogAtyPG
MmaVaGkje4zfIWHlyqJLebOyue1FsmA1xD0tuhguf7hMF0/g1bZGZM6d0qAkcWaXfC7z17fAON6L
CljCY0qTGLzEGKI63dIjxhfvGYwqeaqqp2XTtwpueaiE4GmGENSdZXu6FkKsEMOYtARzr0QSF51a
44cq8Pufjz3opsb+4F3n/didGcDXf0o7zW1Zg2MKla90ZK7qIb4KOaQ5duhsOrf3gHtKFb3rVZ4e
c4o6kQZ1+jB8Q0RGCZ++/HCUIUd/hjUDoMjbbfPt4pYPl2MIZ7JJJs5oRVgGL7LbxW4Lfvk9m+EF
boKXm82EGjYJHzCr1R4hmiNv2iICj0+E1Uwe8Ga2hgcBvtwc+DEfvDTYCWONfQm6onRhEg0pmGoL
JYQyEgTfnR2tYxqZBvhU1jzVFmW/jdxAqtOMvdouHucHU+6bhvl8MNIHtZzFoSWFSvvEGbXX6cb0
MVjfzE/mP4Kqx6fSnt/Y6h7VYKOlMt9f7wL8GRC/3KsD8xP0j2QPgZrxl8504v3tBTU6/WZuNwwZ
/BX2wvVpSHRQhew5+3JdcKilo/a62f1mWp2ix1Qhh9T36JDcH2djv2Z4twR9gh4Yo/GN/sAUUrej
ewtKgFN1TCLEiDuureOpaEmJUa6ZVz7ZBW4jhCaxPk7BdQu5ydcoJYWxPGgyKCKUZauop8iwUqPT
59Bjxm7dxrrLn/uW6+QUmoQ27Ovx0+l9C55oDvyt0EPPpuzdguCRlmpL/acSv0FrzMFL3WjrvkB3
Ed+xBe1XTfj7aGuy+Q5ziqdaAvPaCzYcllV7D4XuPItRf+y+JlSJUhvfD884sQS9T+f5xSLUFSYC
mKbLjJnyvp18Bb0RaXA9GscPxYjJ1w0QqLkvhX1J2tYlHN/2J8JByWIw6hQe5gUlHV3uPB43fQDB
T+fSZnsHgM7CWgWrg55sNBGe760hAzTHZVf+XnACltXwoxzli66uXo1tM+XPESuCqxzJaq6sp4Lw
AnG+R21lUPJmFTbWJTqD05Le09YImfwWuO+JzvEVNqH1oEU3iQGdVwKe3rvSAlZy1MoPI/1lH2J4
rQy/w5vANVmrrj89tcdBG1QLl18/KnksfbVBEhYgrndckpM+/Wf6Oyfy2wMWu9+8PvKOFC16AEvN
SS91piymcuCCsR5ihEG/UKLZ1iwkOoQNufdohaoWngqEWVEnn/AOn7HVZZY8izqdQuZaqfc3h57n
/Odma5yMw3ydCL++SlYiay8+Lk7hDZFF7m2KLPUUYoCxyxcWkmdlC/qU7VWnrC4jNitWVoYLQzwK
Vwt5etdAGY+WUHrtZ3kJTpBgeX4kYUknG3fM6govxNK0jvrDKDEWW3+zhGbr6NzS7a+Fcx8ml+32
3OhhgBWCYV/YWc18Kl9AZIbfUoMJIzJLjRgLHO7xMDecE/IBpQomC6n21cQztgjGxasinnzMXl+0
moUbAOHRpGy5c8XYoD5z/TYmKRneXL4N1hMTPmzmxbZnNp4dRHzjAbHqYDejBqWUwCn4uiYVX+o2
Q5SxNtzjACmIehUxmZivuaLz41xgXMP3K43LzudddNj5/xEGtuimLk74mzmUEQJE9xbsRgrjwHQD
t3KiJYm8K8yy81intqgPOD4bX0GYHa0pWt1cTaMxOQ4M54NuJ/PEEoL2ylpjfBePR3Kxt7k70lwR
2hNhJvlOzKM61/en2T9vRXqp89o+qMr0GFOkGxTQPfIiOCuiDi4RF7jJCbijQQ5pXnQIOn6C92d4
s4/pNMjYUmMPS1tHBt1AuS+8M2t44RnbBQ2CTGHxG5SL81XpUFqy8lRd6FYcr7rSOWYjOQFkk/My
Wtz/QBdK7a/g7VlAyBYR6f6pdyygna7XVRZqYTB+aOuDiku3uPco5v4RXITrSXHsYn3FDHJasg7z
c7+nPX+AV09aaxXYb54ZKlP3ExBPYD0A2WXFaAyooJJND+zDIX/9LIC32n4dXE0Iy+jQcKleXlQ7
OoYU44RNeYacmgTulw4TwOhhGcnKReDUWKMRMPknFkCvfF91AC/y5eUivgqzjZRsHsouMBaUaByJ
Se/uXjrQu72L7yibh3O+om4RYSPNQNjvukOmlEAEH0QAIcLjHZul9g0/HhQL6rN5PcOJquYSDaq8
WuJERrWtWw2PNgKqdHjuhvmnl+GNm7Go3yssm93rLECw9fLTgxmfHJPsxkxMTw+t6UgNIQC7jOi1
c+YcDc+ESXAPEop1kXaDioa4vwn5OGqUr8v1hRnMV3wLTU7A/lURw5xYIdgbw9nviMMp8RNWrOPL
gWLuBBPR4mm9sH/iy0YsD2ZNBrUseDpQ2OwUaHRnjMJY4pfj9e7qJllwnGEViWeHEkJMrYc6MuJZ
JMJDxmZm3/9LMWlE6T4yeaHcL5XlK9qJCyDTKqNOSSqLlIDgEkLYC8DyIciS0jyZ8TDU7qea0hux
yBO5HKY9U4EF/Rb/uTW1KD3m21HuSP7U0hyqkj+LM0JdYPDXMuGtr7dk61gtWQxdTcM+Ocbdl83q
DEgpO4OAi1U4Dmi30rmjJ6A30S91jAVAWurwDHuZm9KoxRzeWrNW6lUXJPg8/FJ7Z5Dwe+DCIuI/
QzwjJSvX73os8k5qpALPMLdT6yDrpezXpG5i+uOA7XRrqg7HxsQeYMYbgOdz2OaqVNBfrATrRvZB
vq4RtC/8W6OZvRLneA9z2baBqUEgnbt25wVPRdZPbgILGS5kBE7iWkxlXGIy8feEixBx+awnO+2A
0u9ggz62JigRNscq/HpH3tB6Me3Qp30HxDlk44OfLnyfuXzRDUJpYK79VKFsCb4FiWbt5dSdw9rw
DzC/bAcDFsi0sqgetYcQZvggx2XOweMkmOXBDFICgmAyK+Zo4fUgjA8sJuULdLhBB7ugoDI47yx/
dogViNOE1Gps1ZjmEEoyC3UsaTE1TiDc4UW3L3FSlEUmGWKa4nEJz8OQE//7qKmCkBcxgnLd3TPJ
Iv0o4hP9OPh+jOvHPdKhRlGrH8bObg0UNppPKGfyXiRdFdHZqIsR0GSPoW14DDGAmV6h6QPJ61Hz
AKNmASBDoD5QMIjPswqV6D3AlpTDtTTlk6wqFjmN5pmcoW4ljboSionc5hnBAH1AHcqGK5OMN/Cc
CKcyvbHUek0LmI+xUKbMaLW0HNAIVGJmgrERvC66DN6BJbpkQ5oDinOr2XYCfekzCmP7QHwJyZb8
/7hkd7XB8N7VgToY3RurQid818RQKOmYcwMLTGBk9c6WL0oQS+hF/BPFCST/9o3sX8AgD2G1+f3p
DE+r65j5QCA5IRY80iyFQebMbGF22shTWwGcRDf7owZC7xp1ge+A1Yo4gL5vvMOoRH9tj6LY92/v
yJvoD38d8sLUahT/RknPfHMj8flyTJWvCYz5qqyjUDAF07S74hiOjCx6Z5UY6e3ZcmswjGiVmWCS
7V5npv2Dvbhdn+0yN9mCXw/EFoign2RkevA1tRXeDtV8QU2RgNOY6J1u25ApOqBwcWfiMS8nt3pj
9kJ/V6TCmpxtqAKv1AI444vjWVkk0sDOIVbLSVgSY2+jgXEQp7GuLPUHjxGjMQ0nUMuodwrHSy/M
/HpQ0vM6wNFJZPkYRXaS/ZYQQu3p6k4dHleOFPGBNJRV8OxIC3fyqyYwZul1WPtKr3QdkQ3WdBqb
ciydVYCMN5DLEEnutulya3CXV/nDSphDEE3knHgk2ikUyS4sWHK16PxRR5U/Vu4FDDX3xCZWDOuM
vIr4iKK5T8OPgvWDf/Pw22/py/Rg/DujMaiPO2KeZzk/73wEC+MPCzZ6zYc0+7S38Un6meHe2Zci
HrzB+PMRZ9aC3IHK9TBBRXkM+S9QF5yisf3KFtlDbZgl7+qGsMD+2ytYwKoBJjy/WL2wJhyaDFHO
au+7muqYmwQBSEJk4pkRyD4MDTV5EoWRNcsWExKpjuWpxSwxLbSkombUnMcC6hgiBSDs45ERd/sk
9ZPAMt2W4vhMayLLE2H3CbJl+nY7KK5EYPX9GVtdOOKq9aWLb2Ka4NGXCEZtMYAE6Ry2fXBu3v/l
X43S4ypGKJ/TmDB55x5oQAX15KEYdzqAIZCyGGoHmlKkcjqTz8s3wv50r+v5zK2Q6YZ03zn5kOyU
TK8747T0YvSCne5e5+eQHR7ijyqulpgwQk3FF6C098MQaz2Nltz1aRJ0F9M3Gbnfj9OXjzxx7rL5
pmwpT6Eqmb6kIS+LV+VJ8+PGPVBOwRaHIx9ewSi69xfVWuwTuwRJ5waFGv3OAIGPqsZuuTcSDWlq
skByZCUXa2Yf9mQTT4OqV02reA1aC212O8l4B4LojlkuAfRF6ShPn1AxruJb+XblZs75h/kuoNVa
OgqjRfPKql4w+9HuG4orUJCjYWpwRy3Y3kO1x73qWFWUgrmJJ7mI3plyT330RvX+m9x2I15oSX5L
WaBifU24DsnM0J6GxfacpNeKopsRDgOPWhhTm19OK+qE4y2vcI0ppZALwYIsW0aalKspggJS7yEO
l4zRhs/fyin4GoIDvcjt1KyrmZvD6PUZHM93cAJjjTL/oFeZSDHDjMM2uGcB2XRw/UI/AR4oZPWA
vq7RyHr7XjpxOqrDi+lENdYINeMnt0WSYyjugYxQ7H2uy7o4ZBEDTNiomRNmAoqZQdEqUQTy+SGe
2n/geu2nwz3GDD2IKbdeOPQkbAz/xHHn0plyPlUxq+taglIdZjOzdux58rSij27bu2TPs4TPSh9+
nBEYHKPb2R2Ci7AVGEw1LMxdiT1ieNprq2pN0B/iiYVt40aYh1xHd5i5yHSMgeNjaINZ6jQtY8Ad
Zmada6r7YE5tj7Evq7SgG+n1EupnatYq1s6z1E2rXzwhl4QukQVTtcKtiFAIZRz76ebnco7zihhm
XFOZxumJM7T4iZ0A3FRipF/cI7hNkR8y8XBp/C1TBd3iiBk+rx0qIC+IzH6DD12Mim/5uCko16GC
LpU8OE0h6nJJF0HzE8lxSusU6w6xXMY9U+vjAUIdEjm/mK137f5YY4Gjo186rFIDNz3jNWwKmeDZ
VwnnRIqnJ3GceUE2HgibWO55mf34cjQNCHbwqYjM7YfGePnRNL2YwRKD05UPANfGb03BZqwRZInP
K+u3lFvvgv4hBKRERwmW8VDR7aACOTDyOiYSd2vn2/yMfPwY4pthKAHg/sKdGBg+Ap8tdTs+bqLw
CFfcYVYVV9cBE40Mu2k7i+d4dAGL4FVIZJ3f9HLgIh8AYWykTnUruQY9CYI9dq5uHFr1QH//dLAs
RxkNfWi15b4SwdNPETuGZk+S23eCgNUwT5zCrNnncU0YTrGnKQayN7mlBBbs5o4h/whDCfz/rJg8
dvFcKc+RuvMCR2QuBpPYy7mzDhDxQtvkxhSTx2UcSdYXbixDNzyBRTnXPx5gAA4vBDrclr1915oY
D7j7CBBEuxmOEPTD1r6eqvAGYtQJ7Br/wFBb4TtRYAyzMApJoOAX4ckcjxP6TOTSubXlOazySUCb
WdgL+nLFUBp9E/Uru5iBZcJ9tRr13rOlUhkBTFcWy+Pt78P0VagqasQ5ZCIwnSyoobXmwCjIZG+p
vV+a/XSDO6P5umYKy7THh/T2F5M0gsGCelVCFxxg8tweUv/kjDy66tD3oy8dWhGpgl6Ij8mgwvtc
FjZqwtjIFAOPg/04dkiQmT2/ExokZQDwSZU7T4UsQS3DOt/mw60sgk8J1dNloiVWyhgwaVvkh0Ky
NP6dMZLNByhnA8qihsDJsetQHXu6bzN0dnpmhSjyjkJYaGVZUsWiz/7nAksvQ7Ylv12y61rse1Kd
1iaR79oDILxhK2h/9Jj63KtIl4RXE85d8k+xsNSMirdRRDjzGHaGaZ7Pvo67PAlogF+rCwGjIrBR
n/DP0/c2Kha0p9rDCQrmkgjOJNmu3183ABwyBCGhytomhHvh899mnD1D3ItALHlb+QHu2xPkpDly
JwFE416FxudmMbMZoHfAb8Lo3w4cnFL/ETGiLiHukoyGnRd36NVZOnA60zhkMhEPl/xtOY5XpAMs
YEkzJnZiAawMGYCLCnOhFGWrEZ1SdhADyoDv4sr7pYkn/TrZlBnpvmDQtSriQhNATU89hZjunaDO
H52M3mRSFyrz67sQpYXQZ/7mACErhqFRWYm5fRuP9jH2ybNMfXEPyuN9czMSbYkW+wrMNtt0dl07
RAOgAK4MtMUBhSeAV8lwdI0/4MEg4Vu4uGUffT098I3AcWPAZYFmzkYzO/k/hfrB7yTWOoTnHUjD
ZcGGbyWx67Ro4o7qltQrRNwcDJGwAUeLtY2Kq7YUiyid2Pxbl8W0iX9nkThv/sPU0/ziakTZvdpA
AhOymTxsOmMXCW+OjnxPzwS+eL6ZaJfwV3suQ4Y/PDWyF2Qd+lBr0L3gOgzrfTuLFhKnekuQ+J+q
anUzb5JXrH3seXglHMH12PD+5jQaVnnBVTH+j933l4OjoMdAjSv5v361YA==
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

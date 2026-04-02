// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Wed Mar 25 19:12:55 2026
// Host        : soyorin running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top o_buf -prefix
//               o_buf_ bbuf_sim_netlist.v
// Design      : bbuf
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z100ffg900-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bbuf,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module o_buf
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
  o_buf_blk_mem_gen_v8_4_8 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 30896)
`pragma protect data_block
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
dko=
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

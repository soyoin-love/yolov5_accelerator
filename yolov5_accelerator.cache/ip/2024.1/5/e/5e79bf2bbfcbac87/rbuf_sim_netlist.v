// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Wed Apr  8 22:03:58 2026
// Host        : soyorin running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ rbuf_sim_netlist.v
// Design      : rbuf
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z100ffg900-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "rbuf,blk_mem_gen_v8_4_8,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_8,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_8 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 30096)
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

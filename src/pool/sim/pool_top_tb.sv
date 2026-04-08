`timescale 1ns / 1ps

module pool_top_tb;
    localparam BANK_NUM = 8;
    localparam TK_IN    = 8;
    localparam N        = 8;

    reg clk;
    reg rst_n;
    reg start;

    reg  [15:0] cfg_w_in;
    reg  [15:0] cfg_h_in;
    reg  [15:0] cfg_w_out;
    reg  [15:0] cfg_h_out;
    reg  [15:0] cfg_ch_groups;
    reg         cfg_pad_zero;

    reg                         cbuf_can_read;
    wire [7:0]                  cbuf_rd_en;
    wire [15:0]                 cbuf_rd_row;
    wire [15:0]                 cbuf_rd_col_align;
    wire [15:0]                 cbuf_rd_ch_grp;
    wire                        cbuf_rd_row_free;
    wire [3:0]                  cbuf_rd_free_num;
    reg                         cbuf_rd_dat_vld;
    reg  [BANK_NUM*TK_IN*N-1:0] cbuf_rd_dat;

    reg                         obuf_can_write;
    wire                        obuf_wr_vld;
    wire [2*BANK_NUM-1:0]       obuf_wr_mask;
    wire [2*BANK_NUM*64-1:0]    obuf_wr_dat;
    wire                        pool_done;

    integer errors;
    integer out_count;
    integer p;
    integer ch;

    reg                         req_vld_pipe [0:3];
    reg signed [15:0]           req_row_pipe [0:3];
    reg signed [15:0]           req_col_pipe [0:3];
    reg  [7:0]                  req_en_pipe  [0:3];
    integer pi;

    pool_top #(
        .BANK_NUM(BANK_NUM),
        .TK_IN(TK_IN),
        .N(N)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .cfg_w_in(cfg_w_in),
        .cfg_h_in(cfg_h_in),
        .cfg_w_out(cfg_w_out),
        .cfg_h_out(cfg_h_out),
        .cfg_ch_groups(cfg_ch_groups),
        .cfg_pad_zero(cfg_pad_zero),
        .cbuf_can_read(cbuf_can_read),
        .cbuf_rd_en(cbuf_rd_en),
        .cbuf_rd_row(cbuf_rd_row),
        .cbuf_rd_col_align(cbuf_rd_col_align),
        .cbuf_rd_ch_grp(cbuf_rd_ch_grp),
        .cbuf_rd_row_free(cbuf_rd_row_free),
        .cbuf_rd_free_num(cbuf_rd_free_num),
        .cbuf_rd_dat_vld(cbuf_rd_dat_vld),
        .cbuf_rd_dat(cbuf_rd_dat),
        .obuf_can_write(obuf_can_write),
        .obuf_wr_vld(obuf_wr_vld),
        .obuf_wr_mask(obuf_wr_mask),
        .obuf_wr_dat(obuf_wr_dat),
        .pool_done(pool_done)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    function automatic signed [7:0] feature_value;
        input integer row;
        input integer col;
        input integer channel;
        integer value;
        begin
            value = row * 16 + col * 2 + channel - 64;
            feature_value = value[7:0];
        end
    endfunction

    function automatic [BANK_NUM*TK_IN*N-1:0] make_cbuf_data;
        input signed [15:0] row;
        input signed [15:0] col_base;
        input [7:0]         rd_mask;
        integer mp;
        integer mc;
        reg signed [7:0] value;
        begin
            make_cbuf_data = {(BANK_NUM*TK_IN*N){1'b0}};
            for (mp = 0; mp < 8; mp = mp + 1) begin
                for (mc = 0; mc < 8; mc = mc + 1) begin
                    if (rd_mask[mp]) begin
                        value = feature_value(row, col_base + mp, mc);
                    end else begin
                        value = -8'sd128;
                    end
                    make_cbuf_data[(mp*8+mc)*8 +: 8] = value;
                end
            end
        end
    endfunction

    function automatic signed [7:0] expected_value;
        input integer out_row;
        input integer out_col;
        input integer channel;
        input bit     pad_zero;
        integer ky;
        integer kx;
        integer in_row;
        integer in_col;
        reg signed [7:0] cur;
        begin
            expected_value = -8'sd128;
            for (ky = 0; ky < 5; ky = ky + 1) begin
                for (kx = 0; kx < 5; kx = kx + 1) begin
                    in_row = out_row + ky - 2;
                    in_col = out_col + kx - 2;
                    if ((in_row >= 0) && (in_row < cfg_h_in) &&
                        (in_col >= 0) && (in_col < cfg_w_in)) begin
                        cur = feature_value(in_row, in_col, channel);
                        if (cur > expected_value) expected_value = cur;
                    end else if (pad_zero) begin
                        if (8'sd0 > expected_value) expected_value = 8'sd0;
                    end
                end
            end
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cbuf_rd_dat_vld <= 1'b0;
            cbuf_rd_dat     <= {(BANK_NUM*TK_IN*N){1'b0}};
            for (pi = 0; pi < 4; pi = pi + 1) begin
                req_vld_pipe[pi] <= 1'b0;
                req_row_pipe[pi] <= 16'sd0;
                req_col_pipe[pi] <= 16'sd0;
                req_en_pipe[pi]  <= 8'd0;
            end
        end else begin
            req_vld_pipe[0] <= |cbuf_rd_en;
            req_row_pipe[0] <= $signed(cbuf_rd_row);
            req_col_pipe[0] <= $signed(cbuf_rd_col_align);
            req_en_pipe[0]  <= cbuf_rd_en;
            for (pi = 1; pi < 4; pi = pi + 1) begin
                req_vld_pipe[pi] <= req_vld_pipe[pi-1];
                req_row_pipe[pi] <= req_row_pipe[pi-1];
                req_col_pipe[pi] <= req_col_pipe[pi-1];
                req_en_pipe[pi]  <= req_en_pipe[pi-1];
            end
            cbuf_rd_dat_vld <= req_vld_pipe[3];
            cbuf_rd_dat     <= make_cbuf_data(req_row_pipe[3], req_col_pipe[3], req_en_pipe[3]);
        end
    end

    always @(posedge clk) begin
        if (rst_n && obuf_wr_vld) begin
            if (obuf_wr_mask !== 16'h003f) begin
                $display("ERROR: unexpected obuf mask %h at row %0d", obuf_wr_mask, out_count);
                errors = errors + 1;
            end

            for (p = 0; p < 6; p = p + 1) begin
                for (ch = 0; ch < 8; ch = ch + 1) begin
                    if ($signed(obuf_wr_dat[p*64 + ch*8 +: 8]) !==
                        expected_value(out_count, p, ch, cfg_pad_zero)) begin
                        $display("ERROR: row=%0d col=%0d ch=%0d got=%0d exp=%0d",
                                 out_count, p, ch,
                                 $signed(obuf_wr_dat[p*64 + ch*8 +: 8]),
                                 expected_value(out_count, p, ch, cfg_pad_zero));
                        errors = errors + 1;
                    end
                end
            end
            out_count = out_count + 1;
        end
    end

    task automatic run_case;
        input bit pad_zero;
        begin
            cfg_pad_zero = pad_zero;
            out_count = 0;
            errors = 0;

            @(posedge clk);
            start = 1'b1;
            @(posedge clk);
            start = 1'b0;

            wait (pool_done);
            repeat (4) @(posedge clk);

            if (out_count != 6) begin
                $display("ERROR: expected 6 output blocks, got %0d", out_count);
                errors = errors + 1;
            end

            if (errors != 0) begin
                $fatal(1, "pool_top_tb failed, pad_zero=%0d errors=%0d", pad_zero, errors);
            end
            $display("PASS: pool_top_tb pad_zero=%0d", pad_zero);
        end
    endtask

    initial begin
        rst_n = 1'b0;
        start = 1'b0;
        cfg_w_in = 16'd6;
        cfg_h_in = 16'd6;
        cfg_w_out = 16'd6;
        cfg_h_out = 16'd6;
        cfg_ch_groups = 16'd1;
        cfg_pad_zero = 1'b0;
        cbuf_can_read = 1'b1;
        obuf_can_write = 1'b1;
        errors = 0;
        out_count = 0;

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        run_case(1'b0);
        run_case(1'b1);

        $display("PASS: pool_top_tb all cases");
        $finish;
    end

endmodule

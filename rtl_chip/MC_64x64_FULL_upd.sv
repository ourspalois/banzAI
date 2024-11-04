module MC_64x64_FULL_upd (
    input logic [63:0] CBL,
    input logic [63:0] CBLEN,
    input logic [63:0] CSL,
    input logic [63:0] DIN,
    input logic [63:0] DINb,

    input logic [31:0] CWLE,
    input logic [31:0] CWLO,

    output logic [63:0] DOUT
);
    
    logic [63:0] CWL ;
    genvar h ; 
    generate
        for(h = 0 ; h < 32 ; h = h+1) begin
            assign CWL[h*2 +:2] = {CWLE[h],CWLO[h]} ;
        end
    endgenerate

    logic [63:0] dout_0 ; 
    // verilator lint_off UNOPTFLAT
    logic [63:0] DOUT_cumulative [63:0] ;
    line_matrix line_matrix_inst0 (
        .CWL(CWL[0]),
        .CBLEN(CBLEN),
        .CBL(CBL),
        .CSL(CSL),
        .DIN(DIN),
        .DINb(DINb),
        .dout(dout_0)
    );
    assign DOUT_cumulative[0] = dout_0 ;

    function logic [63:0] elementwise_or_with_x_check(input logic [63:0] a, input logic [63:0] b);
        logic [63:0] result;
        for (int i = 0; i < 64; i++) begin
            if (a[i] === 1'bx || a[i] === 1'bz) begin
                result[i] = b[i];
            end else if (b[i] === 1'bx || b[i] === 1'bz) begin
                result[i] = a[i];
            end else begin
                result[i] = a[i] | b[i];
            end
        end
        return result;
    endfunction

    genvar j ; 
    generate
        for (j = 1;j <= 63; j= j+1 ) begin
            logic [63:0] dout ;
            line_matrix line_matrix_inst (
                .CWL(CWL[j]),
                .CBLEN(CBLEN),
                .CBL(CBL),
                .CSL(CSL),
                .DIN(DIN),
                .DINb(DINb),
                .dout(dout)
            );
            assign DOUT_cumulative[j] = elementwise_or_with_x_check(DOUT_cumulative[j-1], dout);
        end
    endgenerate 

    function logic [63:0] clamp_to_zero(input logic [63:0] a);
        logic [63:0] result;
        for (int i = 0; i < 64; i++) begin
            if (a[i] === 1'bx || a[i] === 1'bz) begin
                result[i] = 1'b0;
            end else begin
                result[i] = a[i];
            end
        end
        return result;
    endfunction

    assign DOUT = clamp_to_zero(DOUT_cumulative[63]) ;
    
endmodule

module line_matrix (
    input logic CWL,
    input logic [63:0] CBLEN,
    input logic [63:0] CBL,
    input logic [63:0] CSL,
    input logic [63:0] DIN,
    input logic [63:0] DINb,
    output logic [63:0] dout // normally we would use a mux not a tristate buffer 
);
    genvar i ; 
    generate
        for (i = 0 ; i<=63 ; i=i+1) begin
            cell_matrix cell_matrix_inst (
                .CWL(CWL),
                .CBLEN(CBLEN[i]),
                .CBL(CBL[i]),
                .CSL(CSL[i]),
                .DIN(DIN[i]),
                .DINb(DINb[i]),
                .dout(dout[i])
            );
        end
    endgenerate

endmodule

module cell_matrix (
    input logic CWL,
    input logic CBLEN,
    input logic CBL,
    input logic CSL,
    input logic DIN,
    input logic DINb,
    output logic dout
);
    logic [1:0] memristors ; 
    logic rd_en ; 
    logic [1:0] command;
    assign command = {CBL, CSL};
    always_latch begin
        if (CWL) begin
            if(CBLEN) begin
                case (command)
                    2'b00: begin
                        memristors[1] = 1'b0;
                    end
                    2'b01: begin
                        memristors[0] = 1'b1;
                    end
                    2'b10: begin
                        memristors[0] = 1'b0;
                    end
                    2'b11: begin
                        memristors[1] = 1'b1;
                    end
                endcase
                rd_en = 1'b0;
            end else begin 
                if ((CSL == 1'b0) && (rd_en)) begin 
                    if(memristors[0] == memristors[1]) begin 
                        dout = 'z; // better than x for trsitate buffer
                        rd_en = 1'b0;
                    end else begin 
                        dout = ~((memristors[0] && DIN) || (memristors[1] && DINb));
                        rd_en = 1'b0;
                    end
                end else begin 
                    if(CSL) begin 
                        rd_en = 1'b1;
                    end
                end 
            end
        end else begin 
            dout = 'z;
        end
    end

endmodule

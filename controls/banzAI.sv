// controls for the big bayesian machine 

module banzAI #(
  )(
    input logic clk,
    input logic rst_n,
    AXI_LITE.Slave axi_port
  ) ;

  logic [31:0] registers [0:3]; // 16 registers of 32 bits
  // 0 : 0: reset | 1: set
  // 1 : pulse lenght

  logic read_mem, read_regs ;
  logic [10:0] read_addr ;// western reading style, likelihood arrays are continious in memory
  logic [31:0] read_data ;
  logic [15:0] read_counter ;
  logic read_pulse_counter ;
  logic [7:0]  read_output_count ; 

  logic write_mem, write_regs ;
  logic [10:0] write_addr ;// western reading style, likelihood arrays are continious in memory
  logic [31:0] write_data ;
  logic [15:0] write_counter, write_pulse_counter ;

  logic ready ; 
  assign ready = ~(read_mem || read_regs || write_mem || write_regs) ;

  // part 1 AXI interface and control registers
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      registers[0] <= 32'h0;
      registers[1] <= 32'h1;
      registers[2] <= 32'h0;
      registers[3] <= 32'h0;
      axi_port.r_valid <= 1'b0;
      axi_port.b_valid <= 1'b0;
      axi_port.ar_ready <= 1'b0;
      axi_port.aw_ready <= 1'b0;
      axi_port.w_ready <= 1'b0;
      read_mem <= 1'b0;
      read_regs <= 1'b0;
      read_data <= 32'b0;
      read_counter <= 16'b0;
      read_output_count <= 8'b0;
      read_pulse_counter <= 1'b0;
      write_mem <= 1'b0;
      write_regs <= 1'b0;
      write_counter <= 16'b0;
      write_pulse_counter <= 16'b0;
    end
    else begin
      if(axi_port.ar_valid && ready) begin
        if(axi_port.ar_addr < 31'h2000) begin
          read_mem <= 1'b1;
        end else begin
          read_regs <= 1'b1;
        end 
        axi_port.ar_ready <= 1'b1;
        read_addr <= axi_port.ar_addr[2+:11];
      end else begin
        axi_port.ar_ready <= 1'b0;
      end

      if(read_regs && axi_port.r_ready) begin
        axi_port.r_data <= registers[read_addr[3+:2]];
        axi_port.r_valid <= 1'b1;
        read_regs <= 1'b0;
      end else if(read_mem && read_counter>= 4) begin
        axi_port.r_data <= read_data;
        axi_port.r_valid <= 1'b1;
        read_mem <= 1'b0;
        read_counter <= 16'b0;
      end else begin
        axi_port.r_valid <= 1'b0;
      end


      if(axi_port.aw_valid && axi_port.w_valid && ready) begin
        if(axi_port.aw_addr < 31'h2000) begin
          write_mem <= 1'b1;
        end else begin
          write_regs <= 1'b1;
        end
        axi_port.aw_ready <= 1'b1;
        axi_port.w_ready <= 1'b1;
        write_addr <= axi_port.aw_addr[2+:11];
        write_data <= axi_port.w_data;
      end else begin
        axi_port.aw_ready <= 1'b0;
        axi_port.w_ready <= 1'b0;
      end

      if(write_regs && axi_port.b_ready) begin
        registers[write_addr[3:+2]] <= write_data;
        axi_port.b_resp <= 0;
        axi_port.b_valid <= 1'b1;
        write_regs <= 1'b0;
      end else if(write_mem && write_counter == 32) begin
        axi_port.b_resp <= 0;
        axi_port.b_valid <= 1'b1;
        write_mem <= 1'b0;
        write_counter <= 16'b0;
      end else begin
        axi_port.b_valid <= 1'b0;
      end

    end
  end

  // part 2 FSM
  // TODO: manage adresses 
  
  typedef enum int {
    IDLE, READ_SETUP, READ_PRECHARGE, READ_PULSE, READ_OFF, READ_OUT, READ_ZERO,
    WRITE_ADDR, WRITE_PECHARGE, WRITE_PULSE, WRITE_CUTOFF
  } state_t;
  state_t state;

  logic [7:0] read_count ;

  logic CBL, CBLEN, CSL, CWL, inference, load_seed, read_1, read_8, load_mem, read_out, stoch_log;
  logic [7:0] adr_full_col, adr_full_row;
  logic [7:0] seeds;
  logic [3:0] bit_out;

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      state <= IDLE;
    end else begin
      case (state)
        IDLE: begin
          if(read_mem && !(read_counter == 4)) begin
            state <= READ_SETUP;
          end else if (write_mem && !(write_counter==32)) begin
            state <= WRITE_ADDR;
          end
        end
        READ_SETUP: begin
          state <= READ_PRECHARGE;
        end
        READ_PRECHARGE: begin
          state <= READ_PULSE;
        end
        READ_PULSE: begin
          if (read_pulse_counter == 1) begin
            state <= READ_OFF;
            read_pulse_counter <= 1'b0;
          end else begin
            read_pulse_counter <= 1'b1;
          end
        end
        READ_OFF: begin
          state <= READ_OUT;
        end
        READ_OUT: begin
          if(read_output_count == 11) begin
            read_output_count <= 8'b0;
            read_counter <= read_counter + 1;
            state <= READ_ZERO;
          end else if(read_output_count > 2) begin
            read_data <= (read_data<<1) | 1'(bit_out[read_addr[10:9]]);
            read_output_count <= read_output_count + 1;
          end else begin
            read_output_count <= read_output_count + 1;
          end
        end
        READ_ZERO: begin
          state <= IDLE;
        end
      
        WRITE_ADDR: begin
          state <= WRITE_PECHARGE;
        end
        WRITE_PECHARGE: begin
          state <= WRITE_PULSE;
        end
        WRITE_PULSE: begin
          if(write_pulse_counter >= registers[1]) begin
            state <= WRITE_CUTOFF;
            write_pulse_counter <= 16'b0;
          end else begin
            write_pulse_counter <= write_pulse_counter + 1;
          end
        end
        WRITE_CUTOFF: begin
          if(write_counter == 31) begin
            state <= IDLE;
          end else begin
            state <= WRITE_ADDR;
          end
          write_counter <= write_counter + 1;
        end
        default: state <= IDLE;
      endcase
    end
  end

  always_comb begin
    case(state) 
      IDLE: begin
        CBL <= 1'b0;
        CBLEN <= 1'b0;
        CSL <= 1'b0;
        CWL <= 1'b0;
        inference <= 1'b0;
        load_seed <= 1'b0;
        read_1 <= 1'b0;
        read_8 <= 1'b0;
        load_mem <= 1'b0;
        read_out <= 1'b0;
        stoch_log <= 1'b0;
        adr_full_col <= 8'b0;
        adr_full_row <= 8'b0;
        seeds <= 8'b0;
      end
      READ_SETUP: begin
        adr_full_col <= {read_addr[8:7], 3'b0, read_addr[0], ~read_counter[1:0]}; 
        adr_full_row <= {read_addr[10:9], read_addr[6:1]};
        stoch_log <= 1'b1;
        read_8 <= 1'b1;
        read_out <= 1'b0;
      end
      READ_PRECHARGE: begin
        CSL <= 1'b1;
        CWL <= 1'b1;
      end
      READ_PULSE: begin
        CSL <= 1'b0;
      end
      READ_OFF: begin
        CWL <= 1'b0;
        inference <= 1'b1;
      end
      READ_OUT: begin
        read_out <= 1'b1;
      end
      READ_ZERO: begin
        read_8 <= 1'b0;
        load_mem <= 1'b1;
        stoch_log <= 1'b0;
      end

      WRITE_ADDR: begin
        adr_full_col <= {write_addr[8:7], write_addr[0], write_counter[4:0]};
        adr_full_row <= {write_addr[10:9], write_addr[6:1]};
        CBLEN <= 1'b1;
      end
      WRITE_PECHARGE: begin
        CBL <= write_data[write_counter];
        CSL <= registers[0][0];
      end
      WRITE_PULSE: begin
        CWL <= 1'b1;
      end
      WRITE_CUTOFF: begin
        CWL <= 1'b0;
        CBL <= 1'b0;
      end
    endcase
  end

  // part 3 Bayesian machine
  Bayesian_stoch_log chip (
    .clk(clk),
    .CBL(CBL),
    .CBLEN(CBLEN),
    .CSL(CSL),
    .CWL(CWL),
    .inference(inference),
    .load_seed(load_seed),
    .read_1(read_1),
    .read_8(read_8),
    .load_mem(load_mem),
    .read_out(read_out),
    .adr_full_col(adr_full_col),
    .adr_full_row(adr_full_row),
    .stoch_log(stoch_log),
    .seeds(seeds),
    .bit_out(bit_out)
  ) ;
endmodule
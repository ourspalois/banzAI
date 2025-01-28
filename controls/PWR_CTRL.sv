`include "macros.svh"

module PWR_CTRL #(
    parameter int reg_num = 16,
    `ADAM_CFG_PARAMS
)(
    ADAM_SEQ.Slave seq_port,
    AXI_LITE.Slave axi_port[2], 
    AXI_LITE.Master axi_master
  );

  logic clk ; 
  assign clk = seq_port.clk;
  logic rst_n ;
  assign rst_n = ~seq_port.rst;

  reg [31:0] registers [0:reg_num-1]; // 8 registers of 32 bits
  //0 : state 
  // for the pwr registers I use 4bits for components adressing, and 2 bit for the state (so 5 updates on state change max )

  //1 IDLE to WAIT
  //1 HSDOM off, LPCPU off, LPMEM off, (NVMaccels)
  //2 WAIT to FETCH
  //2 
  //3 FETCH toCOMPUTE 
  //3 (NVMaccels)
  //4 COMPUTE to WAIT
  //4 
  //5 COMPUTE to IDLE
  //5 HSDOM on, LPCPU on, LPMEM on, (NVMaccels)

  //6 .. A : observation adresses 

  // 10 wait counter lenght 
  
  // AXIl slave management
  logic read_regs ;
  logic [10:0] read_addr ;// western reading style, likelihood arrays are continious in memory

  logic write_regs ;
  logic [10:0] write_addr ;// western reading style, likelihood arrays are continious in memory
  logic [31:0] write_data ;

  logic ready ; 
  assign ready = ~(read_regs || write_regs) ;
  logic pwr_launch ;  

  typedef enum int { IDLE, WAIT, FETCH, COMPUTE } state_t;
  state_t state ;

  always_ff @( posedge clk ) begin 
    if(!rst_n) begin
      registers[0] <= 32'h0;
      //transitions
      registers[1] <= 32'hffff_ffff;
      registers[1][0+:6] <= 6'b10_0000; // CUT HSDOM
      registers[1][6+:6] <= 6'b10_0001; // CUT LS RAM 
      registers[1][12+:6] <= 6'b10_0010; // CUT LS CPU
      registers[2] <= 32'hffff_ffff;
      registers[3] <= 32'hffff_ffff;
      registers[4] <= 32'hffff_ffff;
      registers[5] <= 32'hffff_ffff;
      registers[5][0+:6] <= 6'b11_0000; // WAKE HSDOM 
      registers[5][6+:6] <= 6'b11_0001; // WAKE LS RAM
      registers[5][12+:6] <= 6'b11_0010; // WAKE LS CPU
      //obs
      registers[6] <= MMAP_ACCEL.start + 3*4 ; 
      registers[7] <= MMAP_ACCEL.start + 4*4 ;
      registers[8] <= MMAP_ACCEL.start + 5*4 ;
      registers[9] <= MMAP_ACCEL.start + 6*4 ;
      //wait lenght
      registers[10] <= 32'h0;

      axi_port[0].r_valid <= 1'b0;
      axi_port[0].b_valid <= 1'b0;
      axi_port[0].ar_ready <= 1'b0;
      axi_port[0].aw_ready <= 1'b0;
      axi_port[0].w_ready <= 1'b0;
      read_regs <= 1'b0;
      write_regs <= 1'b0;
    end
    else begin
      // read management
      if(axi_port[0].ar_valid && ready) begin
        if(axi_port[0].ar_addr < 32'h2000) begin
          read_regs <= 1'b1;
        end 
        axi_port[0].ar_ready <= 1'b1;
        read_addr <= axi_port[0].ar_addr[2+:11];
      end else begin
        axi_port[0].ar_ready <= 1'b0;
      end

      // read response management
      if(axi_port[0].r_ready) begin
        if(read_regs) begin
          axi_port[0].r_data <= registers[read_addr[0+:3]];
          axi_port[0].r_valid <= 1'b1;
          read_regs <= 1'b0;
        end else begin
          axi_port[0].r_valid <= 1'b0;
        end
      end

      // write management
      if(axi_port[0].aw_valid && axi_port[0].w_valid && ready) begin
        if(axi_port[0].aw_addr < 31'h2000) begin
          write_regs <= 1'b1;
        end
        axi_port[0].aw_ready <= 1'b1;
        axi_port[0].w_ready <= 1'b1;
        write_addr <= axi_port[0].aw_addr[2+:11];
        write_data <= axi_port[0].w_data;
      end else begin
        axi_port[0].aw_ready <= 1'b0;
        axi_port[0].w_ready <= 1'b0;
      end

      // write response management
      if(write_regs && axi_port[0].b_ready) begin
        if (write_addr[0+:3] == 3'b0) begin
          pwr_launch <= 1;
        end 
        registers[write_addr[0+:4]] <= write_data;
        axi_port[0].b_resp <= 0;
        axi_port[0].b_valid <= 1'b1;
        write_regs <= 1'b0;
      end else begin
        axi_port[0].b_valid <= 1'b0;
        if(state != IDLE) begin
          pwr_launch <= 0;
        end
      end
    end
  end

  //PWR FSM 
  typedef enum int { GET_SEND, GET_RECEIVE, WRITE } FETCH_t;
  FETCH_t fetch_state ;
  logic [31:0] fetch_counter ;

    // wait counter
  logic counter_done ;
  logic [31:0] counter ;
  assign counter_done = (counter == registers[10]) ;

  //axi read
  logic [31:0] axi_read_addr, axi_read_data ;
  logic axi_read_valid, axi_read_req, axi_read_ready ;

  //FETCH
  logic [31:0] fetched_data ; 

  //axi fsm write
  logic [31:0] fsm_adress, fsm_data ;
  logic fsm_req, fsm_valid, fsm_ack ; // TODO:VALID is useless here

  //COMPUTE 
  logic compute_done, alert ;
  typedef enum int { GET, RECEIVE } read_ctrl_t;
  read_ctrl_t compute_read ;

  always_ff @( posedge clk ) begin 
    if(!rst_n) begin
      state <= IDLE;
    end else begin
      case (state)
        IDLE: begin
         if(pwr_launch) begin
           state <= WAIT;
         end
        end
        WAIT: begin
          if(counter_done) begin
            state <= FETCH;
          end
        end
        FETCH: begin
          if(fetch_counter == 32'h4) begin
            state <= COMPUTE;
          end
        end
        COMPUTE: begin
          if(compute_done) begin
            state <= IDLE ; //TODO : implement alert detection
          end
        end
        default: begin
          state <= IDLE;
        end
      endcase
    end
  end

  always_ff @( posedge clk ) begin //TODO:PIPELINE read and writes 
    if(!rst_n) begin
      fetch_state <= GET_SEND;
      fetch_counter <= 32'h0;
      fsm_req <= 1'b0;
      fsm_adress <= 32'h0;
      fsm_data <= 32'h0;
      compute_done <= 1'b0;
    end else begin
      if(state == FETCH) begin
        case (fetch_state)
          GET_SEND: begin
            fsm_req <= 0;
            if(axi_read_ready && fetch_counter != 32'h4) begin
              axi_read_addr <= registers[fetch_counter+6] ; 
              axi_read_req <= 1;
              fetch_state <= GET_RECEIVE;
            end
          end
          GET_RECEIVE : begin
            axi_read_req <= 0;
            if(axi_read_valid) begin
              fetched_data <= axi_read_data;
              fetch_state <= WRITE;
              fsm_req <= 1;
              fsm_adress <= registers[fetch_counter+6] ;
              fsm_data <= axi_read_data; 
            end
          end
          WRITE: begin
            fsm_req <= 0;
            if(fsm_ack) begin
              fetch_state <= GET_SEND;
              fetch_counter <= fetch_counter + 32'h1;
            end 
          end
          default: begin
            fetch_state <= GET_SEND;
          end
        endcase
      end else if(state == COMPUTE) begin
        case (compute_read)
          GET: begin
            if(axi_read_ready && !compute_done) begin
              axi_read_addr <= MMAP_ACCEL.start ; 
              axi_read_req <= 1;
              compute_read <= RECEIVE;
            end
          end
          RECEIVE: begin
            axi_read_req <= 0;
            if(axi_read_valid) begin
              compute_done <= 1;
              compute_read <= GET;
            end
          end
          default: begin
            compute_read <= GET;
          end 
        endcase
      end else if(state == IDLE) begin
        axi_read_req <= 0;
      end
    end
  end

  // wait counter
  always_ff @( posedge clk ) begin
    if(!rst_n) begin
      counter <= 32'h0;
    end else begin
      if(state == WAIT) begin
        if(counter_done) begin
          counter <= 32'h0;
        end else begin
          counter <= counter + 32'h1;
        end
      end
    end
  end

  axi_read read_port(
    .seq_port(seq_port),
    .axi_master(axi_master),
    .adress_i(axi_read_addr),
    .req_i(axi_read_req),
    .ready_o(axi_read_ready),
    .data_o(axi_read_data),
    .valid_o(axi_read_valid)
  ) ;

  //maestro management
  state_t old_state ; 
  logic [3:0] pwr_counter ;
  logic pwr_ctrl_en ; 

  logic [31:0] maestro_address, maestro_data ;
  logic maestro_req, maestro_valid, maestro_ack ;
  logic [7:0] transition_number, pwr_transition ; 

  always_ff @( posedge clk ) begin
    if(!rst_n) begin
      old_state <= IDLE;      
      pwr_ctrl_en <= 0;
      pwr_counter <= 32'h0;
      transition_number <= 8'h0;
      pwr_transition <= 8'h0;
      maestro_address <= 32'h0;
      maestro_data <= 32'h0;
      maestro_req <= 0;
    end else begin 
      case (old_state)
          IDLE: transition_number <= 8'h0;
          WAIT: transition_number <= 8'h1;
          FETCH: transition_number <= 8'h2;
          COMPUTE: if(state == WAIT) begin transition_number <= 8'h3; end else begin transition_number <= 8'h4; end
      endcase

      old_state <= state;
      if(old_state != state && registers[1 + transition_number][0+:6] != 6'b11_1111) begin
        $display("register content; %b", registers[1 + pwr_transition][0+:6]);
        pwr_ctrl_en <= 1;
        case (old_state)
          IDLE: pwr_transition <= 8'h0;
          WAIT: pwr_transition <= 8'h1;
          FETCH: pwr_transition <= 8'h2;
          COMPUTE: if(state == WAIT) begin pwr_transition <= 8'h3; end else begin pwr_transition <= 8'h4; end
        endcase
      end else if(pwr_ctrl_en && registers[1 + pwr_transition][6*(pwr_counter+1)+:6] == 6'b11_1111) begin 
        pwr_ctrl_en <= 0;
      end

      if(pwr_ctrl_en) begin        
        if (maestro_ack) begin
          pwr_counter <= pwr_counter + 4'b1;
          maestro_req <= 0;
        end else begin
          maestro_address <= MMAP_SYSCFG.start | {28'b0,  registers[1 + pwr_transition][(6*pwr_counter)+:4]} ; // register adress management
          maestro_data <= {30'b0, registers[1 + pwr_transition][(6*pwr_counter)+4 +:2]} +1  ; // register data management
          maestro_req <= 1;
        end
      end else begin
        maestro_req <= 0;
        pwr_counter <= 32'h0;
      end
    end
  end

  axi_write write_port(
    .seq_port(seq_port),
    .axi_master(axi_master),
    .maestro_adress_i(maestro_address),
    .maestro_data_i(maestro_data),
    .maestro_req_i(maestro_req),
    .maestro_valid_o(maestro_valid),
    .maestro_ack_o(maestro_ack),
    .fsm_adress_i(fsm_adress),
    .fsm_data_i(fsm_data),
    .fsm_req_i(fsm_req),
    .fsm_valid_o(fsm_valid),
    .fsm_ack_o(fsm_ack)
  ) ;
    
endmodule
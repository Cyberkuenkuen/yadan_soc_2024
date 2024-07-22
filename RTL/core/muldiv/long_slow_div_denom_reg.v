/******************************************************************************
MIT License

Copyright (c) 2020 BH6BAO

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

******************************************************************************/


`default_nettype none

module long_slow_div_denom_reg   
        #(parameter DATA_WIDTH = 32)(
      
        //=======  clock and reset ======
        input  wire                                         clk,
        input  wire                                         reset_n,
        
        //========== INPUT ==========
        input  wire                                         enable_in,
        input  wire [DATA_WIDTH - 1 : 0]                    numerator,
        input  wire [DATA_WIDTH - 1 : 0]                    denominator,
        
        //========== OUTPUT ==========
        output wire                                         enable_out,
        output wire [DATA_WIDTH - 1 : 0]                    quotient,
        output reg [DATA_WIDTH - 1 : 0]                     remainder,
        output reg                                          div_by_zero,
         
        output reg                                          error
);
        
    
    reg   [DATA_WIDTH * 2 : 0]                      L_num;
    wire  [DATA_WIDTH : 0]                          L_num_high; 
    wire  [DATA_WIDTH  : 0]                         L_den;
    wire  [DATA_WIDTH  : 0]                         difference;
    reg   [DATA_WIDTH - 1 : 0]                      denominator_reg;
        
    reg   [$clog2(DATA_WIDTH) : 0]                  iteration;
        
    reg                                             ctl_set_div_by_zero;
    reg                                             ctl_division_init, ctl_division_enable, ctl_set_enable_out;
    reg  [DATA_WIDTH : 0]                           quotient_i;    
        
    always @(posedge clk) begin 
        if (enable_in) begin
            denominator_reg <= denominator;
        end
    end
    
    assign L_num_high = L_num [DATA_WIDTH * 2 : DATA_WIDTH];
    
    assign difference = L_num_high - L_den; 
    assign L_den = {1'b0, denominator_reg};
        
    always @(posedge clk) begin
        if (ctl_division_init) begin
            L_num <= { {(DATA_WIDTH){1'b0}}, numerator, 1'b0};
        end else if (ctl_division_enable) begin
            if (L_num_high >= L_den) begin
                L_num <= {difference [DATA_WIDTH - 1 : 0], L_num [DATA_WIDTH - 1 : 0], 1'b0};
            end else begin
                L_num <= L_num << 1;
            end
        end
    end
        
    always @(posedge clk) begin
        if (ctl_division_init) begin
            iteration <= 0;
            remainder <= 0;
        end else if (ctl_division_enable) begin
            iteration <= iteration + 1;
            
            remainder <= L_num_high[32 : 1];
            
        end
    end
        
    always @(posedge clk) begin : div_by_zero_proc
        if (enable_in) begin
            div_by_zero <= 0;
        end else begin
            div_by_zero <= ctl_set_div_by_zero;
        end
    end 
            
    always @(posedge clk) begin : error_proc
        if (enable_in) begin
            error <= 0;
        end else if (ctl_set_div_by_zero)  begin
            error <= 1;
        end
    end 
                
    always @(posedge clk) begin : quotient_proc
        if (ctl_division_init) begin
            quotient_i <= 0;
        end else if (ctl_division_enable) begin
            if (L_num_high >= L_den) begin
                quotient_i <= {quotient_i [DATA_WIDTH - 1 : 0], 1'b1};
            end else begin
                quotient_i <= {quotient_i [DATA_WIDTH - 1 : 0], 1'b0};
            end 
        end
    end 
    
    assign quotient = quotient_i [DATA_WIDTH : 1];
    assign enable_out = ctl_set_enable_out;
    
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // FSM
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        localparam S_IDLE = 0, S_CHECK = 1, S_DIVISION = 2, S_OUTPUT = 3;
        reg [3 : 0] current_state, next_state;
                
        // Declare states
        always @(posedge clk, negedge reset_n) begin : state_machine_reg
            if (!reset_n) begin
                current_state <= 0;
            end else begin
                current_state <= next_state;
            end
        end 
        
        // FSM main body
        always @(*) begin : state_machine_comb

            next_state = 0;
            
            ctl_set_div_by_zero = 0;
                
            ctl_division_init = 0;
            ctl_division_enable = 0;
                
            ctl_set_enable_out = 0;
                
            case (1'b1)
                current_state[S_IDLE]: begin
                    if (!enable_in) begin
                        next_state[S_IDLE] = 1;
                    end else begin
                        next_state[S_CHECK] = 1;
                    end
                end
                    
                current_state[S_CHECK] : begin
                    next_state[S_DIVISION] = 1;
                    ctl_division_init = 1;
                    
                    if (denominator_reg == 0) begin
                        ctl_set_div_by_zero = 1;
                    end 
                end
                    
                current_state[S_DIVISION] : begin
                    if (iteration == (DATA_WIDTH + 1)) begin
                        next_state[S_OUTPUT] = 1;
                    end else begin
                        ctl_division_enable = 1;
                        next_state[S_DIVISION] = 1;
                    end 
                end
                    
                current_state[S_OUTPUT] : begin
                    ctl_set_enable_out = 1;
                    next_state[S_IDLE] = 1;
                end
                    
                default: begin
                    next_state[S_IDLE] = 1'b1;
                end
                    
            endcase
          
        end 
    
endmodule


`default_nettype wire

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

`include "yadan_defs.v"

module cpu_ahb_if 
    #(parameter      IDLE    = 3'b000 
                    ,WAIT    = 3'b001 
                    ,CONTROL = 3'b010 
                    ,ENDS    = 3'b100         
    )

(
        input   wire                clk
   ,    input   wire                rst

        //cpu侧接口
   ,    input   wire [31:0]          cpu_addr_i
   ,    input   wire                 cpu_ce_i
   ,    input   wire                 cpu_we_i
   ,    input   wire [31:0]          cpu_writedate_i
   ,    input   wire [2:0]           cpu_sel_i

   ,    output  reg  [31:0]          cpu_readdate_o

        //AHB总线端接口
        //in
   ,    input   wire                M_HGRANT   
   ,    input   wire [31:0]         M_HRDATA   
        //out
   ,    output  reg                 M_HBUSREQ  
    
   ,    output  reg  [31:0]         M_HADDR    
   ,    output  reg  [ 1:0]         M_HTRANS   
   ,    output  reg  [ 2:0]         M_HSIZE    
   ,    output  reg  [ 2:0]         M_HBURST   
   ,    output  reg                 M_HWRITE   
   ,    output  reg  [31:0]         M_HWDATA   

        //去ctrl模块
   ,    output  reg                 stallreq

);
    
    
    
    reg    [2:0]    state ;
    reg    [2:0]    nxt_state;
    
    always @ (posedge clk or negedge rst )  begin 
        if (!rst)
            state <= IDLE ;
        else 
            state<= nxt_state;
    
    end 

    always @ (* )  begin 
       if(rst == `RstEnable)begin
            cpu_readdate_o  = `ZeroWord;
            M_HBUSREQ   = 1'b0;
            M_HADDR     = `ZeroWord;
            M_HTRANS    = 2'b10;
            M_HSIZE     = 3'b010;
            M_HBURST    = 3'b000;
            M_HWRITE    = 1'b0;
            M_HWDATA    = `ZeroWord;
            nxt_state   =  IDLE;
            stallreq    =   1'b0;
        end
        else begin
            M_HSIZE     =   cpu_sel_i;
            M_HADDR     =   cpu_addr_i;
            M_HWRITE    =   1'b0;
            cpu_readdate_o  = `ZeroWord;
            // M_HBUSREQ   = 1'b0;
            M_HTRANS    = 2'b10;
            M_HBURST    = 3'b000;
            M_HWDATA    = `ZeroWord;
            nxt_state   =  IDLE;
            // stallreq    =   1'b0;
            case (state) 
                IDLE :begin

                    if (cpu_ce_i) begin
                        stallreq    =   1'b1;   
                        
                        M_HBUSREQ   =   1'b1;
                        nxt_state   =   WAIT;
                    end
                    else begin
                        stallreq    =   1'b1; 
                        M_HBUSREQ   =   1'b0;
                        nxt_state   =   IDLE;
                    end
                end 
                WAIT:begin 
                    if (cpu_ce_i) begin
                        stallreq    =   1'b1;
                        M_HBUSREQ   =   1'b1;
                       if (M_HGRANT) begin
                            nxt_state = CONTROL ;
                        end  
                        else begin
                            nxt_state = WAIT ;
                        end                 
                    end
                    else begin
                        stallreq    =   1'b1;
                        M_HBUSREQ   =   1'b0;
                        nxt_state   =   IDLE;
                    end
                           
                end 
                CONTROL:begin 
                    if (cpu_ce_i) begin
                        stallreq    =   1'b1;
                        M_HBUSREQ   =   1'b1;
                        nxt_state =  ENDS;
                    end
                    else begin
                        stallreq    =   1'b1;
                        M_HBUSREQ   =   1'b0;
                        nxt_state   =   IDLE;
                    end     
                end 
                ENDS:begin
                    
                    if (cpu_ce_i) begin
                        stallreq    =   1'b0;
                        M_HBUSREQ   =   1'b1; 
                        nxt_state   =  ENDS;
                        if (cpu_we_i == `WriteEnable) begin
                            M_HWDATA    =   cpu_writedate_i;
                        end
                        else begin
                            cpu_readdate_o  =  M_HRDATA;
                        end
                    end                       
                    else begin
                        stallreq    =   1'b1;
                        M_HBUSREQ   =   1'b0;
                        nxt_state   =   IDLE; 
                         
                    end 
                        
                end 
            endcase
        end
       
    end


endmodule
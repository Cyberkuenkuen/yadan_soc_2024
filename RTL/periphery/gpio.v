 /*                                                                      
 Copyright 2020 Blue Liang, liangkangnan@163.com
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
 Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */



module gpio(

    input wire clk,
	input wire rst,

    input wire we_i,
    input wire sel_i,
    input wire enable_i,
    input wire[31:0] addr_i,
    input wire[31:0] data_i,

    output wire     [15:0]HSPLIT,
    output reg[31:0] data_o,
    output wire ack_o,
	output wire[1:0] io_pin

    );

    assign HSPLIT    = 16'h0;

    localparam GPIO_DATA = 4'h4;// 32'h4A100004;

    reg[31:0] gpio_data;
    wire rd;

    assign io_pin = gpio_data[1:0];
    assign ack_o =1'b1;
    assign rd = sel_i & (~we_i) & (enable_i);

    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            gpio_data <= 32'h0;
        end else begin
            if (sel_i & (we_i) & (enable_i)) begin
                case (addr_i[3:0])
                    GPIO_DATA: begin
                        gpio_data <= data_i;
                    end
                    default : begin
                        gpio_data <= 32'h0;
                    end 
                endcase
            end
        end
    end

    always @ (*) begin
        if (rst == 1'b0) begin
            data_o <= 32'h0;
        end else begin 
            if (rd) begin
                case (addr_i[3:0])
                    GPIO_DATA: begin
                        data_o <= gpio_data;
                    end
                    default : begin
                        data_o <= 32'h0;
                    end
                endcase
            end
        end
    end

endmodule

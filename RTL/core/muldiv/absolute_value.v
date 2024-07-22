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

module absolute_value #(parameter DATA_WIDTH=32)(
      
//========== INPUT ==========

        input  wire signed [DATA_WIDTH - 1 : 0]  data_in,
            
        
//========== OUTPUT ==========
        output wire  signed [DATA_WIDTH - 1 : 0] data_out
        
//========== IN/OUT ==========
);
    wire signed [DATA_WIDTH - 1 : 0]    data_sign_ext, data_tmp;
    wire signed [DATA_WIDTH - 1 : 0]    abs_value;
    
    assign data_sign_ext = {(DATA_WIDTH){data_in[DATA_WIDTH - 1]}};
    assign data_tmp      = data_in ^ data_sign_ext;
    assign abs_value     = data_tmp - data_sign_ext;
    
    assign data_out = abs_value;
    
endmodule

`default_nettype wire

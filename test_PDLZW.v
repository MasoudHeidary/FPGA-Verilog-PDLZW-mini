`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: MasoudHeidaryDeveloper@gmail.com
// 
// Create Date:    11:34:36 07/09/2021 
// Design Name: 
// Module Name:    test_PDLZW 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module test_PDLZWRapper();

    reg [2*8-1:0] _data_input = {0};
    reg _data_input_ready = 0;

    wire _data_input_fetched;
    wire [1:0] _shift_data;
    wire [8:0] _data_output;
    wire _data_output_ready;

    reg clk = 0;
    always #5 clk = !clk;

    PDLZWRapper ut
    (
        _data_input,
        _data_input_ready,
        _data_input_fetched,
        _shift_data,
        _data_output,
        _data_output_ready,
        clk
    );

    initial
    begin
        #15;
        
        //compress 0,1
        _data_input <= {8'H01, 8'H0};
        _data_input_ready <= 1;
        #10;

        _data_input_ready <= 0;
        #10;

        while(_data_output_ready != 1) #10;
        $display("data output: %d, shift: %d", _data_output, _shift_data);

        
        //compress 2,3
        _data_input <= {8'H03, 8'H02};
        _data_input_ready <= 1;
        #10;

        _data_input_ready <= 0;
        #10;

        while(_data_output_ready != 1) #10;
        $display("data output: %d, shift: %d", _data_output, _shift_data);

        //compress 0,1
        _data_input <= {8'H01, 8'H0};
        _data_input_ready <= 1;
        #10;

        _data_input_ready <= 0;
        #10;

        while(_data_output_ready != 1) #10;
        $display("data output: %d, shift: %d", _data_output, _shift_data);

        //compress 2,3
        _data_input <= {8'H03, 8'H02};
        _data_input_ready <= 1;
        #10;

        _data_input_ready <= 0;
        #10;

        while(_data_output_ready != 1) #10;
        $display("data output: %d, shift: %d", _data_output, _shift_data);

    end

endmodule



module test_SyncDict();

    reg clk = 0;
    always #5 clk = !clk;

    reg [7:0] _data;
    reg _find_request = 0;
    wire [$clog2(256)-1:0] _index;
    wire _exist;
    wire _saved;
    wire _filled;

    Dict #(.Depth(3)) 
    ut 
    (
        _data,
        _find_request,
        _index,
        _exist,
        _saved,
        _filled,
        clk
    );

    initial
    begin
        #15;

        _find_request <= 1;
        _data <= 8'b00001111;
        #10;    // need 1clk for first index

        _find_request <= 0;
        #10;    

        _data <= 8'b11110000;
        _find_request <= 1;
        #20;    // need 2clk for second index

        _find_request <= 0;
        #10;

        _data <= 8'b00001111;
        _find_request <= 1;
        #10;    // need 1clk for first index

        _find_request <= 0;
        #10;

        _data <= 8'b11110000;
        _find_request <= 1;
        #20;    // need 2clk for secomd index

        _find_request <= 0;
        #10;

        _data <= 8'b01010101;
        _find_request <= 1;
        #30;    // need 3clk for third index

        _data <= 8'b11001100;
        _find_request <= 1;
        #100;    //can't save data -> return FILL

        _find_request <= 0;
        #10;
    end

endmodule
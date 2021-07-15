`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: MasoudHeidaryDeveloper@gmail.com
// 
// Create Date:    11:12:21 07/09/2021 
// Design Name: 
// Module Name:    PDLZW 
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
module PDLZWRapper
(
    input [2*8-1:0] DataInput,
    input DataInputReady,
    output reg DataInputFetch,
    output reg [1:0] ShiftData,
    output reg [8:0] DataOutput,
    output reg DataOutputReady,
    input clk
);

    //search on lay 2
    reg lay_2_find_request = 0;
    wire [$clog2(2*8)-1:0] lay_2_find;
    wire lay_2_save;
    wire lay_2_exist;
    wire lay_2_filled;

    // Dict of lay 2
    Dict 
    #(
        .Width(2*8), .Depth(256)
    )
    Lay2
    (
        DataInput[2*8-1:0],
        lay_2_find_request,
        lay_2_find,
        lay_2_save,
        lay_2_exist,
        lay_2_filled,
        clk
    );

    reg [2*8-1:0] _data_temp = {0};

    reg current_state = fetch_data;
    parameter fetch_data = 0;
    parameter find_in_lay_2 = 1;

    always @(posedge clk)
    begin

        //reset
        DataInputFetch <= 0;
        DataOutputReady <= 0;
        //END reset

        if(current_state == fetch_data)
        begin
            if(DataInputReady)
            begin
                _data_temp <= DataInput;
                DataInputFetch <= 1;

                lay_2_find_request <= 1;
                current_state <= find_in_lay_2;
            end
        end

        else if (current_state == find_in_lay_2)
        begin
            // data find or save on lay 2 -> output the index
            if(lay_2_save | lay_2_exist)
            begin
                DataOutput <= lay_2_find + 256;
                DataOutputReady <= 1;
                ShiftData <= 2;

                lay_2_find_request <= 0;
                current_state <= fetch_data;
            end

            // data can't save on lay 2 -> output that byte
            else if(lay_2_filled)
            begin
                DataOutput <= DataInput[0];
                DataOutputReady <= 1;
                ShiftData <= 1;

                lay_2_find_request <= 0;
                current_state <= fetch_data;
            end
        end
    end

endmodule


module Dict
#(
    parameter Width = 8,
    parameter Depth = 256
)
(
    input [Width-1:0] DataInput,
    input FindRequest,
    output reg [$clog2(Depth)-1:0] FindIndex,
    output reg Exist,
    output reg Saved,
    output reg Filled,
    input clk
);

    reg [Width-1:0] Data [Depth-1:0];               // saved data in Dict
    reg [$clog2(Depth)-1:0] _save_index = 0;        // save new data at this index
    reg [$clog2(Depth)-1:0] _current_index = 0;     // use for find exist data

    always @(posedge clk)
    begin

        // reset pins
        Exist <= 0;
        Saved <= 0;
        Filled <= 0;

        if(FindRequest)
        begin
            _current_index <= _current_index + 1;

            // reach at end of Dict
            if(_current_index == Depth)
            begin
                Filled <= 1;
                _current_index <= _current_index;
            end

            // save doesn't exist data
            else if(_current_index == _save_index)
            begin
                //save data
                Data[_save_index] = DataInput;

                //indicate on output
                FindIndex <= _save_index;
                Saved <= 1;

                //update inside registers
                _save_index <= _save_index + 1;
                _current_index <= 0;
            end


            else
            begin
                //try find data in dictionary
                if(Data[_current_index] == DataInput)
                begin
                    FindIndex <= _current_index;
                    Exist <= 1;
                end
            end
        end
            
        // client dont want find anything -> do nothing    
        else
        begin
            // nothing to do
            _current_index <= 0;
        end
    end
endmodule
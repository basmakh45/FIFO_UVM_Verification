interface FIFO_if #(parameter FIFO_WIDTH = 16, FIFO_DEPTH = 8)(input logic clk);
    logic [FIFO_WIDTH-1:0] data_in;
    logic        wr_en, rd_en, rst_n;
    logic [FIFO_WIDTH-1:0] data_out;
    logic        full, empty, almostfull, almostempty;
    logic        wr_ack, overflow, underflow;

endinterface

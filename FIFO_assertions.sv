module FIFO_assertions #(
    parameter FIFO_WIDTH = 16,
    parameter FIFO_DEPTH = 8
)(
    input logic clk,
    input logic rst_n,
    input logic wr_en,
    input logic rd_en,
    input logic wr_ack,
    input logic overflow,
    input logic underflow,
    input logic full,
    input logic empty,
    input logic almostfull,
    input logic almostempty,
    input logic [FIFO_WIDTH-1:0] data_out,
    input logic [$clog2(FIFO_DEPTH):0] count,
    input logic [$clog2(FIFO_DEPTH)-1:0] wr_ptr,
    input logic [$clog2(FIFO_DEPTH)-1:0] rd_ptr
);

`ifdef SIM

// RESET
property reset_behavior;
    @(posedge clk)
    !rst_n |-> (count == 0 && wr_ptr == 0 && rd_ptr == 0);
endproperty
assert property(reset_behavior)
    else $error("RESET FAIL");

// WR ACK
property wr_ack_check;
    @(posedge clk) disable iff(!rst_n)
    (wr_en && !full) |=> wr_ack;
endproperty
assert property(wr_ack_check)
    else $error("WR_ACK FAIL");

// OVERFLOW
property overflow_check;
    @(posedge clk) disable iff(!rst_n)
    (wr_en && full) |=> overflow;
endproperty
assert property(overflow_check)
    else $error("OVERFLOW FAIL");

// UNDERFLOW
property underflow_check;
    @(posedge clk) disable iff(!rst_n)
    (rd_en && empty) |=> underflow;
endproperty
assert property(underflow_check)
    else $error("UNDERFLOW FAIL");

// FULL / EMPTY
property full_check;
    @(posedge clk) disable iff(!rst_n)
    (count == FIFO_DEPTH) |-> full;
endproperty
assert property(full_check)
    else $error("FULL FAIL");

property empty_check;
    @(posedge clk) disable iff(!rst_n)
    (count == 0) |-> empty;
endproperty
assert property(empty_check)
    else $error("EMPTY FAIL");


//  almostfull 
property almostfull_check;
    @(posedge clk) disable iff(!rst_n)
    (count == FIFO_DEPTH - 1) |-> almostfull;
endproperty
assert property(almostfull_check)
    else $error("almostfull_check FAIL");

// almostempty 
property almostempty_check;
    @(posedge clk) disable iff(!rst_n)
    (count == 1) |-> almostempty;
endproperty
assert property(almostempty_check)
    else $error(" almostempty_check FAIL");


// RANGE
property wr_ptr_range;
    @(posedge clk) disable iff(!rst_n)
    wr_ptr < FIFO_DEPTH;
endproperty
assert property(wr_ptr_range)
    else $error(" wr_ptr_range FAIL");


property rd_ptr_range;
    @(posedge clk) disable iff(!rst_n)
    rd_ptr < FIFO_DEPTH;
endproperty
assert property(rd_ptr_range)
    else $error(" rd_ptr_range FAIL");


// COUNT SAFETY
property count_range;
    @(posedge clk) disable iff(!rst_n)
    count <= FIFO_DEPTH;
endproperty
assert property(count_range)
    else $error(" count_range FAIL");


`endif

endmodule
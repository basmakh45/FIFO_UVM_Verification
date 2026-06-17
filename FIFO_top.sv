`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"

import FIFO_config_pkg::*;
import FIFO_seq_item_pkg::*;
import FIFO_sequences_pkg::*;
import FIFO_sequencer_pkg::*;
import FIFO_driver_pkg::*;
import FIFO_monitor_pkg::*;
import FIFO_agent_pkg::*;
import FIFO_scoreboard_pkg::*;
import FIFO_coverage_pkg::*;
import FIFO_env_pkg::*;
import FIFO_test_pkg::*;


module FIFO_top;

    logic clk;
    initial clk = 0;
    always #5 clk = ~clk;

    FIFO_if fif (.clk(clk));

    FIFO #(.FIFO_WIDTH(16), .FIFO_DEPTH(8)) DUT (
        .clk        (fif.clk),
        .rst_n      (fif.rst_n),
        .data_in    (fif.data_in),
        .wr_en      (fif.wr_en),
        .rd_en      (fif.rd_en),
        .data_out   (fif.data_out),
        .full       (fif.full),
        .empty      (fif.empty),
        .almostfull (fif.almostfull),
        .almostempty(fif.almostempty),
        .wr_ack     (fif.wr_ack),
        .overflow   (fif.overflow),
        .underflow  (fif.underflow)
    );
    bind FIFO FIFO_assertions #(
        .FIFO_WIDTH(16),
        .FIFO_DEPTH(8)
    ) u_assertions (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wr_ack(wr_ack),
        .overflow(overflow),
        .underflow(underflow),
        .full(full),
        .empty(empty),
        .almostfull(almostfull),
        .almostempty(almostempty),
        .data_out(data_out),
        .count(count),
        .wr_ptr(wr_ptr),
        .rd_ptr(rd_ptr)
    );
    initial begin
        uvm_config_db #(virtual FIFO_if)::set(null, "*", "FIFO_IF", fif);
        run_test("FIFO_test");
    end

endmodule

package FIFO_scoreboard_pkg;
    import uvm_pkg::*;
   `include "uvm_macros.svh"

    import FIFO_seq_item_pkg::*;
    
    class FIFO_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(FIFO_scoreboard)

        uvm_analysis_export #(FIFO_seq_item)    sb_export;

        uvm_tlm_analysis_fifo #(FIFO_seq_item)  sb_fifo;

        FIFO_seq_item seq_item_sb;


        localparam FIFO_DEPTH = 8;
        logic [15:0] mem [7:0];
        logic [2:0]  wr_ptr, rd_ptr;
        logic [3:0]  count;
        logic [15:0] data_out_ref;

        int error_count   = 0;
        int correct_count = 0;
        int  first_read   = 1;


        function new(string name = "FIFO_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export = new("sb_export", this);
            sb_fifo   = new("sb_fifo",   this);
            reset_model();
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                sb_fifo.get(seq_item_sb);          
                check_data(seq_item_sb);            
            end
        endtask

       
        task reference_model(FIFO_seq_item txn);

            logic full_ref;
            logic empty_ref;

            if (!txn.rst_n) begin
                reset_model();
                return;
            end

            full_ref  = (count == FIFO_DEPTH);
            empty_ref = (count == 0);

            // READ FIRST
            if (txn.rd_en && !empty_ref) begin
                rd_ptr = (rd_ptr + 1) % FIFO_DEPTH;
            end

            // WRITE SECOND
            if (txn.wr_en && !full_ref) begin
                mem[wr_ptr] = txn.data_in;
                wr_ptr      = (wr_ptr + 1) % FIFO_DEPTH;
            end

            // COUNT UPDATE
            if      ( txn.wr_en && !txn.rd_en && !full_ref )
                count++;

            else if ( !txn.wr_en && txn.rd_en && !empty_ref )
                count--;

            else if ( txn.wr_en && txn.rd_en && empty_ref )
                count++;

            else if ( txn.wr_en && txn.rd_en && full_ref )
                count--;

        endtask

       task check_data(FIFO_seq_item txn);

            logic [15:0] expected_data;

            if (!txn.rst_n) begin
                reference_model(txn);
                return;
            end

            expected_data = data_out_ref;

            if (txn.rd_en && count > 0)
                expected_data = mem[rd_ptr];

            if (txn.rd_en && count > 0) begin

                if (first_read > 0) begin
                    first_read--;
                end
                else begin
                    
                    if (txn.data_out === expected_data) begin
                        correct_count++;
                    end
                    else begin
                        error_count++;

                    `uvm_error("SB",
                                $sformatf(
                                "wr=%0b rd=%0b empty=%0b full=%0b count=%0d rd_ptr=%0d wr_ptr=%0d mem=%0h exp=%0h got=%0h",
                                txn.wr_en,
                                txn.rd_en,
                                txn.empty,
                                txn.full,
                                count,
                                rd_ptr,
                                wr_ptr,
                                mem[rd_ptr],
                                expected_data,
                                txn.data_out
                                ))
                    end
                end
            end

            reference_model(txn);

    endtask


        function void reset_model();
            wr_ptr = 0; rd_ptr = 0; count = 0;
            data_out_ref = 0; first_read = 1;
            foreach(mem[i]) mem[i] = 0;
        endfunction

        
        function void report_phase(uvm_phase phase);
            `uvm_info("report_phase",
                $sformatf("Total successful transactions: %0d", correct_count), UVM_MEDIUM)
            `uvm_info("report_phase",
                $sformatf("Total failed transactions: %0d", error_count), UVM_MEDIUM)
        endfunction


    endclass
endpackage
package FIFO_coverage_pkg;
    import uvm_pkg::*;
   `include "uvm_macros.svh" 
    import FIFO_seq_item_pkg::*;
    
    class FIFO_coverage extends uvm_component;
        `uvm_component_utils(FIFO_coverage)

    
        uvm_analysis_export #(FIFO_seq_item)    cov_export;
        uvm_tlm_analysis_fifo #(FIFO_seq_item)  cov_fifo;
        FIFO_seq_item seq_item_cov;

        covergroup FIFO_cg;
        cp_wr_en:       coverpoint seq_item_cov.wr_en;
        cp_rd_en:       coverpoint seq_item_cov.rd_en;
        cp_full:        coverpoint seq_item_cov.full;
        cp_empty:       coverpoint seq_item_cov.empty;
        cp_almostfull:  coverpoint seq_item_cov.almostfull;
        cp_almostempty: coverpoint seq_item_cov.almostempty;
        cp_overflow:    coverpoint seq_item_cov.overflow;
        cp_underflow:   coverpoint seq_item_cov.underflow;
        cp_wr_ack:      coverpoint seq_item_cov.wr_ack;

        cx1: cross cp_wr_en, cp_rd_en, cp_full;
        cx2: cross cp_wr_en, cp_rd_en, cp_empty;
        cx3: cross cp_wr_en, cp_rd_en, cp_almostfull;
        cx4: cross cp_wr_en, cp_rd_en, cp_almostempty;
        cx5: cross cp_wr_en, cp_rd_en, cp_overflow;
        cx6: cross cp_wr_en, cp_rd_en, cp_underflow;
        cx7: cross cp_wr_en, cp_rd_en, cp_wr_ack;
        endgroup

        function new(string name = "FIFO_coverage", uvm_component parent = null);
            super.new(name, parent);
            FIFO_cg     = new();
            
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export = new("cov_export", this);
            cov_fifo   = new("cov_fifo",   this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_export.connect(cov_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                cov_fifo.get(seq_item_cov);    
                FIFO_cg.sample();
            end
        endtask

        function void report_phase(uvm_phase phase);
            `uvm_info("report_phase",
                        $sformatf("Functional coverage: %.2f%%", FIFO_cg.get_coverage()),
                        UVM_MEDIUM)
        endfunction

    endclass
endpackage
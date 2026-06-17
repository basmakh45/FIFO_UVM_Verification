package FIFO_sequences_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import FIFO_seq_item_pkg::*;

    // Reset Sequence
    class FIFO_reset_sequence extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_reset_sequence)

        int unsigned num_cycles = 3;

        function new(string name = "FIFO_reset_sequence");
            super.new(name);
        endfunction

        task body();
            FIFO_seq_item item;

        
            repeat(num_cycles) begin
                item = FIFO_seq_item::type_id::create("item");
                start_item(item);
                if (!item.randomize() with {
                    rst_n   == 1'b0;
                    wr_en   == 1'b0;
                    rd_en   == 1'b0;
                    data_in == 16'h0;
                }) `uvm_fatal("SEQ", "Randomization failed in reset_sequence")
                `uvm_info("SEQ_RESET", item.convert2string(), UVM_HIGH)
                finish_item(item);
            end

            
            item = FIFO_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize() with {
                rst_n == 1'b1;
                wr_en == 1'b0;
                rd_en == 1'b0;
            }) `uvm_fatal("SEQ", "Randomization failed in reset_sequence deassert")
            `uvm_info("SEQ_RESET", item.convert2string(), UVM_HIGH)
            finish_item(item);
        endtask
    endclass


    //  Write-Only Sequence
    class FIFO_write_only_sequence extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_write_only_sequence)

        int unsigned num_items = 200;

        function new(string name = "FIFO_write_only_sequence");
            super.new(name);
        endfunction

        task body();
            FIFO_seq_item item;
            repeat(num_items) begin
                item = FIFO_seq_item::type_id::create("item");
                
                item.WR_EN_ON_DIST = 100;
                item.RD_EN_ON_DIST = 0;
                start_item(item);
                if (!item.randomize() with { rst_n == 1'b1; })
                    `uvm_fatal("SEQ", "Randomization failed in write_only_sequence")
                `uvm_info("SEQ_WR_ONLY", item.convert2string(), UVM_HIGH)
                finish_item(item);
            end
        endtask
    endclass


    //  Read-Only Sequence
    class FIFO_read_only_sequence extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_read_only_sequence)

        int unsigned num_items = 200;

        function new(string name = "FIFO_read_only_sequence");
            super.new(name);
        endfunction

        task body();
            FIFO_seq_item item;
            repeat(num_items) begin
                item = FIFO_seq_item::type_id::create("item");
            
                item.WR_EN_ON_DIST = 0;
                item.RD_EN_ON_DIST = 100;
                start_item(item);
                if (!item.randomize() with { rst_n == 1'b1; })
                    `uvm_fatal("SEQ", "Randomization failed in read_only_sequence")
                `uvm_info("SEQ_RD_ONLY", item.convert2string(), UVM_HIGH)
                finish_item(item);
            end
        endtask
    endclass


    //  Write-Read Sequence

    class FIFO_write_read_sequence extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_write_read_sequence)

        int unsigned num_items = 300;

        function new(string name = "FIFO_write_read_sequence");
            super.new(name);
        endfunction

        task body();
            FIFO_seq_item item;
            repeat(num_items) begin
                item = FIFO_seq_item::type_id::create("item");
                // Both forced on — mirrors new(WR=100, RD=100)
                item.WR_EN_ON_DIST = 100;
                item.RD_EN_ON_DIST = 100;
                start_item(item);
                if (!item.randomize() with { rst_n == 1'b1; })
                    `uvm_fatal("SEQ", "Randomization failed in write_read_sequence")
                `uvm_info("SEQ_WR_RD", item.convert2string(), UVM_HIGH)
                finish_item(item);
            end
        endtask
    endclass



    class FIFO_main_sequence extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_main_sequence)

        function new(string name = "FIFO_main_sequence");
            super.new(name);
        endfunction

        task body();
            FIFO_reset_sequence       rst_seq;
            FIFO_write_only_sequence  wr_seq;
            FIFO_read_only_sequence   rd_seq;
            FIFO_write_read_sequence  wr_rd_seq;

            //  reset check 
            rst_seq = FIFO_reset_sequence::type_id::create("rst_seq");
            rst_seq.start(m_sequencer);

            // write only check 
            wr_seq = FIFO_write_only_sequence::type_id::create("wr_seq");
            wr_seq.start(m_sequencer);

            // read only check
            rd_seq = FIFO_read_only_sequence::type_id::create("rd_seq");
            rd_seq.start(m_sequencer);

            //  WR+RD check
            wr_rd_seq = FIFO_write_read_sequence::type_id::create("wr_rd_seq");
            wr_rd_seq.start(m_sequencer);

            // Final reset
            rst_seq = FIFO_reset_sequence::type_id::create("rst_seq2");
            rst_seq.start(m_sequencer);
        endtask
    endclass
endpackage  
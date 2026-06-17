package FIFO_seq_item_pkg;
    import uvm_pkg::*;
   `include "uvm_macros.svh"

    class FIFO_seq_item extends uvm_sequence_item;
        `uvm_object_utils(FIFO_seq_item)

        rand logic [15:0] data_in;
        rand logic        wr_en;
        rand logic        rd_en;
        rand logic        rst_n;

        logic [15:0] data_out;
        logic        full, empty, almostfull, almostempty;
        logic        wr_ack, overflow, underflow;

        int RD_EN_ON_DIST;
        int WR_EN_ON_DIST;

        function new(string name = "FIFO_seq_item");
        super.new(name);          
        WR_EN_ON_DIST = 70;
        RD_EN_ON_DIST = 30;

        endfunction

        // Constraint 1: reset asserted rarely
        constraint rst_c {
            rst_n dist {0 := 5, 1 := 95};
        }

        // Constraint 2: write enable distribution
        constraint wr_en_c {
            wr_en dist {1 := WR_EN_ON_DIST, 0 := (100 - WR_EN_ON_DIST)};
        }

        // Constraint 3: read enable distribution
        constraint rd_en_c {
            rd_en dist {1 := RD_EN_ON_DIST, 0 := (100 - RD_EN_ON_DIST)};
        }


        function string convert2string();
            return $sformatf(
                "\n[STIMULUS] rst=%0b wr_en=%0b rd_en=%0b data_in=0x%04h\n[RESPONSE] data_out=0x%04h full=%0b empty=%0b almostfull=%0b almostempty=%0b wr_ack=%0b overflow=%0b underflow=%0b",
                rst_n, wr_en, rd_en, data_in,
                data_out, full, empty, almostfull, almostempty,
                wr_ack, overflow, underflow
            );
        endfunction

        function string convert2string_stimulus();
            return $sformatf(
                "[STIMULUS] rst=%0b wr_en=%0b rd_en=%0b data_in=0x%04h",
                rst_n, wr_en, rd_en, data_in
            );
        endfunction

        
    endclass
endpackage
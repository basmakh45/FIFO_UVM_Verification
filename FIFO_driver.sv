package FIFO_driver_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import FIFO_seq_item_pkg::*;
    import FIFO_config_pkg::*;

    class FIFO_driver extends uvm_driver #(FIFO_seq_item);
        `uvm_component_utils(FIFO_driver)

        virtual FIFO_if    vif;
        FIFO_seq_item      stim_seq_item;

        function new(string name = "FIFO_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db #(virtual FIFO_if)::get(this, "", "FIFO_IF", vif))
            `uvm_fatal("build_phase", "Unable to get virtual interface")
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);

            stim_seq_item = FIFO_seq_item::type_id::create("stim_seq_item");

            
            vif.rst_n   = 0;
            vif.wr_en   = 0;
            vif.rd_en   = 0;
            vif.data_in = 0;
            @(negedge vif.clk);

            forever begin
                seq_item_port.get_next_item(stim_seq_item);

                // Drive all inputs onto the interface
                vif.data_in = stim_seq_item.data_in;
                vif.wr_en   = stim_seq_item.wr_en;
                vif.rd_en   = stim_seq_item.rd_en;
                vif.rst_n   = stim_seq_item.rst_n;

                @(negedge vif.clk);       

                seq_item_port.item_done();

                `uvm_info("run_phase",
                    stim_seq_item.convert2string_stimulus(), UVM_HIGH)
            end
        endtask

    endclass
endpackage    

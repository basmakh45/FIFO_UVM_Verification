package FIFO_agent_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import FIFO_config_pkg::*;
    import FIFO_seq_item_pkg::*;
    import FIFO_sequencer_pkg::*;
    import FIFO_driver_pkg::*;
    import FIFO_monitor_pkg::*;
    
    class FIFO_agent extends uvm_agent;
        `uvm_component_utils(FIFO_agent)

        FIFO_sequencer  sqr;
        FIFO_driver     drv;
        FIFO_monitor    mon;
        FIFO_config     cfg;

        uvm_analysis_port #(FIFO_seq_item) agt_ap;

        function new(string name = "FIFO_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if (!uvm_config_db #(FIFO_config)::get(this, "", "FIFO_CFG", cfg))
                `uvm_fatal("build_phase", "Unable to get configuration object")

            agt_ap = new("agt_ap", this);

            mon = FIFO_monitor::type_id::create("mon", this);

            if (cfg.agent_mode == UVM_ACTIVE) begin
                sqr = FIFO_sequencer::type_id::create("sqr", this);
                drv = FIFO_driver::type_id::create("drv", this);
            end
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

            mon.vif = cfg.vif;
            mon.mon_ap.connect(agt_ap);

            if (cfg.agent_mode == UVM_ACTIVE) begin
                drv.vif = cfg.vif;
                drv.seq_item_port.connect(sqr.seq_item_export);
            end
        endfunction

    endclass
endpackage 
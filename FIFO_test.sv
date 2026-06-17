package FIFO_test_pkg;
    import uvm_pkg::*;
   `include "uvm_macros.svh"
    import FIFO_env_pkg::*;
    import FIFO_sequences_pkg::*;
    import FIFO_config_pkg::*;

    class FIFO_test extends uvm_test;
        `uvm_component_utils(FIFO_test)

        FIFO_env    env;
        FIFO_config cfg;

        function new(string name = "FIFO_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            // Create config, grab vif, push to all children
            cfg = FIFO_config::type_id::create("cfg");
            if (!uvm_config_db #(virtual FIFO_if)::get(this, "", "FIFO_IF", cfg.vif))
                `uvm_fatal("TEST", "Could not get virtual FIFO_if from config db")

            uvm_config_db #(FIFO_config)::set(this, "*", "FIFO_CFG", cfg);

            env = FIFO_env::type_id::create("env", this);
        endfunction

        
        task run_phase(uvm_phase phase);
            FIFO_main_sequence main_seq;
            phase.raise_objection(this);

            main_seq = FIFO_main_sequence::type_id::create("main_seq");
            main_seq.start(env.agt.sqr);
            
            phase.drop_objection(this);
        endtask



    endclass
endpackage
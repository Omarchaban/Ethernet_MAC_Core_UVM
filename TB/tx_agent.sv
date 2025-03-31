

class tx_agent extends uvm_agent;

`uvm_component_utils(tx_agent);

ethernet_sequencer tx_sequencer;
ethernet_tx_monitor tx_monitor;
ethernet_driver tx_driver;

function new(string name ="ethernet_driver", uvm_component parent);
    super.new(name,parent);
    
    
  
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    
   tx_sequencer = ethernet_sequencer::type_id::create("tx_sequencer",this);
   tx_monitor = ethernet_tx_monitor::type_id::create("tx_monitor",this);
   tx_driver = ethernet_driver::type_id::create("tx_driver",this);
    
  endfunction

  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    tx_driver.seq_item_port.connect(tx_sequencer.seq_item_export);
  endfunction


task run_phase (uvm_phase phase);
	super.run_phase(phase);

endtask

endclass
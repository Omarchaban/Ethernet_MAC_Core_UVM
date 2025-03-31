


class rx_agent extends uvm_agent;

`uvm_component_utils(rx_agent);

ethernet_monitor rx_monitor;

function new(string name ="ethernet_driver", uvm_component parent);
    super.new(name,parent);
    
    
  
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    
  
   rx_monitor = ethernet_monitor::type_id::create("rx_monitor",this);
   
  endfunction

  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
  endfunction


task run_phase (uvm_phase phase);
	super.run_phase(phase);

endtask
endclass
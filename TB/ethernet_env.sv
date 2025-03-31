
class ethernet_env extends uvm_env;


`uvm_component_utils(ethernet_env);

tx_agent TX_agent;
rx_agent RX_agent;

ethernet_scoreboard score;

 ethernet_Coverage_Collector coverage_collector;

function new(string name ="ethernet_env", uvm_component parent);
    super.new(name,parent);
    
    
  
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    
  
   TX_agent = tx_agent::type_id::create("TX_agent",this);
   RX_agent = rx_agent::type_id::create("RX_agent",this);
   score = ethernet_scoreboard::type_id::create("score",this);
    coverage_collector = ethernet_Coverage_Collector::type_id::create("coverage_collector",this);
  endfunction

  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    TX_agent.tx_monitor.tx_monitor_port.connect(score.tx_imp);
    RX_agent.rx_monitor.rx_monitor_port.connect(score.rx_imp);
	  TX_agent.tx_monitor.tx_monitor_port.connect(coverage_collector.analysis_export);


  endfunction


task run_phase (uvm_phase phase);
	super.run_phase(phase);

endtask




endclass

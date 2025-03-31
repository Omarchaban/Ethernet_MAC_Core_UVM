

class ethernet_test extends uvm_test;

`uvm_component_utils(ethernet_test);



ethernet_env env;
rst_seq RST;
normal_seq normal;

undersized_seq undersized;
 small_seq Small;
large_seq Large;
oversized_seq oversized;


function new(string name ="ethernet_test", uvm_component parent);
    super.new(name,parent);
    
    
  
  endfunction
  
function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    
  
   env = ethernet_env::type_id::create("env",this);
   
  endfunction

function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    

  endfunction


  task  run_phase(uvm_phase phase);
  
	super.run_phase(phase);

	 phase.raise_objection(this);
	 
	  RST = rst_seq::type_id::create("RST");	
	
	 RST.start(env.TX_agent.tx_sequencer);
	  
	   #50;
	repeat(50) begin
	  normal = normal_seq::type_id::create("normal");
	 normal.start(env.TX_agent.tx_sequencer);

	 #50;
	end
	repeat(3) begin
	  undersized = undersized_seq::type_id::create("undersized");
	 undersized.start(env.TX_agent.tx_sequencer);

	 #50;
	end
	repeat(3) begin
	  Small = small_seq::type_id::create("Small");
	 Small.start(env.TX_agent.tx_sequencer);

	 #50;
	end
	repeat(3) begin
	  Large = large_seq::type_id::create("Large");
	 Large.start(env.TX_agent.tx_sequencer);

	 #50;
	end
	repeat(3) begin
	  oversized = oversized_seq::type_id::create("oversized");
	 oversized.start(env.TX_agent.tx_sequencer);

	 #50;
	end
         phase.drop_objection(this);

	
  endtask

endclass

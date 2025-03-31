
`uvm_analysis_imp_decl(_tx_monitor_port)
`uvm_analysis_imp_decl(_rx_monitor_port)


class ethernet_scoreboard extends uvm_scoreboard;



`uvm_component_utils(ethernet_scoreboard);

uvm_analysis_imp_tx_monitor_port #(ethernet_seq_item , ethernet_scoreboard) tx_imp;
uvm_analysis_imp_rx_monitor_port #(ethernet_seq_item , ethernet_scoreboard) rx_imp;

ethernet_seq_item tx_fifo[$];
ethernet_seq_item rx_fifo[$];


ethernet_seq_item tx_frame;
	
ethernet_seq_item rx_frame;
	
function void write_tx_monitor_port (ethernet_seq_item Tx_frame);

tx_fifo.push_back(Tx_frame);
		
endfunction

function void write_rx_monitor_port (ethernet_seq_item Rx_frame);

rx_fifo.push_back(Rx_frame);

endfunction


function new (string name = "ethernet_scoreboard" , uvm_component parent);


   super.new(name,parent);

   


endfunction : new







function void build_phase (uvm_phase phase);



     super.build_phase(phase);
	  
	  
	  tx_imp   = new ("tx_imp", this);
	  
    rx_imp   = new ("rx_imp", this);
    
    

endfunction: build_phase


function void connect_phase(uvm_phase phase);


    super.connect_phase(phase);
		  
		  
endfunction: connect_phase


task run_phase(uvm_phase phase);


   super.run_phase(phase);

	
  forever begin
     
	
	
	
		
	wait(tx_fifo.size() && rx_fifo.size() );
	   
	
		tx_frame = tx_fifo.pop_front();
		
		rx_frame = rx_fifo.pop_front();
		
 		
		if(tx_frame.reset_156m25_n | rx_frame.reset_156m25_n) begin
			
			 if(tx_frame.dist_add != rx_frame.dist_add)
	 
	   			 `uvm_error(get_type_name(),$sformatf("Invalid destination address as : tx_dst_add = %h ,rx_dst_add = %h ",tx_frame.dist_add,rx_frame.dist_add))
		 
			//else
				//$display("tx_frame.dist_add == %0d , rx_frame.dist_add == %0d",tx_frame.dist_add,rx_frame.dist_add);
		 
		 
   			 if(tx_frame.src_add != rx_frame.src_add)
	 
	  			  `uvm_error(get_type_name(),$sformatf("Invalid source address as : tx_src_add = %h ,rx_src_add = %h ",tx_frame.src_add,rx_frame.src_add))	 
		 
			//else
				//$display("tx_frame.src_add == %0d , rx_frame.src_add == %0d",tx_frame.src_add,rx_frame.src_add);
		 
		 
		 
  			  if(tx_frame.length != rx_frame.length)
	 
				    `uvm_error(get_type_name(),$sformatf("Invalid ethernet length as : tx_ether_len = %0d ,rx_ether_len = %0d ",tx_frame.length ,rx_frame.length ))		 
				 
		 	//else
				//$display("tx_frame.length == %0d , rx_frame.length == %0d",tx_frame.length,rx_frame.length);
		 
		 		 
		 
		 
    			if(tx_frame.data.size() != rx_frame.data.size())
	 		
	   			 `uvm_error(get_type_name(),$sformatf("Invalid data size as : tx_data_size = %0d ,rx_data_size = %0d ",tx_frame.data.size(),rx_frame.data.size()))		 
			 
		 	//else
				//$display("tx_frame.data.size() == %0d , rx_frame..data.size() == %0d",tx_frame.data.size(),rx_frame.data.size());
		 


		 
	
  			 for(int i=0 ; i<tx_frame.data.size() ; i++) begin
	
				if(tx_frame.data[i] != rx_frame.data[i])
		      
		 		   `uvm_error(get_type_name(),$sformatf("Invalid data : tx_data = %0d at index %0d ,rx_data = %0d at index %0d ",tx_frame.data[i],i,rx_frame.data[i],i))		

		
			end
		end
    

end


endtask: run_phase



endclass

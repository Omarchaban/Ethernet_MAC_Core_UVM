
class ethernet_tx_monitor extends uvm_monitor ;

`uvm_component_utils(ethernet_tx_monitor);

virtual eth_intf intf; 
uvm_analysis_port #(ethernet_seq_item) tx_monitor_port;

ethernet_seq_item tempframe;
	logic [63:0] temp_data;
logic [7:0] tempfifo[$];
int flag =0;
semaphore key;
 function new(string name ="ethernet_tx_monitor", uvm_component parent);
    super.new(name,parent);
    
    
  
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    tx_monitor_port = new("tx_monitor_port" , this);
   if(!(uvm_config_db #(virtual eth_intf) ::get(this,"*","intf",intf)))
       		`uvm_error("tx monitor class","failed to get virtual interface");
    if(!(uvm_config_db #(semaphore) ::get(this,"*","key",key)))
       		`uvm_error("tx monitor class","failed to get sem");
   
  endfunction
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
  endfunction

task run_phase(uvm_phase phase) ;

	super.run_phase(phase);
	tempframe = ethernet_seq_item::type_id::create("tempframe");
	//@(posedge intf.clk_156m25);
	forever begin 
		@(negedge intf.clk_156m25);
		//key.get(1);
		if(intf.reset_156m25_n && intf.reset_xgmii_rx_n && intf.reset_xgmii_tx_n) begin
		
			if(intf.pkt_tx_val) begin
				//$display("intf.pkt_tx_data ======== %0d " ,intf.pkt_tx_data);
				if(intf.pkt_tx_sop) begin
					//intf.pkt_tx_sop=0;
					tempframe.dist_add = intf.pkt_tx_data[63:16];
					tempframe.src_add[47:32] = intf.pkt_tx_data[15:0];
					tempframe.reset_156m25_n = intf.reset_156m25_n;
					tempframe.reset_xgmii_rx_n = intf.reset_xgmii_rx_n;
					tempframe.reset_xgmii_tx_n = intf.reset_xgmii_tx_n;
					tempframe.wb_rst_i = intf.wb_rst_i;
					
				end
			
				else if(!intf.pkt_tx_sop  && !intf.pkt_tx_eop && !flag) begin
					tempframe.src_add[31:0] = intf.pkt_tx_data[63:32];
					tempframe.length = intf.pkt_tx_data[31:16];
					tempfifo.push_back(intf.pkt_tx_data[15:8]);
					tempfifo.push_back(intf.pkt_tx_data[7:0]);	
					flag=1;
					
						
				end
				else if(!intf.pkt_tx_sop  && !intf.pkt_tx_eop && flag) begin
					temp_data = intf.pkt_tx_data;
					for(int i =0 ;i<8; i = i+1) begin
						tempfifo.push_back(temp_data[63:56]);
						temp_data = temp_data <<8;	
					end	
				end
				else if(intf.pkt_tx_eop) begin
					temp_data = intf.pkt_tx_data;
					flag=0;
					if(intf.pkt_tx_mod == 0 ) begin
						for(int i =0 ;i<8; i = i+1) begin
							tempfifo.push_back(temp_data[63:56]);
							temp_data = temp_data <<8;	
						end
					end
					else begin
						for(int i =0 ;i<8; i = i+1) begin
							tempfifo.push_back(temp_data[7:0]);
							temp_data = temp_data >> 8;	
						end
					end
				/*for(int i=0 ; i<tempfifo.size()  ; i++) begin
					$display("fifo[%0d] in tx ==== %0d",i,tempfifo[i]);
				
				end*/
					tempframe.data = new[tempfifo.size()];
					for(int i=0 ; tempfifo.size() !=0 ; i++) begin
						tempframe.data[i] = tempfifo.pop_front();
				
					end
						wait(intf.pkt_rx_eop && !intf.pkt_rx_err);
						tx_monitor_port.write(tempframe);
					
				end
			
			
			//@(posedge intf.clk_156m25); // might be removed
			
			end
		end
		

	end


endtask





endclass

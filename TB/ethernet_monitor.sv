
class ethernet_monitor extends uvm_monitor;


`uvm_component_utils (ethernet_monitor);

virtual eth_intf intf;

ethernet_seq_item frame;
	int flag=0;
	logic[63:0] temp_data;

uvm_analysis_port #(ethernet_seq_item) rx_monitor_port;


logic [7:0] fifo[$];

 function new(string name ="ethernet_driver", uvm_component parent);
    super.new(name,parent);
    
    
  
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    rx_monitor_port = new("rx_monitor_port" , this);
   if(!(uvm_config_db #(virtual eth_intf) ::get(this,"*","intf",intf)))
       		`uvm_error("driver class","failed to get virtual interface");
    
  endfunction
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
  endfunction




task run_phase (uvm_phase phase);
	int flag =0;
	super.run_phase(phase);
	frame = ethernet_seq_item::type_id::create("frame");
	forever begin
		@(negedge intf.clk_156m25)
		//$display("intf.pkt_rx_avail ============= %0d " , intf.pkt_rx_avail);
		if(intf.reset_156m25_n && intf.reset_xgmii_rx_n && intf.reset_xgmii_tx_n) begin
			if(intf.pkt_rx_avail) begin
				intf.pkt_rx_ren =1;
				frame.reset_156m25_n = intf.reset_156m25_n;
				frame.reset_xgmii_rx_n = intf.reset_xgmii_rx_n;
				frame.reset_xgmii_tx_n = intf.reset_xgmii_tx_n;
				frame.wb_rst_i = intf.wb_rst_i;
			end
			
			if(intf.pkt_rx_val ) begin
				//$display("intf.pkt_rx_data ============= %0d " ,intf.pkt_rx_data );
		
				if(intf.pkt_rx_sop ) begin
					frame.dist_add = intf.pkt_rx_data[63:16];
					frame.src_add[47:32] = intf.pkt_rx_data[15:0];
					$display("11111111111111");
					/*@(posedge intf.clk_156m25);
					frame.src_add[31:0] = intf.pkt_rx_data[63:32];
					frame.length = intf.pkt_rx_data[31:16];
					fifo.push_back(intf.pkt_rx_data[15:8]);
					fifo.push_back(intf.pkt_rx_data[7:0]);	
					@(posedge intf.clk_156m25);*/
				end
				else if(!intf.pkt_rx_sop  && !intf.pkt_rx_eop && !flag) begin
					frame.src_add[31:0] = intf.pkt_rx_data[63:32];
					frame.length = intf.pkt_rx_data[31:16];
					fifo.push_back(intf.pkt_rx_data[15:8]);
					fifo.push_back(intf.pkt_rx_data[7:0]);	
					flag=1;
					//$display("2222222222222222");
					
				end

				else if(!intf.pkt_rx_sop  && !intf.pkt_rx_eop && flag) begin
					temp_data = intf.pkt_rx_data;
					for(int i =0 ;i<8; i = i+1) begin
						fifo.push_back(temp_data[63:56]);
						temp_data = temp_data <<8;	
					end
					
					
				end
				else if(intf.pkt_rx_eop) begin
					intf.pkt_rx_ren = 1'b0;
					flag=0;
					temp_data = intf.pkt_rx_data;
					if(intf.pkt_rx_mod == 0 ) begin
						for(int i =0 ;i<8; i = i+1) begin
							fifo.push_back(temp_data[63:56]);
							
							temp_data = temp_data <<8;	
						end
					end
					else begin
						for(int i =0 ;i<8; i = i+1) begin
							fifo.push_back(temp_data[7:0]);
							temp_data = temp_data >> 8;	
						end
					end
					frame.data = new[fifo.size()];
					/*for(int i=0 ; i<fifo.size()  ; i++) begin
						$display("fifo[%0d] in mon ==== %0d " , i ,fifo[i]);
					end*/
					for(int i=0 ; fifo.size() !=0 ; i++) begin
						//$display("fifo[%0d] ==== %0d " , i ,fifo[i]);
						frame.data[i] = fifo.pop_front();
					end
					if(!intf.pkt_rx_err ) begin
						//$display("frame.length =============== %0d ",frame.data.size());
					
						rx_monitor_port.write(frame);
					end
					else $display("============Invalid size of frame or CRC ERROR==================="); 
				end
				
				
			end


		end
		else begin
			frame.reset_156m25_n = intf.reset_156m25_n;
			frame.reset_xgmii_rx_n = intf.reset_xgmii_rx_n;
			frame.reset_xgmii_tx_n = intf.reset_xgmii_tx_n;
			frame.wb_rst_i = intf.wb_rst_i;
			//$display("frame.length =============== %0d ",frame.data.size());
					
			//rx_monitor_port.write(frame);
		end

	end




endtask



endclass

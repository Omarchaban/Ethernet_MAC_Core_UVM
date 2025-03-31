
class ethernet_driver extends uvm_driver#(ethernet_seq_item);

`uvm_component_utils(ethernet_driver);

virtual eth_intf intf;
ethernet_seq_item frame;

logic [63:0] data;
	int len;

semaphore key;
 function new(string name ="ethernet_driver", uvm_component parent);
    super.new(name,parent);
    
    
  
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
   // key =  new(1);
   if(!(uvm_config_db #(virtual eth_intf) ::get(this,"*","intf",intf)))
       		`uvm_error("driver class","failed to get virtual interface");
    
	if(!(uvm_config_db #(semaphore) ::get(this,"*","key",key)))
       		`uvm_error("driver class","failed to get sem");
   
  
  endfunction



  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    
  endfunction



task run_phase(uvm_phase phase);

super.run_phase(phase);

frame = ethernet_seq_item::type_id::create("frame");
forever begin
	
	seq_item_port.get_next_item(frame);
	drive(frame);
	seq_item_port.item_done();	

end

endtask

task drive( ethernet_seq_item frame);
	
	data =0;
	if(frame.reset_156m25_n && frame.reset_xgmii_rx_n && frame.reset_xgmii_tx_n) begin
		
		@(posedge intf.clk_156m25);	
		intf.reset_156m25_n = frame.reset_156m25_n;
		intf.reset_xgmii_rx_n = frame.reset_xgmii_rx_n;
		intf.reset_xgmii_tx_n = frame.reset_xgmii_tx_n;
		intf.wb_rst_i = frame.wb_rst_i;
		intf.pkt_tx_sop = 1;
		intf.pkt_tx_eop =0;
		intf.pkt_tx_val =1;
		
		intf.pkt_tx_mod = 0;
		intf.pkt_tx_data = {frame.dist_add , frame.src_add[47:32]};
		
		//key.put(1);
		@(posedge intf.clk_156m25);	
		intf.pkt_tx_sop = 0;
		//$display("time ========= %0d , intf.pkt_tx_sop  == %0d" ,$time, intf.pkt_tx_sop);
		
		if(frame.data.size() == 2) begin
			intf.pkt_tx_sop = 0;
			intf.pkt_tx_eop =1;
			intf.pkt_tx_val =1;
			intf.pkt_tx_mod = 0;
			intf.pkt_tx_data = {frame.src_add[31:0] , frame.length , frame.data[0] , frame.data[1]};
			//$display("time ========= %0d ,intf.pkt_tx_data   == %0d" ,$time, intf.pkt_tx_data );
			//key.put(1);
			
		end
		else begin
			intf.pkt_tx_sop = 0;
			intf.pkt_tx_eop =0;
			intf.pkt_tx_val =1;
			intf.pkt_tx_mod = 0;
			intf.pkt_tx_data = {frame.src_add[31:0] , frame.length , frame.data[0] , frame.data[1]};
			//$display("time ========= %0d , intf.pkt_tx_data   == %0d" ,$time, intf.pkt_tx_data );
			//key.put(1);
		
		end
		if(frame.data.size() % 8 == 0 ) begin
			len = 	frame.data.size() ; 
		end
		else begin
			len = ( 8 - (frame.data.size() % 8) ) +	frame.data.size()  ;
			 
		end
		//$display("frame.data.size() ====== %0d   \n" , frame.data.size());
		for(int i =0 ; i<len ; i = i+8) begin
			while(intf.pkt_tx_full)begin
				 @(posedge intf.clk_156m25);
		       		intf.pkt_tx_val    <= 1'b0;
         			intf.pkt_tx_sop    <= 1'b0;
          			intf.pkt_tx_eop    <= 1'b0;
          			intf.pkt_tx_mod    <= $urandom_range(7,0);
          			intf.pkt_tx_data   <= 0;
				$display("fifo is full ==============");
			end
			if( i != len -8) begin
				@(posedge intf.clk_156m25);	

				intf.pkt_tx_sop = 0;
				intf.pkt_tx_eop =0;
				intf.pkt_tx_val =1;
				intf.pkt_tx_mod = 0;
				intf.pkt_tx_data = {    
							frame.data[i+2]
							,frame.data[i+3]
							,frame.data[i+4]
							,frame.data[i+5]
							,frame.data[i+6]
							,frame.data[i+7]
							,frame.data[i+8]	
							,frame.data[i+9]
							};
				//$display("time ========= %0d , intf.pkt_tx_data   == %0d" ,$time, intf.pkt_tx_data );
				//key.put(1);
				/*data = intf.pkt_tx_data;
				for(int j =0 ;j<8; j = j+1) begin
							$display("intf  === %0d " ,data[63:56]);
					
							data = data <<8;
							
							
						end*/
				//$display("i ======= %0d , len ======== %0d \n",i,len);
				
			end
			else begin
				@(posedge intf.clk_156m25);	
				intf.pkt_tx_sop = 0;
				intf.pkt_tx_eop =1;
				//$display("intf.pkt_tx_eop========== %0d",intf.pkt_tx_eop);	
		
				intf.pkt_tx_val =1;
				intf.pkt_tx_mod = (frame.data.size() ) % 8;
				if(intf.pkt_tx_mod == 0)        data = {frame.data[i],frame.data[i+1],frame.data[i+2],frame.data[i+3],frame.data[i+4],frame.data[i+5],frame.data[i+6],frame.data[i+7]};
				else if (intf.pkt_tx_mod == 1 ) data = {frame.data[i],{56{1'b0}}};
				else if (intf.pkt_tx_mod == 2 ) data = {frame.data[i],frame.data[i+1],{48{1'b0}}};
				else if (intf.pkt_tx_mod == 3 ) data = {frame.data[i],frame.data[i+1],frame.data[i+2],{40{1'b0}}};
				else if (intf.pkt_tx_mod == 4 ) data = {frame.data[i],frame.data[i+1],frame.data[i+2],frame.data[i+3],{32{1'b0}}};
				else if (intf.pkt_tx_mod == 5 ) data = {frame.data[i],frame.data[i+1],frame.data[i+2],frame.data[i+3],frame.data[i+4],{24{1'b0}}};
				else if (intf.pkt_tx_mod == 6 ) data = {frame.data[i],frame.data[i+1],frame.data[i+2],frame.data[i+3],frame.data[i+4],frame.data[i+5], {16{1'b0}}};
				else if (intf.pkt_tx_mod == 7 ) data = {frame.data[i],frame.data[i+1] ,frame.data[i+2],frame.data[i+3],frame.data[i+4],frame.data[i+5],frame.data[i+6], {8{1'b0}} };
				intf.pkt_tx_data = data;
				//key.put(1);
				/*for(int j =0 ;j<8; j = j+1) begin
							$display("intf  === %0d " ,data[63:56]);
					
							data = data <<8;
							
							
				end*/
				/*for(int i=0 ;i< frame.data.size()  ; i++) begin
					$display("fifo[%0d] in driver === %0d " , i ,frame.data[i]);
					
				end*/
				//@(pedge intf.clk_156m25);	
			end
			
		end
		repeat(frame.IFG) begin 
	        	@(posedge intf.clk_156m25);  
	 		intf.pkt_tx_val = 1'b0;
	 		intf.pkt_tx_sop = 1'b0;
	   		intf.pkt_tx_mod = 0;
	     		intf.pkt_tx_eop = 1'b0;
	     		intf.pkt_tx_data = 0;
		end

	end
	else begin
	
		intf.reset_156m25_n = frame.reset_156m25_n;
		intf.reset_xgmii_rx_n = frame.reset_xgmii_rx_n;
		intf.reset_xgmii_tx_n = frame.reset_xgmii_tx_n;
		intf.wb_rst_i = frame.wb_rst_i;
		intf.pkt_tx_sop = 0;
		intf.pkt_tx_eop =0;
		intf.pkt_tx_val =0;
		intf.pkt_tx_data =0;
	end
endtask :drive


endclass
/*intf.pkt_tx_data = {    
							frame.data[i+9]
							,frame.data[i+8]
							,frame.data[i+7]
							,frame.data[i+6]
							,frame.data[i+5]
							,frame.data[i+4]
							,frame.data[i+3]	
							,frame.data[i+2]
							};*/
/*if(intf.pkt_tx_mod == 0) data = {frame.data[i+9],frame.data[i+8],frame.data[i+7],frame.data[i+6],frame.data[i+5],frame.data[i+4],frame.data[i+3],frame.data[i+2]};
				else if (intf.pkt_tx_mod == 1 ) data = { 56{1'b0}, frame.data[i+3],frame.data[i+2]};
				else if (intf.pkt_tx_mod == 2 ) data = { 48{1'b0}, frame.data[i+4],frame.data[i+3],frame.data[i+2]};
				else if (intf.pkt_tx_mod == 3 ) data = { 40{1'b0}, frame.data[i+5],frame.data[i+4],frame.data[i+3],frame.data[i+2]};
				else if (intf.pkt_tx_mod == 4 ) data = { 32{1'b0}, frame.data[i+6],frame.data[i+5],frame.data[i+4],frame.data[i+3],frame.data[i+2]};
				else if (intf.pkt_tx_mod == 5 ) data = { 24{1'b0}, frame.data[i+7],frame.data[i+6],frame.data[i+5],frame.data[i+4],frame.data[i+3],frame.data[i+2]};
				else if (intf.pkt_tx_mod == 6 ) data = { 16{1'b0}, frame.data[i+8],frame.data[i+7],frame.data[i+6],frame.data[i+5],frame.data[i+4],frame.data[i+3],frame.data[i+2]};
				else if (intf.pkt_tx_mod == 7 ) data = { 8{1'b0} , frame.data[i+9],frame.data[i+8] ,frame.data[i+7],frame.data[i+6],frame.data[i+5],frame.data[i+4],frame.data[i+3],frame.data[i+2]};*/
				
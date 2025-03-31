
class base_seq extends uvm_sequence #(ethernet_seq_item);

`uvm_object_utils (base_seq);

function new(string name = "base_seq");

super.new(name);

endfunction



endclass


class rst_seq extends base_seq;

	`uvm_object_utils (rst_seq);
		ethernet_seq_item rst_pkt;
	function new(string name = "rst_seq");

		super.new(name);

	endfunction


	task body ();
		
		 rst_pkt = ethernet_seq_item::type_id::create("rst_pkt");
		start_item(rst_pkt);
		if(!(rst_pkt.randomize() with {
						reset_156m25_n ==0;
						wb_rst_i ==1;
						reset_xgmii_rx_n ==0;
						reset_xgmii_tx_n ==0;
						data.size() == 0;
						IFG == 0;
						}))
						`uvm_error(get_type_name(),"randomization failed in rst_pkt")
		finish_item(rst_pkt);

	endtask

endclass


class normal_seq extends base_seq;
`uvm_object_utils (normal_seq);
	ethernet_seq_item normal_pkt;
	function new(string name = "rst_seq");

		super.new(name);
	endfunction
	task body ();
		 normal_pkt = ethernet_seq_item::type_id::create("normal_pkt");
		start_item(normal_pkt);
		if(!(normal_pkt.randomize() with {
						reset_156m25_n ==1;
						wb_rst_i ==0;
						reset_xgmii_rx_n ==1;
						reset_xgmii_tx_n ==1;
						//length == 50;
						data.size() inside {[2000:3000]};
						IFG inside {[10:50]};
						}))
							`uvm_error(get_type_name(),"randomization failed in normal_pkt")
		finish_item(normal_pkt);

	endtask
endclass


class undersized_seq extends base_seq;
`uvm_object_utils (undersized_seq);
	ethernet_seq_item undersized_seq;
	function new(string name = "undersized_seq");

		super.new(name);
	endfunction
	task body ();
		 undersized_seq = ethernet_seq_item::type_id::create("undersized_seq");
		start_item(undersized_seq);
		if(!(undersized_seq.randomize() with {
						reset_156m25_n ==1;
						wb_rst_i ==0;
						reset_xgmii_rx_n ==1;
						reset_xgmii_tx_n ==1;
						//length == 50;
						data.size() inside {[2:46]};
						IFG inside {[10:50]};
						}))
							`uvm_error(get_type_name(),"randomization failed in undersized_seq")
		finish_item(undersized_seq);

	endtask
endclass

class small_seq extends base_seq;
`uvm_object_utils (small_seq);
	ethernet_seq_item small_seq;
	function new(string name = "small_seq");

		super.new(name);
	endfunction
	task body ();
		 small_seq = ethernet_seq_item::type_id::create("small_seq");
		start_item(small_seq);
		if(!(small_seq.randomize() with {
						reset_156m25_n ==1;
						wb_rst_i ==0;
						reset_xgmii_rx_n ==1;
						reset_xgmii_tx_n ==1;
						//length == 50;
						data.size() inside {[46:50]};
						IFG inside {[10:50]};
						}))
							`uvm_error(get_type_name(),"randomization failed in small_seq")
		finish_item(small_seq);

	endtask
endclass

class large_seq extends base_seq;
`uvm_object_utils (large_seq);
	ethernet_seq_item large_seq;
	function new(string name = "large_seq");

		super.new(name);
	endfunction
	task body ();
		 large_seq = ethernet_seq_item::type_id::create("large_seq");
		start_item(large_seq);
		if(!(large_seq.randomize() with {
						reset_156m25_n ==1;
						wb_rst_i ==0;
						reset_xgmii_rx_n ==1;
						reset_xgmii_tx_n ==1;
						//length == 50;
						data.size() inside {[1450:1500]};
						IFG inside {[10:50]};
						}))
							`uvm_error(get_type_name(),"randomization failed in large_seq")
		finish_item(large_seq);

	endtask
endclass

class oversized_seq extends base_seq;
`uvm_object_utils (oversized_seq);
	ethernet_seq_item oversized_seq;
	function new(string name = "oversized_seq");

		super.new(name);
	endfunction
	task body ();
		 oversized_seq = ethernet_seq_item::type_id::create("oversized_seq");
		start_item(oversized_seq);
		if(!(oversized_seq.randomize() with {
						reset_156m25_n ==1;
						wb_rst_i ==0;
						reset_xgmii_rx_n ==1;
						reset_xgmii_tx_n ==1;
						//length == 50;
						data.size() inside {[1500:5000]};
						IFG inside {[10:50]};
						}))
							`uvm_error(get_type_name(),"randomization failed in oversized_seq")
		finish_item(oversized_seq);

	endtask



endclass
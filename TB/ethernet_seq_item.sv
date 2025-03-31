
class ethernet_seq_item extends uvm_sequence_item;

`uvm_object_utils(ethernet_seq_item);


rand logic [47:0] dist_add;
rand logic [47:0] src_add;
rand logic [7:0] data [];
rand logic [15:0] length;
rand logic [31:0] IFG;
rand bit wb_rst_i;
rand bit reset_156m25_n;
rand bit reset_xgmii_rx_n ;
rand bit reset_xgmii_tx_n;


constraint len {

	data.size() inside {[0:5000]};

}

constraint ifg {
	length inside {[0:50]};
}
endclass

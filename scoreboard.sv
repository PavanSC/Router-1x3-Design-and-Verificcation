class scoreboard extends uvm_scoreboard;

  `uvm_component_utils(scoreboard);

  uvm_tlm_analysis_fifo #(source_trans) source_fifo;
  uvm_tlm_analysis_fifo #(dest_trans) dest_fifo[];

  source_trans source_data;
  source_trans source_cov_data;
  dest_trans dest_data;
  dest_trans dest_cov_data;

  int data_verified_count;

  env_config e_cfg;

  covergroup fcov1;
     option.per_instance = 1;
   
     HEADER: coverpoint source_cov_data.header[1:0]{
                                                  bins fifo0 = {2'b00};
                                                  bins fifo1 = {2'b01};
                                                  bins fifo2 = {2'b10};}

   
    PAYLOAD_SIZE: coverpoint source_cov_data.header[7:2]{
                                                    bins small_packet = {[1:15]};
                                                    bins medium_packet = {[16:30]};
                                                    bins large_packet = {[31:63]};}

   BAD_PKT: coverpoint source_cov_data.err {bins bad_pkt = {0,1};}

   HEADER_X_PAYLOAD_SIZE : cross HEADER, PAYLOAD_SIZE;
endgroup


covergroup fcov2;
     option.per_instance = 1;
   
     HEADER: coverpoint dest_cov_data.header[1:0]{
                                                  bins fifo0 = {2'b00};
                                                  bins fifo1 = {2'b01};
                                                  bins fifo2 = {2'b10};}

   
    PAYLOAD_SIZE: coverpoint dest_cov_data.header[7:2]{
                                                    bins small_packet = {[1:15]};
                                                    bins medium_packet = {[16:30]};
                                                    bins large_packet = {[31:63]};}

   //BAD_PKT: coverpoint dest_cov_data.err {bins bad_pkt = {1};}

   HEADER_X_PAYLOAD_SIZE : cross HEADER, PAYLOAD_SIZE;
endgroup



  function new(string name = "scoreboard", uvm_component parent);
    super.new(name, parent);
    fcov1=new();
    fcov2=new();
  endfunction

  extern function void build_phase(uvm_phase phase);
   extern function void check_data(dest_trans xtn);
  extern task run_phase(uvm_phase phase);

endclass


function void scoreboard::build_phase(uvm_phase phase);

  super.build_phase(phase);

  `uvm_info("SCOREBOARD", "This is build_phase", UVM_LOW)


  if (!uvm_config_db#(env_config)::get(this, "", "env_config", e_cfg)) begin
    `uvm_fatal("SCOREBOARD", "Set the env_config properly")
  end

  source_data = source_trans::type_id::create("source_data");
  dest_data   = dest_trans::type_id::create("dest_data");

  source_fifo = new("source_fifo", this);
  dest_fifo   = new[e_cfg.no_of_dest_agt];

  foreach (dest_fifo[i]) begin
    dest_fifo[i] = new($sformatf("dest_fifo[%0d]", i), this);
  end

endfunction : build_phase



task scoreboard::run_phase(uvm_phase phase);

  `uvm_info("SCOREBOARD", "This is run_phase", UVM_LOW)
fork
  begin

   forever 
    begin
    

      // For Source
     
        source_fifo.get(source_data);
        source_data.print();
        source_cov_data=source_data;
        fcov1.sample();
      end
   end
      // For Destination
      begin
       forever
        begin
        fork
          begin
            dest_fifo[0].get(dest_data);
            dest_data.print();
            check_data(dest_data);
            dest_cov_data=dest_data;
            fcov2.sample();
          end
          begin
            dest_fifo[1].get(dest_data);
            dest_data.print();
            check_data(dest_data);
            dest_cov_data=dest_data;
            fcov2.sample();
          end
          begin
            dest_fifo[2].get(dest_data);
            dest_data.print();
            check_data(dest_data);
            dest_cov_data=dest_data;
            fcov2.sample();
          end
       join_any
       disable fork;
      end
    end
    join
  

endtask : run_phase


function void scoreboard::check_data(dest_trans xtn);

  if(source_data.header==xtn.header)
     `uvm_info("SB","Header info matches",UVM_MEDIUM)
  else
     `uvm_error("SB","Header not matches")


 if(source_data.payload==xtn.payload)
     `uvm_info("SB","Payload info matches",UVM_MEDIUM)
  else
     `uvm_error("SB","Payload not matches")



 if(source_data.parity==xtn.parity)
     `uvm_info("SB","Parity info matches",UVM_MEDIUM)
  else
     `uvm_error("SB","Parity not matches")

 data_verified_count++;

endfunction


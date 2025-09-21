module top ();

reg             clk;    
reg             rst;    
reg             req3;   
reg             req2;   
reg             req1;   
reg             req0;   
wire            gnt3;   
wire            gnt2;   
wire            gnt1;   
wire            gnt0;  

// Clock generator
always #1 clk = ~clk;

initial begin
  // 1. Setup, Reset, and Monitoring
  $dumpfile("arbiter.vcd");
  $dumpvars(0, top); // Dump all signals in the 'top' module and below

  $monitor("Time=%0t rst=%b reqs=%b%b%b%b -> gnts=%b%b%b%b",
           $time, rst, req3, req2, req1, req0, gnt3, gnt2, gnt1, gnt0);

  clk = 0;
  rst = 1;
  {req3, req2, req1, req0} = 4'b0000;
  #10 rst = 0;

  // 2. TEST CASE: Single request from lowest priority
  @(posedge clk);
  req0 <= 1;
  @(posedge clk);
  // Wait for grant to be released
  while (gnt0) @(posedge clk);
  req0 <= 0;
  #5;

  // 3. TEST CASE: Simultaneous requests to test priority
  @(posedge clk);
  $display("\n--- Testing Priority: req2 and req1 assert simultaneously ---");
  req2 <= 1;
  req1 <= 1;
  @(posedge clk); // Give arbiter time to grant
  #2; // Let signals settle for monitoring
  // Because of the bug in your arbiter, req2 will always win here.
  // If it were round-robin, the winner would depend on the last grant.
  @(posedge clk);
  req2 <= 0;
  req1 <= 0;
  #5;

  // 4. TEST CASE: Test bus busy logic
  @(posedge clk);
  $display("\n--- Testing Bus Busy: req3 gets grant, req0 requests while busy ---");
  req3 <= 1; // req3 gets the grant
  repeat(2) @(posedge clk);
  req0 <= 1; // Now req0 asserts, but it should be ignored
  repeat(3) @(posedge clk); // Hold req3 for a few cycles
  req3 <= 0; // Release the bus
  req0 <= 0;
  
  // 5. End Simulation
  #20 $finish;
end

// Connect the DUT
arbiter U (
 clk,    
 rst,    
 req3,   
 req2,   
 req1,   
 req0,   
 gnt3,   
 gnt2,   
 gnt1,   
 gnt0   
);

endmodule

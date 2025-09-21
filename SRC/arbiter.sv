//
// Round-Robin Arbiter for 4 Requesters
// - Correctly implements fair, rotating priority.
// - Logic has been simplified for clarity and scalability.
//
module arbiter (
  // System Signals
  input        clk,
  input        rst,

  // Request Inputs
  input        req3,
  input        req2,
  input        req1,
  input        req0,

  // Grant Outputs
  output       gnt3,
  output       gnt2,
  output       gnt1,
  output       gnt0
);

  // Combine individual requests and grants into vectors for easier processing
  wire  [3:0]  req = {req3, req2, req1, req0};
  reg   [3:0]  gnt;

  // Internal signals for arbitration logic
  reg   [1:0]  priority_mask; // Stores the binary value of the last grant
  wire         bus_busy;      // High when a granted request is active
  reg   [3:0]  next_gnt;      // Combinational logic for the next grant decision
  
  // The bus is busy if any granted line still has an active request
  assign bus_busy = |(gnt & req);

  // Priority Arbitration Logic (Combinational)
  // This block determines who gets the grant if the bus is free.
  integer i;
  always @(*) begin
    next_gnt = 4'b0000; // By default, no one gets the grant

    // This loop implements the round-robin priority.
    // It starts checking from the requester AFTER the one that was last granted.
    // The modulo (%) operator makes the priority wrap around from 3 back to 0.
    for (i = 0; i < 4; i = i + 1) begin
      if (req[(priority_mask + 1 + i) % 4]) begin
        next_gnt[(priority_mask + 1 + i) % 4] = 1'b1;
        break; // Grant to the first valid requester and stop searching
      end
    end
  end

  // Grant and Mask Register Logic (Sequential)
  // This block registers the grant decision and updates the priority mask.
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      gnt <= 4'b0000;
      priority_mask <= 2'b00;
    end else begin
      if (!bus_busy) begin // Only arbitrate for a new grant if the bus is free
        gnt <= next_gnt;

        // If a new grant was awarded, update the mask to that level.
        // This makes the current winner the next lowest priority.
        if (next_gnt[0])      priority_mask <= 2'b00;
        else if (next_gnt[1]) priority_mask <= 2'b01;
        else if (next_gnt[2]) priority_mask <= 2'b10;
        else if (next_gnt[3]) priority_mask <= 2'b11;
      end
      // If bus_busy is true, the grant is held (no change to 'gnt' register).
    end
  end

  // Drive the individual one-hot grant outputs
  assign gnt3 = gnt[3];
  assign gnt2 = gnt[2];
  assign gnt1 = gnt[1];
  assign gnt0 = gnt[0];

endmodule

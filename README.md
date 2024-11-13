This project involves designing and verifying a 1x3 router module. The router directs data from a single input to one of three possible output channels based on a 2-bit control signal. The verification environment includes a scoreboard and coverage metrics to ensure comprehensive testing of the router functionality.


Design Specifications
Router Architecture
The 1x3 router design includes:
1 Input Channel: Accepts packet data and control signals.
3 Output Channels: Routes data to one of three output channels based on the control logic.
Routing Logic: Determines the output channel based on a 2-bit select signal.
Error Handling: Manages cases where invalid control signals or corrupted packets are detected.
Busy State: Indicates when the router is processing and cannot accept new packets.
Packet Validation: Ensures only valid packets are routed.
Signal Definitions
Input Signals:

Data Input (data_in): The main data bus for incoming data packets.
Select Input (sel): A 2-bit control signal to route data to specific outputs:

00: Route to Output 0

01: Route to Output 1

10: Route to Output 2

Valid Input (pkt_valid): Indicates if a valid packet is present on data_in.
Error Signal (error): Flags errors, such as an invalid select signal or corrupted packet.
Busy Signal (busy): Indicates that the router is busy processing and temporarily cannot accept new data.
Clock (clk): Clock signal for synchronous operation.
Reset (rst_n): Active low reset signal.
Output Signals:

Output Data (data_out[0:2]): Routed data for each output channel.
Valid Outputs (valid_out[0:2]): Indicates valid data on each output channel.
Busy Signal (busy_out): Shows that the router is currently processing data for an output channel.
Error Signal (error_out): Indicates an error condition on the output side.

Verification Plan

Verification Goals
Confirm that the router correctly routes packets based on the sel signal.
Ensure that packets are only routed when pkt_valid is high.
Verify that errors are flagged correctly and that the error signal behaves as expected for invalid sel values or corrupted packets.
Ensure busy signal management correctly reflects the router’s active state.

Test Scenarios
Basic Routing:
Route packets to each output based on valid sel values (00, 01, and 10).
Verify that each packet is routed to the correct output with pkt_valid set high.

Error Scenarios:
Apply the reserved sel value 11 to trigger an error.
Inject corrupted packets and verify that the error signal is asserted.
Busy and Packet Validity:

Activate the busy signal to simulate ongoing data processing, ensuring that new packets are not routed until busy is cleared.
Check that the router does not forward any data if pkt_valid is low.
Reset Behavior:

Ensure that all signals reset to their default states upon asserting rst_n.
Testbench Structure
The testbench consists of the following components:

Driver: Generates inputs to test different scenarios based on the router’s routing, error, and busy logic.
Monitor: Observes the input and output channels.
Scoreboard: Compares actual outputs with expected results to determine pass/fail conditions.

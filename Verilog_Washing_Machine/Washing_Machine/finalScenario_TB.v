module scenarios_TB;

    // Inputs
    reg clk;
    reg reset;
    reg start;
    reg pause;
    reg [2:0] preset;
    reg [2:0] custom_temp;
    reg [2:0] custom_speed;
    reg [3:0] custom_cycles;
    reg [5:0] custom_dry_timer;
    reg [2:0] custom_water_level;
    reg door_open_signal;
    reg waterflow;
    reg [2:0] water_level_reading;
    reg power_cut;

    // Outputs
    wire [2:0] speed;
    wire [2:0] temp;
    wire [3:0] cycles;
    wire [5:0] dry_timer;
    wire [2:0] water_level;
    wire rinse_complete;
    wire [5:0] full_state;
    wire [3:0] state;
    wire [1:0] errorpause;
    wire alarm;
    wire finishedAlarm;

    // Instantiate the WashingMachine module
    WashingMachine dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .pause(pause),
        .preset(preset),
        .custom_temp(custom_temp),
        .custom_speed(custom_speed),
        .custom_cycles(custom_cycles),
        .custom_dry_timer(custom_dry_timer),
        .custom_water_level(custom_water_level),
        .door_open_signal(door_open_signal),
        .waterflow(waterflow),
        .water_level_reading(water_level_reading),
        .power_cut(power_cut),
        .speed(speed),
        .temp(temp),
        .cycles(cycles),
        .dry_timer(dry_timer),
        .water_level(water_level),
        .rinse_complete(rinse_complete),
        .full_state(full_state),
        .state(state),
        .errorpause(errorpause),
        .alarm(alarm),
        .finishedAlarm(finishedAlarm)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        start = 0;
        pause = 0;
        preset = 0;
        custom_temp = 0;
        custom_speed = 0;
        custom_cycles = 0;
        custom_dry_timer = 0;
        custom_water_level = 0;
        door_open_signal = 0;
        waterflow = 1;
        water_level_reading = 0;
        power_cut = 0;

        // Reset the system
        reset = 1;
        #10 reset = 0;



        

        // Test Case A1: WASH to FILL_WATER to WASH
        preset = 7;                     // Custom preset
        custom_speed = 2; custom_temp = 3; custom_dry_timer = 50;

        custom_water_level = 3;
        custom_cycles = 10;
        start = 1;
        #30 start = 0;

        water_level_reading = 4;        // Initial state in WASH
        #30 water_level_reading = 2;    // Transition to FILL_WATER
        #30 water_level_reading = 3;    // Transition back to WASH
        


        // Test Case A2: DRAIN to FILL_WATER to RINSE to DRAIN
        reset = 1; #10 reset = 0; // Reset
        preset = 7; // Custom preset

        custom_speed = 2; custom_temp = 5; custom_dry_timer = 50;
        custom_water_level = 3;                                     
        custom_cycles = 1; // Directly to DRAIN state
        start = 1;
        #20 start = 0;
        #20 water_level_reading = 1; // Transition to FILL_WATER
        #20 water_level_reading = 3; // Transition to RINSE
        #100; // Wait for one rinse cycle, back to DRAIN


        // Test Case A3: Closed/Open Door Start
        reset = 1; #10 reset = 0; // Reset
        preset = 1; // Cotton preset
        door_open_signal = 1; // Door open
        start = 1; #10 start = 0; #30; // No state change
        door_open_signal = 0; // Close door
        start = 1; #20 start = 0; // State transitions to RUN
        


        // Test Case A4: Invalid Custom Input Behavior
        reset = 1; #10 reset = 0; // Reset
        preset = 7; // Custom preset
        custom_temp = 0; custom_dry_timer = 0; custom_water_level = 0;

        custom_speed = 6;
        custom_cycles =11; 
        start = 1;
        #30 start = 0;
        custom_speed = 5;
        custom_cycles =10; 
        start = 1; #20 start = 0;
        


        // Test Case B1: Wool Preset Normal Operation
        reset = 1; #10 reset = 0; // Reset
        preset = 0; // Wool preset
        start = 1; #20 start = 0;
        water_level_reading = 6; waterflow = 1; power_cut = 0; pause=0; door_open_signal=0;
        #1000; // Simulate normal operation with fluctuating water_level_reading

        // Test Case B2: Quick Wash with Interruptions
        reset = 1; #10 reset = 0; // Reset
        preset = 2; // Quick Wash preset
        start = 1; #20 start = 0;
        water_level_reading = 4; waterflow = 1; power_cut = 0;
        #50 pause = 1; #5 pause = 0; door_open_signal = 1; #10 start = 1; #5; start=0;  // Pause and open door
        #20 door_open_signal = 0; start = 1; #5; start=0; // Resume from DRAIN
        #1000;


        // Test Case B3: Dry only
        reset = 1; #10 reset = 0; // Reset
        preset = 4; // Dry only preset
        start = 1; #20 start = 0;
        water_level_reading = 0; waterflow = 0; power_cut = 0;  door_open_signal = 0; pause=0;
        #300;

        


        //Upper Edge Case
        reset = 1; #10; reset = 0; // Reset the system
        preset=7;
        custom_cycles = 10;      // Maximum cycles = 10
        custom_speed = 5;        // Maximum speed = 5
        custom_temp = 5;         // Maximum temperature = 5
        custom_water_level = 7;  // Maximum water level = 5
        custom_dry_timer = 60;
        door_open_signal = 0;         // Door is closed
        start = 1; #10; start = 0;    // Start washing
        waterflow = 1;                // Normal water flow
        water_level_reading=7;
        power_cut = 0;                // No power interruptions
        #1000;


        //lower Edge Case
        reset = 1; #10; reset = 0; // Reset the system
        custom_cycles = 1;      // Minimum cycles = 1
        custom_speed = 1;        // Minimum speed = 1
        custom_temp = 0;         // Minimum temperature = 0
        custom_water_level = 1;  // Minimum water level = 1
        custom_dry_timer = 0;
        door_open_signal = 0;         // Door is closed
        start = 1; #10; start = 0;    // Start washing
        waterflow = 1;                // Normal water flow
        water_level_reading=1;
        power_cut = 0;                // No power interruptions
        #1000;


        // Test Case C: Recovery from Waterflow and Power Interruptions
        reset = 1; #10; reset = 0; // Reset the system
        preset = 3;                // Preset 3 (Wash and Dry)
        door_open_signal = 0;      // Door is closed
        start = 1; #10; start = 0; // Start washing
        waterflow = 1;             // Normal waterflow
        power_cut = 0;             // No power interruptions

        water_level_reading=3; #20;
        waterflow = 0; #50; // Waterflow cut

        // Restore waterflow
        waterflow = 1; 
        water_level_reading=6;#50;

        // Simulate power cut during
        power_cut = 1; #50; // Power cut
        // Restore power
        power_cut = 0; #50;



        //Test Case D: Recovery from Continuous Waterflow Interruptions
        reset = 1; #10; reset = 0; // Reset the system
        preset = 3'b010;           // Preset 2 (Quick Wash)
        door_open_signal = 0;      // Door is closed
        start = 1; #10; start = 0; // Start washing
        waterflow = 1;             // Normal waterflow
        power_cut = 0;             // No power interruptions

        

        water_level_reading=0;#50;
        waterflow = 0; #20; // Waterflow cut

        waterflow = 1; #20;
        water_level_reading=2;#50;

        waterflow = 0; #20; // Waterflow cut

        waterflow = 1; #20;
        water_level_reading=4;#50;

        waterflow = 0; #20; // Waterflow cut

        waterflow = 1; #20;
        water_level_reading=6;#50;
        

        $stop; // End simulation

    end
endmodule
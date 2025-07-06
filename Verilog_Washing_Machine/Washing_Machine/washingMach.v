module WashingMachine(
    input clk,
    input reset,
    input start,
    input pause,
    input [2:0] preset,
    input [2:0] custom_temp,
    input [2:0] custom_speed,
    input [3:0] custom_cycles,
    input [5:0] custom_dry_timer,
    input [2:0] custom_water_level,
    input door_open_signal,
    input waterflow,
    input [2:0] water_level_reading,
    input power_cut,
    output reg [2:0] speed,
    output reg [2:0] temp,
    output reg [3:0] cycles,
    output reg [5:0] dry_timer,
    output reg [2:0] water_level,
    output reg rinse_complete,
    output wire [5:0] full_state,
    output reg [3:0] state,
    output reg [1:0] errorpause,
    output reg alarm, //toot toot
    output reg finishedAlarm
);

// Define state parameters
    //superstates:
parameter RUN = 2'b00;
parameter ERROR = 2'b10;
parameter PAUSE = 2'b01;

parameter IDLE = 4'b0000;
parameter CHOOSE_SETTINGS = 4'b0001;
parameter ADJUST_SETTINGS = 4'b0010;
parameter CHECK_DOOR = 4'b0011;

    //substates of normal run
parameter FILL_WATER = 4'b0101;
parameter WASH = 4'b0110;
parameter CHECK_CYCLES = 4'b0111;
parameter DRAIN = 4'b1000;
parameter RINSE = 4'b1001;
parameter SPIN = 4'b1010;
parameter DRY = 4'b1011;
parameter WASH_COMPLETE = 4'b1100;

// Internal registers
reg [4:0] rinse_cycles;
reg [6:0] spin_timer;
reg [5:0] dry_counter;
//reg[1:0] errorpause;
//reg [3:0] state;
assign full_state = {errorpause, state};


initial begin
    rinse_cycles <= 10;
    speed <= 0;
    temp <= 0;
    cycles <= 0;
    dry_timer <= 0;
    dry_counter <=0;
    water_level <= 0;
    rinse_complete <= 0;
    state <= 4'b0;
    spin_timer <= 0;
    errorpause <= 0;
end


//pause state always
always @(posedge clk) begin
    if(pause)
        errorpause[0] <= 1;
    else if(start)
        if(!door_open_signal)
        begin
            errorpause[0] <= 0;
            alarm <= 0;
        end
        else
            alarm <= 1;
    else alarm <= 0;
end 

//error state 
//EDIT
 always @(posedge clk) begin
        if((state == FILL_WATER && !waterflow) || power_cut)
                errorpause[1] <= 1;
        else errorpause[1] <= 0;
end



//Next State Logic
always @(posedge clk or posedge reset) begin

    if(state == WASH_COMPLETE)
        finishedAlarm <= 1;
    else finishedAlarm <= 0;

    if (reset) begin
    speed <= 0;
    temp <= 0;
    cycles <= 0;
    dry_timer <= 0;
    water_level <= 0;
    rinse_complete <= 0;
    state <= 4'b0;
    spin_timer <= 0;
    dry_counter <= 0;
    rinse_cycles <= 10;
    errorpause <= 0;

    end else begin

        case (state) //synopsys full_case
            IDLE:
            begin 
                if (start)                                      
                    state <= CHOOSE_SETTINGS;
            end

            CHOOSE_SETTINGS:
            begin
                if (preset == 7)            //custom settings
                    state <= ADJUST_SETTINGS;
                else begin
                    if (preset==0) 
                        begin                //wool
                            speed <= 2;
                            temp <= 2;
                            cycles <= 4;
                            dry_timer <= 0;
                            water_level <= 5;
                        end 
                    else if (preset==1)
                        begin               //cotton
                            speed <= 3;
                            temp <= 5;
                            cycles <= 6;
                            dry_timer <= 0;
                            water_level <= 7;
                        end 
                    else if (preset==2) 
                        begin                //quick
                            speed <= 4;
                            temp <= 3;
                            cycles <= 2;
                            dry_timer <= 0;
                            water_level <= 4;

                        end 
                    else if (preset==3) 
                        begin                //wash and dry
                            speed <= 3;
                            temp <= 3;
                            cycles <= 8;
                            dry_timer <= 30;
                            water_level <= 6;

                        end 
                    else if (preset==4) 
                        begin               //dry only
                            speed <= 0;
                            temp <= 0;
                            cycles <= 0;
                            dry_timer <= 60;
                            water_level <= 0;

                        end 
                    else if (preset==5) 
                        begin               //sports
                            speed <= 3;
                            temp <= 2;
                            cycles <= 7;
                            dry_timer <= 0;
                            water_level <= 7;

                        end 
                    else if (preset==6) 
                        begin                 //silk
                            speed <= 1;
                            temp <= 20;
                            cycles <= 3;
                            dry_timer <= 0;
                            water_level <= 6;
                        end
                    state <= CHECK_DOOR;
                end
            end
            
            ADJUST_SETTINGS: begin
                if (custom_speed >= 1 && custom_speed <= 5 &&
                    custom_temp >= 0 && custom_temp <= 5 &&
                    custom_cycles >= 0 && custom_cycles <= 10 &&
                    custom_dry_timer >= 0 && custom_dry_timer <= 60 &&
                    custom_water_level>=1 && custom_water_level<= 7)
                    begin
                        speed <= custom_speed;
                        temp <= custom_temp;
                        cycles <= custom_cycles;
                        dry_timer <= custom_dry_timer;
                        water_level<=custom_water_level;
                        state <= CHECK_DOOR;
                    end 
                else
                    state <= ADJUST_SETTINGS;
            end

            CHECK_DOOR: begin
                if (door_open_signal) begin
                    state <= CHECK_DOOR;
                end 
                else 
                    if (cycles == 0)
                        state <= DRY;
                    else
                         state <= FILL_WATER;
            end

            default: begin
                if(!errorpause)
                    case (state) //synopsys full_case
                        FILL_WATER: begin       
                            if (water_level_reading < water_level) begin
                                state <= FILL_WATER;
                            end 
                            else if(cycles==0) begin
                                state <= RINSE;
                            end 
                            else begin 
                                state <= WASH;
                            end
                        end

                        WASH: begin
                            if (water_level_reading < water_level)
                             begin
                                   state <= FILL_WATER;
                             end 
                            else
                             begin
                                    cycles <= cycles - 1;
                                    state <= CHECK_CYCLES;
                             end
                        end 

                        CHECK_CYCLES: begin
                          if (cycles == 0) begin
                               state <= DRAIN;
                            end else begin
                                state<= WASH;
                            end
                        end

                        RINSE: begin
                            if (water_level_reading < water_level)
                                begin
                                    state <= FILL_WATER;
                                end 
                            else
                                begin    
                                if(rinse_cycles > 0)
                                    rinse_cycles <= rinse_cycles - 1;
                                else
                                    rinse_complete <= 1;
                                state <= DRAIN;
                                end
                        end

                        DRAIN: begin
                           if (!rinse_complete) 
                                begin
                                    state <= FILL_WATER;
                                end 
                            else 
                                begin
                                    state <= SPIN;
                                end
                        end

                        SPIN: begin
                            spin_timer <= spin_timer + speed;                     
                            if (spin_timer<=64) begin
                                state <= SPIN;
                            end else if (dry_timer) begin
                                state <= DRY;
                            end else begin
                                state <= WASH_COMPLETE;
                            end
                        end


                        DRY:
                        begin
                            if (dry_counter<dry_timer) 
                                begin
                                    dry_counter <= dry_counter + 1; 
                                    state <= DRY;                             
                                end
                            else
                                state <= WASH_COMPLETE;
                        end
                        
                        WASH_COMPLETE: begin            
                                state <= IDLE;
                        end
                        default: begin
                            state <= state;
                        end
                    endcase
                end
        endcase
    end
end
// Ensure reset moves FSM to IDLE
/*
psl default clock = rose(clk);
psl property Reset_To_IDLE = always (reset -> next(state == IDLE));
psl assert Reset_To_IDLE;
*/

// Ensure that in IDLE, start initiates transition to CHOOSE_SETTINGS
/*
psl property Idle_To_ChooseSettings = always ((state == IDLE && start) -> next(state == CHOOSE_SETTINGS));
psl assert Idle_To_ChooseSettings;
*/

// Ensure preset 7 (custom settings) transitions to ADJUST_SETTINGS
/*
psl property Custom_To_AdjustSettings = always ((state == CHOOSE_SETTINGS && preset == 7) -> next(state == ADJUST_SETTINGS));
psl assert Custom_To_AdjustSettings;
*/

// Ensure other presets transition to CHECK_DOOR
/*
psl property Preset_To_CheckDoor = always ((state == CHOOSE_SETTINGS && preset != 7) -> next(state == CHECK_DOOR));
psl assert Preset_To_CheckDoor;
*/

// Ensure pause sets FSM to PAUSE state
/*
psl property Pause_State = always (pause -> next(errorpause[0] == 1));
psl assert Pause_State;
*/

// Ensure start with the door closed clears PAUSE state and alarm
/*
psl property Start_Without_Alarm = always ((errorpause == PAUSE && start && !door_open_signal) -> next(errorpause[0] == 0 && alarm == 0));
psl assert Start_Without_Alarm;
*/

// Ensure start with the door open triggers alarm
/*
psl property Start_With_Alarm = always ((errorpause == PAUSE && start && door_open_signal) -> next(alarm == 1));
psl assert Start_With_Alarm;
*/

// Ensure ERROR is triggered on power_cut
/*
psl property Error_On_PowerCut = always (power_cut -> next(errorpause[1] == 1));
psl assert Error_On_PowerCut;
*/

// Ensure ERROR is triggered on missing waterflow in FILL_WATER
/*
psl property Error_On_NoWaterflow = always ((state == FILL_WATER && !waterflow) -> next(errorpause[1] == 1));
psl assert Error_On_NoWaterflow;
*/

// Ensure correct transition from WASH to FILL_WATER based on water_level_reading
/*
psl property Wash_To_FillWater = always ((errorpause == 0 && state == WASH && water_level_reading < water_level) -> next(state == FILL_WATER));
psl assert Wash_To_FillWater;
*/

// Ensure CHECK_CYCLES transitions to appropriate states
/*
psl property CheckCycles_Transition = always ((state == CHECK_CYCLES && errorpause == 0) -> next(state == WASH || state == DRAIN));
psl assert CheckCycles_Transition;
*/

// Ensure alarm is activated in WASH_COMPLETE
/*
psl property Alarm_On_WashComplete = always ((state == WASH_COMPLETE) -> next(finishedAlarm == 1));
psl assert Alarm_On_WashComplete;
*/

endmodule
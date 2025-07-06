vlib work
vlog washingMach.v finalScenario_TB.v +cover -covercells
vsim -voptargs=+acc work.scenarios_TB -cover
add wave -r /*
add wave -position end  /scenarios_TB/dut/assert__Reset_To_IDLE
add wave -position end  /scenarios_TB/dut/assert__Idle_To_ChooseSettings
add wave -position end  /scenarios_TB/dut/assert__Custom_To_AdjustSettings
add wave -position end  /scenarios_TB/dut/assert__Preset_To_CheckDoor
add wave -position end  /scenarios_TB/dut/assert__Pause_State
add wave -position end  /scenarios_TB/dut/assert__Start_Without_Alarm
add wave -position end  /scenarios_TB/dut/assert__Start_With_Alarm
add wave -position end  /scenarios_TB/dut/assert__Error_On_PowerCut
add wave -position end  /scenarios_TB/dut/assert__Error_On_NoWaterflow
add wave -position end  /scenarios_TB/dut/assert__Wash_To_FillWater
add wave -position end  /scenarios_TB/dut/assert__CheckCycles_Transition
add wave -position end  /scenarios_TB/dut/assert__Alarm_On_WashComplete
coverage save washingMachine.ucdb -onexit
run -all 
vcover report washingMachine.ucdb -details -annotate -all >washCoverage.txt

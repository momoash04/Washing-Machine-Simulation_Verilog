# 🧼 Washing Machine Controller – Verilog FSM Project

This project is a Verilog-based Finite State Machine (FSM) implementation of a Washing Machine Controller. It simulates the entire washing process—from custom or preset setting selection to wash, rinse, spin, dry, and error handling—using an efficient state-driven design with clear user input handling and safety mechanisms.

🧪 Fully verified through simulation and waveform analysis with QuestaSim.

---

## 📌 Project Overview

The controller models real-world washing machine behavior through a 6-bit full_state signal:

- 2-bit superstate (errorpause): RUN (00), PAUSE (01), ERROR (10)
- 4-bit substate (state): e.g., IDLE (0000), WASH (0110), SPIN (1010)

Transitions are based on user inputs (start, preset, custom settings) and sensor feedback (door state, water flow, power cut). The FSM intelligently progresses through:

- IDLE → Settings Selection → Door Check → Fill Water → Wash → Rinse → Spin → Dry → Wash Complete

Error handling and pause-resume logic are embedded to ensure realistic and safe operation.

---

## 🧠 State Machine Design

🗂 The FSM includes 14 main states:
- IDLE
- CHOOSE_SETTINGS
- ADJUST_SETTINGS
- CHECK_DOOR
- FILL_WATER
- WASH
- CHECK_CYCLES
- RINSE
- DRAIN
- SPIN
- DRY
- WASH_COMPLETE
- PAUSE (superstate)
- ERROR (superstate)

State transitions are based on:
- User-defined presets or custom input
- Water level readings
- Sensor signals (door, waterflow, power)
- Internal counters (rinse_cycles, spin_timer, dry_counter)

---

## 📥 Inputs & 📤 Outputs

### Inputs
| Signal              | Width | Description |
|---------------------|--------|-------------|
| clk                 | 1-bit | Clock signal |
| reset               | 1-bit | Resets controller |
| start               | 1-bit | Starts the machine |
| pause               | 1-bit | Temporarily halts operation |
| preset              | 3-bit | Preset program selector |
| custom_temp         | 3-bit | Custom wash temperature |
| custom_speed        | 3-bit | Custom spin speed |
| custom_cycles       | 4-bit | Number of wash cycles |
| custom_dry_timer    | 6-bit | Custom dry duration |
| custom_water_level  | 3-bit | Target water level |
| door_open_signal    | 1-bit | Indicates if door is open |
| waterflow           | 1-bit | Detects water flow |
| water_level_reading | 3-bit | Water sensor input |
| power_cut           | 1-bit | Detects power interruptions |

### Outputs
| Signal         | Width | Description |
|----------------|--------|-------------|
| speed          | 3-bit | Spin speed control |
| temp           | 3-bit | Wash temperature |
| cycles         | 4-bit | Wash cycle count |
| dry_timer      | 6-bit | Drying duration |
| water_level    | 3-bit | Current water level |
| rinse_complete | 1-bit | Rinse phase done |
| full_state     | 6-bit | Combined errorpause + substate |
| state          | 4-bit | Current substate |
| errorpause     | 2-bit | PAUSE or ERROR flags |
| alarm          | 1-bit | Triggered on fault |
| finishedAlarm  | 1-bit | Indicates process completion |

---

## 🛠️ Key Internal Registers

| Register       | Width | Purpose |
|----------------|--------|---------|
| rinse_cycles   | 5-bit | Number of rinse loops |
| spin_timer     | 6-bit | Tracks spin duration |
| dry_counter    | 6-bit | Tracks dry duration |

---

## 🧪 Verification Plan

Testbench-driven simulation using QuestaSim and PSL assertions covered:

✅ Single feature transitions  
✅ Normal operation presets (e.g., Wool, Quick, Dry-only)  
✅ Edge cases (upper/lower bounds of custom inputs)  
✅ Error handling (e.g., door open, power cut, waterflow interruption)  
✅ Pause/Resume functionality  
✅ Reset recovery

---

## 📊 Coverage Analysis

| Metric              | Result |
|---------------------|--------|
| Statement Coverage  | 100%   |
| Branch Coverage     | 88.70% |
| Condition Coverage  | 58.06% |
| State Coverage (FSM)| 100%   |
| Transition Coverage | 31.50% (valid transitions only) |
| Toggle Coverage     | 91.66% |
| Assertion Coverage  | 75–77% |

🔍 All critical states and scenarios were successfully validated.

---

## 🛠️ Tools Used

- Verilog (RTL)
- QuestaSim (Simulation + Coverage)
- Visual Studio Code (Coding)
- PSL Assertions
- Waveform analysis

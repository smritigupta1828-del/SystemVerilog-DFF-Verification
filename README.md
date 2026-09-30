# SystemVerilog D-Flip-Flop Verification Environment

This repository contains a modular, object-oriented testbench built in SystemVerilog to verify a standard D-Flip-Flop design. The testbench is organized using layered architecture principles to separate stimulus generation, pin-level driving, signal monitoring, and data checking.

## Testbench Architecture

The verification environment is broken down into separate class components that communicate using mailboxes and events:

* Transaction: Defines the data fields for the D-Flip-Flop, including the random input data (din) and the output data (dout). It includes a copy function to duplicate objects safely and a display function for logging.
* Generator: Generates transaction objects, randomizes the input stimuli, and sends them to the driver and scoreboard. It uses a handshake event to wait until the scoreboard finishes checking the current transaction before generating the next one.
* Driver: Receives transactions from the generator through a mailbox. It handles the physical interface by running a 5-clock cycle reset sequence and then driving data onto the interface pins on the rising clock edge.
* Monitor: Observes the output pins of the D-Flip-Flop through the virtual interface, captures the output state, and sends it to the scoreboard for evaluation.
* Scoreboard: Collects the captured transactions from the monitor and the reference transactions from the generator. It compares the actual output against the driven input to verify correctness and prints the results.
* Environment: The container class that instantiates all components, connects the communication mailboxes, links the handshake events, and runs the pre-test, test, and post-test phases.

## Simulation Setup

The top-level module (testbench) instantiates the physical interface and the D-Flip-Flop design. It generates a continuous clock signal with a 20ns period and runs the environment for a set count of 30 transactions. The simulation also generates a standard VCD dump file for waveform viewing.

## How to Run

To run this simulation, compile both the design file and the testbench file using any standard SystemVerilog compiler or simulator such as ModelSim, Questa, VCS, or EDA Playground. 

Ensure that both the interface definition and the D-Flip-Flop module are compiled before running the top-level testbench module.

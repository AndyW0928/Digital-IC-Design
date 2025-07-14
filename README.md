# Digital-IC-Design @ NCKU EE (2025)

This repository includes five major RTL design projects from the graduate-level course **Digital IC Design** at National Cheng Kung University. Projects emphasize Verilog design, FSM implementation, AXI-like bus interface, and synthesis-aware optimization with real-world timing/performance considerations.

---

## HW1 – Median Finder (Hierarchical Comparator Design)
- Designed a parameterized **4-bit comparator** module (`Comparator2`) that outputs min/max of two inputs.
- Built 3-input, 5-input, and 7-input **Median Finder** modules hierarchically using `Comparator2`.
- Verified design via ModelSim testbench with golden pattern matching.
- Demonstrated modular, reusable RTL design using top-down methodology.

## HW2 – LCD Image Controller (FSM Design + Image Processing)
- Implemented a finite state machine to process an 8×8 grayscale image using 8 instructions:
  - `Shift`, `Max`, `Min`, `Average`, and `Write` operations.
- Designed timing-accurate memory bus control for:
  - **IROM** (input image ROM)
  - **IRAM** (output image RAM)
- Passed all 5 functional test patterns via ModelSim.
- Focus: FSM-based control, image memory I/O, and command decoding.

## HW3 – 16-Point FFT Accelerator (Butterfly + Fixed-point Arithmetic)
- Built a 16-point **Fast Fourier Transform** engine with:
  - **Serial-to-parallel input buffer**
  - **Complex butterfly computation**
  - **Fixed-point complex multiplication**
- Synthesized using Quartus (Cyclone IV), performed **pre-layout simulation** with SDF timing.
- Optimized hardware using:
  - Pipeline stages
  - Resource-efficient fixed-point units
- Focus: signal processing hardware + timing closure.

## HW4 – Atrous Convolution + AXI-like Bus System
- Implemented **Atrous convolution** with:
  - Replicate padding (68×68 input from 64×64)
  - ReLU
  - Max-pooling + rounding
- Integrated a **bus-based SoC system** using AXI-like protocol:
  - Master interface with 3 slaves: ROM (image), SRAM0 (Layer0), SRAM1 (Layer1)
- Verified hierarchical SoC system with:
  - Handshake timing (valid/ready, burst transfer)
  - Functional & gate-level simulations


## HW5 – Max Convex Hull (Graham Scan + Shoelace Formula)
- Designed a **geometry accelerator** that computes:
  1. Convex Hull (via Graham Scan)
  2. Polygon area (via Shoelace Formula)
- Reads 20 input coordinates (x, y) and returns area with 1 decimal precision.
- Optimized for:
  - **Functional correctness**
  - **Synthesis-ready pipeline**
  - **Cycle count + resource-aware implementation**
- Synthesized on Quartus, passed ModelSim pre-layout simulation.

---

## 💻 Tools & Environment
- Verilog, ModelSim, Quartus Prime (Cyclone IV E - EP4CE55F23A7)
- Functional Simulation + Pre-Layout Gate-Level Simulation
- Fixed-point arithmetic, FSM design, bus protocol design, geometry pipeline

---

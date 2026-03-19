# 🚀 UART Transmitter and Receiver in Verilog HDL

## 📌 Description
This project implements a complete **UART (Universal Asynchronous Receiver/Transmitter)** system using **Verilog HDL**. It includes both **transmitter and receiver modules**, along with a **baud rate generator** and a **top-level integration module**.

The design also incorporates a simple **XOR-based encryption mechanism** for secure data transmission, making it a more advanced and practical implementation beyond basic UART communication.

---

## ⚙️ Features
- ✔️ 8-bit UART communication  
- ✔️ FSM-based UART Transmitter (TX) and Receiver (RX)  
- ✔️ Configurable baud rate generator  
- ✔️ Start and Stop bit framing  
- ✔️ Optional parity generation and checking  
- ✔️ 16× oversampling receiver for accurate sampling  
- ✔️ XOR-based data encryption and decryption  
- ✔️ Status signals for TX/RX monitoring  
- ✔️ Testbench-based functional verification  
- ✔️ GTKWave waveform visualization  

---

## 🧠 Working Principle
- Data is provided in parallel (8-bit) to the transmitter  
- The transmitter encrypts data using XOR logic and sends it serially:
  - Start bit (LOW)  
  - Data bits (LSB first)  
  - Optional parity bit  
  - Stop bit (HIGH)  
- FSM controls proper sequencing of transmission  
- The receiver uses 16× oversampling to accurately sample incoming bits  
- Received data is reconstructed and decrypted using XOR logic  
- Stop bit is validated to ensure correct frame reception  

### 📷 Transmitter FSM
![UART Transmitter FSM](waveforms/tx_fsm.png)

### 📷 Receiver FSM
![UART Receiver FSM](waveforms/rx_fsm.png)

---

## 🏗️ Project Structure
```
uart-verilog/
│── uart_tx.v          # UART Transmitter
│── uart_rx.v          # UART Receiver
│── baud_gen.v         # Baud Rate Generator
│── top.v              # Top-level Module
│── testbench.v        # Testbench File
│── README.md
```

---

## 🛠️ Tools Used
- Verilog HDL  
- Icarus Verilog (iverilog)  
- GTKWave  
- VS Code  

---

## 📊 Simulation
The design is verified using a Verilog testbench and simulated with **Icarus Verilog**. Waveforms are analyzed using **GTKWave**, demonstrating:

- Correct UART frame transmission (start, data, parity, stop bits)  
- Accurate reception using 16× oversampling  
- Proper encryption and decryption of data  
- No data corruption under normal conditions  

### 📷 Simulation Waveform
![UART Waveform](waveform/waveform.jpeg)

---

## ▶️ How to Run

### 1. Compile the Code
```
iverilog -o uart.vvp *.v
```

### 2. Run Simulation
```
vvp uart.vvp
```

### 3. View Waveform
```
gtkwave dump.vcd
```

---

## 🎯 Applications
- Serial communication systems  
- Secure embedded communication (basic level)  
- FPGA-based data transfer  
- Debugging and logging systems  

---

## 📌 Future Improvements
- Implement explicit framing error detection  
- Enhance encryption mechanism beyond XOR  
- Support configurable data widths  
- FPGA hardware implementation and validation  
---

## 👨‍💻 Author
**Sarthak Modi**  
B.Tech ECE | Interested in Digital Design, Embedded Systems & Robotics  

🔗 GitHub: https://github.com/sarthakmodi4145  

---

## 📜 License
This project is open-source and intended for educational purposes.
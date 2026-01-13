# Satellite Link Budget & Network Analyzer (V5)

This professional MATLAB tool is designed for comprehensive analysis of satellite communication links. It supports dynamic optimization, RSSI (Received Signal Strength Indicator) calculations, and both RF and Optical communication link budgets.

## 🚀 Key Technical Features
* **Dynamic Link Analysis:** Real-time calculation of signal strength and quality.
* **Multi-Spectrum Support:** Analysis capabilities for both RF and Optical (Laser) communication.
* **Advanced Metrics:** Supports $E_b/N_0$, $C/N_0$, and detailed RSSI modeling.
* **Atmospheric Modeling:** Includes path loss, rain fade, and system noise temperature ($T_{sys}$) analysis.
* **Interactive GUI:** A custom-built interface using MATLAB App Designer for professional data visualization.

## 🛠 Engineering Methodology
The core of this analyzer relies on the **Friis Transmission Equation**:
$$P_r = P_t + G_t + G_r - L_p - L_a$$

Where:
* $P_r$: Received Power (dBW)
* $P_t$: Transmitter Power (dBW)
* $G_t, G_r$: Antenna Gains (dBi)
* $L_p$: Free Space Path Loss (dB)
* $L_a$: Atmospheric and System Losses (dB)

## 💻 How to Run
1. Clone the repository.
2. Open MATLAB (R2021a or later recommended).
3. Run the main script: `link_budget.m` or open the `.mlapp` file.

## 🎓 About the Developer
**Gül**, 3rd-year Aerospace Engineering Student.  
Specializing in Satellite Communications, RF/Microwave Systems, and Secure Space Networks.

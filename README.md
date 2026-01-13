# Satellite Link Budget & Network Analyzer (V5)

This professional MATLAB tool is designed for comprehensive analysis of satellite communication links. It supports dynamic optimization, RSSI (Received Signal Strength Indicator) calculations, and both RF and Optical communication link budgets.

## 🚀 Key Technical Features
* **Dynamic Link Analysis:** Real-time calculation of signal strength and quality.
* **Multi-Spectrum Support:** Analysis capabilities for both RF and Optical (Laser) communication.
* **Advanced Metrics:** Supports $E_b/N_0$, $C/N_0$, and detailed RSSI modeling.
* **Atmospheric Modeling:** Includes path loss, rain fade, and system noise temperature ($T_{sys}$) analysis.
* **Interactive GUI:** A custom-built interface using MATLAB App Designer for professional data visualization.


Uploading Adsız video ‐ Clipchamp ile yapıldı (2).mp4…

<img width="1323" height="968" alt="image" src="https://github.com/user-attachments/assets/c2be0b24-6d8c-4329-8db0-828c76b2b99a" />

<img width="1329" height="970" alt="image" src="https://github.com/user-attachments/assets/13ef353b-c2ed-4316-9222-1b2ef4aeeda8" />


<img width="1305" height="959" alt="image" src="https://github.com/user-attachments/assets/c27f4504-d104-405c-86ad-3d7fe9b35327" />

<img width="1301" height="956" alt="image" src="https://github.com/user-attachments/assets/1a44718a-bd19-4b2a-873a-51ddc8d55f76" />

<img width="1386" height="976" alt="image" src="https://github.com/user-attachments/assets/8c9be7ac-a291-43de-931a-b894e48cc554" />

<img width="982" height="788" alt="image" src="https://github.com/user-attachments/assets/465cd230-ee41-4163-9d20-05334115dd5b" />

<img width="1405" height="974" alt="image" src="https://github.com/user-attachments/assets/a1a93cce-d134-49ad-a808-b90625b8c56c" />


<img width="1024" height="1536" alt="link budget formülleri " src="https://github.com/user-attachments/assets/6ed85d85-70b4-46d8-97c5-666a839e84e1" />


https://github.com/user-attachments/assets/7389ebd7-05a6-47fe-a40f-06d0d61b7e84


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

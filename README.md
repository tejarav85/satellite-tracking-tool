# 🛰️ MATLAB Satellite Tracking & Visualization Tool

**Author**: Ravi Teja Vadla  
**License**: MIT (c) 2025 Ravi Teja Vadla   
**Language**: MATLAB

---

## 🔭 Project Overview

This is a real-time satellite tracking and telemetry visualization tool built using **MATLAB** and **TLE (Two-Line Element) data**. The tool uses **SGP4 propagation** to predict orbital positions, visualizes satellite motion in **3D and on Earth maps**, and logs telemetry data for analysis.

---

## 🧠 What It Does

- Accepts **any 3-line TLE input**
- Creates a **satellite scenario** in MATLAB using official orbital models
- Plots:
  - 3D orbit path
  - Real-time **ground track**
  - Current **nadir point** (sub-satellite point)
- Updates GUI with:
  - Latitude, Longitude, Altitude (km)
  - Orbital Speed (km/s)
  - Current UTC time
- Logs telemetry data to `telemetry_log.csv` in real time

---

## ⚙️ How It Works

1. TLE is parsed and saved to a `.tle` file.
2. MATLAB’s `satelliteScenario` loads satellite and simulates motion.
3. Real-time loop extracts ECEF position and converts to **Lat/Lon/Alt** using `ecef2lla`.
4. Telemetry is shown live and also saved to file.
5. GUI is built with:
   - `uifigure`, `uibutton`, `uilabel`, `uitextarea`
   - `geoaxes` and `geoplot` for 2D tracking
   - `satelliteScenarioViewer` for 3D visualization

---

## 🛠️ Requirements

- MATLAB R2023b or later
- Aerospace Toolbox
- Internet connection (for map base layer)
- Compatible TLE data (e.g., from [Celestrak](https://celestrak.org))

---

## 🖼️ Screenshots

| GUI | 3D Viewer | 2D Ground Track |
|-----|-----------|-----------------|
| ![GUI](images/gui.png) | ![3D](images/orbit3D.png) | ![2D](images/groundtrack.png) |

---

## 📂 Project Structure

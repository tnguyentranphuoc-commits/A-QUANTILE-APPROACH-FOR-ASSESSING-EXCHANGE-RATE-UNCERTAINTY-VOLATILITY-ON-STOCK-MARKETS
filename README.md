# A QUANTILE APPROACH FOR ASSESSING EXCHANGE RATE–UNCERTAINTY VOLATILITY ON STOCK MARKETS

📅 **Duration**: May 2025 – Oct 2025  
👤 **Team Size**: 1  
🛠️ **Tech Stack**: Stata  

---

## (i). Overview

This research explores the **asymmetric and joint effects** of **exchange rate volatility (EXV)** and **oil price uncertainty (OVX)**—along with their **conditional covariance (COVOX)**—on **stock market returns (r)** and **volatility (σ)** across **Southeast Asian economies**.

By utilizing a **quantile regression (QR)** approach, the study captures distributional impacts under varying market states. This allows for a richer understanding of **tail behavior**, **risk spillovers**, and the **shock transmission mechanisms** of external uncertainties into local financial markets.

Targeted markets include:
- 🇲🇾 **KLSE (Malaysia)**
- 🇵🇭 **PSI (Philippines)**
- 🇹🇭 **SETI (Thailand)**
- 🇸🇬 **STI (Singapore)**
- 🇻🇳 **VNI (Vietnam)**

---

## (ii). Methodology

All input series underwent rigorous pre-estimation tests:
- ✅ **ADF & PP tests**: Stationarity confirmed at level
- ✅ **BDS test**: Nonlinear dynamics validated
- ✅ **Ljung–Box Q test**: No serial correlation
- ✅ **ARCH–LM**: Presence of heteroskedasticity
- ✅ **Exploratory analysis**: Movements visualized prior to modeling

---

### (iii). Modeling Pipeline

The econometric workflow combines **GARCH-family models** and **quantile techniques** as follows:

1. Estimate σ(EXV) via GJR–GARCH → captures asymmetric exchange rate volatility
2. Estimate COVOX using Asymmetric DCC–GARCH → oil–exchange rate interaction
3. Model stock returns (r) and volatility (σ) using:
     → Quantile Regression (QR) for τ ∈ [0.1, 0.9]
     → Quantile-on-Quantile extension for robustness

## (iv). Key Findings

- 📉 **OVX** has the strongest **negative effect** on **returns at low quantiles** (τ = 0.1–0.3), indicating vulnerability in bearish markets.
- ⚠️ **COVOX** (joint volatility) negatively impacts returns in **KLSE**, **SETI**, and **STI**, particularly under **medium–high quantiles**.
- 📈 **Volatility responses (σ)** are more severe at **upper quantiles** (τ > 0.75) than return responses — suggesting **greater risk in volatile periods**.
- 📊 **COVOX spikes** align with key global shocks:
  - **2014**: Oil price crash
  - **2020**: COVID-19 financial shock
- 🧭 Transmission patterns reveal:
  - **STI** & **SETI** (developed) → act as **volatility transmitters**
  - **VNI** & **PSI** (emerging) → behave as **volatility receivers**

---

## (v). Application: Risk & Portfolio Implications

- Quantile findings support **dynamic asset allocation** under state-contingent uncertainty.
- Insights aid **portfolio hedging strategies** sensitive to **joint oil–forex shocks**.
- Policy implication: **Developing markets require shock buffers** during exogenous volatility spikes.

---

## (vi). Repository Contents

- `THE UNCERTAINTY IMPACTS ... .do` — Stata script for GARCH + QR estimation  
- `THE UNCERTAINTY IMPACTS ... .dta` — Cleaned panel dataset for modeling  
- `Methods and Results.pdf` — Condensed empirical outputs and tables  
- `THE UNCERTAINTY IMPACTS ... .pdf` — Full academic manuscript  
- `README.md` — Project summary and documentation

---

## (vii). Citation

> **Toan N.T.P., et al. (2025)**  
> *The Uncertainty Impacts of Oil Price, Exchange Rate and Its Joint Effect on Stock Market Returns and Volatility: Evidence from ASEAN Countries.*  
> College of Economics, Law and Government – CELG 2025, University of Economics Ho Chi Minh City (UEH)

> Based study:  
> Chen, Y., Msofe, Z. A., Wang, C., & Chen, M. (2025).  
> *Oil price uncertainty, exchange rate volatility, and African stock markets: A nonparametric quantile-on-quantile analysis.*  
> *International Review of Financial Analysis*, 104385.  
> https://doi.org/10.1016/j.irfa.2024.104385

---

## (viii). License

📜 This project is licensed under the **MIT License**.  
Please cite the author appropriately when reusing the code, data, or methodology.

---

## (ix). Acknowledgements

This project is part of the **CELG Awards 2025 – University of Economics Ho Chi Minh City (UEH)**.  
Grateful acknowledgment to the CELG academic board for technical guidance and feedback.

---

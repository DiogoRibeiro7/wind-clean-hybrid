# 🌬️ wind-clean-hybrid

**Professional R package for cleaning and modeling wind-turbine SCADA data**
Combines **Fuzzy C-Means clustering**, **Mahalanobis distance**, and **Artificial Neural Networks** into a robust hybrid pipeline designed to detect and remove abnormal SCADA points from wind turbine power curves.

---

## 📘 Overview

Wind turbine Supervisory Control and Data Acquisition (SCADA) systems often produce noisy and inconsistent data due to sensor drift, communication errors, icing, or maintenance events. These anomalies distort the power curve, leading to inaccurate modeling and performance assessment.

`wind-clean-hybrid` implements a reproducible, fully validated hybrid cleaning model that integrates:

| Stage | Method                   | Purpose                                                               |
| ----- | ------------------------ | --------------------------------------------------------------------- |
| 1     | **Pre-cleaning**         | Remove physically impossible values (e.g., negative power or speed).  |
| 2     | **Fuzzy C-Means (FCM)**  | Cluster turbine operating states using soft memberships.              |
| 3     | **Mahalanobis Distance** | Flag outliers within each cluster based on covariance-aware distance. |
| 4     | **ANN Refinement**       | Train a neural network on cleaned data and filter residual outliers.  |

This design unites interpretability, computational efficiency, and robustness — suitable for research, industrial SCADA analytics, and real-time turbine monitoring.

---

## ⚙️ Installation

```r
# Install development tools if needed
install.packages("devtools")

# Install directly from GitHub
library(devtools)
install_github("DiogoRibeiro7/wind-clean-hybrid")
```

---

## 🚀 Usage Example

```r
library(windCleanHybrid)
library(readr)

# Load example SCADA dataset
data <- read_csv("data/example_scada.csv")

# Run the hybrid pipeline
result <- run_hybrid_pipeline(data, centers = 4)

# Print metrics
print(result$metrics)

# Visualize cleaned power curve
plot_results(result$cleaned_data)
```

---

## 📈 Output

Each pipeline run returns:

```r
list(
  cleaned_data = <tibble with columns wind_speed, power, pred, residual>,
  metrics = list(RMSE, MAE, MAPE, R2, CA)
)
```

**Combined Accuracy (CA)** aggregates normalized RMSE, MAPE, and R² into a bounded index ∈ [0, 1].
Higher values indicate cleaner, more consistent turbine behavior.

---

## 🧩 Main Functions

| Function                        | Description                                                           |
| ------------------------------- | --------------------------------------------------------------------- |
| `preclean_data()`               | Removes invalid and missing data entries.                             |
| `apply_fcm_clustering()`        | Performs Fuzzy C-Means clustering on wind speed and power.            |
| `detect_outliers_mahalanobis()` | Identifies statistical outliers in each cluster.                      |
| `refine_ann()`                  | Trains an ANN on cleaned data and computes residuals.                 |
| `evaluate_metrics()`            | Computes RMSE, MAE, MAPE, R², and CA.                                 |
| `plot_results()`                | Generates a ggplot power curve comparing observed vs predicted power. |
| `run_hybrid_pipeline()`         | Runs the entire process end-to-end.                                   |

---

## 🧠 Methodological Notes

* **FCM Clustering:** Allows partial membership, improving robustness under overlapping operating regimes.
* **Mahalanobis Distance:** Considers feature covariance, outperforming Euclidean thresholds for correlated SCADA features.
* **ANN Refinement:** Learns nonlinear residuals and removes residual anomalies.
* **Error Handling:** Each step validated with explicit type checks and safe fallbacks.

---

## 🧪 Example Results

| Metric | Value (example run) |
| ------ | ------------------- |
| RMSE   | 0.95                |
| MAE    | 0.78                |
| MAPE   | 1.86%               |
| R²     | 0.98                |
| CA     | 0.99                |

*(Results vary depending on dataset and noise intensity.)*

---

## 🧱 Project Structure

```
wind-clean-hybrid/
├── DESCRIPTION
├── NAMESPACE
├── R/
│   ├── preclean.R
│   ├── clustering_fcm.R
│   ├── outlier_mahalanobis.R
│   ├── refine_ann.R
│   ├── utils_metrics.R
│   ├── visualize.R
│   └── hybrid_model.R
├── data/example_scada.csv
└── README.md
```

---

## 📄 License

MIT License © 2025 [Diogo Ribeiro](https://github.com/DiogoRibeiro7)

You are free to use, modify, and distribute this software, provided that proper credit is given.

---

## 📬 Contact

For issues, improvements, or academic collaboration:

* GitHub Issues: [wind-clean-hybrid/issues](https://github.com/DiogoRibeiro7/wind-clean-hybrid/issues)
* Maintainer: [Diogo Ribeiro](https://github.com/DiogoRibeiro7)

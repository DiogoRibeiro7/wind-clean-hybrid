# 🌬️ wind-clean-hybrid

**R package for cleaning and modeling wind-turbine SCADA data**
Combines **Fuzzy C-Means clustering**, **Mahalanobis distance**, and **Artificial Neural Networks** into a hybrid pipeline designed to detect and remove abnormal SCADA points from wind turbine power curves.

---

## 📘 Overview

Wind turbine Supervisory Control and Data Acquisition (SCADA) systems often produce noisy and inconsistent data due to sensor drift, communication errors, icing, or maintenance events. These anomalies distort the power curve, leading to inaccurate modeling and performance assessment.

`wind-clean-hybrid` implements a hybrid cleaning model that integrates:

| Stage | Method                   | Purpose                                                               |
| ----- | ------------------------ | --------------------------------------------------------------------- |
| 1     | **Pre-cleaning**         | Remove physically impossible values (e.g., negative power or speed).  |
| 2     | **Fuzzy C-Means (FCM)**  | Cluster turbine operating states using soft memberships.              |
| 3     | **Mahalanobis Distance** | Flag outliers within each cluster based on covariance-aware distance. |
| 4     | **ANN Refinement**       | Train a neural network on cleaned data and filter residual outliers.  |

This design combines interpretable preprocessing with model-based refinement and is intended for research and exploratory SCADA analytics.

---

## ⚙️ Installation

The package is installable from GitHub without the ANN stack. The ANN refinement step is optional and depends on the R `keras` package plus a working backend setup.

```r
# Install development tools if needed
install.packages("devtools")

# Install directly from GitHub
library(devtools)
install_github("DiogoRibeiro7/wind-clean-hybrid")
```

For ANN usage, install and configure `keras` separately before running `refine_ann()` or the full `run_hybrid_pipeline()`.

---

## 🚀 Usage Example

```r
library(windCleanHybrid)
library(readr)

# Load the example dataset from the repository checkout
data <- read_csv("data/example_scada.csv")

# Run the hybrid pipeline
result <- run_hybrid_pipeline(data, centers = 4)

# Print metrics
print(result$metrics)

# Visualize cleaned power curve
plot_results(result$cleaned_data)
```

The example path above assumes you are running from the repository root. Installed-package data access is not packaged yet.

---

## 📈 Output

Each pipeline run returns:

```r
list(
  cleaned_data = <tibble with columns wind_speed, power, pred, residual>,
  metrics = list(RMSE, MAE, MAPE, R2, CA)
)
```

**Combined Accuracy (CA)** aggregates normalized RMSE, MAPE, and R² into a bounded index in `[0, 1]`.

Current limitation: `MAPE` and `CA` may become undefined when observed power contains zeros, because zero-safe metric handling has not been implemented yet.

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

## ⚠️ Current Limits

* ANN refinement requires the optional `keras` package and backend setup.
* Example data loading currently assumes a repository checkout rather than installed-package access.
* Reproducibility controls such as fixed seeds are not exposed through the main pipeline yet.
* Output is currently a plain list; a richer result object is planned for a later major release.

---

## 🧠 Methodological Notes

* **FCM Clustering:** Allows partial membership, improving robustness under overlapping operating regimes.
* **Mahalanobis Distance:** Considers feature covariance, outperforming Euclidean thresholds for correlated SCADA features.
* **ANN Refinement:** Learns nonlinear residuals and removes residual anomalies.
* **Error Handling:** Core steps include input checks and basic runtime guards, but some edge cases are still being hardened.

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

This repository is intended to be released under the MIT License.

The package metadata and root license file are still being finalized.

---

## 📬 Contact

For issues, improvements, or academic collaboration:

* GitHub Issues: [wind-clean-hybrid/issues](https://github.com/DiogoRibeiro7/wind-clean-hybrid/issues)
* Repository owner: [Diogo Ribeiro](https://github.com/DiogoRibeiro7)

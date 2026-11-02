# PharmaPulse™ Enterprise: DAX Formula Guide & Technical Documentation

## 1. Overview of Semantic Calculation Engine
PharmaPulse™ Enterprise separates data storage from business logic through an isolated, modular **DAX Measures Architecture**. Measures are calculated dynamically at query runtime within the visual filter context, leveraging VertiPaq's columnar scan engine.

---

## 2. Core Measure Formulas & Context Transitions

### 2.1. Base Multi-Column Aggregation: `[Total Monthly Sales]`
```dax
Total Monthly Sales = 
SUM(MonthlySales[M01AB]) + 
SUM(MonthlySales[M01AE]) + 
SUM(MonthlySales[N02BA]) + 
SUM(MonthlySales[N02BE]) + 
SUM(MonthlySales[N05B])  + 
SUM(MonthlySales[N05C])  + 
SUM(MonthlySales[R03])   + 
SUM(MonthlySales[R06])
```
- **Evaluation Mechanism**: Ingests all 8 individual therapeutic columns in `MonthlySales`, evaluates independent columnar sum vectors, and performs additive summation in storage engine cache.
- **Complexity**: $O(N)$ columnar scan where $N = 70$ rows. Execution time $< 1\text{ ms}$.

---

### 2.2. Time Intelligence: `[Previous Month Sales]`
```dax
Previous Month Sales = 
CALCULATE(
    [Total Monthly Sales],
    DATEADD('DateTable'[Date], -1, MONTH)
)
```
- **Evaluation Mechanism**: 
  1. `CALCULATE` initiates a context transition and modifies the existing date filter context.
  2. `DATEADD('DateTable'[Date], -1, MONTH)` shifts the active date selection backward by exactly one calendar month along the conformed date dimension.
  3. Re-evaluates `[Total Monthly Sales]` over the shifted date window.
- **Prerequisite**: Requires a contiguous, unbroken date table marked as Date Table with zero missing calendar dates.

---

### 2.3. Safe Variance Calculation: `[MoM Sales Growth %]`
```dax
MoM Sales Growth % = 
VAR CurrentSales = [Total Monthly Sales]
VAR PriorSales = [Previous Month Sales]
RETURN
    DIVIDE(CurrentSales - PriorSales, PriorSales, 0)
```
- **Evaluation Mechanism**: 
  - Employs variables (`VAR`) to compute `[Total Monthly Sales]` and `[Previous Month Sales]` exactly once, caching results and preventing duplicate query recalculations.
  - Utilizes `DIVIDE(..., 0)` to guarantee safe division, returning 0 instead of throwing `NaN` or divide-by-zero errors during the initial historical month (Jan 2014).

---

### 2.4. Therapeutic Portfolio Concentration: `[N02BE Paracetamol Share %]`
```dax
N02BE Paracetamol Share % = 
DIVIDE(
    SUM(MonthlySales[N02BE]),
    [Total Monthly Sales],
    0
)
```
- **Evaluation Mechanism**: Compares the focal single-class volume against total cross-portfolio gross volume. In the gauge visual, provides the central value indicator bounded by `[Gauge_Min_Floor_Baseline]` and `[Gauge_Max_Ceiling_Capacity]`.

---

### 2.5. Peak Hourly Concentration Ratio: `[Peak Hours Concentration Ratio %]`
```dax
Peak Hours Concentration Ratio % = 
VAR PeakHoursVolume = 
    CALCULATE(
        [Total Daily Sales],
        DailySales[Hour] IN {11, 14, 17}
    )
RETURN
    DIVIDE(PeakHoursVolume, [Total Daily Sales], 0)
```
- **Evaluation Mechanism**: Filters the daily transaction grain specifically to hours `{11, 14, 17}` and computes the proportion against the full 24-hour daily volume.

---

### 2.6. Conditional Formatting Color Palette Driver: `[MoM KPI Status Color]`
```dax
MoM KPI Status Color = 
VAR MoMGrowth = [MoM Sales Growth %]
RETURN
    SWITCH(
        TRUE(),
        MoMGrowth >= 0.05, "#10B981",  // Emerald Green (> +5%)
        MoMGrowth >= 0.00, "#38BDF8",  // Sky Blue (0% to +5%)
        MoMGrowth >= -0.05, "#F59E0B", // Amber Warning (-5% to 0%)
        "#F43F5E"                      // Rose Red Alert (< -5%)
    )
```
- **Evaluation Mechanism**: Bound directly into the Power BI card background and indicator fill properties to automate executive alerting without manual rule configuration.

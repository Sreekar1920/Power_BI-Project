# Interview Preparation Guide: How to Present This Project

This guide provides talking points, architectural explanations, and anticipated technical questions so you can present this Power BI project with complete confidence.

---

## 1. The 60-Second Elevator Pitch

> *"When the interviewer says: 'Walk me through a Power BI project you've built.'"*

**What to say:**

> "I built an end-to-end commercial pharmaceutical analytics platform called **PharmaPulse** using six years of point-of-sale data covering 57 drug brands categorized into 8 WHO therapeutic classes.
>
> Rather than just creating static charts, I designed the report around three real-world business tiers:
> 1. **Strategic (Monthly Trends)**: For commercial executives tracking long-term revenue CAGR and seasonal therapeutic mix shifts.
> 2. **Tactical (Weekly Trends)**: For supply chain planners tracking week-over-week velocity, stockout risks, and product concentration—where I discovered Paracetamol accounts for 42% of total volume.
> 3. **Operational (Daily Insights)**: For store managers, using an hour-by-weekday heatmap and an AI decomposition tree to identify peak prescription pickup windows (11 AM and 5 PM), directly informing pharmacist shift scheduling.
>
> Under the hood, I modeled the data using a clean star schema with a conformed date dimension, wrote custom DAX measures for time intelligence and period-over-period tracking, and kept all relationships single-direction for optimal VertiPaq performance."

---

## 2. Page-by-Page Walkthrough

### Page 1: Monthly Trends (Strategic Level)
- **Story**: "This page answers the macro question: *How is our business expanding year-over-year, and how predictable is our seasonal demand?*"
- **Visuals to point out**:
  - The **Combo Chart** shows steady growth across the date hierarchy from 2014 to 2019 (+6.4% CAGR).
  - The **100% Stacked Column Chart** is critical: explain that respiratory drugs (`R03`) surge in winter, while antihistamines (`R06`) spike in spring. Explain to the interviewer: *"This gives procurement teams a 4–6 week advance warning to build safety buffers before illness peaks hit."*
  - The **KPI Indicator** dynamically benchmarks actual monthly sales against `[Previous Month Sales]`.

### Page 2: Weekly Trends (Tactical Level)
- **Story**: "This page is built for inventory planners: *What is our weekly velocity, and what products carry the highest supply risk?*"
- **Visuals to point out**:
  - The **Velocity Line Chart** tracks 302 weeks with an average velocity of ~1,934 units/week and highlights peak holiday demand (Week 51).
  - The **ATC Funnel Chart** ranks the 8 drug classes by volume contribution.
  - The **Gauge Chart**: Explain that `N02BE` (Paracetamol) represents 42% of total sales. *"If an active pharmaceutical ingredient shortage hits Paracetamol, nearly half our store revenue is at risk. That's a major supply chain insight."*

### Page 3: Daily Insights (Operational Level)
- **Story**: "This page helps dispensary managers optimize daily store operations: *When do customers actually arrive, and how should we schedule staff?*"
- **Visuals to point out**:
  - The **Hour × Weekday Heatmap**: Point out the two peaks: 11:00 AM (outpatient hospital discharge scripts) and 5:00 PM – 7:00 PM (commuters picking up refills after work).
  - The **Actionable Outcome**: *"Instead of having flat staffing throughout the day, store managers can overlap pharmacist shifts during the 10:30–1:30 and 4:30–7:30 windows, cutting queue times."*
  - The **AI Decomposition Tree**: Explain that it lets users break down `[Total Daily Sales]` by hour and weekday interactively.

---

## 3. Top 10 Technical Questions & Answers

### Q1: Why did you use three separate tables (Monthly, Weekly, Daily) instead of one big table?
**Answer**:
> "The source dataset provides data at three natural temporal aggregations. Rather than forcing high-frequency daily data to compute every monthly report (which slows down queries on large volumes), I maintained multi-grain fact tables connected to a single conformed `DateTable`. This star-schema approach enables fast macro reporting while preserving granular hourly analysis where needed."

### Q2: How does your `[Previous Month Sales]` DAX measure work?
**Answer**:
> "I used `CALCULATE([Total Monthly Sales], DATEADD('DateTable'[Date], -1, MONTH))`. 
> `CALCULATE` initiates a context transition, and `DATEADD` shifts the active date filter backward by one calendar month along the conformed date dimension. This requires a marked Date Table with contiguous dates and no gaps."

### Q3: Why did you use `DIVIDE` instead of the forward slash `/` in your growth measures?
**Answer**:
> "I always use `DIVIDE(numerator, denominator, 0)` in production DAX because it provides built-in division-by-zero protection. In the first reporting period (January 2014), the previous month is blank. Using the `/` operator would return `NaN` or infinity, whereas `DIVIDE` safely returns zero."

### Q4: Why did you choose single-direction relationships instead of bidirectional?
**Answer**:
> "Single-direction (`1:*` from Dimension to Fact) is a best practice in dimensional modeling. Bidirectional cross-filtering can introduce circular filter paths, ambiguous query generation, and performance degradation in VertiPaq. Since my `DateTable` filters each fact table cleanly, single-direction is all that's required."

### Q5: What is the purpose of marking `DateTable` as an official Date Table?
**Answer**:
> "Marking it as a Date Table tells Power BI to use that table for all time-intelligence functions (`DATEADD`, `SAMEPERIODLASTYEAR`, `DATESYTD`). It also turns off auto date/time hierarchies for that table behind the scenes, which reduces the model's memory footprint."

### Q6: Can you explain filter context versus row context in DAX?
**Answer**:
> - **Row context** exists during an iteration (like inside a calculated column or an `X` function like `SUMX`), evaluating row by row.
> - **Filter context** is the set of active filters applied to the data model by slicers, visual coordinates, page filters, and `CALCULATE`.
> - A measure is always evaluated in a **filter context**. When you wrap a measure inside `CALCULATE`, it converts any existing row context into an equivalent filter context—this is called **context transition**."

### Q7: What is the VertiPaq engine and how does it compress data?
**Answer**:
> "VertiPaq is the in-memory columnar database engine that powers Power BI and Analysis Services. Because it stores data in columns rather than rows, it achieves high compression using:
> 1. Value encoding (for numeric ranges)
> 2. Hash / Dictionary encoding (for categorical text)
> 3. Run-length encoding (RLE) on sorted columns.
> In this project, columns like `Weekday Name` and `Quarter` have low distinct cardinality, allowing VertiPaq to compress the entire model down to under 200 KB."

### Q8: What was your process in Power Query (M code)?
**Answer**:
> "I used Power Query to ingest the raw files, validate data types, remove null or incomplete date records, and generate a dynamic continuous `DateTable` using `#date()` and `List.Dates()`. I also computed fiscal quarters, month sequences for custom sorting, and weekend indicators."

### Q9: What challenges did you encounter and how did you resolve them?
**Answer**:
> "One challenge was ensuring consistent visual alignment across multiple drug categories without cluttering the screen. Instead of plotting 8 separate lines on one chart, I used a **100% Stacked Column Chart** on Page 1 and an **ATC Contribution Funnel** on Page 2. This immediately surfaced the 42% Paracetamol dominance and the winter respiratory spike without visual overload."

### Q10: If this dataset scaled to 100 million daily rows, what architectural changes would you make?
**Answer**:
> "I would implement three key enterprise optimizations:
> 1. **Incremental Refresh**: Keep historical years in compressed, read-only partitions and only refresh the rolling last 30 days.
> 2. **Composite Model / Aggregations**: Maintain `MonthlySales` and `WeeklySales` in Import mode for instantaneous executive dashboards, while querying `DailySales` via DirectQuery or user-defined aggregations.
> 3. **Cardinality Tuning**: Avoid high-precision floating point timestamps; store dates and integer hours separately to minimize dictionary size."

---

## 4. Key Takeaways to Emphasize

When concluding your presentation, leave the interviewer with these three impressions:
1. **You understand the business problem**, not just the software tool.
2. **You write clean, production DAX** with proper variables, error handling, and formatting.
3. **You design intuitive user interfaces** where each chart answers a specific question for a specific stakeholder.

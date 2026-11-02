# PharmaPulse™ Enterprise: Data Model & Semantic Architecture

## 1. Architectural Philosophy: Conformed Star Schema
In enterprise Business Intelligence, data model architecture determines both query performance and reporting scalability. PharmaPulse™ implements a clean **Star Schema** with a single conformed calendar dimension (`DateTable`) serving three separate fact tables of varying temporal granularity (`MonthlySales`, `WeeklySales`, `DailySales`).

![Data Model Architecture](../assets/images/architecture-star-schema.svg)

---

## 2. Model Schema Specification & Relationships

```mermaid
erDiagram
    DateTable ||--o{ MonthlySales : "1 : * (datum)"
    DateTable ||--o{ WeeklySales : "1 : * (datum)"
    DateTable ||--o{ DailySales : "1 : * (datum)"

    DateTable {
        date Date PK "Conformed Primary Key"
        int Year "Calendar Year (2014-2019)"
        string Month "Calendar Month Name"
        string Quarter "Fiscal/Calendar Quarter"
        int Day "Day of Month"
        string Weekday_Name "Monday through Sunday"
        dax Previous_Month_Sales "Time-Intelligence Measure"
    }

    MonthlySales {
        date datum FK "Foreign Key to DateTable"
        decimal M01AB "Diclofenac / Aceclofenac"
        decimal M01AE "Ibuprofen / Naproxen"
        decimal N02BA "Aspirin / Salicylates"
        decimal N02BE "Paracetamol / Acetaminophen"
        decimal N05B "Anxiolytics / Psycholeptics"
        decimal N05C "Hypnotics / Sedatives"
        decimal R03 "Asthma / Obstructive Airway"
        decimal R06 "Systemic Antihistamines"
        dax Total_Monthly_Sales "Aggregation Measure"
    }

    WeeklySales {
        date datum FK "Foreign Key to DateTable"
        decimal M01AB "Weekly Diclofenac"
        decimal M01AE "Weekly Ibuprofen"
        decimal N02BA "Weekly Aspirin"
        decimal N02BE "Weekly Paracetamol"
        decimal N05B "Weekly Anxiolytics"
        decimal N05C "Weekly Hypnotics"
        decimal R03 "Weekly Asthma"
        decimal R06 "Weekly Antihistamines"
        dax Total_Weekly_Sales "Aggregation Measure"
    }

    DailySales {
        date datum FK "Foreign Key to DateTable"
        int Hour "Transaction Hour (0-23)"
        string Weekday_Name "Operational Day Name"
        int Year "Year Attribute"
        decimal M01AB "Hourly Diclofenac"
        decimal M01AE "Hourly Ibuprofen"
        decimal N02BA "Hourly Aspirin"
        decimal N02BE "Hourly Paracetamol"
        decimal N05B "Hourly Anxiolytics"
        decimal N05C "Hourly Hypnotics"
        decimal R03 "Hourly Asthma"
        decimal R06 "Hourly Antihistamines"
        dax Total_Daily_Sales "Aggregation Measure"
    }
```

---

## 3. Relationship Details & Cardinality

| From Table (Dimension) | From Column | To Table (Fact) | To Column | Cardinality | Cross-Filter Direction | Security Filtering |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `DateTable` | `Date` (PK) | `MonthlySales` | `datum` (FK) | One-to-Many (`1:*`) | Single (`DateTable` filters `MonthlySales`) | Default |
| `DateTable` | `Date` (PK) | `WeeklySales` | `datum` (FK) | One-to-Many (`1:*`) | Single (`DateTable` filters `WeeklySales`) | Default |
| `DateTable` | `Date` (PK) | `DailySales` | `datum` (FK) | One-to-Many (`1:*`) | Single (`DateTable` filters `DailySales`) | Default |

### Best-Practice Architectural Decisions Applied:
1. **Single-Direction Filtering**: All relationships utilize single-direction filtering (`Dimension → Fact`). Bidirectional filtering is deliberately avoided to eliminate ambiguous filter paths, circular dependencies, and VertiPaq performance degradation.
2. **Conformed Date Dimension**: The single `DateTable` serves all three grain levels, enabling synchronized slicers across report pages and unified Time Intelligence (`DATEADD`, `SAMEPERIODLASTYEAR`).
3. **No Many-to-Many Ambiguity**: Each table has a distinct granularity. The dimension connects cleanly without artificial bridge tables.
4. **VertiPaq Columnar Compression Optimization**:
   - High-cardinality floating-point numbers are rounded to 2 decimal places.
   - Text fields like `Weekday Name` and `Quarter` have low distinct value counts (<10 cardinality), resulting in dictionary compression ratios exceeding 90%.
   - Total in-memory model footprint is under 200 KB, executing sub-second visual renders.

# PharmaPulse™ Enterprise: Data Dictionary & Clinical Reference

## 1. Overview of WHO ATC Classification System
The Anatomical Therapeutic Chemical (ATC) Classification System is maintained by the World Health Organization Collaborating Centre for Drug Statistics Methodology. Drugs are divided into different groups according to the organ or system on which they act and their therapeutic, pharmacological, and chemical properties.

PharmaPulse™ Enterprise analyzes point-of-sale transactional volume for 57 commercial drug brand names aggregated into 8 core ATC therapeutic categories.

---

## 2. Comprehensive ATC Therapeutic Class Dictionary

| ATC Code | Official WHO Level 2/3 Descriptor | Representative Clinical Active Ingredients | Primary Therapeutic Indications | Commercial Volume Share | Seasonality Profile |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`M01AB`** | Anti-inflammatory and antirheumatic products, non-steroids, Acetic acid derivatives | Diclofenac, Aceclofenac, Indomethacin, Ketorolac | Osteoarthritis, rheumatoid arthritis, acute musculoskeletal gout, dental pain | **~9.8%** | Moderate year-round; slight winter joint flareups |
| **`M01AE`** | Anti-inflammatory and antirheumatic products, non-steroids, Propionic acid derivatives | Ibuprofen, Naproxen, Ketoprofen, Flurbiprofen | Fever reduction, mild-to-moderate headache, dysmenorrhea, soft-tissue inflammation | **~21.8%** | Year-round OTC volume baseline; minor winter bump |
| **`N02BA`** | Other analgesics and antipyretics, Salicylic acid and derivatives | Aspirin (Acetylsalicylic acid), combinations | Cardioprotective secondary prophylaxis (low-dose), acute pain/fever (high-dose) | **~4.9%** | Highly stable flat baseline |
| **`N02BE`** | Other analgesics and antipyretics, Pyrazolones and Anilides | Paracetamol (Acetaminophen), Propyphenazone | First-line pediatric and adult antipyretic & pain relief (safest hepatic profile when dosed correctly) | **~42.0%** (Dominant) | High seasonal surges during Q4/Q1 influenza cycles |
| **`N05B`** | Psycholeptics, Anxiolytics | Diazepam, Alprazolam, Lorazepam, Bromazepam | Acute anxiety disorders, panic attacks, pre-operative sedation, muscle spasms | **~3.2%** | Regulated prescription controlled; steady distribution |
| **`N05C`** | Psycholeptics, Hypnotics and sedatives | Zolpidem, Zopiclone, Temazepam, Melatonin agonists | Severe insomnia, transient sleep disturbance | **~0.8%** | Controlled prescription; low volume, strict refill caps |
| **`R03`** | Drugs for obstructive airway diseases | Salbutamol, Budesonide, Formoterol, Montelukast | Asthma rescue and maintenance, Chronic Obstructive Pulmonary Disease (COPD) | **~15.6%** | Severe winter cold weather & inversion smog spikes |
| **`R06`** | Antihistamines for systemic use | Cetirizine, Levocetirizine, Loratadine, Fexofenadine | Allergic rhinitis (hay fever), chronic urticaria, allergic conjunctivitis | **~1.9%** | Acute spring (March–June) tree & grass pollen surges |

---

## 3. Fact and Dimension Schema Breakdown

### 3.1. Dimension: `DateTable`
- **Grain**: 1 record per calendar day (Jan 1, 2014 – Dec 31, 2019).
- **Columns**:
  - `Date` (Date): Unique calendar timestamp [Primary Key].
  - `Year` (Integer): 4-digit calendar year (2014–2019).
  - `Month` (Text): 3-character calendar month abbreviation (`Jan`, `Feb`, `Mar`, etc.).
  - `Month Number` (Integer): Numeric sequence (1–12) used to sort `Month`.
  - `Quarter` (Text): Calendar quarter (`Q1`, `Q2`, `Q3`, `Q4`).
  - `Day` (Integer): Day of the month (1–31).
  - `Weekday Name` (Text): English day of week (`Monday` .. `Sunday`).
  - `Day of Week` (Integer): Numeric day of week (1 = Monday .. 7 = Sunday).
  - `IsWeekend` (Integer): Binary indicator (1 = Saturday/Sunday, 0 = Weekday).

### 3.2. Fact: `MonthlySales`
- **Grain**: 1 record per calendar month (70 rows total).
- **Columns**:
  - `datum` (Date): Foreign key referencing `DateTable[Date]` (First day of month).
  - `M01AB` .. `R06` (Decimal): Total units of therapeutic class sold in that month.

### 3.3. Fact: `WeeklySales`
- **Grain**: 1 record per calendar week (302 rows total).
- **Columns**:
  - `datum` (Date): Foreign key referencing `DateTable[Date]` (Monday of week).
  - `M01AB` .. `R06` (Decimal): Total units of therapeutic class sold in that week.

### 3.4. Fact: `DailySales`
- **Grain**: 1 record per hour or day POS transaction cohort (~2,106 rows).
- **Columns**:
  - `datum` (Date): Foreign key referencing `DateTable[Date]`.
  - `Hour` (Integer): POS transaction hour (0–23).
  - `Weekday Name` (Text): Transaction day name.
  - `Year` (Integer): Transaction year cohort.
  - `Month` (Integer): Transaction month sequence.
  - `M01AB` .. `R06` (Decimal): Units sold per hour/day cohort.

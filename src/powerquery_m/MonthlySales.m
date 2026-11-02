// ==============================================================================
// PharmaPulse™ Enterprise - Power Query M Script
// Table: MonthlySales (Fact Table)
// Description: Monthly point-of-sale aggregation across 8 ATC drug categories
// ==============================================================================
let
    // Source ingestion (CSV or Data Lake)
    Source = Csv.Document(File.Contents("data/salesmonthly_sample.csv"), [Delimiter=",", Columns=9, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    
    // Explicit Schema Type Casting
    TypedTable = Table.TransformColumnTypes(PromotedHeaders, {
        {"datum", type date},
        {"M01AB", type number},
        {"M01AE", type number},
        {"N02BA", type number},
        {"N02BE", type number},
        {"N05B",  type number},
        {"N05C",  type number},
        {"R03",   type number},
        {"R06",   type number}
    }),
    
    // Data quality validation: filter null or malformed date stamps
    FilteredRows = Table.SelectRows(TypedTable, each [datum] <> null)
in
    FilteredRows

// ==============================================================================
// PharmaPulse™ Enterprise - Power Query M Script
// Table: WeeklySales (Fact Table)
// Description: Weekly tactical point-of-sale volume across 8 ATC drug categories
// ==============================================================================
let
    Source = Csv.Document(File.Contents("data/salesweekly_sample.csv"), [Delimiter=",", Columns=9, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
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
    FilteredRows = Table.SelectRows(TypedTable, each [datum] <> null)
in
    FilteredRows

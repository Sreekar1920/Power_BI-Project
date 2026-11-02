// ==============================================================================
// PharmaPulse™ Enterprise - Power Query M Script
// Table: DailySales (Fact Table)
// Description: Hourly/daily transactional point-of-sale volume with temporal features
// ==============================================================================
let
    Source = Csv.Document(File.Contents("data/salesdaily_sample.csv"), [Delimiter=",", Columns=13, Encoding=65001, QuoteStyle=QuoteStyle.None]),
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
        {"R06",   type number},
        {"Year",  Int64.Type},
        {"Month", Int64.Type},
        {"Hour",  Int64.Type},
        {"Weekday Name", type text}
    }),
    FilteredRows = Table.SelectRows(TypedTable, each [datum] <> null)
in
    FilteredRows

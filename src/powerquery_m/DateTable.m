// ==============================================================================
// PharmaPulse™ Enterprise - Power Query M Script
// Table: DateTable (Conformed Calendar Dimension)
// Description: Dynamic calendar generator with fiscal hierarchies and date attributes
// ==============================================================================
let
    // Define boundary parameters
    StartDate = #date(2014, 1, 1),
    EndDate = #date(2019, 12, 31),
    DayCount = Duration.Days(Duration.From(EndDate - StartDate)) + 1,
    
    // Generate continuous date list
    DateList = List.Dates(StartDate, DayCount, #duration(1, 0, 0, 0)),
    TableFromList = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}, null, ExtraValues.Error),
    ChangedType = Table.TransformColumnTypes(TableFromList, {{"Date", type date}}),
    
    // Expand temporal attributes
    AddYear = Table.AddColumn(ChangedType, "Year", each Date.Year([Date]), Int64.Type),
    AddMonthNo = Table.AddColumn(AddYear, "Month Number", each Date.Month([Date]), Int64.Type),
    AddMonth = Table.AddColumn(AddMonthNo, "Month", each Date.ToText([Date], "MMM"), type text),
    AddQuarter = Table.AddColumn(AddMonth, "Quarter", each "Q" & Text.From(Date.QuarterOfYear([Date])), type text),
    AddDay = Table.AddColumn(AddQuarter, "Day", each Date.Day([Date]), Int64.Type),
    AddDayOfWeek = Table.AddColumn(AddDay, "Day of Week", each Date.DayOfWeek([Date], Day.Monday) + 1, Int64.Type),
    AddDayName = Table.AddColumn(AddDayOfWeek, "Weekday Name", each Date.DayOfWeekName([Date]), type text),
    AddYearMonth = Table.AddColumn(AddDayName, "YearMonth", each Date.ToText([Date], "yyyy-MM"), type text),
    AddIsWeekend = Table.AddColumn(AddYearMonth, "IsWeekend", each if [Day of Week] >= 6 then 1 else 0, Int64.Type)
in
    AddIsWeekend

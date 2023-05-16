// This file contains your Data Connector logic
section BacenConnector;

vet_usd_url = "https://www3.bcb.gov.br/vet/rest/v2/ranking?valor=100&moeda=USD&finalidade=1&tipoOperacao=C&formaDeEntrega=1&mesAno=";
vet_eur_url = "https://www3.bcb.gov.br/vet/rest/v2/ranking?valor=100&moeda=EUR&finalidade=1&tipoOperacao=C&formaDeEntrega=1&mesAno=";

[DataSource.Kind="BacenConnector", Publish="BacenConnector.Publish"]
shared BacenConnector.Contents = () => BacenConnectorNavTable() as table;

BacenConnector.Feed = (url as text) =>
    let
        source = Web.Contents(url)
    in
        source;

GetVetTableUSD = () =>

    let
        
        //create year month table
        currentDate = Date.From(DateTime.LocalNow()),
        startDate = #date(2019, 1, 1),
        numMonths = Date.Year(currentDate) * 12 + Date.Month(currentDate) - Date.Year(startDate) * 12 - Date.Month(startDate) + 1,
        yearMonthList = List.Transform({0..numMonths-1}, each Date.AddMonths(startDate, _)),
        yearMonthTextList = List.Transform(yearMonthList, each Text.PadStart(Text.From(Date.Month(_)), 2, "0") & Text.From(Date.Year(_))),
        yearMonthTable = Table.FromList(yearMonthTextList, Splitter.SplitByNothing(), {"Year Month"}),
        //add api data
        VetData = Table.AddColumn(yearMonthTable,"VET",each BacenConnector.Feed(vet_usd_url&[Year Month])),
        
        //organise table
        #"Parsed JSON" = Table.TransformColumns( VetData,{{"VET", Json.Document}}),
        #"Expanded VET" = Table.ExpandRecordColumn(#"Parsed JSON", "VET", {"rankingVet"}, {"rankingVet"}),
        #"Expanded rankingVet" = Table.ExpandListColumn(#"Expanded VET", "rankingVet"),
        #"Expanded rankingVet1" = Table.ExpandRecordColumn(#"Expanded rankingVet", "rankingVet", {"codIf", "diferenca", "nomeIf", "numOperacoes", "valorSimulado", "vet"}, {"codIf", "diferenca", "nomeIf", "numOperacoes", "valorSimulado", "vet"}),
        #"Removed Columns" = Table.RemoveColumns(#"Expanded rankingVet1",{"valorSimulado"}),
        #"Divided Column" = Table.TransformColumns(#"Removed Columns", {{"vet", each _ / 10000, type number}}),
        #"Added Custom" = Table.AddColumn(#"Divided Column", "Data", each  Date.EndOfMonth(#date(Number.FromText(Text.Middle([Year Month],2,4)),Number.FromText(Text.Start([Year Month],2)),1))),
        #"Renamed Columns" = Table.RenameColumns(#"Added Custom",{{"nomeIf", "InstituicaoFinanceira"}, {"numOperacoes", "NumeroDeOperacoes"}, {"vet", "rankingVet"}, {"diferenca", "Diferenca"}, {"codIf", "CODIF"}}),
        #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"CODIF", type text}}),
        #"Renamed Columns1" = Table.RenameColumns(#"Changed Type",{{"Year Month", "MesAno"}}),
        #"Divided Column1" = Table.TransformColumns(#"Renamed Columns1", {{"Diferenca", each _ / 1000000, type number}}),
        #"Reordered Columns" = Table.ReorderColumns(#"Divided Column1",{"MesAno", "Data", "CODIF", "InstituicaoFinanceira", "NumeroDeOperacoes", "rankingVet", "Diferenca"}),

        //create monthly ranking
        sortedTable = Table.Sort(#"Reordered Columns", {{"Data", Order.Ascending}, {"rankingVet", Order.Ascending}}),
        #"Changed Type2" = Table.TransformColumnTypes(sortedTable,{{"Data", type date}}),

        #"Grouped Rows" = Table.Group(#"Changed Type2", {"MesAno"}, {
            {"AllData", each _, type table [MesAno=nullable text, Data=nullable date, CODIF=nullable text, rankingVet=nullable number]}
        }),
        #"Added Custom2" = Table.AddColumn(#"Grouped Rows", "RankedData", each Table.AddIndexColumn(Table.Sort([AllData], {"rankingVet", Order.Ascending}), "Rank", 1, 1)),
        #"Renamed Columns2" = Table.RenameColumns(#"Added Custom2",{{"MesAno", "MesAnoOr"}}),
        #"Expanded RankedData" = Table.ExpandTableColumn(#"Renamed Columns2", "RankedData", {"MesAno", "Data", "CODIF", "InstituicaoFinanceira", "NumeroDeOperacoes", "rankingVet", "Diferenca", "Rank"}, {"MesAno", "Data", "CODIF", "InstituicaoFinanceira", "NumeroDeOperacoes", "rankingVet", "Diferenca", "Rank"}),
        #"Removed Columns2" = Table.RemoveColumns(#"Expanded RankedData",{"MesAnoOr", "AllData"})
    in
        #"Removed Columns2";

GetVetTableEUR = () =>

    let
        
        //create year month table
        currentDate = Date.From(DateTime.LocalNow()),
        startDate = #date(2019, 1, 1),
        numMonths = Date.Year(currentDate) * 12 + Date.Month(currentDate) - Date.Year(startDate) * 12 - Date.Month(startDate) + 1,
        yearMonthList = List.Transform({0..numMonths-1}, each Date.AddMonths(startDate, _)),
        yearMonthTextList = List.Transform(yearMonthList, each Text.PadStart(Text.From(Date.Month(_)), 2, "0") & Text.From(Date.Year(_))),
        yearMonthTable = Table.FromList(yearMonthTextList, Splitter.SplitByNothing(), {"Year Month"}),
        //add api data
        VetData = Table.AddColumn(yearMonthTable,"VET",each BacenConnector.Feed(vet_eur_url&[Year Month])),
        
        //organise table
        #"Parsed JSON" = Table.TransformColumns( VetData,{{"VET", Json.Document}}),
        #"Expanded VET" = Table.ExpandRecordColumn(#"Parsed JSON", "VET", {"rankingVet"}, {"rankingVet"}),
        #"Expanded rankingVet" = Table.ExpandListColumn(#"Expanded VET", "rankingVet"),
        #"Expanded rankingVet1" = Table.ExpandRecordColumn(#"Expanded rankingVet", "rankingVet", {"codIf", "diferenca", "nomeIf", "numOperacoes", "valorSimulado", "vet"}, {"codIf", "diferenca", "nomeIf", "numOperacoes", "valorSimulado", "vet"}),
        #"Removed Columns" = Table.RemoveColumns(#"Expanded rankingVet1",{"valorSimulado"}),
        #"Divided Column" = Table.TransformColumns(#"Removed Columns", {{"vet", each _ / 10000, type number}}),
        #"Added Custom" = Table.AddColumn(#"Divided Column", "Data", each  Date.EndOfMonth(#date(Number.FromText(Text.Middle([Year Month],2,4)),Number.FromText(Text.Start([Year Month],2)),1))),
        #"Renamed Columns" = Table.RenameColumns(#"Added Custom",{{"nomeIf", "InstituicaoFinanceira"}, {"numOperacoes", "NumeroDeOperacoes"}, {"vet", "rankingVet"}, {"diferenca", "Diferenca"}, {"codIf", "CODIF"}}),
        #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"CODIF", type text}}),
        #"Renamed Columns1" = Table.RenameColumns(#"Changed Type",{{"Year Month", "MesAno"}}),
        #"Divided Column1" = Table.TransformColumns(#"Renamed Columns1", {{"Diferenca", each _ / 1000000, type number}}),
        #"Reordered Columns" = Table.ReorderColumns(#"Divided Column1",{"MesAno", "Data", "CODIF", "InstituicaoFinanceira", "NumeroDeOperacoes", "rankingVet", "Diferenca"}),

        //create monthly ranking
        sortedTable = Table.Sort(#"Reordered Columns", {{"Data", Order.Ascending}, {"rankingVet", Order.Ascending}}),
        #"Changed Type2" = Table.TransformColumnTypes(sortedTable,{{"Data", type date}}),

        #"Grouped Rows" = Table.Group(#"Changed Type2", {"MesAno"}, {
            {"AllData", each _, type table [MesAno=nullable text, Data=nullable date, CODIF=nullable text, rankingVet=nullable number]}
        }),
        #"Added Custom2" = Table.AddColumn(#"Grouped Rows", "RankedData", each Table.AddIndexColumn(Table.Sort([AllData], {"rankingVet", Order.Ascending}), "Rank", 1, 1)),
        #"Renamed Columns2" = Table.RenameColumns(#"Added Custom2",{{"MesAno", "MesAnoOr"}}),
        #"Expanded RankedData" = Table.ExpandTableColumn(#"Renamed Columns2", "RankedData", {"MesAno", "Data", "CODIF", "InstituicaoFinanceira", "NumeroDeOperacoes", "rankingVet", "Diferenca", "Rank"}, {"MesAno", "Data", "CODIF", "InstituicaoFinanceira", "NumeroDeOperacoes", "rankingVet", "Diferenca", "Rank"}),
        #"Removed Columns2" = Table.RemoveColumns(#"Expanded RankedData",{"MesAnoOr", "AllData"})
    in
        #"Removed Columns2";

BacenConnectorNavTable = () as table =>

let
    source = #table({"Name","Data","ItemKind","ItemName","IsLeaf"},{
        {"VET USD",GetVetTableUSD(),"Table","Table",true},
        {"VET EUR",GetVetTableEUR(),"Table","Table",true}
    }),

    navtable = Table.ToNavigationTable(source,{"Name"},"Name","Data","ItemKind","ItemName","IsLeaf")

in
    navtable;

//função auxiliar que torna a NavTable efetivamente numa tabela de navegação
Table.ToNavigationTable = (
    table as table,
    keyColumns as list,
    nameColumn as text,
    dataColumn as text,
    itemKindColumn as text,
    itemNameColumn as text,
    isLeafColumn as text
) as table =>
    let
        tableType = Value.Type(table),
        newTableType = Type.AddTableKey(tableType, keyColumns, true) meta 
        [
            NavigationTable.NameColumn = nameColumn, 
            NavigationTable.DataColumn = dataColumn,
            NavigationTable.ItemKindColumn = itemKindColumn, 
            Preview.DelayColumn = itemNameColumn, 
            NavigationTable.IsLeafColumn = isLeafColumn
        ],
        navigationTable = Value.ReplaceType(table, newTableType)
    in
        navigationTable;


// Data Source Kind description
BacenConnector = [
    Authentication = [
        // Key = [],
        // UsernamePassword = [],
        // Windows = [],
        Implicit = []
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
BacenConnector.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = BacenConnector.Icons,
    SourceTypeImage = BacenConnector.Icons
];

BacenConnector.Icons = [
    Icon16 = { Extension.Contents("BacenConnector16.png"), Extension.Contents("BacenConnector20.png"), Extension.Contents("BacenConnector24.png"), Extension.Contents("BacenConnector32.png") },
    Icon32 = { Extension.Contents("BacenConnector32.png"), Extension.Contents("BacenConnector40.png"), Extension.Contents("BacenConnector48.png"), Extension.Contents("BacenConnector64.png") }
];


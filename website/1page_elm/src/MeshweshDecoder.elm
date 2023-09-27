module MeshweshDecoder exposing (..)

-- JSON decoding of the types recieved from Meshwesh

import MeshweshTypes
import Json.Decode as Decode
    exposing
        ( Decoder
        , decodeString
        , field
        , int
        , list
        , map3
        , map4
        , string
        )
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Json.Decode exposing (nullable)
import Json.Decode exposing (succeed)
import Json.Decode exposing (fail)
import String.Extra


decodeSummaryList: Decoder (List MeshweshTypes.Summary)
decodeSummaryList =
    list decodeSummary
    
decodeSummary : Decoder MeshweshTypes.Summary
decodeSummary =
    map4 MeshweshTypes.Summary
        (field "id" string)
        (field "name" string)
        (field "keywords" (list string))
        (field "derivedData" decodeDerivedData)

decodeDerivedData : Decoder MeshweshTypes.DerivedData
decodeDerivedData =
    map3 MeshweshTypes.DerivedData
        (field "listStartDate" int)
        (field "listEndDate" int)
        (field "extendedName" string)


decodeInvasionRating : Decoder MeshweshTypes.InvasionRating
decodeInvasionRating =
    Decode.succeed  MeshweshTypes.InvasionRating
        |> required "_id" string
        |> required  "value" int
        |> required "note" decodeNote


decodeManeuverRating : Decoder MeshweshTypes.ManeuverRating
decodeManeuverRating =
    Decode.succeed  MeshweshTypes.ManeuverRating
        |> required "_id" string
        |> required  "value" int
        |> required "note" decodeNote



decodeTopographyHelp : String -> Decoder MeshweshTypes.Topography
decodeTopographyHelp topographyString =
    let 
        -- Work around bug in Meshwesh JSON " Hilly"
        cleanString = String.Extra.clean topographyString
    in
        case cleanString of
            "Arable" -> (Decode.succeed MeshweshTypes.Arable)
            "Delta"   -> (Decode.succeed MeshweshTypes.Delta)
            "Dry" ->   (Decode.succeed MeshweshTypes.Dry)
            "Forest"  -> (Decode.succeed MeshweshTypes.Forest)
            "Hilly" -> (Decode.succeed MeshweshTypes.Hilly)
            "Marsh" -> (Decode.succeed MeshweshTypes.Marsh)
            "Steppe" -> (Decode.succeed MeshweshTypes.Steppe)
            _ -> ( fail ("Invalid topography" ++ topographyString))

decodeTopography : Decoder MeshweshTypes.Topography
decodeTopography =
  string 
    |> Decode.andThen decodeTopographyHelp


decodeHomeTopography: Decoder MeshweshTypes.HomeTopography
decodeHomeTopography =
    Decode.succeed  MeshweshTypes.HomeTopography
        |> required "_id" string
        |> required  "values" (list decodeTopography)
        |> required "note" decodeNote



decodeTroopEntry: Decoder MeshweshTypes.TroopEntry
decodeTroopEntry =
    Decode.succeed  MeshweshTypes.TroopEntry
        |> required "_id" string
        |> required  "troopTypeCode" decodeTroopTypeCode
        |> required  "dismountTypeCode" (Decode.maybe decodeTroopTypeCode)
        |> required "note" decodeNote

decodeTroopEntriesList: Decoder MeshweshTypes.TroopEntriesList
decodeTroopEntriesList =
    Decode.succeed  MeshweshTypes.TroopEntriesList
        |> required "_id" string
        |> required  "troopEntries" (list decodeTroopEntry)


decodeTroopTypeCodeHelp : String -> Decoder MeshweshTypes.TroopTypeCode
decodeTroopTypeCodeHelp troopTypeString =
        case troopTypeString of
            "ARC" -> (Decode.succeed MeshweshTypes.ARC)
            "BAD"   -> (Decode.succeed MeshweshTypes.BAD)
            "BLV" ->   (Decode.succeed MeshweshTypes.BLV)
            "BTX"  -> (Decode.succeed MeshweshTypes.BTX)
            "CAT" -> (Decode.succeed MeshweshTypes.CAT)
            "CHT" -> (Decode.succeed MeshweshTypes.CHT)
            "ECV" -> (Decode.succeed MeshweshTypes.ECV)
            "EFT" -> (Decode.succeed MeshweshTypes.EFT)
            "ELE" -> (Decode.succeed MeshweshTypes.ELE)
            "HBW" -> (Decode.succeed MeshweshTypes.HBW)
            "HFT" -> (Decode.succeed MeshweshTypes.HFT)
            "JCV" -> (Decode.succeed MeshweshTypes.JCV)
            "KNT" -> (Decode.succeed MeshweshTypes.KNT)
            "LFT" -> (Decode.succeed MeshweshTypes.LFT)
            "LSP" -> (Decode.succeed MeshweshTypes.LSP)
            "PAV" -> (Decode.succeed MeshweshTypes.PAV)
            "RBL" -> (Decode.succeed MeshweshTypes.PIK)
            "RDR" -> (Decode.succeed MeshweshTypes.RDR)
            "SKM" -> (Decode.succeed MeshweshTypes.SKM)
            "SPR" -> (Decode.succeed MeshweshTypes.SPR)
            "WBD" -> (Decode.succeed MeshweshTypes.WBD)
            "WRR" -> (Decode.succeed MeshweshTypes.WRR)
            "WWG" -> (Decode.succeed MeshweshTypes.WWG)
            _ -> ( fail ("Invalid TroopTypeCode" ++ troopTypeString))

decodeTroopTypeCode : Decoder MeshweshTypes.TroopTypeCode
decodeTroopTypeCode =
  string 
    |> Decode.andThen decodeTroopTypeCodeHelp


emptyToNothing : Maybe String -> Maybe String
emptyToNothing aNote = 
    Maybe.andThen 
        (\note -> String.Extra.nonBlank note)
        aNote

decodeNote: Decoder (Maybe String)
decodeNote  =
    Decode.nullable string |> Decode.map emptyToNothing

topographyToString: MeshweshTypes.Topography -> String
topographyToString topography =
    case topography of
        MeshweshTypes.Arable -> "Arable"
        MeshweshTypes.Hilly -> "Hilly"
        MeshweshTypes.Dry -> "Dry"
        MeshweshTypes.Forest -> "Forest"
        MeshweshTypes.Delta -> "Delta"
        MeshweshTypes.Steppe -> "Steppe"
        MeshweshTypes.Marsh -> "Marsh"



decodeDerivedData2 : Decoder MeshweshTypes.DerivedData
decodeDerivedData2 =
     Decode.succeed MeshweshTypes.DerivedData
        |> required "listStartDate" int
        |> required "listEndDate" int
        |> required  "extendedName" string


decodeBattleCardCodeHelp : String -> Decoder MeshweshTypes.BattleCardCode
decodeBattleCardCodeHelp battleCardCode =
    case battleCardCode of
        "AM" -> (Decode.succeed MeshweshTypes.AM)
        "DC"   -> (Decode.succeed MeshweshTypes.DC)
        "FC" ->   (Decode.succeed MeshweshTypes.FC)
        "MI"  -> (Decode.succeed MeshweshTypes.MI)
        "NC" -> (Decode.succeed MeshweshTypes.NC)
        "PD" -> (Decode.succeed MeshweshTypes.PD)
        "PT" -> (Decode.succeed MeshweshTypes.PT)
        "SC" -> (Decode.succeed MeshweshTypes.SC)
        "SW" -> (Decode.succeed MeshweshTypes.SW)
        _ -> ( fail ("Invalid battle card code" ++ battleCardCode))

decodeBattleCardCode : Decoder MeshweshTypes.BattleCardCode
decodeBattleCardCode =
  string 
    |> Decode.andThen decodeBattleCardCodeHelp

decodeBattleCardEntry: Decoder MeshweshTypes.BattleCardEntry
decodeBattleCardEntry =
     Decode.succeed MeshweshTypes.BattleCardEntry
        -- |> required  "id" string
        |> required "min" (Decode.maybe int)
        |> required "max" (Decode.maybe int)
        |> required "battleCardCode" decodeBattleCardCode
        |> required "note" decodeNote


decodeDateRangeEntry: Decoder MeshweshTypes.DateRangeEntry
decodeDateRangeEntry =
     Decode.succeed MeshweshTypes.DateRangeEntry
        |> required  "startDate" int
        |> required  "endDate" int


decodeTroopOptionEntry: Decoder MeshweshTypes.TroopOptionEntry
decodeTroopOptionEntry =
     Decode.succeed MeshweshTypes.TroopOptionEntry
        |> required  "min" int
        |> required  "max" int
        |> required "dateRanges" (list decodeDateRangeEntry)
        |> required "troopEntries" (list decodeTroopEntry)
        |> required "description" string
        |> required "note" decodeNote
        |> required "core" string



decodeArmy : Decoder MeshweshTypes.Army
decodeArmy =
     Decode.succeed MeshweshTypes.Army
        |> required  "id" string
        |> required "keywords" (list string)
        |> (required "derivedData" decodeDerivedData2)
        -- -- |> required "sortId" float
        |> required "name" string
        |> required "invasionRatings" (list decodeInvasionRating)
        |> required "maneuverRatings" (list decodeManeuverRating)
        |> required "homeTopographies" (list decodeHomeTopography)
        |> required "troopEntriesForGeneral" (list (decodeTroopEntriesList))
        |> required "battleCardEntries" (list decodeBattleCardEntry)
        |> required "troopOptions" (list decodeTroopOptionEntry)

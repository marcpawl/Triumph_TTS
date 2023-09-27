module GeneralsSubsection exposing (..)

import Browser
import Css exposing (bold, em, fontWeight, padding, px)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (list)
import Html.Events exposing (onClick)
import Html.Styled exposing (styled)
import Html.Attributes
import Http
import Json.Decode as Decode exposing (Decoder)
import List
import MeshweshTypes exposing (..)
import Platform.Cmd as Cmd
import TroopTypeCode exposing (render)
import Notes
import List exposing (length)

toTroopTypeCodeName: TroopEntry -> String
toTroopTypeCodeName troopEntry =
  TroopTypeCode.name (troopEntry.troopTypeCode)

toNoteString: TroopEntry -> String
toNoteString troopEntry =
  Maybe.withDefault "" (troopEntry.note)


-- Render Html.tr
renderTroopEntry: TroopEntry ->  Html.Html msg
renderTroopEntry troopEntry =
    Html.tr
    []
    [
        Html.td 
          []
          [
            TroopTypeCode.render troopEntry.troopTypeCode    
          ]
    ,   Notes.render troopEntry.note
    ]

-- Render the list of Troop Entries, when there is only one list
-- list of Html.tr
render1List: List TroopEntry -> List (Html.Html msg)
render1List troopEntryList =
    List.map renderTroopEntry troopEntryList

-- Format the string that will list all the troop types 
-- for a list, when there is more than one type.
-- See: render1List
stringListForMany: String -> (TroopEntry->String) -> List TroopEntry -> String
stringListForMany seperator fieldExtractor list =
   String.join 
     seperator
     (List.map fieldExtractor list)

removeNothingFromList : List (Maybe a) -> List a 
removeNothingFromList list =
    List.filterMap identity list

-- list of Html.tr
renderListForMany: String -> List TroopEntry -> List (Html.Html msg)
renderListForMany seperator list =
  [
    Html.tr
      []
      [
        Html.td
          []
          [
            Html.text (stringListForMany seperator toTroopTypeCodeName list)
          ]
      ,   Html.td
          []
          [
            Html.text 
               (String.join 
                 "; "
                 (removeNothingFromList 
                   (List.map .note list)))
          ]

      ]
  ]

-- Get the strings for the troop types.
-- Each entry is for a row in the table.
-- If there is only one list then each troop entry is one string.
-- If there is more than one list the each string represents one 
-- list of troop entries.
toTroopEntryStrings: String -> (TroopEntry -> String) -> List (List TroopEntry) -> List String
toTroopEntryStrings seperator fieldExtractor listOfLists =
    case List.head listOfLists of
        Nothing -> [] -- ERROR
        Just head ->
            case List.tail listOfLists of
              Nothing -> 
                -- only 1 list
                (List.map fieldExtractor head)
              Just _ ->
                -- more than 1 list
                (List.map (stringListForMany seperator fieldExtractor) listOfLists)

toTroopTypeCodeNameStrings: List (List TroopEntry) -> List String
toTroopTypeCodeNameStrings listOfLists  =
  toTroopEntryStrings " or " toTroopTypeCodeName listOfLists

hasValue: (Maybe a) -> Bool
hasValue a =
  case a of
    Nothing -> False
    Just _ -> True
    

-- Extract the notes from the troop entries and return the
-- strings of the notes.  If there is no note for a troop
-- entry then remove it.  Join the remaining notes into
-- one string
-- post-conditions:
--   length of result is less than or equal to length list.
toNotesListString: List TroopEntry ->  String
toNotesListString list =
  (List.map .note list) |> 
  (List.filter hasValue) |> 
  (List.map (Maybe.withDefault "")) |>
  (String.join "; ")

-- For each list of entries, find the string that
-- is the joining of the notes
toTroopNoteStrings: List (List TroopEntry) -> List String
toTroopNoteStrings listOfLists  =
  List.map toNotesListString listOfLists

ifOtherwise: Int -> List TroopEntry -> String
ifOtherwise index _ =
  if index == 0 then
    "If present"
  else
    "Otherwise"

toPrefixStrings: List (List MeshweshTypes.TroopEntry) -> List String
toPrefixStrings listOfLists  =
    if (List.length listOfLists) == 1 then
      [ "" ]
    else
      List.indexedMap ifOtherwise listOfLists

   
toTableRowContents: List MeshweshTypes.TroopEntriesList -> List (String,String,String)
toTableRowContents troopEntriesList =
  let
    _ = List.map .troopEntries troopEntriesList
  in
    []

toTd: String -> Html.Html msg
toTd text =
  Html.td
    []
    [
      Html.text text
    ]

toTableRow: (String,String,String) -> Html.Html msg
toTableRow (a,b,c) =
    Html.tr
      []
      [
        (toTd a)
      , (toTd b)
      , (toTd c)
      ]


subsectionRendered: Army -> Html.Html msg
subsectionRendered army =
    Html.div []
        [ Html.div
            [
                Html.Attributes.class "general_troop_type_subsection_header"
            ]
            [ Html.text "General's Troop Type"
            ]
        , Html.table
            []
            [ 
                Html.tbody
                    []
                    (List.map toTableRow (toTableRowContents army.troopEntriesForGeneral))
            ]
        ]


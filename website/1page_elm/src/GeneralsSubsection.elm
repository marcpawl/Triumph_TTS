module GeneralsSubsection exposing (..)

import Debug
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
import TroopTypeCode exposing (name)
import Notes
import List exposing (length)
import BookParts exposing (..)

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


toTroopTypeNameString: TroopEntry -> String
toTroopTypeNameString troopEntry =
  TroopTypeCode.name (troopEntry.troopTypeCode)

orTogetheredTroopTypeames: TroopEntriesList -> String
orTogetheredTroopTypeames troopEntryList =
  ( List.map
      (\troopEntry->toTroopTypeNameString troopEntry)
      troopEntryList.troopEntries
  ) |> (String.join ", or ")
        

toTroopTypeNameStrings: List TroopEntriesList -> List String
toTroopTypeNameStrings listOfLists  =
    List.map orTogetheredTroopTypeames listOfLists


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
toNotesListString: TroopEntriesList->  String
toNotesListString list =
  (List.map .note list.troopEntries) |> 
  (List.filter hasValue) |> 
  (List.map (Maybe.withDefault "")) |>
  (String.join "; ")

-- For each list of entries, find the string that
-- is the joining of the notes
toTroopNoteStrings: List TroopEntriesList -> List String
toTroopNoteStrings listOfLists  =
  List.map toNotesListString listOfLists

   
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


toTable: List (String, String, String) -> Html.Html msg
toTable rowData =
  Html.table
    []
    [ 
      Html.tbody
        []
        (List.map toTableRow rowData)
    ]
  

ifPresentList: List a -> List String
ifPresentList list =
  if (List.length list) == 1 then
    [""]
  else
    List.append 
      ["If Present"] 
      (List.repeat 
        ((List.length list) - 1)
      "Otherwise"
      )


zip3 a b c =
  (a, b, c)


renderManyListTable: List TroopEntriesList -> Html.Html msg
renderManyListTable listTroopEntriesList =
  let
    notes = toTroopNoteStrings listTroopEntriesList
    troopNames = toTroopTypeNameStrings listTroopEntriesList
    present = ifPresentList listTroopEntriesList
    rowData = List.map3  zip3 present troopNames notes
  in
    toTable rowData


render1ListTable: TroopEntriesList -> Html.Html msg
render1ListTable troopEntriesList =
  let
    notes = List.map (\troopEntry->troopEntry.note) troopEntriesList.troopEntries |>
            (List.map (Maybe.withDefault ""))
    troopNames =
      List.map
       (\troopEntry->troopEntry.troopTypeCode) 
       troopEntriesList.troopEntries 
      |> List.map TroopTypeCode.name
    present = ifPresentList troopEntriesList.troopEntries
    rowData = List.map3 zip3 present troopNames notes
  in
    toTable rowData


error message =
  Html.div
    [
      Html.Attributes.class "error"
    ]
    [
      Html.text message
    ]

tableRendered: List TroopEntriesList -> Html.Html msg
tableRendered listTroopEntriesList =
  let 
    length = List.length listTroopEntriesList
  in
    if length < 1 then
      error "listTroopEntriesList is too small"
    else if length == 1 then
      let
        headMaybe = List.head listTroopEntriesList
      in
        case headMaybe of
          Nothing ->  error "No head in listTroopEntriesList"
          Just head -> render1ListTable head
    else
      (renderManyListTable listTroopEntriesList)


subsectionRendered: Army -> Html msg
subsectionRendered army =
  let
    table = tableRendered army.troopEntriesForGeneral
  in
       (Html.div []
            [
              ( Html.div
                [
                    Html.Attributes.class "subsectionHeader"
                ]
                [ Html.text "General's Troop Type" ]
              )
          , table
            ])
 

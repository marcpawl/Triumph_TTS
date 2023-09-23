module GeneralsSubsection exposing (subsectionRendered)

import Armies exposing (..)
import Browser
import Css exposing (bold, em, fontWeight, padding, px)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (list)
import Html.Events exposing (onClick)
import Html.Styled exposing (styled)
import Html.Styled.Attributes
import Http
import Json.Decode as Decode exposing (Decoder)
import List
import MeshWeshTypes exposing (..)
import Platform.Cmd as Cmd
import Themes
import TroopTypeCode exposing (render)
import Notes
import List exposing (length)

toTroopTypeCodeName: TroopEntry -> String
toTroopTypeCodeName troopEntry =
  TroopTypeCode.name (troopEntry.troopTypeCode)

toNoteString: TroopEntry -> String
toNoteString troopEntry =
  Maybe.withDefault "" (troopEntry.note)


-- type Prefix = NoPrefix | IfPresent | OtherwisePrefix


-- renderGeneralListOtherwise: List a -> List (Prefix,a)
-- renderGeneralListOtherwise list =
--   List.map (\a->(OtherwisePrefix,a) ) list

-- renderGeneralList2Plus: a -> (List a) -> (List (Prefix,a))
-- renderGeneralList2Plus first tail =
--   List.concat
--     [
--       [
--         (IfPresent, first)
--       ]
--     , renderGeneralListOtherwise tail
--     ]

-- renderGeneralList1Plus: a -> Maybe (List a) -> (List (Prefix,a))
-- renderGeneralList1Plus first maybeTail =
--     case maybeTail of
--         Nothing -> [ (NoPrefix, first)]
--         Just y -> renderGeneralList2Plus first y

-- renderGeneralList0Plus: (Maybe a) -> (List a) -> (List (Prefix,a))
-- renderGeneralList0Plus head list =
--     case head of
--         Nothing -> []
--         Just x -> renderGeneralList1Plus x (List.tail list)

-- renderGeneralList: List a -> List (Prefix, a)
-- renderGeneralList list =
--     let 
--       maybeHead = List.head list
--     in
-- `       case maybeHead of
--           Nothing -> [] -- ERROR
--           Just head -> renderGeneralList1Plus head (List.tail list)


-- Render Html.tr
renderTroopEntry: TroopEntry ->  Html.Styled.Html msg
renderTroopEntry troopEntry =
    Html.Styled.tr
    []
    [
        Html.Styled.td 
          []
          [
            TroopTypeCode.render troopEntry.troopTypeCode    
          ]
    ,   Notes.render troopEntry.note
    ]

-- Render the list of Troop Entries, when there is only one list
-- list of Html.tr
render1List: List TroopEntry -> List (Html.Styled.Html msg)
render1List troopEntryList =
    List.map renderTroopEntry troopEntryList

-- Format the string that will list all the troop types 
-- for a list, when there is more than one type.
-- See: render1List
stringListForMany: (TroopEntry->String) -> List TroopEntry -> String
stringListForMany fieldExtractor list =
   String.join 
     " or "
     (List.map fieldExtractor list)

removeNothingFromList : List (Maybe a) -> List a 
removeNothingFromList list =
    List.filterMap identity list

-- list of Html.tr
renderListForMany: List TroopEntry -> List (Html.Styled.Html msg)
renderListForMany list =
  [
    Html.Styled.tr
      []
      [
        Html.Styled.td
          []
          [
            Html.Styled.text (stringListForMany toTroopTypeCodeName list)
          ]
      ,   Html.Styled.td
          []
          [
            Html.Styled.text 
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
toTroopEntryStrings: (TroopEntry -> String) -> List (List TroopEntry) -> List String
toTroopEntryStrings fieldExtractor listOfLists =
    case List.head listOfLists of
        Nothing -> [] -- ERROR
        Just head ->
            case List.tail listOfLists of
              Nothing -> 
                -- only 1 list
                (List.map fieldExtractor head)
              Just _ ->
                -- more than 1 list
                (List.map (stringListForMany fieldExtractor) listOfLists)

toTroopTypeCodeNameStrings: List (List TroopEntry) -> List String
toTroopTypeCodeNameStrings listOfLists  =
  toTroopEntryStrings toTroopTypeCodeName listOfLists

toTroopNoteStrings: List (List TroopEntry) -> List String
toTroopNoteStrings listOfLists  =
  toTroopEntryStrings toNoteString listOfLists

ifOtherwise: Int -> List TroopEntry -> String
ifOtherwise index _ =
  if index == 0 then
    "If present"
  else
    "Otherwise"

toPrefixStrings: List (List TroopEntry) -> List String
toPrefixStrings listOfLists  =
    if (List.length listOfLists) == 1 then
      [ "" ]
    else
      List.indexedMap ifOtherwise listOfLists

zip3: String -> String -> String -> (String,String,String)
zip3 a b c = 
  (a,b,c)

toTableRowContents: List (List TroopEntry) -> List (String,String,String)
toTableRowContents listOfLists =
    List.map3
      zip3 
      (toPrefixStrings  listOfLists)
      (toTroopTypeCodeNameStrings listOfLists)
      (toTroopNoteStrings listOfLists)
 
toTd: String -> Html.Styled.Html msg
toTd text =
  Html.Styled.td
    []
    [
      Html.Styled.text text
    ]

toTableRow: (String,String,String) -> Html.Styled.Html msg
toTableRow (a,b,c) =
    Html.Styled.tr
      []
      [
        (toTd a)
      , (toTd b)
      , (toTd c)
      ]


subsectionRendered: Army -> Html.Styled.Html msg
subsectionRendered army =
    Html.Styled.div []
        [ Html.Styled.div
            [
                Html.Styled.Attributes.class "general_troop_type_section_header"
            ]
            [ Html.Styled.text "General's Troop Type"
            ]
        , Html.Styled.table
            []
            [ 
                Html.Styled.tbody
                    []
                    (List.map toTableRow (toTableRowContents army.troopEntriesForGeneral))
            ]
        ]


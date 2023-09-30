module TroopOptionsSubsection exposing (subsectionRendered)

-- import Debug
-- import Browser
-- import Css exposing (bold, em, fontWeight, padding, px)
import Html exposing (Html, button, div, text)
-- import Html.Attributes exposing (list)
-- import Html.Events exposing (onClick)
-- import Html.Styled exposing (styled)
import Html.Attributes
-- import Http
-- import Json.Decode as Decode exposing (Decoder)
import List
import MeshweshTypes exposing (..)
-- import Platform.Cmd as Cmd
import TroopTypeCode exposing (name)
import Notes
import List exposing (length)
import BookParts exposing (..)
import DateRange
import BattleCards


-- toNoteString: TroopEntry -> String
-- toNoteString troopEntry =
--   Maybe.withDefault "" (troopEntry.note)


-- -- Render Html.tr
-- renderTroopEntry: TroopEntry ->  Html.Html msg
-- renderTroopEntry troopEntry =
--     Html.tr
--     []
--     [
--         Html.td 
--           []
--           [
--             TroopTypeCode.render troopEntry.troopTypeCode    
--           ]
--     ,   Notes.render troopEntry.note
--     ]


-- -- Format the string that will list all the troop types 
-- -- for a list, when there is more than one type.
-- -- See: render1List
-- stringListForMany: String -> (TroopEntry->String) -> List TroopEntry -> String
-- stringListForMany seperator fieldExtractor list =
--    String.join 
--      seperator
--      (List.map fieldExtractor list)

removeNothingFromList : List (Maybe a) -> List a 
removeNothingFromList list =
    List.filterMap identity list


toTroopTypeNameString: TroopEntry -> String
toTroopTypeNameString troopEntry =
  TroopTypeCode.name (troopEntry.troopTypeCode)

orTogetheredTroopTypenames: List TroopEntry -> String
orTogetheredTroopTypenames list =
  ( List.map
      (\troopEntry->toTroopTypeNameString troopEntry)
      list
  ) |> (String.join ", or ")
        

-- toTroopTypeNameStrings: List TroopEntriesList -> List String
-- toTroopTypeNameStrings listOfLists  =
--     List.map orTogetheredTroopTypeames listOfLists


-- hasValue: (Maybe a) -> Bool
-- hasValue a =
--   case a of
--     Nothing -> False
--     Just _ -> True
    

-- Extract the notes from the troop entries and return the
-- strings of the notes.  If there is no note for a troop
-- entry then remove it. 
-- toNotesList: List TroopEntry-> List String
-- toNotesList list =
--   (List.map .note list) |> 
--   (List.filter hasValue) |> 
--   (List.map (Maybe.withDefault "")) 


-- -- For each list of entries, find the string that
-- -- is the joining of the notes
-- toTroopNoteStrings: List TroopEntriesList -> List String
-- toTroopNoteStrings listOfLists  =
--   List.map toNotesListString listOfLists

   
-- toTableRowContents: List MeshweshTypes.TroopEntriesList -> List (String,String,String)
-- toTableRowContents troopEntriesList =
--   let
--     _ = List.map .troopEntries troopEntriesList
--   in
--     []

-- toTd: String -> Html.Html msg
-- toTd text =
--   Html.td
--     []
--     [
--       Html.text text
--     ]

-- toTableRow: (String,String,String) -> Html.Html msg
-- toTableRow (a,b,c) =
--     Html.tr
--       []
--       [
--         (toTd a)
--       , (toTd b)
--       , (toTd c)
--       ]


-- toTable: List (String, String, String) -> Html.Html msg
-- toTable rowData =
--   Html.table
--     []
--     [ 
--       Html.tbody
--         []
--         (List.map toTableRow rowData)
--     ]
  

-- ifPresentList: List a -> List String
-- ifPresentList list =
--   if (List.length list) == 1 then
--     [""]
--   else
--     List.append 
--       ["If Present"] 
--       (List.repeat 
--         ((List.length list) - 1)
--       "Otherwise"
--       )


-- zip3 a b c =
--   (a, b, c)


-- renderManyListTable: List TroopEntriesList -> Html.Html msg
-- renderManyListTable listTroopEntriesList =
--   let
--     notes = toTroopNoteStrings listTroopEntriesList
--     troopNames = toTroopTypeNameStrings listTroopEntriesList
--     present = ifPresentList listTroopEntriesList
--     rowData = List.map3  zip3 present troopNames notes
--   in
--     toTable rowData


-- render1ListTable: TroopEntriesList -> Html.Html msg
-- render1ListTable troopEntriesList =
--   let
--     notes = List.map (\troopEntry->troopEntry.note) troopEntriesList.troopEntries |>
--             (List.map (Maybe.withDefault ""))
--     troopNames =
--       List.map
--        (\troopEntry->troopEntry.troopTypeCode) 
--        troopEntriesList.troopEntries 
--       |> List.map TroopTypeCode.name
--     present = ifPresentList troopEntriesList.troopEntries
--     rowData = List.map3 zip3 present troopNames notes
--   in
--     toTable rowData


-- error message =
--   Html.div
--     [
--       Html.Attributes.class "error"
--     ]
--     [
--       Html.text message
--     ]

-- tableRendered: List TroopEntriesList -> Html.Html msg
-- tableRendered listTroopEntriesList =
--   let 
--     length = List.length listTroopEntriesList
--   in
--     if length < 1 then
--       error "listTroopEntriesList is too small"
--     else if length == 1 then
--       let
--         headMaybe = List.head listTroopEntriesList
--       in
--         case headMaybe of
--           Nothing ->  error "No head in listTroopEntriesList"
--           Just head -> render1ListTable head
--     else
--       (renderManyListTable listTroopEntriesList)



renderTroopEntries: List TroopEntry -> List (Html msg)
renderTroopEntries list =
  -- TODO TroopEntry dismount code
  -- TODO TroopEntry note
  [
    Html.div
      []
      [
        Html.text (orTogetheredTroopTypenames list)
      ]
  ]

renderMin: TroopOptionEntry -> Html msg
renderMin troopOptionEntry =
  Html.text (String.fromInt troopOptionEntry.min)


renderMax: TroopOptionEntry -> Html msg
renderMax troopOptionEntry =
  Html.text (String.fromInt troopOptionEntry.max)


renderBattleLine: TroopOptionEntry -> Html msg
renderBattleLine troopOptionEntry =
  Html.td
    [
      Html.Attributes.class "battleLineColumn"
    ]
    [ 
      if (String.length troopOptionEntry.core) == 0 then
        Html.text "-"
      else
        Html.text troopOptionEntry.core
    ]


renderDateRestriction: DateRangeEntry -> Html msg
renderDateRestriction dateRange =
  Html.div 
    []
    [
      Html.text 
        (DateRange.formattedDateRange dateRange.startDate dateRange.endDate)
    ]


renderDateRestrictions: TroopOptionEntry -> List (Html msg)
renderDateRestrictions troopOptionEntry =
  List.map renderDateRestriction troopOptionEntry.dateRanges


renderNoteRestrictions: TroopOptionEntry -> List (Html msg)
renderNoteRestrictions troopOptionEntry =
  case troopOptionEntry.note of
    Nothing -> []
    Just note -> 
      [ Html.div [] [ Html.text note ] ]


renderRestrictions: TroopOptionEntry -> List (Html msg)
renderRestrictions troopOptionEntry =
  List.concat
    [
      ( renderDateRestrictions troopOptionEntry )
    , ( renderNoteRestrictions troopOptionEntry )
    ]


formatCount: Int -> Int -> List String
formatCount min max =
  if max == min then
    if min == 1 then
        []
    else
      [ String.fromInt(min) ]
  else
      [ String.concat [ (String.fromInt min), " - ", (String.fromInt max) ] ]


renderBattleCardNote: BattleCardEntry -> List (String)
renderBattleCardNote battleCardEntry =
  case battleCardEntry.note of
    Nothing -> []
    Just note -> [ note ]
      

renderBattleCard: BattleCardEntry -> Html msg
renderBattleCard battleCardEntry =
  Html.div
    []
    [
      Html.text
        (
          String.join " "
            (
              List.concat
                [
                  (formatCount battleCardEntry.min battleCardEntry.max)
                , [ BattleCards.name battleCardEntry.battleCardCode ]
                , (renderBattleCardNote battleCardEntry)
                ]
            )
        )
    ]


renderBattleCards: TroopOptionEntry -> List (Html msg)
renderBattleCards troopOptionEntry =
  List.map
    renderBattleCard 
    troopOptionEntry.battleCardEntries


renderTroopRow: TroopOptionEntry -> Html msg
renderTroopRow troopOptionEntry =
  Html.tr
    []
    [
      (Html.td
        []
        (renderTroopEntries troopOptionEntry.troopEntries)
      )
    , (Html.td
        [
          Html.Attributes.class "numberColumn"
        ]
        [ 
          renderMin troopOptionEntry
        ] )
    , (Html.td
        [
          Html.Attributes.class "numberColumn"
        ]
        [ 
          renderMax troopOptionEntry
        ] )
    , (renderBattleLine troopOptionEntry)
    , (Html.td
        []
        (renderRestrictions troopOptionEntry))
    , (Html.td
        []
        (renderBattleCards troopOptionEntry)
      )
    ]


renderTroopRows: List TroopOptionEntry -> List (Html msg)
renderTroopRows list =
  List.map renderTroopRow list

renderTroopsTables: List TroopOptionEntry -> Html msg
renderTroopsTables list =
  Html.table
    []
    [ 
      Html.thead
        []
        [
          Html.tr
          []
          [
            Html.td [][Html.text "Troop Types"]
          , Html.td [][Html.text "Min"]
          , Html.td [][Html.text "Max"]
          , Html.td [][Html.text "Battle Line"]
          , Html.td [][Html.text "Restrictions"]
          , Html.td [][Html.text "Battle Cards"]
          ]
        ]
      , Html.tbody 
        []
        (renderTroopRows list)
    ]


renderRequiredTroops: Army -> Html msg
renderRequiredTroops army = 
  Html.div
    []
    [
      Html.div 
        [
          Html.Attributes.class "requiredTroopsTitle"
        ]
        [
          Html.text "Required Troops"
        ]
      , Html.div
        [
          Html.Attributes.class "requiredTroopsDescription"
        ]
        [
          Html.text "These troops are part of the main army. The minimum and maximum always apply unless overridden by the restrictions."
        ]
      , renderTroopsTables army.troopOptions
      ]


subsectionRendered: Army -> Html msg
subsectionRendered army =
      (Html.div []
          [
            ( Html.div
              [
                  Html.Attributes.class "subsectionHeader"
              ]
              [ Html.text "Troop Options" ]
            )
        , Html.div 
          [
          ] 
          [Html.text "Showing troop options for Standard Triumph."]
        , renderRequiredTroops army
          ])
 

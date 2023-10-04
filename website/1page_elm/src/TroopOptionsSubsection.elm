module TroopOptionsSubsection exposing (subsectionRendered, renderTroopsTables)
--TODO move renderTroopsTables into its own module

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
        

troopNotes: List TroopEntry -> List (Html msg)
troopNotes list =
  let 
    maybeNotesList =
          ( List.map
            (\troopEntry->troopEntry.note)
            list
          ) 
    _ = Debug.log "maybeNotesList" maybeNotesList
    notesString =
        List.filterMap (\x->x) maybeNotesList
     |> (List.intersperse ".  ")
     |> String.concat
    _ = Debug.log "notesString" notesString
  in
    if String.isEmpty notesString then
      []
    else
      [
        Html.br [] []
      , Html.em
          [Html.Attributes.class "troopNotes"]
          [
            Html.text notesString
          ]
     ]
  

renderTroopEntries: List TroopEntry -> Html msg
renderTroopEntries list =
  -- TODO TroopEntry dismount code
    Html.div
      []
      ( List.concat
          [
            [ Html.text (orTogetheredTroopTypenames list) ]
          , (troopNotes list) 
          ]
      )

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
    Just note -> [ "(" ++ note ++ ")" ]
      

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


renderTroopDescription: String -> Html msg
renderTroopDescription description =
  Html.em
    [Html.Attributes.class "troopDescription"]
    [
      Html.text description
    ]


renderTroopRow: TroopOptionEntry -> Html msg
renderTroopRow troopOptionEntry =
  Html.tr
    [
      Html.Attributes.class "troopRow"
    ]
    [
      (Html.td
        []
        [
          renderTroopEntries troopOptionEntry.troopEntries
        , renderTroopDescription troopOptionEntry.description
        ]
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
            Html.th 
              [Html.Attributes.class "columnHeader"]
              [Html.text "Troop Types"]
          , Html.th 
              [Html.Attributes.class "columnHeader"]
              [Html.text "Min"]
          , Html.th 
              [Html.Attributes.class "columnHeader"]
              [Html.text "Max"]
          , Html.th 
              [Html.Attributes.class "columnHeader"]
              [
                  Html.text "Battle"
              ,   Html.br [] []
              ,   Html.text "Line"
              ]
          , Html.th 
              [Html.Attributes.class "columnHeader"]
              [Html.text "Restrictions"]
          , Html.th 
              [Html.Attributes.class "columnHeader"]
              [Html.text "Battle Cards"]
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
 

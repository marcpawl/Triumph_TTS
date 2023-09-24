module ArmyBattleCardsSubsection exposing (..)

import Armies exposing (..)
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
import MeshWeshTypes exposing (..)
import Platform.Cmd as Cmd
import Themes
import BattleCards exposing (render)
import Notes
import List exposing (length)

td: String -> Html.Html msg
td string =
    Html.td
        []
        [
            Html.text string
        ]


tdMaybe: Maybe String -> Html.Html msg
tdMaybe maybeSstring =
    case maybeSstring of
        Nothing ->    Html.td [] []
        Just string -> td string


countTd: MeshWeshTypes.BattleCardEntry -> Html.Html msg
countTd battleCard =
    case battleCard.min of
        Nothing -> tdMaybe (battleCard.max |> Maybe.map String.fromInt)
        Just minValue ->
            case battleCard.max of 
                Nothing -> td (String.fromInt minValue)
                Just maxValue ->
                    (String.concat 
                        [ 
                            (String.fromInt minValue)
                        ,   " - "
                        ,   (String.fromInt maxValue)
                        ]) 
                    |>
                    td

nameTd: MeshWeshTypes.BattleCardEntry -> Html.Html msg
nameTd battlecard =
    td (BattleCards.name (.battleCardCode battlecard))

noteTd: MeshWeshTypes.BattleCardEntry -> Html.Html msg
noteTd battlecard =
    tdMaybe (.note battlecard)

tr: BattleCardEntry -> Html.Html msg
tr battlecard =
    Html.tr
        []
        [
            countTd battlecard
        ,   nameTd battlecard
        ,   noteTd battlecard
        ]

table: List BattleCardEntry -> Html.Html msg
table list =
    Html.table
    []
    [ 
        Html.tbody
            []
            (List.map tr list)
    ]


subsectionRendered: Army -> Html.Html msg
subsectionRendered army =
    Html.div []
        [ 
            Html.div
                [
                    Html.Attributes.class "army_battle_cards_subsection_header"
                ]
                [ Html.text "Army Battle Cards"
                ]
        ,   table army.battleCardEntries
        ]


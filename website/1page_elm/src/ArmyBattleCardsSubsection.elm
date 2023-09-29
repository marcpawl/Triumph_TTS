module ArmyBattleCardsSubsection exposing (..)

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


countTd: MeshweshTypes.BattleCardEntry -> Html.Html msg
countTd battleCard =
    if battleCard.min == battleCard.max then
        if battleCard.min == 1 then
            Html.td [] []
        else
            Html.td 
                [] 
                [ Html.text (String.fromInt battleCard.min) ]
    else
        Html.td 
            [] 
            [ 
                Html.text 
                    ( String.concat
                        [
                            (String.fromInt battleCard.min)
                        ,   " - "
                        ,    (String.fromInt battleCard.min)
                        ]
                    )
            ]


nameTd: MeshweshTypes.BattleCardEntry -> Html.Html msg
nameTd battlecard =
    td (BattleCards.name (.battleCardCode battlecard))

noteTd: MeshweshTypes.BattleCardEntry -> Html.Html msg
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
    if (List.length list) == 0 then
        Html.div [][Html.text "None"]
    else
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
                    Html.Attributes.class "subsectionHeader"
                ]
                [ Html.text "Army Battle Cards"
                ]
        ,   table army.battleCardEntries
        ]


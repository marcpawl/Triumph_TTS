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
import Notes
import List exposing (length)

td: String-> String -> Html.Html msg
td class string =
    Html.td
        [
            Html.Attributes.class class
        ]
        [
            Html.text string
        ]


tdMaybe: String -> Maybe String -> Html.Html msg
tdMaybe class maybeString =
    case maybeString of
        Nothing ->    
            Html.td 
                [
                    Html.Attributes.class class
                ]
                []
        Just string -> td class string


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
    td ".armyBattleCardsNameColumn" (battlecard.battleCard.displayName)

noteTd: MeshweshTypes.BattleCardEntry -> Html.Html msg
noteTd battlecard =
    tdMaybe ".armyBattleCardsNotesColumn" (.note battlecard)

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


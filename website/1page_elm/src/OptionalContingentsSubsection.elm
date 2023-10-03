module OptionalContingentsSubsection exposing (subsectionRendered)

import MeshweshTypes exposing (..)
import Html exposing (..)
import Html.Attributes
import List
import DateRange
import TroopOptionsSubsection

-- These troops are part of the main army but are in an optional contingent. The minimum and maximum only apply if the contingent is selected. In the cases where there is more than one optional contingent, the player may select any or all of the optional contingents.

-- No optional contingents available

renderMaybeDate: Maybe DateRangeEntry -> List (Html msg)
renderMaybeDate maybeDate =
    case maybeDate of
        Nothing -> []
        Just date -> [ DateRange.renderedDateRange date.startDate date.endDate ]


renderAllyEntry:  AllyEntry -> List (Html msg)
renderAllyEntry entry =
    if entry.allyArmyList.internalContingent then
        [
            Html.h4
                [
                    Html.Attributes.class "allyHeader"
                ]
                ( List.concat
                    [
                        [ Html.div
                            []
                            [
                              Html.text entry.name
                            ]
                        ]
                    ,   renderMaybeDate entry.allyArmyList.dateRange
                    ,   [ TroopOptionsSubsection.renderTroopsTables entry.allyArmyList.troopOptions ]
                    ]
                )
        ]
    else
        []

renderAllyOptions: AllyOptions -> List (Html msg)
renderAllyOptions options =
    List.concat 
        (List.concat
            [
                -- TODO render options.note
                -- TODO render options.date
                (List.map renderAllyEntry options.allyEntries)
            ]
        )

renderAllyOptionsList: List AllyOptions ->  Html msg
renderAllyOptionsList list =
    let 
        rendering = List.concat (List.map renderAllyOptions list)
    in 
        if ( List.length rendering) < 1 then
            Html.div
                []
                [
                    Html.text """No optional contingents available"""
                ]
        else
            Html.div
                []
                rendering



subsectionRendered: List AllyOptions -> Html msg
subsectionRendered allies =
    Html.div []
        [
            ( Html.div
                [
                    Html.Attributes.class "subsectionHeader"
                ]
                [ Html.text "Optional Contingents" ]
            )
        , Html.div 
          [
          Html.Attributes.class "requiredTroopsDescription"
          ] 
          [Html.text 
            """These troops are part of the main army but are in an optional contingent. The minimum and maximum only apply if the contingent is selected. In the cases where there is more than one optional contingent, the player may select any or all of the optional contingents."""
          ]
        , (renderAllyOptionsList allies)
        ]

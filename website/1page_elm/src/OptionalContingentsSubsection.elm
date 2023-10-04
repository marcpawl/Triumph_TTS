module OptionalContingentsSubsection exposing (subsectionRendered)

import MeshweshTypes exposing (..)
import Html exposing (..)
import Html.Attributes
import List
import DateRange
import TroopOptionsSubsection

renderMaybeDate: Maybe DateRangeEntry -> List (Html msg)
renderMaybeDate maybeDate =
    case maybeDate of
        Nothing -> []
        Just date -> [ DateRange.renderedDateRange date.startDate date.endDate ]


renderFullListReference:  Bool -> (Maybe String) -> List (Html msg)
renderFullListReference internal maybeArmyListId =
    if internal then
        []
    else
        [
            -- TODO make anchor
            Html.div
                []
                [
                    Html.text "Full Army List: "
                ,   case maybeArmyListId of
                        Nothing -> Html.text "not available"
                        Just armyId -> Html.text armyId -- TODO
                ]
        ]



renderAllyEntryHeader: AllyEntry -> Html msg
renderAllyEntryHeader entry =
    Html.h4
        [ Html.Attributes.class "allyHeader" ]
        ( List.concat
            [
                [ Html.div
                    []
                    [
                        Html.text entry.name
                    ]
                ]
            ,   renderMaybeDate entry.allyArmyList.dateRange
            ]
        )


renderAllyEntry:  Bool -> AllyEntry -> List (Html msg)
renderAllyEntry internal entry  =
    if  internal == entry.allyArmyList.internalContingent  then
        List.concat 
            [
                    [ renderAllyEntryHeader entry ]
                ,   [ TroopOptionsSubsection.renderTroopsTables entry.allyArmyList.troopOptions ]
                ,   renderFullListReference internal entry.allyArmyList.armyListId
            ]
    else
        []

renderAllyOptions: Bool -> AllyOptions -> List (Html msg)
renderAllyOptions internal options =
    List.concat 
        (List.concat
            [
                -- TODO render options.note
                -- TODO render options.date
                (List.map (renderAllyEntry internal) options.allyEntries)
            ]
        )


allyOptionsDescriptionText: Bool -> String
allyOptionsDescriptionText internal = 
    if internal then
        """These troops are part of the main army but are in an optional 
        contingent. The minimum and maximum only apply if the 
            contingent is selected. In the cases where there is more than 
        one optional contingent, the player may select any or all of 
        the optional contingents.
        """
    else
        """These troops are not part of the main army. The minimum 
            and maximum only apply if the ally option is selected. 
            No more than one ally option may be selected. Most ally 
            options only include one allied contingent. Some ally 
            options include two allied contingents.
        """


renderAllyOptionsList: Bool -> List AllyOptions ->  Html msg
renderAllyOptionsList internal list =
    let 
        rendering = List.concat (List.map (renderAllyOptions internal) list)
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
                (List.concat
                    [  
                        [ Html.div 
                           [ Html.Attributes.class "requiredTroopsDescription" ] 
                           [ Html.text (allyOptionsDescriptionText internal) ]
                        ]
                    ,   rendering
                    ]
                )


optionalContingentsSubsectionRendered: List AllyOptions -> Html msg
optionalContingentsSubsectionRendered allies =
    Html.div []
        [
            ( Html.div
                [
                    Html.Attributes.class "subsectionHeader"
                ]
                [ Html.text "Optional Contingents" ]
            )
        , ((renderAllyOptionsList True) allies)
        ]

allyContingentsSubsectionRendered: List AllyOptions -> Html msg
allyContingentsSubsectionRendered allies =
    Html.div []
        [
            ( Html.div
                [
                    Html.Attributes.class "subsectionHeader"
                ]
                [ Html.text "Ally Troop Options" ]
            )
        , ((renderAllyOptionsList False) allies)
        ]

subsectionRendered: List AllyOptions -> Html msg
subsectionRendered allies =
    Html.div
        []
        [
            optionalContingentsSubsectionRendered allies
        ,   allyContingentsSubsectionRendered allies
        ]

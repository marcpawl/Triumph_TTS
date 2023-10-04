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


renderFullListReference:  (MeshweshTypes.ArmyId -> String ) -> Bool -> (Maybe ArmyId) -> List (Html msg)
renderFullListReference armyNameFinder internal maybeArmyListId =
    if internal then
        []
    else
        [
            Html.div
                []
                [
                    Html.text "Full Army List: "
                ,   case maybeArmyListId of
                        Nothing -> Html.text "not available"
                        Just armyId -> 
                            let
                                name = armyNameFinder armyId
                            in
                                Html.a
                                    [ Html.Attributes.href ("#" ++ name)]
                                    [ Html.text name ]
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


renderAllyEntry:  (MeshweshTypes.ArmyId -> String ) -> Bool -> AllyEntry -> List (Html msg)
renderAllyEntry armyNameFinder internal entry  =
    if  internal == entry.allyArmyList.internalContingent  then
        List.concat 
            [
                    [ renderAllyEntryHeader entry ]
                ,   [ TroopOptionsSubsection.renderTroopsTables entry.allyArmyList.troopOptions ]
                ,   renderFullListReference armyNameFinder internal entry.allyArmyList.armyListId
            ]
    else
        []

renderAllyOptions: (MeshweshTypes.ArmyId -> String ) -> Bool -> AllyOptions -> List (Html msg)
renderAllyOptions armyNameFinder internal options =
    List.concat 
        (List.concat
            [
                -- TODO render options.note
                -- TODO render options.date
                (List.map (renderAllyEntry armyNameFinder internal) options.allyEntries)
            ]
        )


allyOptionsDescriptionText:  Bool -> String
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


renderAllyOptionsList: (MeshweshTypes.ArmyId -> String) -> Bool -> List AllyOptions ->  Html msg
renderAllyOptionsList armyNameFinder internal list =
    let 
        rendering = List.concat (List.map (renderAllyOptions armyNameFinder internal) list)
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


optionalContingentsSubsectionRendered: (MeshweshTypes.ArmyId -> String) -> List AllyOptions -> Html msg
optionalContingentsSubsectionRendered armyNameFinder allies =
    Html.div []
        [
            ( Html.div
                [
                    Html.Attributes.class "subsectionHeader"
                ]
                [ Html.text "Optional Contingents" ]
            )
        , ((renderAllyOptionsList armyNameFinder True) allies)
        ]

allyContingentsSubsectionRendered: (MeshweshTypes.ArmyId -> String) -> List AllyOptions -> Html msg
allyContingentsSubsectionRendered armyNameFinder allies =
    Html.div []
        [
            ( Html.div
                [
                    Html.Attributes.class "subsectionHeader"
                ]
                [ Html.text "Ally Troop Options" ]
            )
        , ((renderAllyOptionsList armyNameFinder False) allies)
        ]

subsectionRendered: (MeshweshTypes.ArmyId -> String) -> List AllyOptions -> Html msg
subsectionRendered armyNameFinder allies =
    Html.div
        []
        [
            optionalContingentsSubsectionRendered armyNameFinder allies
        ,   allyContingentsSubsectionRendered armyNameFinder allies
        ]

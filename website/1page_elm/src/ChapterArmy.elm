-- Render the page for displaying an armies details

module ChapterArmy exposing (partArmyLists)

import LoadedData exposing (..)
import MeshweshTypes exposing (..)
import Html exposing (..)
import Html.Attributes
import BookParts exposing (..)
import DateRange exposing (formattedDateRange)
import ArmyBattleCardsSubsection
import GeneralsSubsection
import TroopOptionsSubsection exposing (subsectionRendered)
import OptionalContingentsSubsection exposing (subsectionRendered)
import EnemiesSubsection exposing (subsectionRendered)
import RelatedArmiesSubsection exposing (subsectionRendered)
import ArmyThematicCategoriesSubsection exposing (subsectionRendered)
import Notes
import ArmyIdTable


topographyToString : Topography -> String
topographyToString topography =
    case topography of
        Arable ->
            "Arable"

        Delta ->
            "Delta"

        Steppe ->
            "Steppe"

        Hilly ->
            "Hilly"

        Dry ->
            "Dry"

        Forest ->
            "Forest"

        Marsh ->
            "Marsh"


topographyRendered : Topography -> Html.Html msg
topographyRendered topography =
    Html.div []
        [ Html.text (topographyToString topography)
        ]


homeTopographiesItemsRendered : HomeTopography -> Html.Html msg
homeTopographiesItemsRendered topographies =
    Html.tr []
        [ Html.td [
            Html.Attributes.class "HomeTopographies_note"
        ]
            [ Notes.render topographies.note
            ]
        , Html.td [ Html.Attributes.class "HomeTopographies_values"]
            (List.map topographyRendered topographies.values)
        ]


homeTopographiesListRendered : Army -> Html.Html msg
homeTopographiesListRendered army =
    Html.table []
        [ Html.tbody
            []
            (List.map homeTopographiesItemsRendered army.homeTopographies)
        ]


homeTopographiesRendered : Army -> Html.Html msg
homeTopographiesRendered army =
    Html.div []
        [ Html.div
            [
                Html.Attributes.class "subsectionHeader"
            ]
            [ Html.text "Home Topography"
            ]
        , Html.div
            []
            [ homeTopographiesListRendered army ]
        ]




invasionRatingValue : InvasionRating -> Int
invasionRatingValue rating =
    rating.value


invasionRatingNote : InvasionRating -> Maybe String
invasionRatingNote rating =
    rating.note


invasionRatings : Army -> List InvasionRating
invasionRatings army =
    .invasionRatings army


invasionRatingRendered : Army -> Html.Html msg
invasionRatingRendered army =
    ratingsRendered "Invasion Ratings" invasionRatingValue invasionRatingNote invasionRatings army



maneuverRatingValue : InvasionRating -> Int
maneuverRatingValue rating =
    rating.value


maneuverRatingNote : InvasionRating -> Maybe String
maneuverRatingNote rating =
    rating.note


maneuverRatings : Army -> List ManeuverRating
maneuverRatings army =
    .maneuverRatings army


maneuverRatingsRendered : Army -> Html.Html msg
maneuverRatingsRendered army =
    ratingsRendered "Maneuver Ratings" maneuverRatingValue maneuverRatingNote maneuverRatings army

ratingsRowRendered : (c -> Int) -> (c -> Maybe String) -> c -> Html.Html msg
ratingsRowRendered ratingValue ratingNote rating =
    Html.tr
        []
        [ Html.td
            []
            [ Html.text (String.fromInt (ratingValue rating))
            ]
        , Notes.render (ratingNote rating)
        ]


ratingsRendered : String -> (x -> Int) -> (x -> Maybe String) -> (Army -> List x) -> Army -> Html.Html msg
ratingsRendered title valueExtractor noteExtractor ratingsExtractor army =
    let
        renderer =
            ratingsRowRendered valueExtractor noteExtractor
    in
    Html.div
        []
        [ 
          Html.div
            [
                Html.Attributes.class "subsectionHeader"
            ]
            [ Html.text title
            ]
        , Html.table
            []
            [ Html.tbody []
                (List.map renderer (ratingsExtractor army))
            ]
        ]


ratingsEtcRendered : Army -> Html msg
ratingsEtcRendered army =
    let
        generals = GeneralsSubsection.subsectionRendered army
    in
        Html.div
            []
            [ invasionRatingRendered army
            , maneuverRatingsRendered army
            , homeTopographiesRendered army
            , generals
            , ArmyBattleCardsSubsection.subsectionRendered army
            ]


-- 1 chapter for an army
chapterArmy: (MeshweshTypes.ArmyId -> String) -> ArmyLoaded -> Html msg
chapterArmy armyNameFind army  =
    chapter 
        army.armyName 
        (Just 
            (formattedDateRange 
                army.armyDetails.derivedData.listStartDate 
                army.armyDetails.derivedData.listEndDate
            )
        )
        [
            Html.table
                []
                [
                    Html.tbody
                        []
                        [
                            Html.tr
                            []
                            [
                                Html.td
                                    []
                                    [
                                        ratingsEtcRendered army.armyDetails
                                    ]
                            ,   Html.td
                                    [
                                        Html.Attributes.class "armyReferences"
                                    ]
                                    [
                                            EnemiesSubsection.subsectionRendered armyNameFind army.enemies
                                        ,   RelatedArmiesSubsection.subsectionRendered armyNameFind army.enemies
                                        ,   ArmyThematicCategoriesSubsection.subsectionRendered army.thematicCategories
                                    ]
                            ]
                        ]
                ]
            ,   TroopOptionsSubsection.subsectionRendered army.armyDetails
            ,   OptionalContingentsSubsection.subsectionRendered armyNameFind army.allyOptions
       ]
 

-- Create chapters for all the armies.
-- Each army gets one chapter.
chaptersForAllArmies: (MeshweshTypes.ArmyId -> String) -> LoadedData -> List (Html msg)
chaptersForAllArmies armyNameFind loadedData =
    List.map
        (chapterArmy armyNameFind)
        -- TODO sort by name
        (ArmyIdTable.values loadedData.armies)


armyListReference: ArmyLoaded -> Html msg
armyListReference armyLoaded =
    Html.div
        []
        [
            Html.a
                [
                    Html.Attributes.href ("#" ++ armyLoaded.armyName)
                ]
                [
                    Html.text armyLoaded.armyDetails.derivedData.extendedName
                ]
        ]

armyListTableOfContents : LoadedData -> Html msg
armyListTableOfContents loadedData =
    Html.div
        []
        (
            List.map
            armyListReference
            (ArmyIdTable.values loadedData.armies)
        )

partArmyLists: (MeshweshTypes.ArmyId -> String) -> LoadedData -> Html msg
partArmyLists armyNameFind loadedData =
    part
        "Army Lists"
        ( List.concat
            [
                [ armyListTableOfContents loadedData ]
            ,   (chaptersForAllArmies armyNameFind loadedData)
            ]
        )
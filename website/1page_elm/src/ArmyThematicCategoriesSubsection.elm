module ArmyThematicCategoriesSubsection exposing (subsectionRendered)

import Html exposing (Html, button, div, text)
import Html.Attributes
import List
import MeshweshTypes exposing (ArmyId, ThematicCategory)
import LoadedData exposing (ArmyLoaded)

renderCategory: ThematicCategory -> Html msg
renderCategory category =
    Html.div
        []
        [
            Html.a
                [
                    Html.Attributes.href ("#" ++ category.name)
                ]
                [
                    Html.text category.name
                ]
        ]

subsectionRendered: List ThematicCategory -> Html msg
subsectionRendered categories =
    Html.div []
        ( List.concat 
            [ 
                [ Html.div
                    [ Html.Attributes.class "subsectionHeader" ]
                    [ Html.text "Thematic Categories" ]
                ]
            , (List.map renderCategory categories)
            ]
        )



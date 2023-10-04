module RelatedArmiesSubsection exposing (subsectionRendered)

import Html exposing (Html, button, div, text)
import Html.Attributes
import List
import MeshweshTypes exposing (ArmyId)
import LoadedData exposing (ArmyLoaded)

armyName: ArmyId -> Html msg
armyName armyId =
    Html.div
        []
        [ Html.text armyId.id ] -- TODO

subsectionRendered: List ArmyId -> Html msg
subsectionRendered armies =
    Html.div []
        ( List.concat 
            [ 
                [ Html.div
                    [ Html.Attributes.class "subsectionHeader" ]
                    [ Html.text "Related Army Lists" ]
                ]
            , (List.map armyName armies)
            ]
        )



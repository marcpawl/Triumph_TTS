module EnemiesSubsection exposing (subsectionRendered)

import Html exposing (Html, button, div, text)
import Html.Attributes
import List
import MeshweshTypes exposing (ArmyId)
import LoadedData exposing (ArmyLoaded)

enemyName: ArmyId -> Html msg
enemyName armyId =
    Html.div
        []
        [ Html.text armyId.id ] -- TODO

subsectionRendered: List ArmyId -> Html msg
subsectionRendered enemies =
    Html.div []
        ( List.concat 
            [ 
                [ Html.div
                    [ Html.Attributes.class "subsectionHeader" ]
                    [ Html.text "Enemies" ]
                ]
            , (List.map enemyName enemies)
            ]
        )



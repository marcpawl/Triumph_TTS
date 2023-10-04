module EnemiesSubsection exposing (subsectionRendered)

import Html exposing (Html, button, div, text)
import Html.Attributes
import List
import MeshweshTypes exposing (ArmyId)
import LoadedData exposing (ArmyLoaded)

renderEnemyName: (ArmyId -> String) -> ArmyId -> Html msg
renderEnemyName armyNameFinder armyId =
    let 
        name = armyNameFinder armyId
    in
        Html.div
            [ Html.Attributes.class "armyReferenceLink" ]
            [
                Html.a
                    [ Html.Attributes.href ("#" ++ name)]
                    [ Html.text name ] 
            ]


subsectionRendered: (ArmyId -> String) -> List ArmyId -> Html msg
subsectionRendered armyNameFinder enemies =
    Html.div []
        ( List.concat 
            [ 
                [ Html.div
                    [ Html.Attributes.class "subsectionHeader" ]
                    [ Html.text "Enemies" ]
                ]
            , (List.map (renderEnemyName armyNameFinder) enemies)
            ]
        )



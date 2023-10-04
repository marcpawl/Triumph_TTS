module RelatedArmiesSubsection exposing (subsectionRendered)

import Html exposing (Html, button, div, text)
import Html.Attributes
import List
import MeshweshTypes exposing (ArmyId)
import LoadedData exposing (ArmyLoaded)

renderArmyName: (ArmyId->String) -> ArmyId -> Html msg
renderArmyName armyNameFinder armyId =
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


subsectionRendered: (ArmyId->String) -> List ArmyId -> Html msg
subsectionRendered armyNameFinder armies =
    Html.div []
        ( List.concat 
            [ 
                [ Html.div
                    [ Html.Attributes.class "subsectionHeader" ]
                    [ Html.text "Related Army Lists" ]
                ]
            , (List.map (renderArmyName armyNameFinder) armies)
            ]
        )



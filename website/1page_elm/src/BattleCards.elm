module BattleCards exposing(..)

import MeshweshTypes exposing (..)
import Html

name: MeshweshTypes.BattleCardCode -> String
name battleCardCode =
    case battleCardCode of
        AM -> "Ambush"
        DC -> "Deceptive Deployment"
        FC -> "Fortified Camp"
        MI -> "Mobile Infantry" 
        NC -> "No Camp"
        PD -> "Prepared Defenses"
        PT -> "Pack Train and Herds"
        SC -> "Scythed Chariots and Stampedes"
        SW -> "Standard Wagon"

render: MeshweshTypes.BattleCardCode -> Html.Html msg
render battleCardCode =
    Html.text (name battleCardCode)

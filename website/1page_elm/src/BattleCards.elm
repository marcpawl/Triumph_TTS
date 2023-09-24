module BattleCards exposing(..)

import MeshWeshTypes exposing (..)
import Html

name: MeshWeshTypes.BattleCardCode -> String
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

render: MeshWeshTypes.BattleCardCode -> Html.Html msg
render battleCardCode =
    Html.text (name battleCardCode)

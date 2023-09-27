module BattleCards exposing(..)

import MeshweshTypes exposing (..)
import Html

name: MeshweshTypes.BattleCardCode -> String
name battleCardCode =
    case battleCardCode of
        AC -> "AC" -- TODO
        AM -> "Ambush"
        CC -> "CC" -- TODO
        CF -> "CF" -- TODO
        CH -> "CH" -- TODO
        CT -> "CT" -- TODO
        DC -> "DC" -- TODO
        DD -> "DD" -- TODO
        ES -> "ES" -- TODO
        ET -> "ET" -- TODO
        FC -> "Fortified Camp"
        HD -> "Hoplite Deep Formation"
        HL -> "Hold the Line"
        LC -> "Light Camelry"
        MD -> "MD" -- TODO
        MI -> "Mobile Infantry" 
        NC -> "No Camp"
        PD -> "Prepared Defenses"
        PL -> "PL" -- TODO
        PT -> "Pack Train and Herds"
        SC -> "Scythed Chariots and Stampedes"
        SB -> "Supporting Bowmen"
        SF -> "SF" -- TODO 
        SP -> "SP" -- TODO
        SS -> "SS" -- TODO 
        SV -> "SV" -- TODO 
        SW -> "Standard Wagon"

render: MeshweshTypes.BattleCardCode -> Html.Html msg
render battleCardCode =
    Html.text (name battleCardCode)

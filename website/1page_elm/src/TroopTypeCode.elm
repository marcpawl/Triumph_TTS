module TroopTypeCode exposing (render, name)

import MeshWeshTypes exposing (..)

import Browser
import Css exposing (bold, em, fontWeight, padding, px)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (list)
import Html.Events exposing (onClick)
import Html.Styled exposing (styled)
import Html.Styled.Attributes
import List


name: TroopTypeCode -> String
name troopTypeCode =
    case troopTypeCode of
        ARC -> "Archers"
        BAD -> "Bad Horse"
        BLV -> "Bow Levy"
        BTX -> "Battle Taxi"
        CAT -> "Cataphracts" 
        CHT -> "Chariots"
        ECV -> "Elite Calvary"
        EFT -> "Elite Foot"
        ELE -> "Elephants" 
        HBW -> "Horse Bow"
        HFT -> "Heavy Foot" 
        JCV -> "Javelin Cavalry" 
        KNT -> "Knights"
        LFT -> "Light Foot"
        LSP -> "Light Spears"
        PAV -> "Pavasiers"
        PIK -> "Pike"
        RBL -> "Rabble"
        RDR -> "Raiders"
        SKM -> "Skirmishers" 
        SPR -> "Spears" 
        WBD -> "Warband"
        WRR -> "Warriors" 
        WWG -> "War Wagons"

render: TroopTypeCode -> Html.Styled.Html msg
render troopTypeCode =
    Html.Styled.text (name troopTypeCode)

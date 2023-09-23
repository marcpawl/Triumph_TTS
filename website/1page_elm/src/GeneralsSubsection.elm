module GeneralsSubsection exposing (subsectionRendered)

import Armies exposing (..)
import Browser
import Css exposing (bold, em, fontWeight, padding, px)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (list)
import Html.Events exposing (onClick)
import Html.Styled exposing (styled)
import Html.Styled.Attributes
import Http
import Json.Decode as Decode exposing (Decoder)
import List
import MeshWeshTypes exposing (..)
import Platform.Cmd as Cmd
import Themes
import TroopTypeCode exposing (render)


type Prefix = NoPrefix | IfPresent | OtherwisePrefix


renderGeneralListOtherwise: List a -> List (Prefix,a)
renderGeneralListOtherwise list =
  List.map (\a->(OtherwisePrefix,a) ) list

renderGeneralList2Plus: a -> (List a) -> (List (Prefix,a))
renderGeneralList2Plus first tail =
  List.concat
    [
      [
        (IfPresent, first)
      ]
    , renderGeneralListOtherwise tail
    ]

renderGeneralList1Plus: a -> Maybe (List a) -> (List (Prefix,a))
renderGeneralList1Plus first maybeTail =
    case maybeTail of
        Nothing -> [ (NoPrefix, first)]
        Just y -> renderGeneralList2Plus first y

renderGeneralList0Plus: (Maybe a) -> (List a) -> (List (Prefix,a))
renderGeneralList0Plus head list =
    case head of
        Nothing -> []
        Just x -> renderGeneralList1Plus x (List.tail list)

renderGeneralList: List a -> List (Prefix, a)
renderGeneralList lists =
    renderGeneralList0Plus
        (List.head lists)
        lists

renderTroopEntry: TroopEntry ->  Html.Styled.Html msg
renderTroopEntry troopEntry =
    Html.Styled.tr
    []
    [
        Html.Styled.td 
          []
          [
            TroopTypeCode.render troopEntry.troopTypeCode    
          ]
    ,
        Html.Styled.td 
          []
          [
            Html.Styled.text "notes"      
          ]
    ]

renderList: List TroopEntry -> List (Html.Styled.Html msg)
renderList troopEntryList =
    List.map renderTroopEntry troopEntryList


subsectionRendered: Army -> Html.Styled.Html msg
subsectionRendered army =
    Html.Styled.div []
        [ Html.Styled.div
            [
                Html.Styled.Attributes.class "general_troop_type_section_header"
            ]
            [ Html.Styled.text "General's Troop Type"
            ]
        , Html.Styled.table
            []
            [ 
                Html.Styled.tbody
                    []
                    (List.concat (List.map renderList army.troopEntriesForGeneral))
            ]
        ]


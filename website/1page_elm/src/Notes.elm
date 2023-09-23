module Notes exposing (render)

import Browser
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (list)
import Html.Events exposing (onClick)
import Html.Styled exposing (styled)
import Html.Styled.Attributes

render : Maybe String -> Html.Styled.Html msg
render note =
    Html.Styled.td
        []
        (case note of
            Just x ->
                [ Html.Styled.text x ]

            Nothing ->
                []
        )

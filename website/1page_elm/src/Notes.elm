module Notes exposing (render)

import Browser
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (list)
import Html.Events exposing (onClick)
import Html.Styled exposing (styled)
import Html.Attributes

render : Maybe String -> Html.Html msg
render note =
    Html.td
        []
        (case note of
            Just x ->
                [ Html.text x ]

            Nothing ->
                []
        )


module Main exposing(..)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Http
import Platform.Cmd as Cmd
import Html.Attributes exposing (list)
import Html
import Json.Decode as Decode exposing (Decoder)
import List

import Themes
import Css exposing (padding)
import Css exposing (fontWeight)
import Css exposing (bold)
import Css exposing (px)
import Html.Styled exposing (styled)
import Css exposing (em)
-- MODEL

type alias Model =  PageStatus

type PageStatus
  = 
   WaitingForArmy
   | Loading String
  | Loaded String
  | Error


init : Model
init = WaitingForArmy

-- UPDATE

type Msg = 
      GetArmy
    | DataReceived (Result Http.Error String)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    GetArmy -> (model, getArmy model)


    DataReceived (Err _) -> (Error, Cmd.none)

    DataReceived (Ok data) -> 
        (Loaded data, Cmd.none)

-- VIEW

view model =
  Html.Styled.toUnstyled (
  Html.Styled.div []
    [ 
    --   button [ onClick GetArmy ] [ text "Start" ],
    --   button [ onClick GetArmy ] [ text "-" ]
    -- , div []
     Html.Styled.text (
      status model
      )
    ,  thematicCategories 
    ,  thematicCategiesContent
    --   (text (
    --   "todo"
    --   -- String.fromInt model
    --   ) )
    ]
  )

status: Model -> String
status model =
  case model of 
    WaitingForArmy -> "Starting"
    Loading url ->
      "loading " ++ url
    Loaded data ->
      "Loaded " ++ data
    Error -> "Error"

thematicCategory : Themes.Theme -> Html.Styled.Html msg
thematicCategory theme =
  styledContentLink [] [Html.Styled.text theme.name]

thematicCategories : Html.Styled.Html msg
thematicCategories =
  Html.Styled.div []
    [ 
         styledContentHeader [] [(Html.Styled.text "Thematic Categories")]
      ,  Html.Styled.text """Thematic categories are a way of grouping army lists that fit a
           common period and broad geographic region. Many army lists belong to
          more than one thematic category."""
      , Html.Styled.div [] (List.map thematicCategory Themes.themes)
    ]

-- Contents of a theme
thematicCategoryContent : Themes.Theme -> Html.Styled.Html msg
thematicCategoryContent theme =
  Html.Styled.div
    []
    [
      Html.Styled.text theme.name
    ]

-- Each theme with the contents of the theme
thematicCategiesContent :  Html.Styled.Html msg
thematicCategiesContent =
  Html.Styled.div
    []
    (List.map thematicCategoryContent Themes.themes)

getArmy : Model -> Cmd Msg
getArmy _ =
    Http.get
        { url = "https://raw.githubusercontent.com/marcpawl/Triumph_TTS/v2.3/fake_meshwesh/armyLists/5fb1b9d8e1af0600177092b3"
        , expect = Http.expectString DataReceived
        }

styledContentHeader : List (Html.Styled.Attribute msg) -> List (Html.Styled.Html msg) -> Html.Styled.Html msg
styledContentHeader =
    styled Html.Styled.div
        [ 
            Css.fontFamilies ["Helvetica Neue", "Helvetica", "Arial", "sans-serif"]
          , Css.lineHeight  (Css.num 1.42857143)
          , Css.color (Css.rgb 0x33 0x33 0x33)
          , Css.marginTop (px 16)
          , Css.marginBottom (px 20)
          , Css.fontSize (em 2)
        ]
    -- TODO
    -- -webkit-text-size-adjust: 100%;
    -- -webkit-tap-highlight-color: rgba(0, 0, 0, 0);

styledContentLink : List (Html.Styled.Attribute msg) -> List (Html.Styled.Html msg) -> Html.Styled.Html msg
styledContentLink =
    styled Html.Styled.div
      [
            Css.fontFamilies ["Helvetica Neue", "Helvetica", "Arial", "sans-serif"]
          , Css.lineHeight  (Css.num 1.42857143)
          , Css.fontSize (em 1.5)
          , Css.boxSizing Css.borderBox
          , Css.backgroundColor Css.transparent
          , Css.color (Css.rgb 0x33 0x7a 0xb7)
          , Css.textDecoration Css.none
      ]


  -- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = \flags -> ( WaitingForArmy, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



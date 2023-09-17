module Hello2 exposing(..)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Http
import Platform.Cmd as Cmd


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

view : Model -> Html Msg
view model =
  div []
    [ 
      button [ onClick GetArmy ] [ text "Start" ],
      button [ onClick GetArmy ] [ text "-" ]
    , div []
     [ text (
      status model
      ) ],
      (text (
      "todo"
      -- String.fromInt model
      ) )
    ]

status: Model -> String
status model =
  case model of 
    WaitingForArmy -> "Starting"
    Loading url ->
      "loading " ++ url
    Loaded data ->
      "Loaded " ++ data
    Error -> "Error"

getArmy : Model -> Cmd Msg
getArmy _ =
    Http.get
        { url = "https://raw.githubusercontent.com/marcpawl/Triumph_TTS/v2.3/fake_meshwesh/armyLists/5fb1b9d8e1af0600177092b3"
        , expect = Http.expectString DataReceived
        }
     
  -- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = \flags -> ( WaitingForArmy, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



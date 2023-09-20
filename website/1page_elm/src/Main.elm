module Main exposing(..)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Http
import Platform.Cmd as Cmd
import Html.Attributes exposing (list)
import Json.Decode as Decode exposing (Decoder)
import Summary
import List

-- MODEL

type alias Model =  PageStatus

type PageStatus
  = 
   WaitingForArmy
   | Loading String
  | Loaded String
  | Error

type alias SummaryItem = {
    id: String
  , name: String
  }

summaryItemDecoder : Decoder SummaryItem
summaryItemDecoder =
    Decode.map2 SummaryItem (Decode.field "id" Decode.string) (Decode.field "name" Decode.string)

summaryListItemDecoder : Decoder (List SummaryItem)
summaryListItemDecoder =
    Decode.list summaryItemDecoder

summaryData : b -> Result Decode.Error (List SummaryItem)
summaryData = always (Decode.decodeString summaryListItemDecoder Summary.summary)

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
    --   button [ onClick GetArmy ] [ text "Start" ],
    --   button [ onClick GetArmy ] [ text "-" ]
    -- , div []
     text (
      status model
      ),
      thematicCategories 
    --   (text (
    --   "todo"
    --   -- String.fromInt model
    --   ) )
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

thematicCategory: SummaryItem -> Html msg
thematicCategory item =
  Html.li [] [ Html.text item.name]

thematicCategoryList : List SummaryItem -> List (Html msg)
thematicCategoryList theCategories =
     List.map thematicCategory theCategories

thematicCategoriesMaybe: Result Decode.Error (List SummaryItem ) -> Html msg
thematicCategoriesMaybe maybeSummaryItem =
  case maybeSummaryItem of
    Result.Ok theCategories -> Html.ul []  (thematicCategoryList theCategories)

    Err error ->
                           Debug.todo (Decode.errorToString error)
thematicCategories : Html msg
thematicCategories =
  div []
    [ 
      Html.h1 [] [ (text "Thematic Categories")],
      Html.ul [] 
        [
          thematicCategoriesMaybe (summaryData 1)
        ]
    ]



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



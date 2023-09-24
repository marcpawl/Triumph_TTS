module Main exposing (..)

import Armies exposing (..)
import ArmyBattleCardsSubsection
import GeneralsSubsection
import Browser
import Css exposing (bold, em, fontWeight, padding, px)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (list)
import Html.Events exposing (onClick)
import Html.Styled exposing (styled)
import Html.Attributes
import Http
import Json.Decode as Decode exposing (Decoder)
import List
import MeshWeshTypes exposing (..)
import Platform.Cmd as Cmd
import Themes
import Notes



-- MODEL


type alias Model =
    PageStatus


type PageStatus
    = WaitingForArmy
    | Loading String
    | Loaded String
    | Error


init : Model
init =
    WaitingForArmy



-- UPDATE


type Msg
    = GetArmy
    | DataReceived (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetArmy ->
            ( model, getArmy model )

        DataReceived (Err _) ->
            ( Error, Cmd.none )

        DataReceived (Ok data) ->
            ( Loaded data, Cmd.none )



-- VIEW


view model =
    (Html.div []
        [ --   button [ onClick GetArmy ] [ text "Start" ],
            --   button [ onClick GetArmy ] [ text "-" ]
            -- , div []
            Html.text
            (status model)
        , thematicCategoriesTableOfContents
        , thematicCategiesContent
        , armiesTableOfContents
        , armiesDetailed

        --   (text (
        --   "todo"
        --   -- String.fromInt model
        --   ) )
        ]
    )


status : Model -> String
status model =
    case model of
        WaitingForArmy ->
            "Starting"

        Loading url ->
            "loading " ++ url

        Loaded data ->
            "Loaded " ++ data

        Error ->
            "Error"



-- Value of ID in an element, use for in document HREF


anchor_tag : String -> String -> String
anchor_tag typename id =
    String.concat [ typename, id ]


theme_tag : Theme -> String
theme_tag theme =
    anchor_tag "theme_" theme.id


theme_href : Theme -> Html.Attribute msg
theme_href theme =
    Html.Attributes.href (String.concat [ "#", theme_tag theme ])


army_tag : Army -> String
army_tag army =
    anchor_tag "army_" army.id


army_href : Army -> Html.Attribute msg
army_href theme =
    Html.Attributes.href (String.concat [ "#", army_tag theme ])


thematicCategory : Theme -> Html.Html msg
thematicCategory theme =
    Html.div
        []
        [ Html.a
            [ theme_href theme
            ]
            [ Html.text theme.name
            ]
        ]



-- Page that contains the list of all the categories


thematicCategoriesTableOfContents : Html.Html msg
thematicCategoriesTableOfContents =
    Html.div 
        []
        [ 
            Html.div [] [ Html.text "Thematic Categories" ]
        , Html.text """Thematic categories are a way of grouping army lists that fit a
           common period and broad geographic region. Many army lists belong to
          more than one thematic category."""
        , Html.div [] (List.map thematicCategory Themes.themes)
        ]


armyNameList : List Army -> Html.Html msg
armyNameList armies =
    Html.div
        []
        (List.map
            (\army ->
                Html.div
                    []
                    [ Html.a
                        [ army_href army
                        ]
                        [ Html.text army.extendedName
                        ]
                    ]
            )
            armies
        )



-- Contents of a theme


thematicCategoryContent : Theme -> Html.Html msg
thematicCategoryContent theme =
    Html.div []
        [ Html.h1
            [ Html.Attributes.id (theme_tag theme)
            ]
            [ Html.text theme.name
            ]
        , Html.h2 [] [ Html.text "Army Lists" ]
        , armyNameList theme.armies
        ]



-- Each theme with the contents of the theme
-- Each theme is is own "page"


thematicCategiesContent : Html.Html msg
thematicCategiesContent =
    Html.div
        []
        (List.map thematicCategoryContent Themes.themes)



-- "Page" containing the list of all the armies


armiesTableOfContents : Html.Html msg
armiesTableOfContents =
    Html.div
        []
        [ Html.h1
            []
            [ Html.text "List of all armies" ]
        , Html.div
            []
            [ armyNameList Armies.all_armies
            ]
        ]



-- Section containing the "Pages" for each army


armiesDetailed : Html.Html msg
armiesDetailed =
    Html.div
        []
        (List.map (\army -> armyDetail army) Armies.all_armies)


armyDetail : Army -> Html.Html msg
armyDetail army =
    Html.div
        [ Html.Attributes.id (army_tag army)
        ]
        [ armyListAndDateRange army
        , ratingsEtcRendered army
        ]


ratingsEtcRendered : Army -> Html.Html msg
ratingsEtcRendered army =
    Html.div
        []
        [ invasionRatingRendered army
        , maneuverRatingsRendered army
        , homeTopographiesRendered army
        , GeneralsSubsection.subsectionRendered army
        , ArmyBattleCardsSubsection.subsectionRendered army
        ]



invasionRatingValue : InvasionRating -> Int
invasionRatingValue rating =
    rating.value


invasionRatingNote : InvasionRating -> Maybe String
invasionRatingNote rating =
    rating.note


invasionRatings : Army -> List InvasionRating
invasionRatings army =
    .invasionRatings army


maneuverRatingValue : InvasionRating -> Int
maneuverRatingValue rating =
    rating.value


maneuverRatingNote : InvasionRating -> Maybe String
maneuverRatingNote rating =
    rating.note


maneuverRatings : Army -> List ManeuverRating
maneuverRatings army =
    .maneuverRatings army



-- ratingsRowRendered : (x -> Int) -> ( x  -> Maybe String) -> x -> Html.Html msg


ratingsRowRendered : (c -> Int) -> (c -> Maybe String) -> c -> Html.Html msg
ratingsRowRendered ratingValue ratingNote rating =
    Html.tr
        []
        [ Html.td
            []
            [ Html.text (String.fromInt (ratingValue rating))
            ]
        , Notes.render (ratingNote rating)
        ]


ratingsRendered : String -> (x -> Int) -> (x -> Maybe String) -> (Army -> List x) -> Army -> Html.Html msg
ratingsRendered title valueExtractor noteExtractor ratingsExtractor army =
    let
        renderer =
            ratingsRowRendered valueExtractor noteExtractor
    in
    Html.div
        []
        [ 
          Html.div
            []
            [ Html.text title
            ]
        , Html.table
            []
            [ Html.tbody []
                (List.map renderer (ratingsExtractor army))
            ]
        ]


invasionRatingRendered : Army -> Html.Html msg
invasionRatingRendered army =
    ratingsRendered "Invasion Ratings" invasionRatingValue invasionRatingNote invasionRatings army


maneuverRatingsRendered : Army -> Html.Html msg
maneuverRatingsRendered army =
    ratingsRendered "Maneuver Ratings" maneuverRatingValue maneuverRatingNote maneuverRatings army


topographyToString : Topography -> String
topographyToString topography =
    case topography of
        Arable ->
            "Arable"

        Delta ->
            "Delta"

        Steppe ->
            "Steppe"

        Hilly ->
            "Hilly"

        Dry ->
            "Dry"

        Forest ->
            "Forest"

        Marsh ->
            "Marsh"


topographyRendered : Topography -> Html.Html msg
topographyRendered topography =
    Html.div []
        [ Html.text (topographyToString topography)
        ]


homeTopographiesItemsRendered : HomeTopographies -> Html.Html msg
homeTopographiesItemsRendered topographies =
    Html.tr []
        [ Html.td [
            Html.Attributes.class "HomeTopographies_note"
        ]
            [ Notes.render topographies.note
            ]
        , Html.td [ Html.Attributes.class "HomeTopographies_values"]
            (List.map topographyRendered topographies.values)
        ]


homeTopographiesListRendered : Army -> Html.Html msg
homeTopographiesListRendered army =
    Html.table []
        [ Html.tbody
            []
            (List.map homeTopographiesItemsRendered army.homeTopographies)
        ]


homeTopographiesRendered : Army -> Html.Html msg
homeTopographiesRendered army =
    Html.div []
        [ Html.div
            []
            [ Html.text "Home Topography"
            ]
        , Html.div
            []
            [ homeTopographiesListRendered army ]
        ]



armyListAndDateRange : Army -> Html.Html msg
armyListAndDateRange army =
    Html.div
        []
        [ Html.h1
            []
            [ Html.span
                []
                [ Html.text army.name
                ]
            ]
        , renderedDateRange army.listStartDate army.listEndDate
        ]


renderedDateRange : Int -> Int -> Html.Html msg
renderedDateRange startDate endDate =
    Html.text (formattedDateRange startDate endDate)


era : Int -> String
era date =
    if date < 0 then
        "B.C"

    else
        "A.D."


formattedDate : Int -> String
formattedDate date =
    let
        date_string =
            String.fromInt (abs date)

        era_string =
            era date
    in
    String.concat [ date_string, " ", era_string ]


formattedDateRange : Int -> Int -> String
formattedDateRange startDate endDate =
    if startDate == endDate then
        formattedDate startDate

    else
        String.concat
            [ formattedDate startDate
            , " to "
            , formattedDate endDate
            ]


getArmy : Model -> Cmd Msg
getArmy _ =
    Http.get
        { url = "https://raw.githubusercontent.com/marcpawl/Triumph_TTS/v2.3/fake_meshwesh/armyLists/5fb1b9d8e1af0600177092b3"
        , expect = Http.expectString DataReceived
        }


main : Program () Model Msg
main =
    Browser.element
        { init = \flags -> ( WaitingForArmy, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }

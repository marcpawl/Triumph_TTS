module Main exposing (..)

import Armies exposing (..)
import GeneralsSubsection
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
    Html.Styled.toUnstyled
        (Html.Styled.div []
            [ --   button [ onClick GetArmy ] [ text "Start" ],
              --   button [ onClick GetArmy ] [ text "-" ]
              -- , div []
              Html.Styled.text
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


theme_href : Theme -> Html.Styled.Attribute msg
theme_href theme =
    Html.Styled.Attributes.href (String.concat [ "#", theme_tag theme ])


army_tag : Army -> String
army_tag army =
    anchor_tag "army_" army.id


army_href : Army -> Html.Styled.Attribute msg
army_href theme =
    Html.Styled.Attributes.href (String.concat [ "#", army_tag theme ])


thematicCategory : Theme -> Html.Styled.Html msg
thematicCategory theme =
    styledContentLink
        []
        [ Html.Styled.a
            [ theme_href theme
            ]
            [ Html.Styled.text theme.name
            ]
        ]



-- Page that contains the list of all the categories


thematicCategoriesTableOfContents : Html.Styled.Html msg
thematicCategoriesTableOfContents =
    styledMain []
        [ styledContentHeader [] [ Html.Styled.text "Thematic Categories" ]
        , Html.Styled.text """Thematic categories are a way of grouping army lists that fit a
           common period and broad geographic region. Many army lists belong to
          more than one thematic category."""
        , Html.Styled.div [] (List.map thematicCategory Themes.themes)
        ]


armyNameList : List Army -> Html.Styled.Html msg
armyNameList armies =
    Html.Styled.div
        []
        (List.map
            (\army ->
                styledThematicCategoryContentArmy
                    []
                    [ Html.Styled.a
                        [ army_href army
                        ]
                        [ Html.Styled.text army.extendedName
                        ]
                    ]
            )
            armies
        )



-- Contents of a theme


thematicCategoryContent : Theme -> Html.Styled.Html msg
thematicCategoryContent theme =
    styledMain []
        [ Html.Styled.h1
            [ Html.Styled.Attributes.id (theme_tag theme)
            ]
            [ Html.Styled.text theme.name
            ]
        , Html.Styled.h2 [] [ Html.Styled.text "Army Lists" ]
        , armyNameList theme.armies
        ]



-- Each theme with the contents of the theme
-- Each theme is is own "page"


thematicCategiesContent : Html.Styled.Html msg
thematicCategiesContent =
    Html.Styled.div
        []
        (List.map thematicCategoryContent Themes.themes)



-- "Page" containing the list of all the armies


armiesTableOfContents : Html.Styled.Html msg
armiesTableOfContents =
    styledMain
        []
        [ Html.Styled.h1
            []
            [ Html.Styled.text "List of all armies" ]
        , Html.Styled.div
            []
            [ armyNameList Armies.all_armies
            ]
        ]



-- Section containing the "Pages" for each army


armiesDetailed : Html.Styled.Html msg
armiesDetailed =
    Html.Styled.div
        []
        (List.map (\army -> armyDetail army) Armies.all_armies)


armyDetail : Army -> Html.Styled.Html msg
armyDetail army =
    styledMain
        [ Html.Styled.Attributes.id (army_tag army)
        ]
        [ armyListAndDateRange army
        , ratingsEtcRendered army
        ]


ratingsEtcRendered : Army -> Html.Styled.Html msg
ratingsEtcRendered army =
    Html.Styled.div
        []
        [ invasionRatingRendered army
        , maneuverRatingsRendered army
        , homeTopographiesRendered army
        , GeneralsSubsection.subsectionRendered army
        ]


noteRendered : Maybe String -> Html.Styled.Html msg
noteRendered note =
    Html.Styled.td
        []
        (case note of
            Just x ->
                [ Html.Styled.text x ]

            Nothing ->
                []
        )


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



-- ratingsRowRendered : (x -> Int) -> ( x  -> Maybe String) -> x -> Html.Styled.Html msg


ratingsRowRendered : (c -> Int) -> (c -> Maybe String) -> c -> Html.Styled.Html msg
ratingsRowRendered ratingValue ratingNote rating =
    Html.Styled.tr
        []
        [ Html.Styled.td
            []
            [ Html.Styled.text (String.fromInt (ratingValue rating))
            ]
        , noteRendered (ratingNote rating)
        ]


ratingsRendered : String -> (x -> Int) -> (x -> Maybe String) -> (Army -> List x) -> Army -> Html.Styled.Html msg
ratingsRendered title valueExtractor noteExtractor ratingsExtractor army =
    let
        renderer =
            ratingsRowRendered valueExtractor noteExtractor
    in
    Html.Styled.div
        []
        [ styledContentSubHeader
            []
            [ Html.Styled.text title
            ]
        , Html.Styled.table
            []
            [ Html.Styled.tbody []
                (List.map renderer (ratingsExtractor army))
            ]
        ]


invasionRatingRendered : Army -> Html.Styled.Html msg
invasionRatingRendered army =
    ratingsRendered "Invasion Ratings" invasionRatingValue invasionRatingNote invasionRatings army


maneuverRatingsRendered : Army -> Html.Styled.Html msg
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


topographyRendered : Topography -> Html.Styled.Html msg
topographyRendered topography =
    Html.Styled.div []
        [ Html.Styled.text (topographyToString topography)
        ]


homeTopographiesItemsRendered : HomeTopographies -> Html.Styled.Html msg
homeTopographiesItemsRendered topographies =
    Html.Styled.tr []
        [ Html.Styled.td [
            Html.Styled.Attributes.class "HomeTopographies_note"
        ]
            [ noteRendered topographies.note
            ]
        , Html.Styled.td [ Html.Styled.Attributes.class "HomeTopographies_values"]
            (List.map topographyRendered topographies.values)
        ]


homeTopographiesListRendered : Army -> Html.Styled.Html msg
homeTopographiesListRendered army =
    Html.Styled.table []
        [ Html.Styled.tbody
            []
            (List.map homeTopographiesItemsRendered army.homeTopographies)
        ]


homeTopographiesRendered : Army -> Html.Styled.Html msg
homeTopographiesRendered army =
    Html.Styled.div []
        [ Html.Styled.div
            []
            [ Html.Styled.text "Home Topography"
            ]
        , Html.Styled.div
            []
            [ homeTopographiesListRendered army ]
        ]



armyListAndDateRange : Army -> Html.Styled.Html msg
armyListAndDateRange army =
    Html.Styled.div
        []
        [ Html.Styled.h1
            []
            [ Html.Styled.span
                []
                [ Html.Styled.text army.name
                ]
            ]
        , renderedDateRange army.listStartDate army.listEndDate
        ]


renderedDateRange : Int -> Int -> Html.Styled.Html msg
renderedDateRange startDate endDate =
    Html.Styled.text (formattedDateRange startDate endDate)


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


styledContentHeader : List (Html.Styled.Attribute msg) -> List (Html.Styled.Html msg) -> Html.Styled.Html msg
styledContentHeader =
    styled Html.Styled.div
        [ Css.fontFamilies [ "Helvetica Neue", "Helvetica", "Arial", "sans-serif" ]
        , Css.lineHeight (Css.num 1.42857143)
        , Css.color (Css.rgb 0x33 0x33 0x33)
        , Css.marginTop (px 16)
        , Css.marginBottom (px 20)
        , Css.fontSize (em 2)
        ]



-- TODO
-- -webkit-text-size-adjust: 100%;
-- -webkit-tap-highlight-color: rgba(0, 0, 0, 0);


styledContentSubHeader : List (Html.Styled.Attribute msg) -> List (Html.Styled.Html msg) -> Html.Styled.Html msg
styledContentSubHeader =
    styled Html.Styled.div
        [ Css.fontFamilies [ "Helvetica Neue", "Helvetica", "Arial", "sans-serif" ]
        , Css.lineHeight (Css.num 1.42857143)
        , Css.color (Css.rgb 0x33 0x33 0x33)
        , Css.boxSizing Css.borderBox
        , Css.fontSize (em 1.2)
        , Css.marginTop (px 10)
        , Css.marginBottom (px 20)
        , Css.fontWeight Css.bold
        ]



-- TODO
--  -webkit-text-size-adjust: 100%;
-- -webkit-tap-highlight-color: rgba(0, 0, 0, 0);


styledContentLink : List (Html.Styled.Attribute msg) -> List (Html.Styled.Html msg) -> Html.Styled.Html msg
styledContentLink =
    styled Html.Styled.div
        [ Css.fontFamilies [ "Helvetica Neue", "Helvetica", "Arial", "sans-serif" ]
        , Css.lineHeight (Css.num 1.42857143)
        , Css.fontSize (em 1.5)
        , Css.boxSizing Css.borderBox
        , Css.backgroundColor Css.transparent
        , Css.color (Css.rgb 0x33 0x7A 0xB7)
        , Css.textDecoration Css.none
        ]


styledThematicCategoryContentArmies : List (Html.Styled.Attribute msg) -> List (Html.Styled.Html msg) -> Html.Styled.Html msg
styledThematicCategoryContentArmies =
    styled Html.Styled.div
        [ Css.fontFamily Css.inherit
        , Css.fontWeight (Css.int 400)
        , Css.lineHeight (Css.num 1)
        , Css.boxSizing Css.borderBox
        , Css.backgroundColor Css.transparent
        , Css.color (Css.rgb 0x33 0x7A 0xB7)
        , Css.textDecoration Css.none
        ]



-- TODO
-- -webkit-text-size-adjust: 100%;
-- -webkit-tap-highlight-color: rgba(0, 0, 0, 0);
-- font-size: 65%;


styledThematicCategoryContentArmy : List (Html.Styled.Attribute msg) -> List (Html.Styled.Html msg) -> Html.Styled.Html msg
styledThematicCategoryContentArmy =
    styled Html.Styled.div
        [ Css.fontFamily Css.inherit
        , Css.fontWeight (Css.int 400)
        , Css.lineHeight (Css.num 1.5)
        , Css.boxSizing Css.borderBox
        , Css.backgroundColor Css.transparent
        , Css.color (Css.rgb 0x33 0x7A 0xB7)
        , Css.textDecoration Css.none
        , Css.fontSize (Css.pct 65)
        ]


styledMain : List (Html.Styled.Attribute msg) -> List (Html.Styled.Html msg) -> Html.Styled.Html msg
styledMain =
    styled Html.Styled.div
        [ Css.fontFamilies [ "Helvetica Neue", "Helvetica", "Arial", "sans-serif" ]
        , Css.lineHeight (Css.num 1.42857143)
        , Css.fontSize (Css.px 14)
        , Css.boxSizing Css.borderBox
        , Css.color (Css.rgb 0x33 0x33 0x33)
        , Css.textDecoration Css.none
        , Css.marginTop (Css.em 3)
        , Css.borderBottom3 (Css.px 3) Css.solid (Css.rgb 120 120 120)
        , Css.paddingBottom (Css.em 1)
        , Css.paddingLeft (Css.em 1)
        ]



-- TODO
-- -webkit-text-size-adjust: 100%;
-- -webkit-tap-highlight-color: rgba(0, 0, 0, 0);
-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = \flags -> ( WaitingForArmy, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }

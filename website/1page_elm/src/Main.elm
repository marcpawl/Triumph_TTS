module Main exposing (..)

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
import MeshweshTypes exposing (..)
import Platform.Cmd as Cmd
import Notes
import MeshweshDecoder
import Json.Decode
import Debug
import Dict exposing (Dict)


-- MODEL


type alias Model =
    PageStatus


type PageStatus
    = Unloaded
    | LoadingSummary
    | LoadingArmies (Dict String ArmyLoading)
    | Loaded
    | Error String


-- Army that is waiting for a file to load.
type alias ArmyLoading =
    {
        id: String
    ,   armyName: String
    ,   armyDetails: Maybe MeshweshTypes.Army
    ,   allyOptions: Bool
    ,   thematicCategories: Bool
  }

init : Model
init =
    Unloaded



-- UPDATE


type Msg
    = 
      LoadSummary
    | SummaryReceived (Result Http.Error String)
    | ArmyReceived  String (Result Http.Error MeshweshTypes.Army)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadSummary -> (LoadingSummary, downloadSummary)
        SummaryReceived  (Err httpError) -> 
            (Error (httpErrorToString httpError), Cmd.none)
        SummaryReceived (Ok summaryString) -> downloadArmies summaryString 
        ArmyReceived id result -> handleArmyReceivedMsg id result model

httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.BadUrl url ->
            "The URL " ++ url ++ " was invalid"
        Http.Timeout ->
            "Unable to reach the server, try again"
        Http.NetworkError ->
            "Unable to reach the server, check your network connection"
        Http.BadStatus 500 ->
            "The server had a problem, try again later"
        Http.BadStatus 400 ->
            "Verify your information and try again"
        Http.BadStatus _ ->
            "Unknown error"
        Http.BadBody errorMessage ->
            errorMessage

-- VIEW

unloadedView: Html.Html msg
unloadedView =
    Html.div
        []
        [
            Html.text "Unloaded .."
        ]

loadingSummaryView: Html.Html msg
loadingSummaryView =
    Html.div
        []
        [
            Html.text "Loading summary .."
        ]


loadingArmiesView: Dict String ArmyLoading -> Html.Html msg
loadingArmiesView waiting =
    Html.div
        []
        [
            Html.h1
                []
                [
                    Html.text "Loading Armies ..."
                ]
        ,   Html.table
                []
                [
                    Html.tbody
                        []
                        (List.map armyLoadingView (Dict.values waiting))
                ]
        ]

downloadStateView: Bool -> Html.Html msg
downloadStateView downloaded =
    Html.td
        []
        [
            if downloaded then
                Html.text "Done"
            else
                Html.text "..."
        ]


downloadMaybeView: Maybe a -> Html.Html msg
downloadMaybeView downloaded =
    Html.td
        []
        [
            case downloaded of
                Nothing -> Html.text "..."
                Just _ -> Html.text "Done"
        ]


armyLoadingView: ArmyLoading -> Html.Html msg
armyLoadingView armyLoading =
    Html.tr
        []
        [
            downloadMaybeView armyLoading.armyDetails
        ,   downloadStateView armyLoading.allyOptions                   
        ,   downloadStateView armyLoading.thematicCategories
        ,   Html.td
            []
            [
                Html.text armyLoading.armyName
            ]    
        ]

loadedView: Html.Html msg
loadedView =
    Html.div
        []
        [
            Html.text "Loading summary .."
        ]

errorView: String -> Html.Html msg
errorView errorMessage =
    Html.div
        []
        [
            Html.h1
                []
                [
                    Html.text "ERROR"
                ]
        ,   Html.text errorMessage
        ]

view model =
        case model of
            Unloaded -> unloadedView
            LoadingSummary -> loadingSummaryView
            LoadingArmies waiting -> loadingArmiesView waiting
            Loaded -> loadedView
            Error errorMessage -> errorView errorMessage
        
-- `    (Html.div []
--         [ --   button [ onClick GetArmy ] [ text "Start" ],
--             --   button [ onClick GetArmy ] [ text "-" ]
--             -- , div []
--             Html.text
--             (status model)
--         , thematicCategoriesTableOfContents
--         , thematicCategiesContent
--         , armiesTableOfContents
--         , armiesDetailed

--         --   (text (
--         --   "todo"
--         --   -- String.fromInt model
--         --   ) )
--         ]
--     )


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
        ,   Html.text """Thematic categories are a way of grouping army lists that fit a
           common period and broad geographic region. Many army lists belong to
          more than one thematic category."""
        ,   Html.div
                [] 
                (List.map thematicCategory (all_themes))
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
                        [ Html.text army.derivedData.extendedName
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
        (List.map thematicCategoryContent (all_themes))



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
            [ armyNameList (all_armies)
            ]
        ]



-- Section containing the "Pages" for each army


armiesDetailed : Html.Html msg
armiesDetailed =
    Html.div
        []
        (List.map (\army -> armyDetail army) (all_armies))


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


homeTopographiesItemsRendered : HomeTopography -> Html.Html msg
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
        , renderedDateRange army.derivedData.listStartDate army.derivedData.listEndDate
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


downloadSummary:   Cmd Msg
downloadSummary =
    Http.get
        { url = "http://localhost:5016/summary.json"
        , expect = Http.expectString SummaryReceived
        }


toArmyLoading: MeshweshTypes.Summary -> (String, ArmyLoading)
toArmyLoading summary =
    (summary.id, ArmyLoading summary.id summary.name Nothing False False)

loadingArmiesList: List MeshweshTypes.Summary ->  Dict String ArmyLoading
loadingArmiesList summaries =
    Dict.fromList (List.map toArmyLoading summaries)

downloadArmies: String -> (Model, Cmd Msg)
downloadArmies summaryString =
    let 
        summaryListResult = Json.Decode.decodeString MeshweshDecoder.decodeSummaryList summaryString
    in
        case summaryListResult of
            Err _ -> (Error "Summary list decode error", Cmd.none)
            Ok summaryList ->
                let
                    -- TODO process all the armies
                    waitingList = loadingArmiesList (List.take 5 summaryList)
                in
                    let 
                        commands = List.map downloadArmy (Dict.values waitingList)
                    in
                    (LoadingArmies waitingList, Cmd.batch commands)


downloadArmy: ArmyLoading -> Cmd Msg
downloadArmy armyLoading =
    let 
        _ = Debug.log "Downloading army " armyLoading.id
    in
        Http.get
            { 
                url = String.concat ["http://localhost:5016/", armyLoading.id, ".army.json"]
                , expect = Http.expectJson (ArmyReceived armyLoading.id) MeshweshDecoder.decodeArmy
            }


isFullyLoaded: ArmyLoading -> Bool
isFullyLoaded armyLoading =
    case armyLoading.armyDetails of
        Nothing -> False
        Just _ ->
            if (not armyLoading.allyOptions) then
                False
            else
                if (not armyLoading.thematicCategories) then
                    False
                else
                    True


updateWaiting: Dict String ArmyLoading -> ArmyLoading ->  ( Model, Cmd msg )
updateWaiting waiting newEntry =
    if (isFullyLoaded newEntry) then
        (LoadingArmies (Dict.remove newEntry.id waiting), Cmd.none)
    else
        (LoadingArmies (Dict.update newEntry.id (\_ -> Just newEntry) waiting), Cmd.none)
    

armyReceived: Dict String ArmyLoading -> MeshweshTypes.Army ->  ( Model, Cmd msg )
armyReceived waiting newArmy =
    let
        oldEntryMaybe = Dict.get newArmy.id waiting
    in
        case oldEntryMaybe of
            Nothing -> 
                let 
                    _ = (Debug.log "Ignoring army received that we are not waring for " newArmy.id)
                in
                    (LoadingArmies waiting, Cmd.none)
            Just oldEntry ->
                let 
                    newEntry = { oldEntry | armyDetails= Just newArmy}
                in
                    updateWaiting waiting newEntry

handleArmyReceivedMsg : a -> Result Http.Error Army -> PageStatus -> ( Model, Cmd msg )
handleArmyReceivedMsg id result model =
    let
        _ = Debug.log "Received army" id
    in
        case result of
            Ok newArmy -> 
                case model of
                    LoadingArmies waiting ->  armyReceived waiting newArmy

                    Unloaded -> 
                         Debug.log "Army received while Unloaded"
                         (model, Cmd.none)

                    LoadingSummary ->
                         Debug.log "Army received while LoadingSummary"
                         (model, Cmd.none)

                    Loaded ->
                         Debug.log "Army received while Loaded"
                         (model, Cmd.none)

                    Error _ ->
                         Debug.log "Army received while already in Error"
                         (model, Cmd.none)

            Err httpError -> 
                (Error (httpErrorToString httpError), Cmd.none)



main : Program () Model Msg
main =
    Browser.element
        { init = \flags -> ( LoadingSummary, downloadSummary )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }

-- TODO
all_armies = []
all_themes = []
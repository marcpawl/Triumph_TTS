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
import ArmyIdTable

-- MODEL


type alias Model =
    PageStatus


type PageStatus
    = Unloaded
    | LoadingSummary
    | LoadingArmies LoadingData
    | Loaded LoadedData
    | Error String

type alias LoadingData =
    {
        -- Army we are waiting for
        waiting: ArmyIdTable.Table  ArmyLoading
        -- Armies that have all their data.
    ,   loaded: ArmyIdTable.Table ArmyLoading
    }

-- Army that is waiting for a file to load.
type alias ArmyLoading =
    {
        id: MeshweshTypes.ArmyId
    ,   armyName: String
    ,   armyDetails: Maybe MeshweshTypes.Army -- Nothing indicates waiting for response
    ,   allyOptions: Maybe (List MeshweshTypes.AllyOptions) -- Nothing indicates waiting for response
    ,   thematicCategories: Maybe (List MeshweshTypes.ThematicCategory)  -- Nothing indicates waiting for response
  }


-- Armies that belong to a theme  
type alias ThemeLoaded =
  { id : String
  , name : String
  , armies: List Army
  }


type alias LoadedData =
    {
    }


init : Model
init =
    Unloaded



-- UPDATE


type Msg
    = 
      LoadSummary
    | SummaryReceived (Result Http.Error String)
    | ArmyReceived  MeshweshTypes.ArmyId (Result Http.Error MeshweshTypes.Army)
    | ThematicCategoriesReceived MeshweshTypes.ArmyId (Result Http.Error (List MeshweshTypes.ThematicCategory))
    | AllyOptionsReceived MeshweshTypes.ArmyId (Result Http.Error (List MeshweshTypes.AllyOptions))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadSummary -> (LoadingSummary, downloadSummary)
        SummaryReceived  (Err httpError) -> 
            (Error (httpErrorToString httpError), Cmd.none)
        SummaryReceived (Ok summaryString) -> downloadArmies summaryString 
        ArmyReceived id result -> handleArmyReceivedMsg id result model
        ThematicCategoriesReceived id result -> handleThematicCategoriesReceivedMsg id result model
        AllyOptionsReceived id result -> handleAllyOptionsReceivedMsg id result model

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


loadingArmiesView: LoadingData -> Html.Html msg
loadingArmiesView loadingData =
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
                        (List.map armyLoadingView (ArmyIdTable.values loadingData.waiting))
                ]
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
        ,   downloadMaybeView armyLoading.allyOptions                   
        ,   downloadMaybeView armyLoading.thematicCategories
        ,   Html.td
            []
            [
                Html.text armyLoading.armyName
            ]    
        ]

loadedView: LoadedData -> Html.Html msg
loadedView _ =
    Html.div
        []
        [
            Html.text "TODO display LOADED view"
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
            LoadingArmies loadingData -> loadingArmiesView loadingData
            Loaded loadedData -> loadedView loadedData
            Error errorMessage -> errorView errorMessage


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
    anchor_tag "army_" army.id.id


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


toArmyLoading: MeshweshTypes.Summary -> (MeshweshTypes.ArmyId, ArmyLoading)
toArmyLoading summary =
    (summary.id, ArmyLoading summary.id summary.name Nothing Nothing Nothing)

loadingArmiesList: List MeshweshTypes.Summary ->  ArmyIdTable.Table ArmyLoading
loadingArmiesList summaries =
    ArmyIdTable.fromList (List.map toArmyLoading summaries)

downloadArmies: String -> (Model, Cmd Msg)
downloadArmies summaryString =
    let 
        summaryListResult = Json.Decode.decodeString MeshweshDecoder.decodeSummaryList summaryString
    in
        case summaryListResult of
            Err jsonDecodeError -> 
                (
                    Error 
                        (String.concat
                            [
                                "Summary list decode error:"
                            ,   (Json.Decode.errorToString jsonDecodeError)
                            ]
                        )
                ,   Cmd.none
                )
            Ok summaryList ->
                let
                    -- TODO process all the armies
                    waitingList = loadingArmiesList (List.take 700 summaryList)
                in
                    let 
                        commands =
                            List.concat 
                                [ 
                                    List.map downloadArmy (ArmyIdTable.values waitingList)
                                ,   List.map downloadThematicCategories (ArmyIdTable.values waitingList)
                                ,   List.map downloadAllyOptions (ArmyIdTable.values waitingList)
                                ]
                    in
                    (LoadingArmies 
                        (LoadingData waitingList (ArmyIdTable.empty)), 
                        Cmd.batch commands)


downloadArmy: ArmyLoading -> Cmd Msg
downloadArmy armyLoading =
    let 
        _ = Debug.log "Downloading army " armyLoading.id
    in
        Http.get
            { 
                url = String.concat ["http://localhost:5016/", armyLoading.id.id, ".army.json"]
                , expect = Http.expectJson (ArmyReceived armyLoading.id) MeshweshDecoder.decodeArmy
            }

downloadThematicCategories: ArmyLoading -> Cmd Msg
downloadThematicCategories armyLoading =
    let 
        _ = Debug.log "Downloading thematic category " armyLoading.id
    in
        Http.get
            { 
                url = String.concat ["http://localhost:5016/", armyLoading.id.id, ".thematicCategories.json"]
                , expect = Http.expectJson (ThematicCategoriesReceived armyLoading.id) MeshweshDecoder.decodeThematicCategories
            }

downloadAllyOptions: ArmyLoading -> Cmd Msg
downloadAllyOptions armyLoading =
    let 
        _ = Debug.log "Downloading ally options " armyLoading.id
    in
        Http.get
            { 
                url = String.concat ["http://localhost:5016/", armyLoading.id.id, ".allyOptions.json"]
                , expect = Http.expectJson (AllyOptionsReceived armyLoading.id) 
                    (Decode.list MeshweshDecoder.decodeAllyOptions)
            }



isJust: Maybe a -> Bool
isJust a =
    case a of
        Nothing -> False
        Just _ -> True

isFullyLoaded: ArmyLoading -> Bool
isFullyLoaded armyLoading =
    List.all (\x->x) [
        isJust armyLoading.allyOptions, 
        isJust armyLoading.thematicCategories, 
        isJust armyLoading.armyDetails]


updateWaiting: LoadingData -> ArmyLoading ->  ( Model, Cmd msg )
updateWaiting loadingData newEntry =
    if (isFullyLoaded newEntry) then
        let 
            newWaiting = ArmyIdTable.remove newEntry.id loadingData.waiting
            newLoaded = ArmyIdTable.insert newEntry.id newEntry loadingData.loaded
        in
            if ArmyIdTable.isEmpty newWaiting then
                (Loaded LoadedData, Cmd.none)
            else
                (LoadingArmies (LoadingData newWaiting newLoaded), Cmd.none)
    else
        let 
            newWaiting = ArmyIdTable.update newEntry.id (\_ -> Just newEntry) loadingData.waiting
        in
            (LoadingArmies (LoadingData newWaiting loadingData.loaded), Cmd.none)

dataReceived: LoadingData -> MeshweshTypes.ArmyId -> dataType -> (ArmyLoading->dataType->ArmyLoading) -> ( Model, Cmd msg )
dataReceived loadingData armyId data assignment =
    let
        oldEntryMaybe = ArmyIdTable.get armyId loadingData.waiting
    in
        case oldEntryMaybe of
            Nothing -> 
                let 
                    _ = (Debug.log "Ignoring army received that we are not waring for " armyId)
                in
                    (LoadingArmies loadingData, Cmd.none)
            Just oldEntry ->
                let 
                    newEntry = assignment oldEntry data
                in
                    updateWaiting loadingData newEntry



armyReceived: LoadingData -> MeshweshTypes.ArmyId -> MeshweshTypes.Army ->  ( Model, Cmd msg )
armyReceived loadingData armyId newArmy =
    dataReceived 
        loadingData 
        armyId 
        newArmy 
        (\oldEntry data -> { oldEntry | armyDetails= Just data})

thematicCategoriesReceived: LoadingData -> MeshweshTypes.ArmyId -> List MeshweshTypes.ThematicCategory ->  ( Model, Cmd msg )
thematicCategoriesReceived loadingData armyId newCategories =
    dataReceived 
        loadingData 
        armyId 
        newCategories 
        (\oldEntry data -> { oldEntry | thematicCategories= Just data})


allyOptionsReceived: LoadingData -> MeshweshTypes.ArmyId -> List MeshweshTypes.AllyOptions ->  ( Model, Cmd msg )
allyOptionsReceived loadingData armyId newAllyOptions =
    dataReceived 
        loadingData 
        armyId 
        newAllyOptions 
        (\oldEntry data -> { oldEntry | allyOptions= Just data})

dataReceivedErrorMessage: String -> String -> MeshweshTypes.ArmyId -> Model -> (Model, Cmd msg)
dataReceivedErrorMessage state dataTypeName armyId model =
    let
        _ = Debug.log ("Data received while " ++ state) (String.concat [dataTypeName, " ", armyId.id])
    in
        (model, Cmd.none)

handleDataReceivedReceivedMsg : MeshweshTypes.ArmyId -> Result Http.Error dataTypeReceived -> Model -> (LoadingData -> MeshweshTypes.ArmyId -> dataTypeReceived ->  ( Model, Cmd msg )) -> String -> ( Model, Cmd msg )
handleDataReceivedReceivedMsg armyId result model modelUpdater dataTypeName =
    let
        _ = Debug.log "Received army" armyId.id
    in
        case result of
            Ok newArmy -> 
                case model of
                    LoadingArmies loadingData ->  modelUpdater loadingData armyId newArmy

                    Unloaded -> 
                        dataReceivedErrorMessage "Unloaded"  dataTypeName  armyId model

                    LoadingSummary ->
                        dataReceivedErrorMessage "LoadingSummary"  dataTypeName  armyId model

                    Loaded _ ->
                        dataReceivedErrorMessage "Loaded" dataTypeName armyId model

                    Error _ ->
                        dataReceivedErrorMessage "Error" dataTypeName armyId model

            Err httpError -> 
                (
                    Error 
                    (String.concat 
                        [
                            "Army "
                        ,   armyId.id
                        ,   ": "
                        ,  (httpErrorToString httpError)
                        ])
                ,   Cmd.none
                )



handleArmyReceivedMsg : MeshweshTypes.ArmyId -> Result Http.Error Army -> Model -> ( Model, Cmd msg )
handleArmyReceivedMsg armyId result model =
    handleDataReceivedReceivedMsg armyId result model armyReceived "Army"


handleThematicCategoriesReceivedMsg : MeshweshTypes.ArmyId -> Result Http.Error (List MeshweshTypes.ThematicCategory) -> Model -> ( Model, Cmd msg )
handleThematicCategoriesReceivedMsg armyId result model =
    handleDataReceivedReceivedMsg armyId result model thematicCategoriesReceived "Thematic Category"


handleAllyOptionsReceivedMsg : MeshweshTypes.ArmyId -> Result Http.Error (List MeshweshTypes.AllyOptions) -> Model -> ( Model, Cmd msg )
handleAllyOptionsReceivedMsg armyId result model =
    handleDataReceivedReceivedMsg armyId result model allyOptionsReceived "Thematic Category"


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
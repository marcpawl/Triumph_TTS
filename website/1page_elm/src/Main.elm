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
import Url exposing (Url)
import Dict exposing (Dict)
import ArmyIdTable
import LoadedData exposing (ArmyLoaded, LoadedData)
import BookParts exposing (..)
import ChapterArmy exposing (partArmyLists)
import ChapterCategory exposing (partThematicCategories)
import DateRange exposing (..)


-- MODEL


type alias Model =
    PageStatus


type PageStatus
    = Unloaded Url
    | LoadingSummary PreloadData
    | LoadingArmies LoadingData
    | Loaded LoadedData
    | Error String

type alias PreloadData = 
    {
        summaryList: Maybe (List MeshweshTypes.Summary)
    }

type alias LoadingData =
    {
        -- Army we are waiting for
        waiting: ArmyIdTable.Table  ArmyLoading
        -- Armies that have all their data.
    ,   loaded: ArmyIdTable.Table ArmyLoaded
    }

-- Army that is waiting for a file to load.
type alias ArmyLoading =
    {
        id: MeshweshTypes.ArmyId
    ,   armyName: String
    ,   armyDetails: Maybe MeshweshTypes.Army -- Nothing indicates waiting for response
    ,   allyOptions: Maybe (List MeshweshTypes.AllyOptions) -- Nothing indicates waiting for response
    ,   thematicCategories: Maybe (List MeshweshTypes.ThematicCategory)  -- Nothing indicates waiting for response
    ,   enemies: Maybe (List MeshweshTypes.ArmyId)
    ,   relatedArmies: Maybe (List MeshweshTypes.ArmyId)
  }




-- href is the URL of the loaded page
init : String -> Model
init href =
    let
        urlMaybe = Url.fromString(href)
    in
        case urlMaybe of
            Nothing -> Error ("Initial page is not valid: " ++ href)
            Just url -> Unloaded url


-- UPDATE


type Msg
    = 
      LoadSummary
    | SummaryReceived (Result Http.Error (List MeshweshTypes.Summary))
    | ArmyReceived  MeshweshTypes.ArmyId (Result Http.Error MeshweshTypes.Army)
    | ThematicCategoriesReceived MeshweshTypes.ArmyId (Result Http.Error (List MeshweshTypes.ThematicCategory))
    | AllyOptionsReceived MeshweshTypes.ArmyId (Result Http.Error (List MeshweshTypes.AllyOptions))
    | EnemiesReceived MeshweshTypes.ArmyId (Result Http.Error (List MeshweshTypes.ArmyId))
    | RelatedArmiesReceived MeshweshTypes.ArmyId (Result Http.Error (List MeshweshTypes.ArmyId))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadSummary -> (LoadingSummary (PreloadData Nothing), downloadSummary)
        SummaryReceived result -> handleSummaryReceivedMsg result model
        ArmyReceived id result -> handleArmyReceivedMsg id result model
        ThematicCategoriesReceived id result -> handleThematicCategoriesReceivedMsg id result model
        AllyOptionsReceived id result -> handleAllyOptionsReceivedMsg id result model
        EnemiesReceived id result -> handleEnemiesReceivedMsg id result model
        RelatedArmiesReceived id result -> handleRelatedArmiesReceivedMsg id result model

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
            "Unknown error: Bad status"
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

loadingSummaryView: PreloadData -> Html.Html msg
loadingSummaryView preloadData =
    Html.div
        []
        [
            case preloadData.summaryList of
                Just _ ->  Html.text "done summary"
                Nothing ->  Html.text "... summary"
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
        ,   downloadMaybeView armyLoading.enemies
        ,   Html.td
            []
            [
                Html.text armyLoading.armyName
            ]    
        ]

armyNameFinder: LoadedData -> MeshweshTypes.ArmyId -> String
armyNameFinder loadedData armyId =
    let
        maybeArmy = ArmyIdTable.get armyId loadedData.armies
    in
        case maybeArmy of
            Nothing ->
                let 
                    _ = Debug.log "Army not found" armyId
                in
                    "ERROR " ++ armyId.id
            Just army ->
                army.armyName


loadedView: (MeshweshTypes.ArmyId -> String) -> LoadedData -> Html.Html msg
loadedView armyNameFind loadedData =
    Html.div
        []
        [
            partArmyLists armyNameFind loadedData 
        ,   partThematicCategories loadedData
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
            Unloaded _ -> unloadedView
            LoadingSummary preloadData -> loadingSummaryView preloadData
            LoadingArmies loadingData -> loadingArmiesView loadingData
            Loaded loadedData -> loadedView (armyNameFinder loadedData) loadedData
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






-- Return the URL for a file in the ArmyLists directory
armyListsUrl: String -> String
armyListsUrl file =
    String.concat
        [
            "http://localhost:5016/armyLists/"
        ,   file
        ]

downloadSummary:   Cmd Msg
downloadSummary =
    Http.get
        { url = (armyListsUrl "summary.json")
        , expect = Http.expectJson SummaryReceived MeshweshDecoder.decodeSummaryList
        }


toArmyLoading: MeshweshTypes.Summary -> (MeshweshTypes.ArmyId, ArmyLoading)
toArmyLoading summary =
    (summary.id, ArmyLoading summary.id summary.name Nothing Nothing Nothing Nothing Nothing)

loadingArmiesList: List MeshweshTypes.Summary ->  ArmyIdTable.Table ArmyLoading
loadingArmiesList summaries =
    ArmyIdTable.fromList (List.map toArmyLoading summaries)

downloadArmies: List MeshweshTypes.Summary -> (Model, Cmd Msg)
downloadArmies summaryList =
    let
        -- TODO process all the armies
        waitingList = loadingArmiesList (List.take 50 summaryList)
    in
        let 
            commands =
                List.concat 
                    [ 
                        List.map downloadArmy (ArmyIdTable.values waitingList)
                    ,   List.map downloadThematicCategories (ArmyIdTable.values waitingList)
                    ,   List.map downloadAllyOptions (ArmyIdTable.values waitingList)
                    ,   List.map downloadEnemies (ArmyIdTable.values waitingList)
                    ,   List.map downloadRelatedArmies (ArmyIdTable.values waitingList)
                    ]
        in
        (LoadingArmies 
            (LoadingData waitingList (ArmyIdTable.empty)), 
            Cmd.batch commands)


downloadArmy: ArmyLoading -> Cmd Msg
downloadArmy armyLoading =
    Http.get
        { 
            url = armyListsUrl (String.concat [armyLoading.id.id, ".army.json"])
            , expect = Http.expectJson (ArmyReceived armyLoading.id) MeshweshDecoder.decodeArmy
        }

downloadThematicCategories: ArmyLoading -> Cmd Msg
downloadThematicCategories armyLoading =
    Http.get
        { 
            url = armyListsUrl( String.concat [armyLoading.id.id, ".thematicCategories.json"])
            , expect = Http.expectJson (ThematicCategoriesReceived armyLoading.id) MeshweshDecoder.decodeThematicCategories
        }

downloadAllyOptions: ArmyLoading -> Cmd Msg
downloadAllyOptions armyLoading =
    Http.get
        { 
            url = armyListsUrl (String.concat [armyLoading.id.id, ".allyOptions.json"])
            , expect = Http.expectJson (AllyOptionsReceived armyLoading.id) 
                (Decode.list MeshweshDecoder.decodeAllyOptions)
        }

downloadEnemies: ArmyLoading -> Cmd Msg
downloadEnemies armyLoading =
    Http.get
        { 
            url = armyListsUrl (String.concat [armyLoading.id.id, ".enemyArmy.json"])
            , expect = Http.expectJson (EnemiesReceived armyLoading.id) 
                MeshweshDecoder.decodeEnemies
        }


downloadRelatedArmies: ArmyLoading -> Cmd Msg
downloadRelatedArmies armyLoading =
    Http.get
        { 
            url = armyListsUrl (String.concat [armyLoading.id.id, ".associatedArmyLists.json"])
            , expect = Http.expectJson (RelatedArmiesReceived armyLoading.id) 
                MeshweshDecoder.decodeRelatedArmies
        }


isJust: Maybe a -> Bool
isJust a =
    case a of
        Nothing -> False
        Just _ -> True

isFullyLoaded: ArmyLoading -> Bool
isFullyLoaded armyLoading =
    List.all 
        (\x->x) 
        [
            isJust armyLoading.allyOptions
        ,   isJust armyLoading.thematicCategories
        ,   isJust armyLoading.armyDetails
        ,   isJust armyLoading.enemies
        ]

toArmyLoaded: ArmyLoading -> Maybe ArmyLoaded
toArmyLoaded armyLoading =
    case armyLoading.armyDetails of
        Nothing -> Nothing
        Just armyDetails ->
            (case armyLoading.allyOptions of
                Nothing -> Nothing
                Just allyOptions ->
                    (case armyLoading.thematicCategories of
                        Nothing -> Nothing
                        Just thematicCategories -> 
                            case armyLoading.enemies of
                                Nothing -> Nothing
                                Just enemies ->
                                    case armyLoading.relatedArmies of
                                        Nothing -> Nothing
                                        Just relatedArmies ->
                                            Just (ArmyLoaded
                                                    armyLoading.id
                                                    armyLoading.armyName 
                                                    armyDetails
                                                    allyOptions
                                                    thematicCategories
                                                    enemies
                                                    relatedArmies)
                    )
            )


-- Update the loading date for the reception of new data
-- loadingData: The model before the new data
-- newEntry: The data that has been received
-- returns the new model
updateLoadingData: LoadingData -> ArmyLoading -> LoadingData
updateLoadingData loadingData newEntry =
    let 
        newLoadedEntryMaybe = toArmyLoaded newEntry
    in
        case newLoadedEntryMaybe of
            Nothing ->
                -- update the existing waiting entry
                let 
                    newWaiting = ArmyIdTable.update newEntry.id (\_ -> Just newEntry) loadingData.waiting
                in
                    LoadingData newWaiting loadingData.loaded
            Just newLoadedEntry ->
                let
                    newWaiting = ArmyIdTable.remove newEntry.id loadingData.waiting
                    newLoaded = ArmyIdTable.insert newLoadedEntry.id newLoadedEntry loadingData.loaded
                in
                    LoadingData newWaiting newLoaded


-- Update the mode while we are waiting for data
-- loadingData: Model before the new data
-- newEntry: data received
-- new model an command to enact
updateWaiting: LoadingData -> ArmyLoading ->  ( Model, Cmd Msg )
updateWaiting loadingData newEntry =
    let
        newLoadingData = updateLoadingData loadingData newEntry
    in
        if (ArmyIdTable.isEmpty newLoadingData.waiting) then
            (Loaded (LoadedData newLoadingData.loaded), Cmd.none)
        else
            (LoadingArmies newLoadingData, Cmd.none)


dataReceived: LoadingData -> MeshweshTypes.ArmyId -> dataType -> (ArmyLoading->dataType->ArmyLoading) -> ( Model, Cmd Msg )
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



armyReceived: LoadingData -> MeshweshTypes.ArmyId -> MeshweshTypes.Army ->  ( Model, Cmd Msg )
armyReceived loadingData armyId newArmy =
    dataReceived 
        loadingData 
        armyId 
        newArmy 
        (\oldEntry data -> { oldEntry | armyDetails= Just data})

thematicCategoriesReceived: LoadingData -> MeshweshTypes.ArmyId -> List MeshweshTypes.ThematicCategory ->  ( Model, Cmd Msg )
thematicCategoriesReceived loadingData armyId newCategories =
    dataReceived 
        loadingData 
        armyId 
        newCategories 
        (\oldEntry data -> { oldEntry | thematicCategories= Just data})


allyOptionsReceived: LoadingData -> MeshweshTypes.ArmyId -> List MeshweshTypes.AllyOptions ->  ( Model, Cmd Msg )
allyOptionsReceived loadingData armyId newAllyOptions =
    dataReceived 
        loadingData 
        armyId 
        newAllyOptions 
        (\oldEntry data -> { oldEntry | allyOptions= Just data})


enemiesReceived: LoadingData -> MeshweshTypes.ArmyId -> List MeshweshTypes.ArmyId ->  ( Model, Cmd Msg )
enemiesReceived loadingData armyId newEnemyId =
    dataReceived 
        loadingData 
        armyId 
        newEnemyId 
        (\oldEntry data -> { oldEntry | enemies= Just data})


relatedArmiesReceived: LoadingData -> MeshweshTypes.ArmyId -> List MeshweshTypes.ArmyId ->  ( Model, Cmd Msg )
relatedArmiesReceived loadingData armyId relatedArmyId =
    dataReceived 
        loadingData 
        armyId 
        relatedArmyId 
        (\oldEntry data -> { oldEntry | relatedArmies= Just data})


dataReceivedErrorMessage: String -> String -> MeshweshTypes.ArmyId -> Model -> (Model, Cmd Msg)
dataReceivedErrorMessage state dataTypeName armyId model =
    let
        _ = Debug.log ("Data received while " ++ state) (String.concat [dataTypeName, " ", armyId.id])
    in
        (model, Cmd.none)

handleDataReceivedReceivedMsg : MeshweshTypes.ArmyId -> Result Http.Error dataTypeReceived -> Model -> (LoadingData -> MeshweshTypes.ArmyId -> dataTypeReceived ->  ( Model, Cmd Msg )) -> String -> ( Model, Cmd Msg )
handleDataReceivedReceivedMsg armyId result model modelUpdater dataTypeName =
    case result of
        Ok newArmy -> 
            case model of
                LoadingArmies loadingData ->  modelUpdater loadingData armyId newArmy

                Unloaded _ -> 
                    dataReceivedErrorMessage "Unloaded"  dataTypeName  armyId model

                LoadingSummary _ ->
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


handleSummaryReceivedMsg : Result Http.Error (List MeshweshTypes.Summary) -> Model -> ( Model, Cmd Msg )
handleSummaryReceivedMsg result model =
    case result of
        Ok newSummaryList ->  
            ( case model of
                LoadingSummary preload -> 
                    let
                        newPreload = { preload | summaryList = Just newSummaryList}
                    in
                        case newPreload.summaryList of
                            Nothing -> (LoadingSummary newPreload, Cmd.none)
                            Just summaryList -> (downloadArmies summaryList)
                -- TODO log errors
                Unloaded _ -> (model, Cmd.none)
                LoadingArmies _ -> (model, Cmd.none)
                Loaded _  -> (model, Cmd.none)
                Error  _ -> (model, Cmd.none)
            )
        Err httpError -> 
            (
                Error ("Http summary failed" ++ (httpErrorToString httpError))
            ,   Cmd.none
            )


handleArmyReceivedMsg : MeshweshTypes.ArmyId -> Result Http.Error Army -> Model -> ( Model, Cmd Msg )
handleArmyReceivedMsg armyId result model =
    handleDataReceivedReceivedMsg armyId result model armyReceived "Army"


handleThematicCategoriesReceivedMsg : MeshweshTypes.ArmyId -> Result Http.Error (List MeshweshTypes.ThematicCategory) -> Model -> ( Model, Cmd Msg )
handleThematicCategoriesReceivedMsg armyId result model =
    handleDataReceivedReceivedMsg armyId result model thematicCategoriesReceived "Thematic Category"


handleAllyOptionsReceivedMsg : MeshweshTypes.ArmyId -> Result Http.Error (List MeshweshTypes.AllyOptions) -> Model -> ( Model, Cmd Msg )
handleAllyOptionsReceivedMsg armyId result model =
    handleDataReceivedReceivedMsg armyId result model allyOptionsReceived "Thematic Category"


handleEnemiesReceivedMsg : MeshweshTypes.ArmyId -> Result Http.Error (List MeshweshTypes.ArmyId) -> Model -> ( Model, Cmd Msg )
handleEnemiesReceivedMsg armyId result model =
    handleDataReceivedReceivedMsg armyId result model enemiesReceived "Enemies"


handleRelatedArmiesReceivedMsg : MeshweshTypes.ArmyId -> Result Http.Error (List MeshweshTypes.ArmyId) -> Model -> ( Model, Cmd Msg )
handleRelatedArmiesReceivedMsg armyId result model =
    handleDataReceivedReceivedMsg armyId result model relatedArmiesReceived "Related Armies"



compare: String -> String -> Order
compare aa bb =
    if aa < bb then
        LT
    else if aa == bb then
        EQ
    else
        GT


-- compareArmyName: MeshweshTypes.Army -> MeshweshTypes.Army -> Order
compareArmyName a b =
    compare a.derivedData.extendedName b.derivedData.extendedName



main : Program () Model Msg
main =
    Browser.element
        { init = \flags -> ( LoadingSummary (PreloadData Nothing), downloadSummary )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }

-- TODO
all_armies = []
all_themes = []

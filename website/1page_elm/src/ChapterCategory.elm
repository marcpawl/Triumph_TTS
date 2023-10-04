-- Render the page for displaying the armies in a category

module ChapterCategory exposing (partThematicCategories)

import Dict exposing (Dict)
import Set exposing (Set)
import LoadedData exposing (..)
import MeshweshTypes exposing (..)
import Html exposing (..)
import Html.Attributes
import BookParts exposing (..)
import ArmyIdTable
import DateRange


type alias ArmyDescriptor =
    {
        armyId: ArmyId
    ,   name: String
    ,   extendedName: String
    ,   listStartDate: Int
    ,   listEndDate: Int
    }


renderArmyName: ArmyDescriptor -> Html msg
renderArmyName army =
    Html.div
        [
        ]
        [
            Html.a
                [
                    Html.Attributes.href ("#" ++ army.name)
                ]
                [
                     Html.text army.extendedName
                ]
        ]

minDate: List ArmyDescriptor -> Maybe Int
minDate armies =
    List.minimum
        (List.map
            (\army -> army.listStartDate)
            armies
        )

maxDate: List ArmyDescriptor -> Maybe Int
maxDate armies =
    List.maximum
        (List.map
            (\army -> army.listEndDate)
            armies
        )

categoryDateString: List ArmyDescriptor -> Maybe String
categoryDateString armies =
    Maybe.map2
        DateRange.formattedDateRange
            (minDate armies)
            (maxDate armies)


-- 1 chapter for a category
chapterCategory: (ThematicCategory, List ArmyDescriptor) -> Html msg
chapterCategory (category,armies) =
    chapter 
        category.name 
        (categoryDateString armies)
        (   List.map
                renderArmyName
                armies
        )
    


armyTuples: ArmyLoaded -> List (ThematicCategory, ArmyDescriptor)
armyTuples army =
    List.map 
        (\x-> (x, (ArmyDescriptor 
                    army.armyDetails.id 
                    army.armyDetails.name                    
                    army.armyDetails.derivedData.extendedName
                    army.armyDetails.derivedData.listStartDate
                    army.armyDetails.derivedData.listEndDate
                    )))
        army.thematicCategories


compareTuple: (ThematicCategory, ArmyDescriptor) -> (ThematicCategory, ArmyDescriptor) -> Basics.Order
compareTuple a b =
    let
        (a_category, a_army) = a
        (b_category, b_army) = b
    in
        case (compare a_category.name b_category.name) of
            LT -> GT
            GT -> LT
            EQ ->
                case (compare a_army.extendedName b_army.extendedName) of
                    LT -> GT
                    GT -> LT
                    EQ -> EQ



fold: (ThematicCategory, ArmyDescriptor) -> List (ThematicCategory, List ArmyDescriptor) -> List (ThematicCategory, List ArmyDescriptor)
fold entry list =
    let 
        (theme,army) = entry
    in
        case list of
            [] ->[ (theme, [army]) ]
            (h :: t) -> 
                let 
                    (hTheme, hArmies) = h
                in
                    if hTheme.id == theme.id then
                        -- Add to existing cateogry
                        (hTheme, army :: hArmies) :: t
                    else
                        -- Create new category
                        (theme, [army]) :: list
            

-- createCategories: LoadedData -> List (ThematicCategory, List ArmyDescriptor)
createCategories loadedData =
    let 
        tuples = List.concat 
                ( List.map
                    armyTuples
                    (ArmyIdTable.values loadedData.armies)
                )
            |> List.sortWith compareTuple
    in
    List.foldl
        fold
        []
        tuples
    

-- Create chapters for all the thematic categories.
-- Each category gets one chapter.
chaptersForAllCategories: List (ThematicCategory, List ArmyDescriptor) -> LoadedData -> List (Html msg)
chaptersForAllCategories categories loadedData =
    List.map
        chapterCategory
        categories

renderCategoryReference: (ThematicCategory, List ArmyDescriptor) -> Html msg
renderCategoryReference category =
    let
        (catId, armies) = category
        maybeDate = categoryDateString armies
    in
        Html.div
            []
            [
                Html.a
                    [ Html.Attributes.href ("#" ++ catId.name)]
                    ( List.concat
                        [
                            [ Html.text catId.name]
                        ,   case maybeDate of
                            Nothing -> []
                            Just text -> [ Html.text (" " ++ text)]
                        ]
                    )
            ]

byStartDate: (ThematicCategory, List ArmyDescriptor) -> (ThematicCategory, List ArmyDescriptor) -> Order
byStartDate a b =
    let
        (a_cat, a_armies) = a
        (b_cat, b_armies) = b
        a_start = minDate(a_armies)
        b_start = minDate(b_armies)
        dateOrder = compare 
            (Maybe.withDefault -99999 a_start)
            (Maybe.withDefault -99999 b_start)

    in
        case dateOrder of
            GT -> GT
            LT -> LT
            EQ -> compare a_cat.name b_cat.name


categoriesTableOfContents: List (ThematicCategory, List ArmyDescriptor) -> LoadedData -> Html msg
categoriesTableOfContents categories loadedData = 
    Html.div
        []
        (
                List.sortWith byStartDate categories
            |>  List.map
                renderCategoryReference
        )

partThematicCategories: LoadedData -> Html msg
partThematicCategories loadedData =
    let
        categories = createCategories loadedData
    in
        part
            "Thematic Categories"
            ( List.concat
                [
                    [ categoriesTableOfContents categories loadedData ]
                ,   (chaptersForAllCategories categories loadedData)
            ]
        )

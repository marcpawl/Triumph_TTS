module BookParts exposing (..)

import Html exposing (..)
import Html.Attributes


-- Part of a book, collection of chapters
part: String -> List (Html msg) -> Html msg 
part partTitle chapters =
    Html.div
        [
            Html.Attributes.class "part"
        ]
        (
            List.append
                [
                    page [Html.text partTitle]
                ]
                chapters
        )


chapterTitle: String -> Maybe String -> Html msg
chapterTitle title subtitleMaybe =
    case subtitleMaybe of
        Nothing ->  
            Html.div 
                [
                    Html.Attributes.class "chapterTitle"
                ]
                [Html.text title]
        Just subtitle ->
             (Html.div []
            [
                Html.div 
                    [
                        Html.Attributes.class "chapterTitle"
                    ]
                    [Html.text title]
            ,   Html.div 
                    [
                        Html.Attributes.class "chapterSubtitle"
                    ]
                    [Html.text subtitle]
            ])


chapter: String-> Maybe String -> List (Html msg) -> Html msg
chapter title subTitle body =
    (Html.div
        [
            Html.Attributes.class "chapter"
        ]
        (
            List.append
                [
                    page 
                        [
                            (chapterTitle title subTitle)
                        ]
                ]
                body
        ))


-- Page Break
page: List (Html msg) -> Html msg
page body =
     (Html.div
        [
            Html.Attributes.class "page"
        ]
        body)


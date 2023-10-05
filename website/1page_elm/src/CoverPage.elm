module CoverPage exposing (coverPage)

import Html
import Html.Attributes


coverPage:  Html.Html msg
coverPage =
    Html.div
        [
            Html.Attributes.class "coverPage"
        ]
        [
            Html.div 
                []
                [
                    Html.img 
                        [ Html.Attributes.src "https://meshwesh.wgcwar.com/images/meshwesh-banner.png"]
                        []
                ]
        ,   Html.div 
                []
                [
                    Html.img 
                        [ Html.Attributes.src "https://meshwesh.wgcwar.com/images/triumph-title.png"]
                        []
                ]
        ]

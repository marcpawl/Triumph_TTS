module DateRange exposing (..)

import Html


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

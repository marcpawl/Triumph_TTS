module MeshweshDecoder exposing (..)

-- JSON decoding of the types recieved from Meshwesh

import MeshweshTypes
import Json.Decode as Decode
    exposing
        ( Decoder
        , decodeString
        , field
        , int
        , list
        , map3
        , map4
        , string
        )

decodeSummary : Decoder MeshweshTypes.Summary
decodeSummary =
    map4 MeshweshTypes.Summary
        (field "id" string)
        (field "name" string)
        (field "keywords" (list string))
        (field "derivedData" decodeDerivedData)

decodeDerivedData : Decoder MeshweshTypes.DerivedData
decodeDerivedData =
    map3 MeshweshTypes.DerivedData
        (field "listStartDate" int)
        (field "listEndDate" int)
        (field "extendedName" string)

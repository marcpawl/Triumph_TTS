module MeshweshDecoderTest exposing (suite)

import Expect exposing (Expectation)
import Test exposing (..)
import MeshweshTypes
import MeshweshDecoder
import Json.Decode


summary = """
{"id":"6153508f03385c0016b82744",
"name":"North Maritime First Nations",
"keywords":["word1", "word2"],
"derivedData":{
    "listStartDate":1100,
    "listEndDate":1770,
    "extendedName":"North Maritime First Nations  1100 to 1770 AD"
    }
}
"""

suite : Test
suite =
    describe "MeshweshDecoder -- JSON Decoding"
        [ 
            summary_id_and_name
        ,   test_derived_data
        ]

summary_id_and_name = 
    let 
        actual = Json.Decode.decodeString
                        MeshweshDecoder.decodeSummary 
                        summary
    in
    test "Summary" <|
        \_ ->
            Expect.equal 
                actual
                (Ok (MeshweshTypes.Summary 
                        "6153508f03385c0016b82744" 
                        "North Maritime First Nations" 
                        ["word1", "word2"]
                        (MeshweshTypes.DerivedData 1100 1770 "North Maritime First Nations  1100 to 1770 AD")
                    )
                ) 



derivedData = MeshweshTypes.DerivedData 1100 1770 "North Maritime First Nations  1100 to 1770 AD"
derivedDataString = """
{
    "listStartDate":1100,
    "listEndDate":1770,
    "extendedName":"North Maritime First Nations  1100 to 1770 AD"
}"""

test_derived_data = 
    test "Derived Data" <|
    \_ ->
    let 
        actual =                     (Json.Decode.decodeString
                MeshweshDecoder.decodeDerivedData
                derivedDataString) 
    in
        case actual of
            Err message -> Expect.fail (Json.Decode.errorToString message)
            Ok value -> Expect.equal value derivedData

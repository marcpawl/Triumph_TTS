module GeneralsSubsectionTest exposing (suite)

import Expect exposing (Expectation)
import Test exposing (..)
import GeneralsSubsection
import Armies

suite : Test
suite =
    describe "GeneralsSubsection"
        [ test "troop type code names are joined with ' or,'" <|
            \_ ->
                Expect.equal 
                    (GeneralsSubsection.toTroopTypeCodeNameStrings 
                        Armies.troopEntriesForGeneral_5fb1b9dee1af060017709665) 
                    ["Knights or Pike","Javelin Cavalry"]
        ,test "Nothing notes not rendered" <|
            \_ ->
                Expect.equal 
                    (GeneralsSubsection.toTroopNoteStrings
                        Armies.troopEntriesForGeneral_5fb1b9dee1af060017709665) 
                    ["only if Antigonos",""]
        ]

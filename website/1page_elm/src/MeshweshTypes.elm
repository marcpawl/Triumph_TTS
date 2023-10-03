module MeshweshTypes exposing (..)
import Json.Decode exposing (int)
import Css exposing (All)

type alias ArmyId =
  {
    id: String
  }
  
type alias DerivedData =
  {
    listStartDate: Int
  , listEndDate: Int
  , extendedName: String
  }

type alias Summary =
  {
    id: ArmyId
  , name: String
  , keywords: List String
  , derivedData: DerivedData
  } 
    
type alias InvasionRating =
  {
    id: String
  , value: Int
  , note: Maybe String
  }
              
type alias ManeuverRating =
  {
    id: String
  , value: Int
  , note: Maybe String
  }

type Topography = Hilly | Dry | Arable | Forest | Delta | Steppe | Marsh
              
type alias HomeTopography =
  {
    id: String
  , values: List Topography
  , note: Maybe String
  }

type TroopTypeCode = 
    ARC | ART | BAD | BLV | BTX | CAT | CHT 
  | ECV | EFT | ELE 
  | HBW | HFT | HRD 
  | JCV | KNT | LFT | LSP | PAV | PIK | RBL | RDR | SKM | SPR | WBD
  | WRR | WWG

type alias TroopEntry = 
  {
    id: String
  , troopTypeCode: TroopTypeCode
  , dismountTypeCode: Maybe TroopTypeCode
  , note: Maybe String
  }

type BattleCardCode = 
    AC | AM | CC | CF | CT | CH 
  | DC | DD
  | ES | ET | FC  
  | HD | HL 
  | LC | MD | MI 
  | NC | PD | PL | PT 
  | SB | SC | SF | SP | SS | SV | SW

type alias BattleCardEntry =
  {
    -- _id: String
    min: Int
  , max: Int
  , battleCardCode: BattleCardCode
  , note: Maybe String
  }


type alias TroopEntriesList =
  { 
    id : String
  ,  troopEntries: List TroopEntry
  }
              

type alias DateRangeEntry =
  {
    -- id: String
    startDate: Int
  , endDate: Int
  }

type alias AllyEntryReference =
  {
    name: String
  , allyArmyList: ArmyId
  }

type alias AllyOptionEntry =
  {
    dateRange: Maybe DateRangeEntry
  , note: Maybe String
  , allyEntries: List AllyEntryReference
  }

type alias TroopOptionEntry =
  {
    -- id: String
    min: Int
  , max: Int
  , dateRanges: List DateRangeEntry
  , troopEntries: List TroopEntry
  , description: String
  , note: Maybe String
  , core: String
  , battleCardEntries: List BattleCardEntry
  }

type alias Army =
  { 
    id : ArmyId
  , keywords: List String
  , derivedData: DerivedData
  , name: String   
  , invasionRatings: List InvasionRating
  , maneuverRatings: List ManeuverRating   
  , homeTopographies: List HomeTopography
  , troopEntriesForGeneral: List TroopEntriesList
  , battleCardEntries: List BattleCardEntry
  , troopOptions: List TroopOptionEntry
  , allyOptions: List AllyOptionEntry
  }

-- Category that an army belongs to.
type alias ThematicCategory =
  { id : String
  , name : String
  }

  
type alias Theme =
  { id : String
  , name : String
  , armies: List Army
  }

type alias AllyArmyList =
  {
    name: String
  , dateRange: Maybe DateRangeEntry
  , troopOptions: List TroopOptionEntry
  , internalContingent: Bool
  }

type alias AllyEntry =
  {
    name: String
  , allyArmyList: AllyArmyList
  }

type alias AllyOptions =
  {
    dateRange: Maybe DateRangeEntry
  , note: Maybe String
  , allyEntries: List AllyEntry
  }

  
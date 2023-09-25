module MeshweshTypes exposing (..)

type alias DerivedData =
  {
    listStartDate: Int
  , listEndDate: Int
  , extendedName: String
  }

type alias Summary =
  {
    id: String
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
              
type alias HomeTopographies =
  {
    id: String
  , values: List Topography
  , note: Maybe String
  }

type TroopTypeCode = ARC | BAD | BLV | BTX | CAT | CHT | ECV | EFT | ELE 
  | HBW | HFT | JCV | KNT | LFT | LSP | PAV | PIK | RBL | RDR | SKM | SPR | WBD
  | WRR | WWG

type alias TroopEntry = 
  {
    id: String
  , troopTypeCode: TroopTypeCode
  , dismountTypeCode: Maybe TroopTypeCode
  , note: Maybe String
  }

type BattleCardCode = AM | DC | FC  | MI | NC | PD | PT | SC | SW

type alias BattleCardEntry =
  {
    -- _id: String
    min: Maybe Int
  , max: Maybe Int
  , battleCardCode: BattleCardCode
  , note: Maybe String
  }
              
type alias Army =
  { 
    id : String
  , keywords: List String
  , listStartDate: Int
  , listEndDate: Int
  , extendedName: String
  , sortId: Float
  , sublistId: String
  , name: String   
  , invasionRatings: List InvasionRating
  , maneuverRatings: List ManeuverRating   
  , homeTopographies: List HomeTopographies    
  , troopEntriesForGeneral: List (List TroopEntry)
  , battleCardEntries: List BattleCardEntry
  }

type alias Theme =
  { id : String
  , name : String
  , armies: List Army
  }

module MeshWeshTypes exposing (..)

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
  }

type alias Theme =
  { id : String
  , name : String
  , armies: List Army
  }

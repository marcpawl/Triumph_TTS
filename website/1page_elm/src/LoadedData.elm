module LoadedData exposing (..)

import Dict exposing (Dict)
import ArmyIdTable
import MeshweshTypes

-- -- Armies that belong to a theme  
-- type alias ThemeLoaded =
--   { id : String
--   , name : String
--   , armies: List Army
--   }


type alias ArmyLoaded =
    {
        id: MeshweshTypes.ArmyId
    ,   armyName: String
    ,   armyDetails: MeshweshTypes.Army 
    ,   allyOptions: (List MeshweshTypes.AllyOptions) 
    ,   thematicCategories: (List MeshweshTypes.ThematicCategory)
    ,   enemies: List MeshweshTypes.ArmyId
    ,   relatedArmies: List MeshweshTypes.ArmyId
  }

type alias ThematicCategoryLoaded =
    {
        name : String
    ,   armies: List ArmyLoaded
    }


type alias LoadedData =
    {
        armies: ArmyIdTable.Table ArmyLoaded
    }

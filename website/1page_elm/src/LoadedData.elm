module LoadedData exposing (..)

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
  }


type alias LoadedData =
    {
        armies: ArmyIdTable.Table ArmyLoaded
    }

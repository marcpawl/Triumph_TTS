-- Wrapper around dict to take ArmyId as the key

module ArmyIdTable exposing ( Table, empty, fromList, get, insert, isEmpty, remove,
  toList, update, values)


import Dict exposing (Dict)
import MeshweshTypes exposing (ArmyId)
import Html.Attributes exposing (list)



-- TABLE

type Table info =
  Table  (Dict String info)

empty : Table info
empty =
  Table Dict.empty

fromList : List ( ArmyId, info ) -> Table info
fromList list =
  Table
    (
      (List.map
        (\(armyId,data) -> (armyId.id,data))
        list
      ) 
      |> Dict.fromList
    )

toList : Table info -> List ( ArmyId, info )
toList (Table dict) =
  List.map
    (\(string,data)->(ArmyId string, data))
    (Dict.toList dict)

get : ArmyId -> Table info -> Maybe info
get armyId (Table  dict) =
  Dict.get armyId.id dict

insert: ArmyId -> info -> Table info -> Table info
insert armyId newData (Table dict) =
  Table (Dict.insert armyId.id newData dict)

isEmpty: Table info -> Bool
isEmpty (Table dict) =
  Dict.isEmpty dict

remove: ArmyId -> Table info -> Table info
remove armyId (Table dict) =
  Table (Dict.remove armyId.id dict)

update: ArmyId  -> (Maybe info -> Maybe info) -> Table info -> Table info
update armyId changeFn (Table dict) =
  Table (Dict.update armyId.id changeFn dict)

values: Table info -> List info
values (Table dict) =
  Dict.values dict


-- add : info -> Table info -> (Table info, MeshweshTypes.ArmyId)
-- add info (Table nextId dict) =
--   ( Table (nextId + 1) (Dict.insert nextId info dict)
--   , Id nextId
--   )

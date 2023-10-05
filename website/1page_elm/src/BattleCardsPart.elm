module BattleCardsPart exposing (renderPart)
import LoadedData exposing (LoadedData)
import Html
import Html.Attributes
import BookParts
import MeshweshTypes exposing (BattleCard)
import Html.Parser
import Html.Parser.Util

renderBattleCard: BattleCard -> Html.Html msg
renderBattleCard battleCard =
    BookParts.chapter
        battleCard.displayName
        Nothing
        ( case (Html.Parser.run battleCard.htmlText) of
            Err _    -> []
            Ok nodes -> Html.Parser.Util.toVirtualDom nodes
        )

byName: BattleCard -> BattleCard -> Order
byName a b =
    compare
        (a.displayName)
        (b.displayName)

renderPart: LoadedData -> Html.Html msg
renderPart loadedData =
    BookParts.part
        "Battle Cards"
        (List.map renderBattleCard (List.sortWith byName loadedData.battleCards))

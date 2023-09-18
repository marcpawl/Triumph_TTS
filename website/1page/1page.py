#!/usr/bin/env python3


import html
import json
from typing import List, Optional
from xml.dom.minidom import getDOMImplementation, Element

from troop_type import troop_type_to_name


def battleCardCodeToName(battleCardCode: str) -> str:
    if battleCardCode == "CT" :
        return "Charge Through"
    if battleCardCode == "FC" :
        return "Fortified Camp"
    if battleCardCode == "HD" : 
        return 'Hoplite Deep Formation'
    if battleCardCode == "HL" :
        return "Hold the Line"
    if battleCardCode == "PT" :
        return "Pack Train"
    # TODO
    return battleCardCode



def readJson(path: str):
    with open(path, "r") as file:
        return json.load(file)

summary_data = readJson("../../fake_meshwesh/armyLists/summary.json")
army_data = readJson("../output/army_data.json")
armies_data = readJson("../output/armies_data.json")


def loadArmy(armyId) :
    return readJson("../../fake_meshwesh/armyLists/" + armyId + ".army.json")


def getArmySummary(armyName: str):
    return next(n for n in summary_data if n['name'] == armyName)


domimpl = getDOMImplementation()

doc = domimpl.createDocument(namespaceURI=None, qualifiedName="html", doctype=None)
html_element: Element = doc.documentElement
head = doc.createElement("head")
html_element.appendChild(head)
body = doc.createElement("body")
html_element.appendChild(body)

def toId(key: str) -> str:
    """Convert a key to a node id"""
    return html.escape(key)


def createThemes():
    themes = doc.createElement("span")
    themes.setAttribute("id", toId("themes"))
    body.appendChild(themes)
    title = doc.createElement("h1")
    themes.appendChild(title)
    titleText = doc.createTextNode("Thematic Categories")
    title.appendChild(titleText)
    description = doc.createTextNode(
        """Thematic categories are a way of grouping army lists that fit a 
        common period and broad geographic region. Many army lists belong to 
        more than one thematic category.""")
    themes.appendChild(description)
    
    themeNames = list(armies_data.keys())
    themeNames.sort()
    ul = doc.createElement("ul")
    themes.appendChild(ul)
    for themeName in themeNames:
        li = doc.createElement("li")
        themes.appendChild(li)
        anchor = doc.createElement("a")
        li.appendChild(anchor)
        anchor.setAttribute("href", "#" + toId("theme/" + themeName))
        theme_text = doc.createTextNode(themeName)
        li.appendChild(theme_text)

    for themeName in themeNames:
        themeSpanElement = doc.createElement("span")
        themes.appendChild(themeSpanElement)
        themeSpanElement.setAttribute("id", toId("theme/" + themeName ))
        themeHeader = doc.createElement("h2")
        themeSpanElement.appendChild(themeHeader)
        themeHeaderText = doc.createTextNode(themeName)
        themeHeader.appendChild(themeHeaderText)

        armyListsHeader = doc.createElement("h3")
        themeSpanElement.appendChild(armyListsHeader)
        armyListsHeaderText = doc.createTextNode("Army Lists")
        armyListsHeader.appendChild(armyListsHeaderText)
        
        armyListsList = doc.createElement("ul")
        themeSpanElement.appendChild(armyListsList)
        
        theme = armies_data[themeName]
        armyNames = list(theme.keys())
        armyNames.sort()
        for armyName in armyNames:
            armyListItem = doc.createElement("li")
            armyListsList.appendChild(armyListItem)

            armyAnchor = doc.createElement("a")
            armyListItem.appendChild(armyAnchor)
            armyAnchor.setAttribute("href", "#" + toId("army/" + armyName))

            armyNameText = doc.createTextNode(armyName)
            armyAnchor.appendChild(armyNameText)


def formatYear(year: int) -> str:
    if year < 0:
        return str(-year) + " BC"
    else:
        return str(year) + " AD"
    

def formatYearRange(startDate: int, endDate: Optional[int]) -> str:
    if startDate == endDate or (endDate is None):
        return formatYear(startDate)
    
    return f"{formatYear(startDate)} to {formatYear(endDate)}"


def formatDateRange(dateRange: Element) -> str:
    return formatYearRange(dateRange["startDate"], dateRange["endDate"])


def appendText(parent: Element, text):
    """ If the text is not None then add a new text node to parent.
    """
    if text is None:
        return
    textNode = doc.createTextNode(str(text))
    parent.appendChild(textNode)


def dateRange(parent: Element, startDate: int, endDate: int):
    date = doc.createElement("p")
    parent.appendChild(date)
    dateText = doc.createTextNode(formatYearRange(startDate, endDate))
    date.appendChild(dateText)


def createTableElement(parent: Element, title: str, data:List[List]):
    """Create a table elemnt.
    
    parent: Element to add new table element to.
    data: Rows of the table
    """
    titleElement = doc.createElement("p")
    parent.appendChild(titleElement)
    appendText(titleElement, title)

    tableElement = doc.createElement("table")
    parent.appendChild(tableElement)
    tableBodyElement = doc.createElement("tbody")
    tableElement.appendChild(tableBodyElement)

    for row in data:
        rowElement = doc.createElement("tr")
        tableBodyElement.appendChild(rowElement)
        for column in row:
            columnElement = doc.createElement("td")
            rowElement.appendChild(columnElement)
            appendText(columnElement, column)


def    invasionRatings(parent: Element, army):
    def extractRowData(invasionRating):
        return [ invasionRating['value'], invasionRating.get("note", None) ]
    data = map(extractRowData, army['invasionRatings'])
    createTableElement(parent, "Invasion Rating", data)


def    maneuverRatings(parent: Element, army):
    def extractRowData(maneuverRating):
        return [ maneuverRating['value'], maneuverRating.get("note", None) ]
    data = map(extractRowData, army['maneuverRatings'])
    createTableElement(parent, "Maneuver Rating", data)


def    homeTopography(parent: Element, army):
    def extractRowData(maneuverRating):
        values = ", ".join(maneuverRating['values'])
        return [ values, maneuverRating.get("note", None) ]
    data = map(extractRowData, army['homeTopographies'])
    createTableElement(parent, "Home Topography", data)


def troopEntriesForGeneral(parent: Element, army):
    data = []
    entriesForGeneral = army['troopEntriesForGeneral']
    index = 0
    for entries in entriesForGeneral:
        troopEntries = entries['troopEntries']
        codes = map(lambda troopEntry: troopEntry['troopTypeCode'], troopEntries)
        troopTypeNames = map(troop_type_to_name, codes)
        troopNameString = " or ".join(troopTypeNames)
        
        index = index + 1
        condition = None
        if len(entries) > 1:
            if index < len(entries):
                condition = "If Present"
            else:
                 condition = 'Otherwise'

        data.append( [condition, troopNameString])
    createTableElement(parent, "General's Troop Type", data)


def armyBattleCards(parent: Element, army):
    def battleCardToList(battleCardEntry):
        battleCardName = battleCardCodeToName(battleCardEntry['battleCardCode'])
        return [
            battleCardEntry.get("min", None),
            battleCardEntry.get("max", None),
            battleCardName, 
            battleCardEntry.get("note", None)]
    
    battleCardEntries = army["battleCardEntries"]
    if len(battleCardEntries) == 0:
        data = [ [ "None" ]]
    else:
        data = map(battleCardToList, battleCardEntries)
    createTableElement(parent, "Army Battle Cards", data)


def troopOptions(parent: Element, army):
    def tableHeaderColumn(row: Element, text):
        columnElement = doc.createElement("td")
        row.appendChild(columnElement)
        appendText(columnElement, text)

    def tableHeader(parent: Element, columns: List) -> Element:
        tableHeadElement = doc.createElement("thead")
        parent.appendChild(tableHeadElement)
        tableHeadRowElement = doc.createElement("tr")
        tableHeadElement.appendChild(tableHeadRowElement)
        for column in columns:
            tableHeaderColumn(tableHeadRowElement, column)
        return tableHeadElement

    troopOptionsElement = doc.createElement("h2")
    parent.appendChild(troopOptionsElement)
    appendText(troopOptionsElement, "Troop Options")

    requiredTroops = doc.createElement("h3")
    parent.appendChild(requiredTroops)
    appendText(requiredTroops, "Required Troops")

    tableElement = doc.createElement("table")
    parent.appendChild(tableElement)
    tableHeader(tableElement, ["Troop Types", "Min", "Max", "Battle Line", "Restrictions", "Battle Cards"])
    tableBodyElement = doc.createElement("tbody")
    tableElement.appendChild(tableBodyElement)

    troopOptions = army['troopOptions']
    for troopOption in troopOptions:
        tableRowElement = doc.createElement("tr")
        tableBodyElement.appendChild(tableRowElement)

        troopTypesElement = doc.createElement("td")
        tableRowElement.appendChild(troopTypesElement)

        minElement = doc.createElement("td")
        tableRowElement.appendChild(minElement)

        maxElement = doc.createElement("td")
        tableRowElement.appendChild(maxElement)

        battleLineElement = doc.createElement("td")
        tableRowElement.appendChild(battleLineElement)

        restrictionsElement = doc.createElement("td")
        tableRowElement.appendChild(restrictionsElement)

        battleCardsElement = doc.createElement("td")
        tableRowElement.appendChild(battleCardsElement)

        min = troopOption.get("min")
        appendText(minElement, min)

        max = troopOption.get("max")
        appendText(maxElement, max)

        battleLine = troopOption.get("core", "-")
        appendText(battleLineElement, battleLine)


        dateRanges = troopOption.get("dateRanges", None)
        if dateRanges is not None:
            dateRangesString = ", ".join(list(map(formatDateRange, dateRanges)))
            appendText(restrictionsElement, dateRangesString)

        troopEntries = troopOption['troopEntries']
        for troopEntry in troopEntries:
          troopEntryElement = doc.createElement("div")
          troopTypesElement.appendChild(troopEntryElement)
          troopEntryElement.setAttribute("class", "troopEntry")

          troopTypeElement = doc.createElement("div")
          troopTypeElement.setAttribute("class", "troopType")
          troopEntryElement.appendChild(troopTypeElement)
          troopTypeName = troop_type_to_name(troopEntry['troopTypeCode'])
          appendText(troopTypeElement, troopTypeName)

          if troopEntry['dismountTypeCode'] is not None and len(troopEntry['dismountTypeCode']) > 0:
              dismountTroopTypeName = troop_type_to_name(troopEntry['dismountTypeCode'])
              dismountTroopTypeElement = doc.createElement("div")
              troopTypeElement.appendChild(dismountTroopTypeElement)
              dismountTroopTypeElement.setAttribute("class", "dismountTroopType")
              appendText(dismountTroopTypeElement, "dismounts as " + dismountTroopTypeName)

          if troopEntry['note'] is not None and len(troopEntry['note']) > 0:
              noteElement = doc.createElement("div")
              troopTypeElement.appendChild(noteElement)
              noteElement.setAttribute("class", "note")
              appendText(noteElement, troopEntry['note'])

        if troopOption['description'] is not None and len(troopOption['description']) > 0:
            descriptionElement = doc.createElement("div")
            troopTypeElement.appendChild(descriptionElement)
            descriptionElement.setAttribute("class", "description")
            appendText(descriptionElement, troopOption['description'])


def createArmy(parent: Element, armyName: str):
    armySummary = getArmySummary(armyName)
    derivedData = armySummary["derivedData"]
    armyId = armySummary['id']

    armySpan = doc.createElement("span")
    parent.appendChild(armySpan)
    armySpan.setAttribute("id", toId("army/" + derivedData["extendedName"]))

    nameHeader = doc.createElement("h1")
    armySpan.appendChild(nameHeader)

    nameText = doc.createTextNode(armyName)
    nameHeader.appendChild(nameText)

    dateRange(armySpan, derivedData["listStartDate"], derivedData['listEndDate'])

    army = loadArmy(armyId)

    invasionRatings(armySpan, army)
    maneuverRatings(armySpan, army)
    homeTopography(armySpan, army)
    troopEntriesForGeneral(armySpan, army)
    armyBattleCards(armySpan, army)
    troopOptions(armySpan, army)
    # TODO Optional Contingents
    # TODO Ally Troop Options
    # TODO Enemies
    # TODO Related Army Lists
    # TODO Thematic Categories


def createArmies():
    armyNames = list(map( lambda army : army['name'], summary_data))
    armyNames.sort()
    for armyName in armyNames:
        createArmy(body, armyName)

        
createThemes()
createArmies()


with open("output/index.html", "w", encoding="utf-8") as output:
    doc.writexml(writer=output, encoding="utf-8", addindent="  ")

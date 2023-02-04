#!/usr/bin/env python3

import json
import libxml2
import sys


text_bottom_margin = 15 - 13.857281
icon_bottom_margin = 15 - 9.5093451

def make_svg(color:str, troop_name: str, troop_data: dict):
    svg_file_name = (color + "_" + troop_name + ".svg").lower().replace(' ','_')
    icon_file_name = f"../icons/{troop_name.lower().replace(' ','_')}.png"
    doc = libxml2.parseFile("drawing.svg")
    ctxt = doc.xpathNewContext()
    ctxt.xpathRegisterNs("svg", "http://www.w3.org/2000/svg")
    ctxt.xpathRegisterNs("sodipodi", "http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd")
    ctxt.xpathRegisterNs("inkscape", "http://www.inkscape.org/namespaces/inkscape")
    ctxt.xpathRegisterNs("xmlns:xlink", "http://www.w3.org/1999/xlink")
    res = ctxt.xpathEval("/svg:svg")
    svg = res[0]
    svg.setProp("height", f"{troop_data['base_depth']}mm")
    svg.setProp("viewBox", f"0 0 40 {troop_data['base_depth']}")
    svg.setProp("sodipodi:docname", svg_file_name)
    res = ctxt.xpathEval("//svg:rect[@inkscape:label='background']")
    rect = res[0]
    rect.setProp("height", str(troop_data['base_depth']))
    res = ctxt.xpathEval("//svg:rect[@inkscape:label='general outside']")
    rect = res[0]
    rect.setProp("height", str(troop_data['base_depth']))
    res = ctxt.xpathEval("//svg:rect[@inkscape:label='general inside']")
    rect = res[0]
    # 0.5mm width of general decoration
    rect.setProp("height", str(troop_data['base_depth'] - 1))

    # Replace the text
    text_y = str(troop_data['base_depth'] - text_bottom_margin)
    res = ctxt.xpathEval("//svg:text[@inkscape:label='troop type']")
    text = res[0]
    text.setProp("y", text_y)

    res = ctxt.xpathEval("//svg:text[@inkscape:label='troop type']/svg:tspan")
    tspan = res[0]
    tspan.setContent(troop_name)

    res = ctxt.xpathEval("//svg:text[@inkscape:label='combat factors']")
    text = res[0]
    text.setProp("y", text_y)

    res = ctxt.xpathEval("//svg:text[@inkscape:label='combat factors']/svg:tspan/svg:tspan")
    tspan_movement = res[0]
    tspan_movement.setContent(f"{troop_data['tactical_move_distance']}MU")
    tspan.setContent(troop_name)
    res = ctxt.xpathEval("//svg:text[@inkscape:label='combat factors']/svg:tspan")
    tspan_combat = res[0]
    combat = f" {troop_data['combat_factor_vs_foot']}/{troop_data['combat_factor_vs_mounted']}"
    tspan_combat.setContent(combat)

    # Replace the icon
    res = ctxt.xpathEval("//svg:image[@inkscape:label='icon']")
    image = res[0]
    image.setProp("sodipodi:absref", icon_file_name)
    image.setProp("xlink:href", icon_file_name)
    image.setProp("preserveAspectRatio", "xMidYMid")
    image.setProp("height", str(troop_data["base_depth"] - icon_bottom_margin));

    doc.saveFileEnc(svg_file_name, "UTF-8")
    doc.freeDoc()
    ctxt.xpathFreeContext()


with open("data.json", "r") as data_file:
    data = json.load(data_file)
    for type in data:
        if type not in ["Camp", 'Elephant Screen Counter']:
            make_svg("red", type, data[type])


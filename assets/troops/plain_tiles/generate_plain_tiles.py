#!/usr/bin/env python3

import json
import libxml2
import numbers
import pathlib
import subprocess


text_bottom_margin = 15 - 13.857281
icon_bottom_margin = 15 - 9.5093451

with open("data.json", "r") as data_file:
    base_tool_tips = json.load(data_file)
    for troop_type in base_tool_tips:
        # Add the key as a data field to make processing easier
        base_tool_tips[troop_type]['troop_type'] = troop_type

plain_army = {}

base_definitions = {}
base_definitions["camp"]={
  "id":"camp",
  "name":'Camp',
  "min":0,
  "max":1,
  "description":'Camp',
  "troop_type":"Camp",
}
base_definitions["camp_fortified"]={
  "id":"camp_fortified",
  "name":'Camp',
  "min":0,
  "max":1,
  "description":'Fortified Camp',
  "fortified_camp":True,
  "troop_type":"Camp",
}
base_definitions["camp_pack_train"]={
  "id":"camp_pack_train",
  "name":'Camp',
  "min":0,
  "max":1,
  "description":'Pack Train',
  "pack_train":True,
  "troop_type":"Camp",
}

base_definitions["prepared_defenses"]={
  "id":"prepared_defenses",
  "name":"Prepared Defenses",
  "min":0,
  "max":1,
  "description":'',
  "prepared_defenses": True,
  "troop_type":"Prepared Defenses",
}

plain_army[ 'camp' ] = base_definitions['camp']
plain_army[ 'camp_fortified' ] = base_definitions['camp_fortified']
plain_army[ 'camp_pack_train' ] = base_definitions['camp_pack_train']
plain_army[ 'prepared_defenses' ] = base_definitions['prepared_defenses']


def is_camp(troop_data: dict) -> bool:
    if not 'is_camp' in troop_data:
        return False
    return troop_data['is_camp']


def is_foot(troop_data: dict) -> bool:
    if 'open_order_foot' in troop_data:
        return True
    if 'close_order_foot' in troop_data:
        return True
    return False

def get_color_code(color):
    if color == "red":
        return "#b52327"
    if color == "orange":
        return "#E9900C"
    if color == "yellow":
        return "#DDFF00"
    if color == "blue":
        return "#235db5"
    if color == "green":
        return "#21C51B"
    if color == "purple":
        return "#641EB3"

    raise Exception("Unexpected color")

def change_fill(elem, color:str):
    color_code = get_color_code(color)
    style = elem.prop("style")
    new_style = ""
    for part in style.split(";"):
        name,value = part.split(":")
        if name != "fill":
            new_style = new_style + name + ":" + value + ";"
        else:
            new_style = new_style + name + ":" + color_code + ";"
    new_style = new_style[:-1]
    elem.setProp("style", new_style)

def calc_code_name(troop_name: str, general: bool, mobile_infantry: bool) :
    if general:
        general_file_name = "_general"
    else:
        general_file_name = ""
    mobile_infantry_file_name = ""
    if mobile_infantry:
        mobile_infantry_file_name = "_mi"
    code_name = (f"{troop_name}{general_file_name}{mobile_infantry_file_name}").lower().replace(' ','_')
    return code_name

def calc_code_name_from_definition(base_definition: dict) :
    general = 'general' in base_definition and base_definition['general']
    mobile_infantry = 'mobile_infantry' in base_definition and base_definition['mobile_infantry']
    return calc_code_name(troop_name=base_definition['troop_type'], general=general, mobile_infantry=mobile_infantry)

def calc_tile_name(base_definition: dict) :
    tile_name = "tile_plain_" 
    tile_name = tile_name + base_definition['troop_type']
    if 'general' in base_definition and base_definition['general']:
        tile_name = tile_name + "_Gen"
    if 'mobile_infantry' in base_definition and base_definition['mobile_infantry']:
        tile_name = tile_name + "_MI"
    tile_name = tile_name.replace(' ', '_')
    return tile_name

def write_tile(output, base_definition: dict):
    troop_type = base_definition['troop_type']
    if troop_type == "Prepared Defenses":
        # No tile is generated, the tile is predefined
        return
    tool_tips = base_tool_tips[ troop_type]
    if 'base_depth' not in tool_tips:
        return
    base_depth = tool_tips['base_depth']
    if 'mobile_infantry' in base_definition and base_definition['mobile_infantry']:
        base_depth = 40
    base_width = 80 if is_camp(tool_tips) else 40

    tile_name = calc_tile_name(base_definition)
    description = base_definition['troop_type']
    if 'general' in base_definition and base_definition['general']:
        description = description + " General"
    if 'mobile_infantry' in base_definition and base_definition['mobile_infantry']:
        description = description + " Mobile Infrantry"
    description = description + " Tile"
    author = 'Plain tile, original work by Arkein (model) and Rod (texture), using troop icon from Lorenzo Moro, modified by Marc.'
    mesh = f"g_assets['dir'] .. 'troops/plain_tiles/tile_{base_width}_{base_depth}.obj'"
    code_name = calc_code_name_from_definition(base_definition)
    red_tex = f"g_assets['dir'] .. 'troops/plain_tiles/red_{code_name}.png'"
    orange_tex = f"g_assets['dir'] .. 'troops/plain_tiles/orange_{code_name}.png'"
    yellow_tex = f"g_assets['dir'] .. 'troops/plain_tiles/yellow_{code_name}.png'"
    blue_tex = f"g_assets['dir'] .. 'troops/plain_tiles/blue_{code_name}.png'"
    green_tex = f"g_assets['dir'] .. 'troops/plain_tiles/green_{code_name}.png'"
    purple_tex = f"g_assets['dir'] .. 'troops/plain_tiles/purple_{code_name}.png'"

    output.write(f"""
{tile_name} = {{
  height_correction = 0,
  scale = 1,
  rotation = 0,
  depth = {base_depth},
  width = {base_width},
  description = '{description}',
  author = '{author}',
  mesh = {{ {mesh}, }},
  player_red_tex = {red_tex},
  player_orange_tex = {orange_tex},
  player_yellow_tex = {yellow_tex},
  player_blue_tex = {blue_tex},
  player_green_tex = {green_tex},
  player_purple_tex = {purple_tex},
}}
""")


def make_base_definition(general: bool, troop_name: str, troop_data: dict, mobile_infantry: bool):
    code_name = calc_code_name(troop_name=troop_name, general=general, mobile_infantry=mobile_infantry)

    # Record the plain tile for the plain army
    global plain_army
    global base_definitions
    if code_name not in base_definitions:
        base_definition_name = troop_name
        if general:
            base_definition_name = base_definition_name + " General"
        base_definitions[code_name]={
            'id':code_name,
            'name':base_definition_name,
            'min':0,
            'max':1,
            'description':'',
            'troop_type':troop_name,
            'troop_option_id':"plain_base",
        }
        if mobile_infantry:
            base_definitions[code_name]['mobile_infantry'] = True
            dismount_code_name = calc_code_name(troop_name=troop_name, general=general, mobile_infantry=False)
            base_definitions[code_name]['dismount_as'] = dismount_code_name
        if general:
            base_definitions[code_name]['general'] =True
        plain_army[ code_name ] = base_definitions[code_name]


def make_svg(color:str, general: bool, troop_name: str, troop_data: dict, mobile_infantry: bool):
    code_name = calc_code_name(troop_name=troop_name, general=general, mobile_infantry=mobile_infantry)
    
    name_suffix = ""
    base_depth = troop_data['base_depth'] if 'base_depth' in troop_data else 40
    base_width = 40 if not is_camp(troop_data) else 80
    y_adjustment = 0
    movement_rate = troop_data['tactical_move_distance'] if 'tactical_move_distance' in troop_data else None
    if mobile_infantry:
        base_depth = 40
        y_adjustment = (troop_data['base_depth'] - base_depth) / 2.0
        movement_rate = 6
        name_suffix = name_suffix + " MI"

    svg_file_name = f"{color}_{code_name}.svg"
    png_file_name = svg_file_name[:-3] + "png"
    icon_file_name = f"../icons/{troop_name.lower().replace(' ','_')}.png"
    icon_path = pathlib.Path(icon_file_name)
    if not icon_path.exists():
        raise Exception("Icon missing: " + icon_file_name)
    doc = libxml2.parseFile("drawing.svg")
    ctxt = doc.xpathNewContext()
    ctxt.xpathRegisterNs("svg", "http://www.w3.org/2000/svg")
    ctxt.xpathRegisterNs("sodipodi", "http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd")
    ctxt.xpathRegisterNs("inkscape", "http://www.inkscape.org/namespaces/inkscape")
    ctxt.xpathRegisterNs("xmlns:xlink", "http://www.w3.org/1999/xlink")
    res = ctxt.xpathEval("/svg:svg")
    svg = res[0]
    svg.setProp("height", f"{base_depth}mm")
    svg.setProp("width", f"{base_width}mm")
    svg.setProp("viewBox", f"0 0 {base_width} {base_depth}")
    svg.setProp("sodipodi:docname", svg_file_name)
    
    res = ctxt.xpathEval("//svg:rect[@inkscape:label='background']")
    background = res[0]
    background.setProp("height", str(base_depth))
    background.setProp("width", str(base_width))
    change_fill(background, color)

    res = ctxt.xpathEval("//svg:rect[@inkscape:label='background_edges']")
    background = res[0]
    background.setProp("height", str(base_depth))
    background.setProp("width", str(base_width))

    res = ctxt.xpathEval("//svg:rect[@inkscape:label='general outside']")
    rect = res[0]
    if not general:
        rect.unlinkNode()
    else:
         rect.setProp("y", str(base_depth - 3.9))

    # res = ctxt.xpathEval("//svg:rect[@inkscape:label='general inside']")
    # rect = res[0]
    # if not general:
    #     rect.unlinkNode()
    # else:
    #     # 0.5mm width of general decoration
    #     rect.setProp("height", str(base_depth - 1))
    #     change_fill(rect, color)

    # Replace the text
    text_y = str(base_depth - text_bottom_margin)
    res = ctxt.xpathEval("//svg:text[@inkscape:label='troop type']")
    text = res[0]
    text.setProp("y", text_y)

    # Set the troop type
    res = ctxt.xpathEval("//svg:text[@inkscape:label='troop type']/svg:tspan")
    tspan = res[0]
    name = f"{troop_name}{name_suffix}"
    tspan.setContent(name)

    res = ctxt.xpathEval("//svg:text[@inkscape:label='combat factors']")
    text = res[0]
    text.setProp("y", text_y)

    # Set the combat factors text
    res = ctxt.xpathEval("//svg:text[@inkscape:label='combat factors']/svg:tspan/text()")
    text_combat = res[0]
    foot_cf = troop_data['combat_factor_vs_foot']
    mounted_cf = troop_data['combat_factor_vs_mounted']
    # Uncomment to include the generals +1
    # if general:
    #     foot_cf = foot_cf + 1
    #     mounted_cf = mounted_cf + 1
    combat = f" +{foot_cf}/+{mounted_cf}"
    text_combat.setContent(combat)
    # Adjust position for wide bases
    x_pos = base_width - (40 - float(text_combat.parent.prop('x')))
    text_combat.parent.setProp("x", str(x_pos))
    text_combat.parent.parent.setProp("x", str(x_pos))

    # Set the movement rate
    res = ctxt.xpathEval("//svg:text[@inkscape:label='combat factors']/svg:tspan/svg:tspan")
    tspan_movement = res[0]
    if movement_rate is None:
        tspan_movement.unlinkNode()
    else:
        tspan_movement.setContent(f"{movement_rate}MU")

    # Replace the icon
    res = ctxt.xpathEval("//svg:image[@inkscape:label='icon']")
    image = res[0]
    image.setProp("sodipodi:absref", icon_file_name)
    image.setProp("xlink:href", icon_file_name)
    image.setProp("preserveAspectRatio", "xMidYMid")
    image_area_height = base_depth - icon_bottom_margin
    image.setProp("height", str(image_area_height));
    image.setProp("width", str(base_width));
    if mobile_infantry:
        mi_icon_file_name = "../icons/mobileinf.png"
        print(mi_icon_file_name)
        mi_image = image.copyNode(True)
        mi_image.setProp("sodipodi:absref", mi_icon_file_name)
        mi_image.setProp("xlink:href", mi_icon_file_name)
        mi_image.setProp("inkscape:label", "mi_icon")
        mi_icon_height = 0.25 * image_area_height
        icon_height = image_area_height - mi_icon_height
        image.setProp("height", str(icon_height));
        old_image_y = float(image.prop('y'))
        new_image_y = str(old_image_y + mi_icon_height)
        image.setProp("y", new_image_y)
        mi_image.setProp("height", str(mi_icon_height));
        image.addNextSibling(mi_image)

    # # Adjust the y-position for mobile infrantry
    # if mobile_infantry:
    #     res = ctxt.xpathEval("/svg:svg/svg:g//*['y']")
    #     for node in res:
    #         old_y = node.prop('y')
    #         if old_y is not None:
    #             new_y = str(float(old_y) + y_adjustment)
    #             node.setProp('y', new_y)

    doc.saveFileEnc(svg_file_name, "UTF-8")
    doc.freeDoc()
    ctxt.xpathFreeContext()

    # Convert SVG to PNG
    cmd = ['/cygdrive/c/Program Files/Inkscape/inkscape.exe',  
        '--without-gui',
        '-w', str(22 * base_width), '-h', str(22 * base_depth),
        '-f', svg_file_name, 
        '-e', png_file_name]
    subprocess.check_call(cmd)

    # Record the plain tile for the plain army
    if code_name not in base_definitions:
        base_definition_name = troop_name
        if general:
            base_definition_name = base_definition_name + " General"
        base_definitions[code_name]={
            'id':code_name,
            'name':base_definition_name,
            'min':0,
            'max':1,
            'description':'',
            'troop_type':troop_name,
            'troop_option_id':"plain_base",
        }
        if mobile_infantry:
            base_definitions[code_name]['mobile_infantry'] = True
            dismount_code_name = calc_code_name(troop_name=troop_name, general=general, mobile_infantry=False)
            base_definitions[code_name]['dismount_as'] = dismount_code_name
        if general:
            base_definitions[code_name]['general'] =True
        plain_army[ code_name ] = base_definitions[code_name]


def make_base_definitions(data):
    for type in data:
        if type not in ["Camp",  'Elephant Screen Counter']:
            troop_data = data[type]
            generals = [False] if is_camp(troop_data) else [False, True]
            for general in generals:
                make_base_definition(general=general, troop_name=type, troop_data=troop_data,  mobile_infantry=False)
                if is_foot(troop_data) and type not in ["War Wagons"]:
                    make_base_definition(general=general, troop_name=type, troop_data=data[type], mobile_infantry=True)


def make_svgs(base_tool_tip: dict):
    generals = [False] if is_camp(base_tool_tip) else [False, True]
    for color in ['red', 'orange', 'yellow', 'blue', 'green', 'purple'] :
        for general in generals:
            make_svg(color, general, type, base_tool_tip, mobile_infantry=False)
            if is_foot(base_tool_tip):
                if base_tool_tip['troop_type'] not in ["War Wagons"]:
                    make_svg(color, general, type, base_tool_tip, mobile_infantry=True)


def write_base_definition(data_file, key) :
    data_file.write(f"g_base_definitions['{key}']={{\n")
    for k in base_definitions[key]:
        value = base_definitions[key][k]
        if isinstance(value, bool):
            if value :
                value = "true"
            else:
                value = "false"
            data_file.write(f'  {k}={value},\n')
        elif isinstance(value, numbers.Number):
            data_file.write(f'  {k}={value},\n')
        else:
            data_file.write(f'  {k}="{value}",\n')
    data_file.write("}\n\n")
    

make_base_definitions(base_tool_tips)
for type in base_tool_tips:
    if type not in ["Camp", 'Elephant Screen Counter']:
        make_svgs(base_tool_tips[type])    

with open("plain_army.ttslua", "w") as data_file:
    data_file.write("""
-- GENERATED FILE
-- DO NOT EDIT
-- see generate_plain_tiles.py

require("Triumph_TTS/scripts/static_maps")
""")
    # Write out the plain tiles
    keys = sorted(base_definitions.keys())
    for key in keys:
        write_tile(data_file, base_definitions[key])

    data_file.write("""
troop_options['plain_base'] = {
  min=0,
  max=1,
  dateRange={
    startDate=-5000,
    endDate=5000,
  }
}
""")
    for key in base_definitions:
        write_base_definition(data_file=data_file, key=key)

    data_file.write("""
army['plain_army']={
  data={
    invasionRatings={
      0,
      1,
      2,
      3,
      4,
      5,
    },
    maneuverRatings={
      0,
      1,
      2,
      3,
      4,
      5,
    },
    homeTopographies = {
      'Ariable',
      'Forest',
      'Hilly',
      'Dry',
      'Steepe',
      'Delta',
      'Marsh',
    },
    name = ' Plain Bases',
    id = 'plain_army',
    dateRange = {
      startDate = -5000,
      endDate = 5000,
    },
  },
""")
    for key in plain_army:
        data_file.write(f"  g_base_definitions['{key}'],\n")
    data_file.write("}\n\n")
    data_file.write("""
army['plain_army_ally_plain_army'] = army["plain_army"]
allies['plain_army'] = {
  {
    id='plain_army',
    dateRange={startDate=-50000, endDate=50000}
  }
}

armies["All"][army["plain_army"].data.name] = army["plain_army"]
army_dates["plain_army"] = {}
army_dates["plain_army"]["5000 BC to 5000 AD"] = {
  startDate=-5000,
  endDate=5000
}

""")

# Adding Troops

Troops are the renderings for one more figures.  Having individual
figures gives the most opportunities to reuse it in different contexts.

The definitions are in the file  [scripts\data\data_troops.ttslua](scripts\data\data_troops.ttslua)

Example definition:

```
troop_gallic_ps_javelin = {
    height_correction = 0,
    scale = 0.9,
    rotation = 180,
    description = 'Gallic Psiloi',
    author = 'Gallic Psiloi by Eric Delemer.',
    mesh = {
          'http://cloud-3.steamusercontent.com/ugc/1667984827364988467/F0DF6DDC93B933631E89B39659E8C9401D9845CA/'
    },
    player_red_tex = 'http://cloud-3.steamusercontent.com/ugc/1667984827364988092/B2B37D6B20584DDA7245EEF9409943155D4F8B9B/',
    player_blue_tex = 'http://cloud-3.steamusercontent.com/ugc/1667984827364988092/B2B37D6B20584DDA7245EEF9409943155D4F8B9B/',
}
```

## Fields

height_correction: TODO

scale: Ratio to shrink or grow the object.

rotation: Degrees to rotate the object.

description: Used to describe the object when placing on the table.

author: Give credit to the person that provided the object when placing on 
the table.

mesh: URL to OBJ file used by Tabletop Simulator.

player_red_tex: URL to PNG Texture use for the red player.

player_blue_tex: PNG Texture use for the blue player.

Two different textures are used so the the OBJ can look different for each
player, for example red vs blue shields.

## URL's

Meshes and Texture URL's should be to this project in Github or to
Steam, Github is preferred stored in the assets/troops directory.
We have lost files that were in other cloud services.

[saves/clean_save](saves/clean_save) will automatically adjust the assets
to use the github for assets the refer to the assets directory.  Execute
the command

```saves/clean_save --force-local```

You will get the URL prefix for the files in the assets directory.


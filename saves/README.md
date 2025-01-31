
Copying Saved Game
==================

To put the game into TTS so you can run it

./to_tts 
or
cp *.json  *.png ~/My\ Documents/My\ Games/Tabletop\ Simulator/Saves/

You may have to create a symbolic link for "My Documents" in  your
home directory.

from_tts uses TS_Save_1.* as the file to copy into the current directory.

Split Save
==========

Takes the saved game and extracts the objects so you can work on them.
Also makes it easier to see what TTS changed if you create a new save
file in TTS.

./split_save

Clean Save
==========

Updates the save file to contain the latest source.

.ttslu files, main.xml are copied into the save file.
The objects that have been extracted from split_save are used as the source for updating.

The Lua script is modified with the current date unless the --no-date option is used.

Cleaning will remove extra data that should not be part 
of a game that is in the store.

Examples:
  ./clean_save --no-date

If there are any modifications on the file system that have not pushed to Github then
assets are referenced by a URL to the file system.  Otherwise assets are referenced
with URL on Github.

The version of TS_Save_1.json that has no assets referencing the file system may be 
uploaded to Steam.


to_tts
======

To get a saved game from TTS into the correct directory for working on it:

./from_tts
or
cp ~/My\ Documents/My\ Games/Tabletop\ Simulator/Saves/TS_Save_1.* .


workflow
========

When working on files other than source
---------------------------------------

git restore TS_Save_1.json && ./clean_save && to_save

If you are working on assets, you should disable mod-caching in TTS.
In TTS load game 1.

When working in TTS
-------------------

./from_tts && ./split_save

Perform a git restore on the files that should not be 
changed.  One common change is that TTS slightly moves objects around. You want
to reduce the scope of the change to make it clear in the history what has been done.

Check that the files build for TTS with:

git restore TS_Save_1.json && ./clean_save && to_save

assets/assets.ttslua
====================

Images and meshes that are in the assets directory should be listed in
assets/assets.ttslua

clean_save will walk through the file and change the URL to the file system
or github.  The file system is used if there are files that have yet to
be pushed to github.

You can modify the file and then use "Save and  Play" in Atom.  The file's
table is accessed in lua by the variable g_assets.

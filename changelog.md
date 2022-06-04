# Changelog

## v58

### Features

- Add support for passing the difficulty via the commandline (192d05)

### Bug fixes

- Improve co-op init file (#97)
    Fixes the 'missing map on launch' problem, adds support for custom strategic icons and in general
    improves the init file to be more informative about what is (not) going on

- Set correct number of available (player) slots for the client (56b650)

### Contributors

- Jip (#97)
- speed2 (192d05, 56b650)

## v57 (February 23rd, 2020)
- Added a new option for common army, where all players will control a single army.
- Fixed timed expansions settings not being saved.
- Ingame menu button to display objectives renamed from "Scenario" to "Objectives".

### Constributors
- KionX
- speed2

## v56 (October 27th, 2019)
- Remove AI autofill option from the lobby.
- Hide AI replacement option from the lobby.
- Fix line endings.

### Contributors
- Downlord
- speed2

## v55 (January 12th, 2018)
- New lobby option to disable timed expansion.

### Contributors
- speed2

## v54 (December 21th, 2017)
- Hotfix for broken Capture objectives.

### Contributors
- speed2

## v53 (December 20th, 2017)
- Fixed wrong mountpoints causing coop to not work in Downlord's client.
- New functions to prevent giving objective units to other player (giving them was breaking some missions).
- Better splitting of unit cap among all players.
- Default share condition changed to Full share.

### Contributors
- axel12
- speed2

## v52 (September 28th, 2017)
- Fixed syntax error in mod_info.lua.
- Added helper fuctions for random events and refreshing unit restrictions.

### Contributors
- Downlord
- speed2

## v51 (August 15th, 2017)
- Fixed more mixes dialogues.
- Added support for naval rally points to be used.

### Improvements integrated in FAF patch
- Added a new way of creating naval attacks for future use.
- Added several new land platoons for AI.
- Bonus objectives are now properly hidden.
- Fixed code for making player's units not take damage during cinematics to affect all human players.
- Added better control of AIs platoon sizes to allow more variety in attacks.
- Base manager can now operate with TMLs.

## v50 (May 17th, 2017)
- Fixed mixes dialogue cues in UEF and Cybran campaigns.

### Contributors
- ExoticRetard
- speed2

## v49 (May 14th, 2017)
- Seraphim Destroyers on initial patrols will surface now.
- Added a button into the menu to open a transmission log (contains all played VOs).
- Lobby defaults on the first FA mission if the last scenario is invalid (for mission developers).
- Added translations of vanilla missions.

- Voices from vanilla missions got compressed to 1/4 of their original size.
- Added movies to the vanilla missions. This fixes the desync when some players didn't have linked vanilla supcom.

### Improvements integrated in FAF patch
- Fixes desync during mid game cinematics (camera on a dying ACU or a killed base).
- Added new objective type: bonus. Bonus objectives will get added into all missions, they will be hidden until completed.
- Later completing bonus objectives will unlock achievements.
- Scenario info now works and shows objective overview. https://puu.sh/vOE0s/1ce1d52f41.png
- Added transmission log. https://puu.sh/vODZm/53b53c487d.png
- Both can be accessed via main menu. https://puu.sh/vODVM/dfdf861169.png
- Objectives on the score screen now have a tooltip with their description.
- Captured units no longer disappear.
- Restricted units can be repaired now.
- Objective tooltip now changes colour according to the theme the player is using.
- Ally nuke pings are no longer displayed during cinematics.
- Fixes some AI templates.
- Kill or Capture objective has it's own icon now. https://puu.sh/vtw2X/5fc2f020d7.png

### Contributors
- Keyblue
- speed2

## v48 (February 11th, 2017)
- Removed unnecessary options from the lobby.
- Small code improvements

### Contributors
- KeyBlue
- speed2

## v47 (November 14th, 2016)
- Game lobby now uses markers instead of ACUs to determine the starting positions on the map preview. It should load all maps faster when entering the lobby.
- Fixed typo causing some attacks not work.

### Contributors
- KeyBlue

## v46 (November 2nd, 2016)
- Added support for any number of players (no mission uses more than 4 yet).
- Added support for displaying announcements to the players.
- Map filters in the lobby are now ignored. That was causing some missions not showing up in the list.
- Improved trigger functions to work with all players.

### Contributors
- speed2
- KeyBlue

## v45 (September 1st, 2016)
- Added new build condition that works with more armies at once.

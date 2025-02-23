# Oxygen

Mission scripting is one of the most hard part of making coop mission.
It has its own stages and parts that decide mission flow.
Currently there is only one way of scripting mission in coop. It is using ingame **Scenario Framework** and its dependencies.
However, it has so many problems in root that make scripting more pain than joy.

Oxygen is a Framework that solves this problem and improves some aspects of mission scripting.
These are main parts that form coop mission.

## Objectives and their management

As I mentioned before each mission is a bunch of sequential objectives of different types, such as:

* Kill specific unit
* Kill units in area
* Capture unit
* Reclaim unit
* Build specific unit
* Protect units
* Locating units
* Timer
* Damage unit on required value (by Oxygen)

There can be added more as I did for Damaging unit, but rn objectives are pure trash in their implementation.
To reduce communication with old framework Oxygen provides with **Objective Builder** and **Objective Manager**.

Objective Builder simplifies creation of objective to be loaded then with Objective Manager.

```lua

local objectives = Oxygen.ObjectiveManager()
local objectiveBuilder = Oxygen.ObjectiveBuilder()


objectives:Init
{
objectiveBuilder
  :New "objective1" --name of objective to be called then with ObjectiveManager
  :Title "your title" -- title that player will see in UI
  :Description [[
    description of objective
    ]] -- description that player will see in UI
  :To(Oxygen.Objective.Kill) -- class of the objective that will be instantiated and will receive Target
  :Target
  {
    ... -- arguments for objective (annotated)
  }
  :OnStart(function()
    ... -- function that will be called before objective is assigned and actually started, can return table with arguments for Target (useful when specific unit required for objective)
  end)
  :OnSuccess(function()
   ... -- function that is called when objective is successfully complete
  end)
  :OnFail(function()
    ... -- function that is called when objective is failed (optional)
  end)
  :Next "objective2" -- objective that is started after success of this one (optional)
  :Create(),
  ...
}

```

I won't provide how this looks in base game because I dont want to hurt your eyes :P

After objectives were initialized they can be started:

```lua
objectives:Start "objective1"
```

When mission can be ended at success or fail:

```lua
 objectives:EndGame(true) -- success
    ...
 objectives:EndGame(false) -- fail
```

And **Objective Manager** will automatically assemble all data for primary, secondary and bonus objectives to be then displayed in UI.

## Cinematics

During start or end of objectives players must be notified about next ones with some kind of message quickly briefing then about it.
After mission is complete and new one starts players can be notified with dialog appearing briefing them.
Also we can make cutscene showing objective targets during which players cant do any input: NIS mode.
This is useful to create immersive shots of battles and enemy units moving towards players.

Oxygen Cinematics kicks in:

```lua
local OC = Oxygen.Cinematics
...
-- During NIS mode players cant do any input and black bars appear on top and bottom.
-- We can also pass in areas where units will become invulnerable during cutscene.
OC.NISMode(function()

    -- Position camera with marker defined on map
    OC.MoveTo("Cam1", 0)

    -- Create dialog where nice man tells you about objective (there are lots of examples in other missions,
    -- most important here that we can create our own provided with mission, but it isnt easy process since game is really old)
    ScenarioFramework.Dialogue( {{
            text = '[HQ]: <something describing mission>',
            vid = 'video.sfd',
            bank = 'wolf',
            cue = 'corre',
            faction = 'Cybran'
        }}, nil, true)
    
    -- waiting a bit
    WaitSeconds(2)

    -- we can display some text, but as I tried to make it bigger, it would crash game
    -- UI 4 Sim is better which I'll show later (UI 4 Sim allows you create custom UI for map which is synced)
    OC.DisplayText("Global\nWarning", 12, 'ffffffff', 'center', 1)

    -- moving camera to other position for 2,5 seconds
    OC.MoveTo("Cam3", 2.5)
    WaitSeconds(2.5)

    -- creating vision at enemy base just to show how dangerous it is
    -- it will be hidden after NIS mode ends leaving no icons ('true' flag)
    OC.VisionAtLocation("MainBase_M", 60, Brains.Player1):DestroyOnExit(true)

    -- and so on...
    OC.MoveTo("BaseCam1", 3)
    OC.MoveTo("BaseCam2", 1)
    OC.MoveTo("Cam3", 4)

end, {"BattleField1", "BattleField2"})

```

There are lots of possibilities for phase between objectives:

* expanding map and loading new bases
* creating attacking units defined on map and  giving them orders
* setting up objective's targets

But let's do players' setup since we need those as well.

## Players

Oxygen provides with **PlayersManager** which simplifies process of setting up players and spawning em, however, it also
cuts some certain advanced options, but for our purposes this will fit extremely well.

```lua
local playersManager = Oxygen.PlayersManager()

...

playersData = playersManager:Init
 {
    -- name of each upgrade is annotated, so, you dont need to 
    -- learn each to set. But dont forget that not all upgrades may fit in the same slot.
    -- Setting up upgrades for all players:
    -- the returned value is data per player, it has as many entries as there are players in lobby
  enhancements = {`
    Aeon = {
        "AdvancedEngineering",
        "T3Engineering",
        "ResourceAllocation",
        "ResourceAllocationAdvanced",
        "EnhancedSensors"
    },
    Cybran = {
        "AdvancedEngineering",
        "T3Engineering",
        "ResourceAllocation",
        "MicrowaveLaserGenerator"
    },
    UEF = {
        "AdvancedEngineering",
        "T3Engineering",
        "ResourceAllocation",
        "Shield",
        "ShieldGeneratorField"
    },
    Seraphim = {
        "AdvancedEngineering",
        "T3Engineering",
        "DamageStabilization",
        "DamageStabilizationAdvanced",
        "ResourceAllocation",
        "ResourceAllocationAdvanced"
    }
  },
  {
    -- we can set any color we want as it is done in UI
    color = "ff18DAE0",
    -- those are used to spawn player on map (those names must be defined on map
    -- for each player)
    units =
    {
        Aeon = 'AeonPlayer_1',
        Cybran = 'CybranPlayer_1',
        UEF = 'UEFPlayer_1',
        Seraphim = 'SeraPlayer_1',
    },
    -- custom name for a player (if not set it will use its own from lobby)
    name = "Punch lox"
  },
  {
    color = "ff69D63E",
    units =
    {
        Cybran = 'CybranPlayer_2',
        UEF = 'UEFPlayer_2',
        Aeon = 'AeonPlayer_2',
        Seraphim = 'SeraPlayer_2',
    },
    name = "Zadsport",
    -- we can set specific upgrades per player as well
    enhancements = {
        Aeon = {
            "AdvancedEngineering",
            "T3Engineering",
            "ResourceAllocation",
        },
        Cybran = {
            "AdvancedEngineering",
            "T3Engineering",
            "ResourceAllocation",
        },
        UEF = {
            "AdvancedEngineering",
            "T3Engineering",
            "ResourceAllocation",
        },
        Seraphim = {
            "AdvancedEngineering",
            "T3Engineering",
            "ResourceAllocation",
        }
  },
  },
 }

-- we can get their count like this
local playersCount = table.getsize(playersData)

 ...
-- After that we can spawn players' ACUs warping them ...
playersManager:WarpIn(function()
    ScenarioFramework.Dialogue(VOStrings.E01_D01_010, PlayerDeath, true)
end)
-- or gating in (this only changes effects ACUs spawn with, you will have to setup gate on map yourself)
playersManager:GateIn(function()
    ScenarioFramework.Dialogue(VOStrings.E01_D01_010, PlayerDeath, true)
end)
-- The function passed in is players' death callback.
-- You can make mission end if player dies or keep count of dead players.
```

## Base Managers and Platoons

AIs must have something to control to offend player during objective.
This can be reached with **Base Managers** that produce units groups.

Base Manager handles most of things dedicated to base management:

* Managing engineers
* Construction and maintenance of base
* Production of Platoons
* Scouting
* Transporting (by Oxygen)

The most important here is that base manager does most of the stuff for us from the box.
There are platoons left to be setup here and it is pretty large topic, because this makes AIs "alive".

### Platoons

Platoon is a group of units controlled by a thread specified after its assemble.
And why it is a large topic is because platoons have so many options to be set.

Here comes **Platoon Builder** to simplify this process:

```lua
...
local pb = Oxygen.PlatoonBuilder()
 -- before platoon builder is used it can be set up to reduce amount of code
pb
    -- sets AI function to be used for any platoon created by platoon builder 
    -- if there wasnt specified
    :UseAIFunction(Oxygen.PlatoonAI.Common, "PatrolChainPickerThread") 
    -- base manager name that builds this platoon
    -- not necessary since platoon loader of Advanced Base Manager sets it by default
    -- (ill show later)
    :UseLocation "SE_BASE"
    -- type of platoon to produce (can be Land, Air, Sea, Gate or Any)
    :UseType 'Land'
    -- sets PlatoonData to be used by AI function
    :UseData
    {
        PatrolChains = {
            "LAC01",
            "LAC02",
            "LAC03",
        },
        Offset = 10
    }

    -- after that we can add platoons into base manager directly with creating

baseManager:LoadPlatoons 
{
    pb:New "Rhinos SE" -- name of platoon, must be a unique value
        :InstanceCount(5)     -- number of instances of platoon that base manager will produce (defaults to 1)
        :Priority(280)        -- priority of platoon construction, base manager will build platoons with higher priority first
        :AddUnit(UNIT "Rhino", 4) -- adding 4 rhinos into platoon
        :AddUnit(UNIT "Deceiver", 1) -- and 1 deceiver
        :Create(), -- creating, before it is actually added into BM it will get all 'Use' we set before

    -- another way of doing this
    pb:New "Brick Attack"
        :InstanceCount(5)
        :Priority(200)
        -- we can set on what difficulties to build this platoon
        :Difficulty { "Medium", "Hard" }
        :AddUnits
        {
            { UNIT "Brick", 5 },
            { UNIT "Banger", 3 },
            { UNIT "Deceiver", 1 },
        }
        :Create(),
    
    -- we can make brick fly, platoon will pick transport from dedicated BM or from global pool
    -- and then move on transport by chains specified (PlatoonData is being replaced as well as AIFunction,
    -- because we specified those)
    pb:New "Flying Brick"
        :InstanceCount(3)
        :Priority(250)
        :AddUnit(UNIT "Brick", 1)
        :AddUnit(UNIT "Deceiver", 1)
        :AIFunction('/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports')
        :Data
        {
            TransportReturn = "MainBase_M",
            TransportChain = "FlyingBrickRoute",
            LandingChain = "FlyingBrickLanding",
            AttackChain = "TransportAttack"
        }
        :Create(),

    -- transporting engineers to build expansion base, also requires dedicated BM to exist
    pb:New "SE Engineers"
        :InstanceCount(1)
        :Priority(500)
        :AddUnit(UNIT "T3 Cybran Engineer", 5)
        :Data
        {
            UseTransports = true,
            TransportReturn = "MainBase_M",
            TransportChain = "SE_Base_chain",
            LandingLocation = "SE_Base_M",
        }
        -- this line makes all magic, it makes specific platoon setup
        -- so it becomes an expansion one (also provided by Oxygen)
        :Create(Oxygen.BaseManager.Platoons.ExpansionOf "SE_BASE"),
    
    -- we can load platoon template units that were defined on map
    -- setting up squad (Artillery) and its formation (GrowthFormation)
    -- by default all units added into platoon builder without specified
    -- squad or formation get those as 'Attack' and 'AttackFormation'
    pb:New "Arty attack"
        :Priority(500)
        :AddUnits(
            Oxygen.Misc.FromMapUnits("Evil Bot", "ArtyAttack", 'Artillery', 'GrowthFormation')
        )
        :Create(),

    -- Ras bots are also supported :P
    -- of course Gate must present in base
    pb:New "bois"
        :Type "Gate"
        :Priority(500)
        :AddUnit(UNIT "Cybran RAS SACU", 10)
        :Create(Oxygen.BaseManager.Platoons.ExpansionOf "NukeBaseGroup"),

}
```

## Game and Expanding map

 TODO

## Triggers

TODO

## Links

[Test map and Demo one](https://github.com/4z0t/MapsCoopDev/tree/GW/maps)

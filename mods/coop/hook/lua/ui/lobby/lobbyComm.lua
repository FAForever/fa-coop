local MapUtil = import('/lua/ui/maputil.lua')

-- Add some extra magic to LaunchGame: a convenient time to hook pre-launch for all players.
BaseLobbyComm = LobbyComm
LobbyComm = Class(BaseLobbyComm) {
    LaunchGame = function(self, gameInfo)
        scenarioInfo = MapUtil.LoadScenario(gameInfo.GameOptions.ScenarioFile)

        -- Get the armies defined in the scenario.
        local scenarioArmies = MapUtil.ReallyGetArmies(scenarioInfo)

        local newPlayerOptions = {}

        -- We need to place each army at the index in PlayerOptions corresponding to the army's index in
        -- the map's army table. There are usually a bunch of other AI armies defined in the table,
        -- which we can probably ignore. I hope.
        -- Some dipshit decided not to standardise this.
        local num = 1
        for armyIndex, armyName in scenarioArmies do
            if StringStartsWith(armyName, "Player") then
                -- Shift each player to the slot that corresponds to their target army.
                newPlayerOptions[armyIndex] = gameInfo.PlayerOptions[num]
                num = num + 1
            else
                -- Voodoo copied from SinglePlayerLaunch.lua's stock logic for starting campaign.
                local newAI = GetDefaultPlayerOptions(armyName)
                newPlayerOptions[armyIndex] = newAI
                newAI.Human = false
                newAI.Faction = 1
            end

            if newPlayerOptions[armyIndex] then
                newPlayerOptions[armyIndex].ArmyName = armyName
            end
        end

        gameInfo.PlayerOptions = newPlayerOptions

        BaseLobbyComm.LaunchGame(self, gameInfo)
    end
}

local EntityCategoryContains = EntityCategoryContains
local IObjective = import("IObjective.lua").IObjective
local ObjectiveHandlers = import("ObjectiveHandlers.lua")
local ObjectiveArrow = import("/lua/objectivearrow.lua").ObjectiveArrow
local ScenarioUtils = import("/lua/sim/scenarioutilities.lua")

---@param armies string[]
---@return table<integer, boolean>
local function CreateArmiesList(armies)
    if not armies then return {} end

    local armiesList = {}
    for _, armyName in armies do
        assert(type(armyName) == "string",
            "Armies in requirements need to be of type string, provided type: " .. type(armyName))
        if armyName == 'HumanPlayers' then
            local tblArmy = ListArmies()
            for iArmy, strArmy in pairs(tblArmy) do
                if ScenarioInfo.ArmySetup[strArmy].Human then
                    armiesList[ScenarioInfo.ArmySetup[strArmy].ArmyIndex] = true
                end
            end
        elseif ScenarioInfo.ArmySetup[armyName] then
            armiesList[ScenarioInfo.ArmySetup[armyName].ArmyIndex] = true
        else
            error('Army doesnt exist: ' .. armyName)
        end
    end

    return armiesList
end

---@class CategoriesInAreaObjective : IObjective
CategoriesInAreaObjective = Class(IObjective)
{

    ---@param self CategoriesInAreaObjective
    ---@param args ObjectiveArgs
    PostCreate = function(self, args)
        assert(args.Requirements, self.Title .. " :Objective requires Requirements in Target specified!")

        for _, requirement in args.Requirements do

            if args.MarkArea then
                self.Decals:Add(ObjectiveHandlers.CreateAreaObjectiveDecal(requirement.Area))
            elseif args.FlashVisible then
                ObjectiveHandlers.FlashViz(self, requirement.Area)
            end

            requirement.ArmiesList = CreateArmiesList(requirement.Armies)
            requirement.Rect = ScenarioUtils.AreaToRect(requirement.Area)
            requirement.CompareFunc = ObjectiveHandlers.GetCompareFunc(requirement.CompareOp)
        end

        self:UpdateProgressUI(0, table.getn(args.Requirements))
        self.Trash:Add(ForkThread(self.WatchAreaThread, self))
    end,

    ---@param self CategoriesInAreaObjective
    WatchAreaThread = function(self)
        local lastReqsMet = 0
        local requirements = self.Args.Requirements
        local totalReqs = table.getn(requirements)

        while self.Active do
            local reqsMet = 0

            for _, requirement in requirements do
                local units = GetUnitsInRect(requirement.Rect)
                local count = 0
                local armiesList = requirement.ArmiesList
                if units then
                    for _, unit in units do
                        if not unit.Dead and not unit:IsBeingBuilt()
                            and
                            (
                            not (requirement.ArmyIndex or requirement.Armies)
                                or (requirement.ArmyIndex == unit.Army)
                                or armiesList[unit.Army]
                            )
                            and EntityCategoryContains(requirement.Category, unit)
                        then
                            if not unit.Marked and self.Args.MarkUnits then
                                unit.Marked = true
                                self:AddUnitTarget(unit)
                                self.UnitMarkers:Add(ObjectiveArrow { AttachTo = unit })
                            end
                            count = count + 1
                        end
                    end
                end
                if requirement.CompareFunc(count, requirement.Value) then
                    reqsMet = reqsMet + 1
                end
            end

            if lastReqsMet ~= reqsMet then
                self:UpdateProgressUI(reqsMet, totalReqs)
                lastReqsMet = reqsMet
            end

            if reqsMet == totalReqs then
                self:OnRequirementsMet()
                return
            end
            WaitTicks(10)
        end
    end,

    ---Called when all requirements are met
    ---@param self CategoriesInAreaObjective
    OnRequirementsMet = function(self)
        self:Success()
    end
}

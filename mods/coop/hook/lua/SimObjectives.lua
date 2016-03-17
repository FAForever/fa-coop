function AddObjective(Type,         -- 'primary', 'bonus', etc
                      Complete,     -- 'complete', 'incomplete'
                      Title,        -- e.g. "Destroy Radar Stations"
                      Description,  -- e.g. "A reason why you need to destroy the radar stations"
                      ActionImage,        -- '/textures/ui/common/missions/mission1.dds'
                      Target,       -- Can be one of:
                                    --   Units = { unit1, unit2, ... }
                                    --   Areas = { 'areaName1', 'areaName2', ... }
                      IsLoading,    -- Are we loading a saved game?
                      loadedTag     -- If IsLoading is specified, whats the tag?
                      )

    if Type == 'bonus' then
        return {Tag = 'Invalid'} -- bonus objectives cut
    end

    if(not Sync.ObjectivesTable) then
        Sync.ObjectivesTable = {}
    end

    local tag

    if IsLoading then
        tag = loadedTag
    else
        tag = 'Objective' .. objNum
        objNum = objNum + 1
        table.insert( SavedList, {AddArgs = {Type,Complete,Title,Description,ActionImage,Target,true,tag,n=8},Tag=tag} )
    end

    --LOG("Debug: AddObjective: ", Title,":", Description, " (Tag=",tag,")")

    -- Set up objective table to return.
    local objective = {
        -- Used to synchronize sim objectives with user side objectives
        Tag = tag,

        -- Whether the objective is in progress or not and does not indicate
        -- success or failure.
        Active = true,

        -- success or failure.
        Complete = false,

        -- Decal table, keyd by area names
        Decals = {},

        -- Unit arrow table
        UnitMarkers = {},

        -- Visibility markers that we manage
        VizMarkers = {},

        -- Single decal
        Decal = false,

        -- Strategic icon overrides
        IconOverrides = {},

        -- For tracking targets
        NextTargetTag = 0,
        PositionUpdateThreads = {},

        Title = Title,
        Description = Description,

        SimStartTime = GetGameTimeSeconds(),

        -- Called on success or failure
        ResultCallbacks = {},
        AddResultCallback = function(self,cb)
            table.insert(self.ResultCallbacks,cb)
        end,

        -- Some objective types can provide progress updates (not success/fail)
        ProgressCallbacks = {},
        AddProgressCallback = function(self,cb)
            table.insert(self.ProgressCallbacks,cb)
        end,

        -- Dont override these if you want notification. Call Add???Callback
        -- intead
        OnResult = function(self,success,data)

            self.Complete = success

            for k,v in self.ResultCallbacks do v(success,data) end

            -- Destroy decals
            for k,v in self.Decals do v:Destroy() end

            -- Destroy unit marker things
            for k,v in self.UnitMarkers do
                v:Destroy()
            end

            -- Revert strategic icons
            for k,v in self.IconOverrides do
                if not v:BeenDestroyed() then
                    v:SetStrategicUnderlay("")
                end
            end

            -- Destroy visibility markers
            for k,v in self.VizMarkers do
                v:Destroy()
            end

            if self.PositionUpdateThreads then
                for k,v in self.PositionUpdateThreads do
                    if v then
                        KillThread(self.PositionUpdateThreads[k])
                        self.PositionUpdateThreads[k] = false
                    end
                end
            end
        end,

        OnProgress = function(self,current,total)
            for k,v in self.ProgressCallbacks do v(current,total) end
        end,

        -- Call this to manually fail the objective
        Fail = function(self)
            self.Active = false
            self:OnResult(false)
            UpdateObjective(self.Title,'complete','failed',self.Tag)
        end,

        AddUnitTarget = function(self,unit) end, -- defined below
        AddAreaTarget = function(self,area) end, -- defined below
    }

    -- Takes a unit that is an objective target and uses its recon detect
    -- event to notify the objectives that we have a blip for the unit.
    local function SetupNotify(obj,unit,targetTag)
        if GetFocusArmy() == -1 then
            return
        end

        -- Add a detectedBy callback to notify the user layer when our recon
        -- on the target comes in and out.
        local detectedByCB = function(cbunit,armyindex)
            --LOG('detected by ',armyindex, ' focus = ',GetFocusArmy())

            if armyindex != 1 then
                return
            end

            if not obj.Active then
                return
            end

            -- now if weve been detected by the focus army ...
            if armyindex == GetFocusArmy() then
                -- get the blip that is associated with the unit
                local blip = cbunit:GetBlip(armyindex)

                -- Only provide the target position to the user layer if
                -- the blip IsSeenEver() (i.e. has been identified).
                obj.PositionUpdateThreads[targetTag] = ForkThread(
                    function()
                        while obj.Active do
                            WaitTicks(10)
                            if blip:BeenDestroyed() then
                                return
                            end

                            if blip:IsSeenEver(armyindex) then
                                UpdateObjective(Title,
                                                'Target',
                                                {
                                                    Type = 'Position',
                                                    Value = blip:GetPosition(),
                                                    BlueprintId = blip:GetBlueprint().BlueprintId,
                                                    TargetTag=targetTag
                                                },
                                                obj.Tag )

                                -- If it's not mobile we can exit the thread since
                                -- the blip won't move.
                                if not unit:IsDead() and not unit:BeenDestroyed() and not EntityCategoryContains( categories.MOBILE, unit ) then
                                    return
                                end
                            end
                        end
                    end
                )

                local destroyCB = function(cbblip)
                    if not obj.Active then
                        return
                    end

                    if obj.PositionUpdateThreads[targetTag] then
                        --LOG('killing thread')
                        KillThread( obj.PositionUpdateThreads[targetTag] )
                        obj.PositionUpdateThreads[targetTag] = false
                    end

                    -- when the blip is destroyed, tell objectives we dont
                    -- have a blip anymore. This doesnt necessarily mean the
                    -- unit is killed, we simply lost the blip.
                    UpdateObjective(Title,
                                    'Target',
                                    {
                                        Type = 'Position',
                                        Value = nil,
                                        BlueprintId = nil,
                                        TargetTag=targetTag,
                                    },
                                    obj.Tag )
                end

                -- When the blip is destroyed, have it call this callback
                -- function (defined above)
                blip:AddDestroyHook(destroyCB)
            end
        end

        -- When the unit is detected by an army, have it call this callback
        -- function (defined above)
        unit:AddDetectedByHook(detectedByCB)

        -- See if we can detect the unit right now
        local blip = unit:GetBlip(GetFocusArmy())
        if blip then
            detectedByCB(unit,GetFocusArmy())
        end
    end

    -- Take an objective target unit that is owned by the focus army
    -- Info passed to user layer to handle zoom to button and chiclet image
    function SetupFocusNotify(obj, unit, targetTag)
        obj.PositionUpdateThreads[targetTag] = ForkThread(
            function()
                while obj.Active do
                    if unit:BeenDestroyed() then
                        return
                    end

                    UpdateObjective(Title,
                                    'Target',
                                    {
                                        Type = 'Position',
                                        Value = unit:GetPosition(),
                                        BlueprintId = unit:GetBlueprint().BlueprintId,
                                        TargetTag=targetTag
                                    },
                                    obj.Tag )

                    -- If it's not mobile we can exit the thread since
                    -- the unit won't move.
                    if not unit:IsDead() and not unit:BeenDestroyed() and not EntityCategoryContains( categories.MOBILE, unit ) then
                        return
                    end
                    WaitTicks(10)
                end
            end
        )

        local destroyCB = function()
            if not obj.Active then
                return
            end

            if obj.PositionUpdateThreads[targetTag] then
                --LOG('killing thread')
                KillThread( obj.PositionUpdateThreads[targetTag] )
                obj.PositionUpdateThreads[targetTag] = false
            end

            -- when the blip is destroyed, tell objectives we dont
            -- have a blip anymore. This doesnt necessarily mean the
            -- unit is killed, we simply lost the blip.
            UpdateObjective(Title,
                            'Target',
                            {
                                Type = 'Position',
                                Value = nil,
                                BlueprintId = nil,
                                TargetTag=targetTag,
                            },
                            obj.Tag )
        end

        -- When the unit is destroyed have it call this callback
        -- function (defined above)
        Triggers.CreateUnitDeathTrigger(destroyCB, unit )
    end

    function SetupVizMarker(objective, object)
        if IsEntity(object) then
            local pos = object:GetPosition()
            local spec = {
                X = pos[1],
                Z = pos[2],
                Radius = 8,
                LifeTime = -1,
                Omni = false,
                Vision = true,
                Army = 1,
            }
            local vizmarker = VizMarker(spec)
            object.Trash:Add(vizmarker)
            vizmarker:AttachBoneTo(-1,object,-1)
        else
            local rect = ScenarioUtils.AreaToRect(Target.Area)
            local width = rect.x1 - rect.x0
            local height = rect.y1 - rect.y0
            local spec = {
                X = rect.x0 + width/2,
                Z = rect.y0 + height/2,
                Radius = math.max( width, height ),
                LifeTime = -1,
                Omni = false,
                Vision = true,
                Army = 1,
            }
            local vizmarker = VizMarker(spec)
            table.insert(objective.VizMarkers,vizmarker);
        end
    end

    function FlashViz (object)
        if IsEntity(object) then

            local pos = object:GetPosition()
            local spec = {
                X = pos[1],
                Z = pos[2],
                Radius = 2,
                LifeTime = 1.00,
                Omni = false,
                Vision = true,
                Radar = false,
                Army = 1,
            }
            local vizmarker = VizMarker(spec)
            object.Trash:Add(vizmarker)
            vizmarker:AttachBoneTo(-1,object,-1)
        else
            local rect = ScenarioUtils.AreaToRect(object)
            local width = rect.x1 - rect.x0
            local height = rect.y1 - rect.y0
            local spec = {
                X = rect.x0 + width/2,
                Z = rect.y0 + height/2,
                Radius = math.max( width, height ),
                LifeTime = 0.01,
                Omni = false,
                Vision = true,
                Radar = false,
                Army = 1,
            }
            local vizmarker = VizMarker(spec)
        end
    end

    local userTargets = {}
    if Target.ShowFaction then
        if Target.ShowFaction == 'Cybran' then
            Target.Image = '/textures/ui/common/faction_icon-lg/cybran_ico.dds'
        elseif Target.ShowFaction == 'Aeon' then
            Target.Image = '/textures/ui/common/faction_icon-lg/aeon_ico.dds'
        elseif Target.ShowFaction == 'UEF' then
            Target.Image = '/textures/ui/common/faction_icon-lg/uef_ico.dds'
        elseif Target.ShowFaction == 'Seraphim' then
            Target.Image = '/textures/ui/common/faction_icon-lg/seraphim_ico.dds'
        end
    end

    if Target and Target.Requirements then
        for k,req in Target.Requirements do
            if req.Area then
                table.insert(userTargets, { Type = 'Area', Value = ScenarioUtils.AreaToRect(req.Area) })
            end
        end
    elseif Target and Target.Timer then
        userTargets = {Type = 'Timer', Time = Target.Timer}
    end

    if Target.Category then
        local bps = EntityCategoryGetUnitList(Target.Category)
        if table.getn(bps) > 0 then
            table.insert(userTargets, { Type = 'Blueprint', BlueprintId = bps[1] })
        end
    end

    local userObjectiveData = {
        tag = tag,
        type = Type,
        complete = Complete,
        title = Title,
        description = Description,
        actionImage = ActionImage,
        targetImage = Target.Image,
        progress = "",
        targets = userTargets,
        loading = IsLoading,
        StartTime = objective.SimStartTime,
    }

    Sync.ObjectivesTable[tag] = userObjectiveData

    objective.AddUnitTarget = function(self,unit)
        self.NextTargetTag = self.NextTargetTag + 1
        if unit:GetArmy() == GetFocusArmy() then
            SetupFocusNotify(self,unit,self.NextTargetTag)
            --it's our unit
            if GetFocusArmy() == 1 then
                SetupFocusNotify(self,unit,self.NextTargetTag)
            end
        else
            --it's someone else unit
            SetupNotify(self,unit,self.NextTargetTag)
        end
        if Target.AlwaysVisible then
            SetupVizMarker(self,unit)
        end

        table.insert(self.IconOverrides,unit)

        -- Mark the units unless MarkUnits == false
        if ( Target.MarkUnits == nil ) or Target.MarkUnits then
            if Type == 'primary' then
                unit:SetStrategicUnderlay('icon_objective_primary')
            elseif Type == 'secondary' then
                unit:SetStrategicUnderlay('icon_objective_secondary')
            end
        end
    end

    objective.AddAreaTarget = function(self,area)
        self.NextTargetTag = self.NextTargetTag + 1
        UpdateObjective(Title,
                        'Target',
                        {
                            Type = 'Area',
                            Value = ScenarioUtils.AreaToRect(area),
                            TargetTag=self.NextTargetTag
                        },
                        self.Tag )

        if Target.AlwaysVisible then
            SetupVizMarker(self,area)
        end
    end

    if Target then
        if Target.Units then
            for k,v in Target.Units do
                if v and v.IsDead and not v:IsDead() then
                    objective:AddUnitTarget(v)
                end
            end
        end

        if Target.Unit then
            if Target.Unit.IsDead and not Target.Unit:IsDead() then
                objective:AddUnitTarget(Target.Unit)
            end
        end

        if Target.Areas then
            for k,v in Target.Areas do
                objective:AddAreaTarget(v)
            end
        end

        if Target.Area then
            objective:AddAreaTarget(Target.Area)
        end
    end

    return objective
end
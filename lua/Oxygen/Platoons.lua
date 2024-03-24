---Sets target priorities after being built
---@param targetCategories EntityCategory[]
---@return fun(platoonBuilder: PlatoonTemplateBuilder)
function TargettingPriorities(targetCategories)
    if targetCategories[table.getn(targetCategories)] ~= categories.ALLUNITS then
        -- insert allunits category in the end to keep sure units will target something else
        table.insert(targetCategories, categories.ALLUNITS)
    end

    ---@param platoonBuilder PlatoonTemplateBuilder
    return function(platoonBuilder)
        platoonBuilder
            :AddCompleteCallback(Oxygen.PlatoonAI.Common, 'PlatoonSetTargetPriorities')
            :MergeData
            {
                CategoryPriorities = targetCategories
            }
    end
end

---@param marker Marker
---@param layer? NavLayers
---@return fun(platoonBuilder: PlatoonTemplateBuilder)
function NavigateTo(marker, layer)
    ---@param platoonBuilder PlatoonTemplateBuilder
    return function(platoonBuilder)
        platoonBuilder
            :AIFunction(Oxygen.PlatoonAI.NavMesh, 'PlatoonNavigateToPosition')
            :MergeData
            {
                Destination = marker,
                Layer = layer or 'Land'
            }
    end
end

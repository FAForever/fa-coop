-- Ignore map filters from Game.prefs
function InitFilters()
    currentFilters = {}
    local savedFilterState = {
        map_obsolete = {
            SelectedKey = 1 -- Enable obsolete map filtering by default.
        }
    }

    -- savedFilterState is an array of tables of filter options
    for filterKey, v in savedFilterState do
        local filter = mapFilters[GetFilterIndex(filterKey)]
        local factory = filter.FilterFactory
        factory.SelectedKey = v.SelectedKey
        factory.SelectedComparator = v.SelectedComparator
        currentFilters[filter.FilterKey] = factory:Build()
    end
end

local reallyCreateDialog = CreateDialog
function CreateDialog(...)
    local ret = reallyCreateDialog(unpack(arg))

    -- Delete the map filter UI (there aren't enough coop missions to warrant a scrollbar, and the most
    -- of these filters don't make sense for coop anyway.
    dialogContent.filterGroup.Show = dialogContent.filterGroup.Hide
    dialogContent.filterGroup:Hide()

    -- Move the map select group up into the space.
    LayoutHelpers.RightOf(dialogContent.mapSelectGroup, dialogContent.preview, 23)

    return ret
end

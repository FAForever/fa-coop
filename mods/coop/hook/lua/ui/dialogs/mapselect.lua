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

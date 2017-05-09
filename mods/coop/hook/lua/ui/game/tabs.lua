-- Using pause button for creating the announcement since it's the easiest way to have it appear from the top of the screen without creating our own control for it.
function CreateSimAnnouncement(tblData)
    import('/lua/ui/game/announcement.lua').CreateAnnouncement(tblData.text, pauseBtn, tblData.secondaryText)
end

-- Add a button to show a transmission log into the main menu
do
    local transmissionEntry = {action = 'TransmissionLog', label='<LOC trans_log_0000>Transmission Log', tooltip = 'inbox'}
    table.insert(menus.main.replay, 4, transmissionEntry)
    table.insert(menus.main.lan, 3, transmissionEntry)
    table.insert(menus.main.gpgnet, 3, transmissionEntry)
    table.insert(menus.main.singlePlayer, 5, transmissionEntry)

    actions.TransmissionLog = function() import('/lua/ui/game/transmissionlog.lua').ToggleTransmissionLog() end
end
local oldOnSync = OnSync
OnSync = function()
	oldOnSync()
	if Sync.CreateSimAnnouncement then
        import('/lua/ui/game/tabs.lua').CreateSimAnnouncement(Sync.CreateSimAnnouncement)
	end
end
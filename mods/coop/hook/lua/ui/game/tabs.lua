-- Using pause button for creating the announcement since it's the easiest way to have it appear from the top of the screen without creating our own control for it.
function CreateSimAnnouncement(tblData)
	import('/lua/ui/game/announcement.lua').CreateAnnouncement(tblData.text, pauseBtn, tblData.secondaryText)
end
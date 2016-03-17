function CameraTrackEntities( units, zoom, seconds )
    local army = GetFocusArmy()
    if army == -1 then
        army = 1
    end
    for i,v in units do
        if army ~= v:GetArmy() then
            units[i] = v:GetBlip(army)
        end
    end

    # Watch the entities
    ScenarioInfo.Camera:TrackEntities( units, zoom, seconds )

    # Keep it from pitching up all the way
    ScenarioInfo.Camera:HoldRotation()

    if ( seconds ) and ( seconds != 0 ) then
        # Wait for it to be done
        WaitForCamera()
    end
end
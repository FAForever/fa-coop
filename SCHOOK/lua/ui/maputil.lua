--- Return a fixed army set for coop games. Keep the old function available as we need it at
-- launch-time.
ReallyGetArmies = GetArmies

function GetArmies(scenario)
    return {"Player", "Coop1", "Coop2", "Coop3"}
end

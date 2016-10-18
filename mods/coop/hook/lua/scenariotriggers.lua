
function CreateGiveUnitTrigger( cb, unit )
    unit:AddUnitCallback( cb, 'OnGive' ) 
end
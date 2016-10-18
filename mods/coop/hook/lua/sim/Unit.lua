OldUnit = Unit
OldOnPreCreate = Unit.OnPreCreate

Unit = Class(OldUnit){
    
    OnPreCreate = function(self)
        OldOnPreCreate(self)
        self.EventCallbacks['OnGive'] = {}
    end,

    OnGive = function(self, newUnit)
            self:DoUnitCallbacks( 'OnGive', newUnit )
    end,

    AddGiveCallback = function(self, fn)
        self:AddUnitCallback(fn, 'OnGive')
    end,
}

-- function Unit:OnGive( newUnit)
        -- self:DoUnitCallbacks( 'OnGive', newUnit )
-- end

-- function Unit:AddGiveCallback( fn)
    -- self:AddUnitCallback(fn, "OnGive")
-- end
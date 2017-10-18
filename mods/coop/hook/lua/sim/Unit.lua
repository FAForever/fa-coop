local oldUnit = Unit
Unit = Class(oldUnit) {
    OnCreate = function(self)
        oldUnit.OnCreate(self)
        self.CanBeGiven = true
    end,

    SetCanBeGiven = function(self, val)
        self.CanBeGiven = val
    end,
}
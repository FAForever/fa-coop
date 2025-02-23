---@class Sample
---@field tick integer
---@field value number

---@class Samples
---@field n integer
---@field data Sample[]
Samples = ClassSimple
{
    ---@param self Samples
    ---@param n integer
    __init = function(self, n)
        self.n = n
        self:Fill()
    end,

    ---@param self Samples
    Fill = function(self)
        self.data = {}
        for i = 1, self.n do
            self.data[i] = { tick = 0, value = 0 }
        end
    end,


    ---@param self Samples
    ---@param value number
    ---@return boolean
    Add = function(self, value)
        local currentTick = GetGameTick()

        if self.data[self.n].tick == currentTick then
            return false
        end

        self.data[1].tick = currentTick
        self.data[1].value = value

        table.sort(self.data, function(a, b)
            return a.tick < b.tick
        end)
        return true
    end,

    ---@param self Samples
    Average = function(self)

        local value = 0
        local data = self.data

        for i = 1, self.n - 1 do
            if data[i].tick == 0 then
                break
            end
            value = value + (data[i + 1].value + data[i].value) * 0.5 * (data[i + 1].tick - data[i].tick)
        end
        return value / (data[self.n].tick - data[1].tick)
    end,

}

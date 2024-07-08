local callbacks = {}

---Adds callback for Oxygen
---@param name string
---@param func fun(...)
function Add(name, func)
    assert(callbacks[name] == nil, "There is already Oxygen callback named \"" .. name .. "\"")
    callbacks[name] = func
end

---@param name string
---@param data any
function Invoke(name, data)
    if callbacks[name] then
        callbacks[name](data)
    end
end

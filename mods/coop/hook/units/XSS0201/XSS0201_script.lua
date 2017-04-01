local oldXSS0201 = XSS0201
XSS0201 = Class(oldXSS0201) {
    OnCreate = function(self)
        oldXSS0201.OnCreate(self)
        IssueDive({self})
    end,
}
TypeClass = XSS0201
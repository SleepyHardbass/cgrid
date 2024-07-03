local AND, OR, SHL, SHR; do
    local bit = require("bit")
    AND = bit.band
    OR = bit.bor
    SHL = bit.lshift
    SHR = bit.rshift
    bit = nil
end

return {
    new = function(self, side)
        if AND(side, side - 1) ~= 0 then
            return -- Error Not Power Of Two
        end
        
        local array = {}
        local exp = math.log(side)/math.log(2)
        local mask = 0x0
        
        for index = 1, exp do
            mask = SHL(mask, 2) + 1
        end
        
        for index = 0, side^2 - 1 do
            array[index] = 0
        end
        
        return {
            side = side,
            exp = exp,
            xmask = mask,
            ymask = mask*2,
            distance = 0,
            array = array,
            
            setValue = self.setValue,
            getValue = self.getValue,
            
            setPosition = self.setPosition,
            getPosition = self.getPosition,
            
            up = self.up,
            down = self.down,
            left = self.left,
            right = self.right,
        }
    end,
    
    setValue = function(self, value)
        self.array[self.distance] = value
        return self
    end,

    getValue = function(self)
        return self.array[self.distance]
    end,
    
    setPosition = function(self, x, y)
        x = AND(OR(x, SHL(x, 8)), 0x00FF00FF)
        x = AND(OR(x, SHL(x, 4)), 0x0F0F0F0F)
        x = AND(OR(x, SHL(x, 2)), 0x33333333)
        x = AND(OR(x, SHL(x, 1)), self.xmask)
        
        y = AND(OR(y, SHL(y, 8)), 0x00FF00FF)
        y = AND(OR(y, SHL(y, 4)), 0x0F0F0F0F)
        y = AND(OR(y, SHL(y, 2)), 0x33333333)
        y = AND(OR(y, SHL(y, 1)), self.xmask)
        
        self.distance = OR(x, SHL(y, 1))
        return self
    end,

    getPosition = function(self)
        local x = AND(self.distance, 0x55555555)
        x = AND(OR(x, SHR(x, 1)), 0x33333333)
        x = AND(OR(x, SHR(x, 2)), 0x0F0F0F0F)
        x = AND(OR(x, SHR(x, 4)), 0x00FF00FF)
        x = AND(OR(x, SHR(x, 8)), 0x0000FFFF)
        
        local y = AND(SHR(self.distance, 1), 0x55555555)
        y = AND(OR(y, SHR(y, 1)), 0x33333333)
        y = AND(OR(y, SHR(y, 2)), 0x0F0F0F0F)
        y = AND(OR(y, SHR(y, 4)), 0x00FF00FF)
        y = AND(OR(y, SHR(y, 8)), 0x0000FFFF)
        
        return x, y
    end,

    up = function(self)
        local z = self.distance
        self.distance = OR(AND(AND(z, self.ymask) - 1, self.ymask), AND(z, self.xmask))
        return self
    end,

    down = function(self)
        local z = self.distance
        self.distance = OR(AND(OR(z, self.xmask) + 1, self.ymask), AND(z, self.xmask))
        return self
    end,

    left = function(self)
        local z = self.distance
        self.distance = OR(AND(AND(z, self.xmask) - 1, self.xmask), AND(z, self.ymask))
        return self
    end,

    right = function(self)
        local z = self.distance
        self.distance = OR(AND(OR(z, self.ymask) + 1, self.xmask), AND(z, self.ymask))
        return self
    end
}

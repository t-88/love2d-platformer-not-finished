Tile = {}

function Tile:new(obj)
    obj = obj or {}
    setmetatable(obj,self)
    self.__index = self

    self.x, self.y , self.w , self.h =  0 , 0 , 36 , 36

    return obj
end


function Tile:setRect(x,y,w,h)
    self.x = x or self.x
    self.y = y or self.y
    self.w = w or self.w
    self.h = h or self.h
end
function Tile:update(dt)
end

function Tile:render()
    love.graphics.rectangle("line",self.x,self.y,self.w,self.h)
end



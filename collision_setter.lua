CollistionSetter = {}

function CollistionSetter:init(obj)
    obj = obj or {}
    setmetatable(obj,self)
    self.__index = self

    self.tileSize = 32
    
    self.tiles = {}
    self.collidbleTiles = {}



    self.mouseIsUp = true
    self.map_editor = nil


    return obj
end

function CollistionSetter:initGrid()
    for y = 0 , HEIGHT , self.tileSize do
        for x = 0 , self.map_editor.lvlWidth , self.tileSize do
            local index = x / self.tileSize+ y * (self.map_editor.lvlWidth / self.tileSize) / self.tileSize
            self.tiles[index] = false
        end
    end
    self.verticalTilesCount = self.map_editor.lvlWidth / self.tileSize

end

function CollistionSetter:update()
    self:input()
    self:handleTilePlacing()
end

function CollistionSetter:render()
    for y = 0 , HEIGHT , self.tileSize do
        for x = 0 , self.map_editor.lvlWidth , self.tileSize do
            love.graphics.rectangle(
                "line",
                x + self.map_editor.offsetX ,
                y,self.tileSize,
                self.tileSize
            )     
        end
    end

    for index, tile in ipairs(self.tiles) do
        if tile then
            love.graphics.setColor(255,0,0,255)

            love.graphics.rectangle(
                "line",
                (index - 1) % self.verticalTilesCount * self.tileSize + self.map_editor.offsetX,
                math.floor((index - 1) / self.verticalTilesCount) * self.tileSize,
                self.tileSize,self.tileSize
            )

            love.graphics.setColor(255,255,255,1)
        end
    end
    
    for _, rect in ipairs(self.collidbleTiles) do
        love.graphics.setColor(255,0,255,1)

        love.graphics.rectangle(
            "line",
            rect.x + self.map_editor.offsetX,
            rect.y,
            rect.w,
            rect.h
        )     

       love.graphics.setColor(255,255,255,1)
    end

end

function CollistionSetter:input()
    if love.keyboard.isDown("right","d")  then
        self.map_editor:offsetMap("right")
    elseif love.keyboard.isDown("left","a") then
        self.map_editor:offsetMap("left")
    end
end



function CollistionSetter:rowNeighbors(usedTiles,rect,prevIndex,index) 
    if usedTiles[index] or not self.tiles[index]  then
        return rect
    end
    if prevIndex ~= nil then
        if prevIndex % self.verticalTilesCount == 0 then
            if index % self.verticalTilesCount == 1 then
                return
            end
        end
    end

    usedTiles[index] = true
    table.insert(rect,index)
    self:rowNeighbors(usedTiles,rect,index,index + 1)
    self:rowNeighbors(usedTiles,rect,index,index - 1)
end

function CollistionSetter:toggleRect(toggle)
    local x , y = love.mouse.getPosition()

    x = math.floor((x - self.map_editor.offsetX) / self.tileSize ) + 1
    y = math.floor(y / self.tileSize )


    local index = x + y * (self.map_editor.lvlWidth / self.tileSize) 
    self.tiles[index] = toggle

    local usedTiles = {}
    local rowRects = {}
    
    for index, tile in ipairs(self.tiles) do
        if tile and not usedTiles[index] then
            local rect = {}
            self:rowNeighbors(usedTiles,rect,nil,index)
            table.sort(rect)            
            if #rect then
                table.insert(rowRects,rect)                                    
            end
        end
    end

    self.collidbleTiles = {}
    for _, rectIndexs in ipairs(rowRects) do
        local rect = {}
        rect.y = math.floor(rectIndexs[1] / (self.map_editor.lvlWidth / (self.tileSize))) * self.tileSize
        if rectIndexs[1] % self.verticalTilesCount == 0 then
            rect.x = (self.verticalTilesCount - 1 )* self.tileSize               
            rect.y = rect.y - self.tileSize   
        else
            rect.x = (rectIndexs[1] % self.verticalTilesCount - 1 ) * self.tileSize
        end
        rect.w = (math.abs(rectIndexs[1] - rectIndexs[#rectIndexs]) + 1) * self.tileSize
        rect.h = self.tileSize
        table.insert(self.collidbleTiles,rect)

    end
end


function CollistionSetter:handleTilePlacing()
    if love.mouse.isDown(1,2) then
        local toggle = love.mouse.isDown(1) == true
        self:toggleRect(toggle)
    end
end


TileSelector = {}

function TileSelector:init(obj)
    obj = obj or {}
    setmetatable(obj,self)
    self.__index = self

    
    self.tileSheetPath = ""
    self.tileSheet = nil
    self.tileSize = 0
    self.tiles = {}

    self.leftKeyDown = false
    self.rightKeyDown = false
    self.columnCount = 11
    self.scale = TILE_SIZE / 16


    self.wasUp = true
    self.selectedTile = {}

    return obj


end

function TileSelector:loadTileSheet(tileSheetPath)
    self.tileSheetPath = tileSheetPath or self.tileSheetPath
    if self.tileSheetPath == "" then
        print("set a path for the tile sheet")
        return
    end

    self.tileSheet = love.graphics.newImage(self.tileSheetPath)
    self.tileSheetData = love.image.newImageData(self.tileSheetPath)
end

function TileSelector:sliceTileSheet(tileSize)
    self.tileSize = tileSize or self.tileSize
    if self.tileSheetPath == "" then
        print("set a tile size")
        return
    end

    local w , h =  self.tileSheet:getDimensions()
    for y = 0, h, self.tileSize do
        for x = 0, w, self.tileSize do
            local croppedImg = love.image.newImageData(self.tileSize,self.tileSize)
            croppedImg:paste(self.tileSheetData,0,0,x,y,self.tileSheetData:getDimensions())
            local isAnEmptyImg = true
            
            for x0 = 0, croppedImg:getWidth() - 1 , 1 do
                if not isAnEmptyImg then
                    break
                end
                for y0 = 0, croppedImg:getHeight() - 1 , 1 do
                    local r , g , b , a = croppedImg:getPixel(x0,y0)
                    if not (r == 0 and g == 0 and b == 0 and a == 0) then
                        local tile = {}
                        tile.quad = love.graphics.newQuad(x,y,self.tileSize,self.tileSize,self.tileSheet:getDimensions())
                        tile.rect = {w=self.tileSize * self.scale,h=self.tileSize * self.scale}
                        table.insert(self.tiles,tile)
                        self.tiles[#self.tiles].index = #self.tiles 
                        isAnEmptyImg = false
                        break
                    end
                end
            end

        end
    end

    self:updateRects()
end

function TileSelector:updateRects()
    for index , tile in ipairs(self.tiles) do
        tile.rect.x = ((index -1) % self.columnCount) * self.tileSize * self.scale
        tile.rect.y = math.floor((index -1) / self.columnCount) * self.tileSize* self.scale
    end    
end

function TileSelector:select()
    if love.mouse.isDown(1) then
        if self.wasUp then
            self.wasUp = false
            for index, tile in ipairs(self.tiles) do
                local mouse = {x = love.mouse.getX(),y = love.mouse.getY(),w = 1,h = 1}
                if AABB(tile.rect,mouse) then
                    self. selectedTile = tile
                    break
                end            
            end
        end
    else
        self.wasUp = true
    end
end

function TileSelector:updateCoulumCount()
    if love.keyboard.isDown("left")  then
        if not self.leftKeyDown then
            self.leftKeyDown = true            
            self.columnCount = self.columnCount - 1
        self:updateRects()
end
    else
        self.leftKeyDown = false            
    end
    if love.keyboard.isDown("right")  then
        if not self.rightKeyDown then
            self.rightKeyDown = true            
            self.columnCount = self.columnCount + 1
            self:updateRects()
        end
    else
        self.rightKeyDown = false            
    end
end

function TileSelector:update()

    self:updateCoulumCount()
    self:select()
end

function TileSelector:render()
    for _ , tile in ipairs(self.tiles) do
        love.graphics.draw(self.tileSheet,tile.quad,tile.rect.x,tile.rect.y,0,self.scale,self.scale)
        love.graphics.rectangle("line",tile.rect.x,tile.rect.y,tile.rect.w,tile.rect.h)

        -- love.graphics.draw(self.tileSheet,tile,((index -1) % self.columnCount) * self.tileSize * self.scale,math.floor((index -1) / self.columnCount) * self.tileSize* self.scale,0,self.scale,self.scale)
        -- love.graphics.rectangle("line",tile.rect.x,tile.rect.y)
    end
    
    if self.selectedTile.quad then        
        love.graphics.draw(self.tileSheet,self.selectedTile.quad,WIDTH - self.selectedTile.rect.w,HEIGHT- self.selectedTile.rect.h,0,self.scale,self.scale)
    end
end
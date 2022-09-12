MapEditor = {}

function MapEditor:init(obj)
    obj = obj or {}
    setmetatable(obj,self)
    self.__index = self

    self.map = {}
    self.map.tiles = {}
    self.map.collidbles = {}

    self.collistion_setter = nil


    self.lvlWidth = TILE_SIZE * 40 

    for y = 0, HEIGHT , TILE_SIZE do
        for x = 0, self.lvlWidth , TILE_SIZE do
            table.insert(self.map.tiles,{x=x,y=y,type=""})     
        end
    end

    self.currTile = {
       x = 0,
        y = 0
    }

    self.offsetX = 0
    self.moveDelayDefault = 2
    self.moveDelay = self.moveDelayDefault
    self.hasMoved = false

    self.tile_selector = nil


    return obj
end

function MapEditor:update()
    self:handleTilePlacing()
    self:switchTiles()

    if self.hasMoved and self.moveDelay > 0 then
        self.moveDelay = self.moveDelay - love.timer.getDelta() * 60
    else
        self.hasMoved = false 
        self.moveDelay = self.moveDelayDefault
    end
end

function MapEditor:render()
    for _ ,  tile in ipairs(self.map.tiles) do
        if tile.index then
            love.graphics.draw(self.tile_selector.tileSheet,self.tile_selector.tiles[tile.index].quad, tile.rect.x + self.offsetX,tile.rect.y,0,self.tile_selector.scale,self.tile_selector.scale)
            
        end
    end

    love.graphics.print({{255,0,0},self.currTile.text},self.currTile.x,self.currTile.y)
end

function MapEditor:offsetMap(dir)
    if dir == "right" and self.offsetX > -self.lvlWidth + WIDTH and not self.hasMoved then
        self.offsetX = self.offsetX - TILE_SIZE
        self.hasMoved = true
    elseif dir == "left" and self.offsetX < 0 and not self.hasMoved then
        self.offsetX = self.offsetX + TILE_SIZE
        self.hasMoved = true
    end
    
end

function MapEditor:switchTiles()


    if love.keyboard.isDown("s") then
        local collidbleTiles = {}
        for _, rect in ipairs(self.collistion_setter.collidbleTiles) do
            table.insert(collidbleTiles,{rect.x,rect.y,rect.w,rect.h})
        end
        self.map.collidbles = collidbleTiles
        love.filesystem.write("lvl0.txt",ser(self.map))
    end

    if love.keyboard.isDown("right","d")   then
        self:offsetMap("right")
    elseif love.keyboard.isDown("left","a")  then
        self:offsetMap("left")

    end


end

function MapEditor:handleTilePlacing()
    if love.mouse.isDown(1) then
        local x , y = love.mouse.getPosition()

        x = math.floor(x / TILE_SIZE) + 1
        y = math.floor(y / TILE_SIZE)

        local tile = {}
        tile.rect = {}
        
        tile.index = self.tile_selector.selectedTile.index
        tile.rect.x , tile.rect.y = (x - 1) * TILE_SIZE - self.offsetX  ,y *  TILE_SIZE 
        self.map.tiles[x - self.offsetX / TILE_SIZE + y * (self.lvlWidth / TILE_SIZE + 1 ) ] = tile --self.currTile.text
    end
end


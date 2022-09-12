Camera = {}

function Camera:new(obj)
    obj = obj or {}
    setmetatable(obj,self)
    self.__index = self

    self.player = nil
    self.tiles = nil


    self.w , self.h = WIDTH - 400  , HEIGHT
    self.x , self.y = (WIDTH - self.w) / 2  , 0
    self.lvlWidth = TILE_SIZE * 40 

    
    self.slideX = 0
    self.globalSlideX = 0
    self.playerOutOfBorder = false

    return obj
end     


function Camera:slide()
    local ableToSlide = false
    self.slideX = 0
    if self.player.x + self.player.w - self.slideX >  self.x + self.w  and -self.globalSlideX < self.lvlWidth - WIDTH - 5 then
        self.slideX = self.x + self.w - (self.player.x + self.player.w)
        self.player.x = self.x + self.w - self.player.w 
        ableToSlide = true
    end 

    if self.player.x - self.slideX <  self.x and self.x - math.floor(self.globalSlideX) > 205 then
    self.slideX = self.x  - self.player.x 
    self.player.x = self.x 
        ableToSlide = true
    end 

    if ableToSlide then
        for _ , tile in ipairs(self.map.tiles) do
            if tile.index then
                tile.rect.x = tile.rect.x  + self.slideX
                
            end
        end 
        for _ , collidble in ipairs(self.map.collidbles) do
            collidble.x = collidble.x  + self.slideX
        end 
    end
    self.globalSlideX = self.globalSlideX + self.slideX
end

function Camera:playerBounderies()
    if self.player.x + self.player.w - self.globalSlideX > self.lvlWidth then
        self.player.x = self.lvlWidth + self.globalSlideX - self.player.w
    end
    if self.player.x < 0  then
        self.player.x = 0
    end
    

end

function Camera:update()
    self:slide()
    self:playerBounderies()
end

function Camera:render()
    for _ , tile in pairs(self.map.tiles) do
        if tile.index then
            love.graphics.draw(self.tile_selector.tileSheet,self.tile_selector.tiles[tile.index].quad, tile.rect.x + self.slideX,tile.rect.y,0,self.tile_selector.scale,self.tile_selector.scale)
        end
    end
    self.player:render()
    -- love.graphics.rectangle("line",self.x ,self.y,self.w,self.h)
end
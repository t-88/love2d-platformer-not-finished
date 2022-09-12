require "camera"
require "player"
require "tile"
local map =  require "lvl0"

Level = {}

function Level:init(obj)
    obj = obj or {}
    setmetatable(obj,self)
    self.__index = self

    self.player = Player:new()
    self.cam = Camera:new()

    self.tile_selector = nil

    self.map = map
    -- self.map = love.filesystem.load("lvl0.txt")()   
    
    local collidbleTiles = {}
    for _, collidble in ipairs(self.map.collidbles) do
        local rect = {}
        rect.x ,rect.y , rect.w , rect.h = collidble[1], collidble[2] , collidble[3] , collidble[4]
        table.insert(collidbleTiles,rect)
    end
    self.map.collidbles = collidbleTiles

    self.cam.player = self.player
    self.cam.map = self.map
    return obj
end

function Level:update()
    self.cam.tile_selector = self.tile_selector
    
    self.player:update(self.map.collidbles)
    self.cam:update()


    
end

function Level:render()
    self.cam:render()
end

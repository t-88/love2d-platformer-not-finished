require "map"


ser =  require "ser"
require "level"
require "map_editor"
require "tile_selector"
require "collision_setter"

local kp8IsUp = true
local kp9IsUp = true

local frameRate = 1 / 120
local nextFrame = frameRate
local currFrame = 0


local editCollistion = false
local startGame = false

local function input()
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    if love.keyboard.isDown("kp9") then
        if kp9IsUp then
            sceneIndex = sceneIndex + 1
            scene = scenes[sceneIndex % 2 + 1]
            kp9IsUp = false
        end
    else
        kp9IsUp = true
    end

    if love.keyboard.isDown("kp8") then
        if  kp8IsUp then
            editCollistion = not editCollistion
            kp8IsUp = false
    end
    else
        kp8IsUp = true
    end

    if love.keyboard.isDown("space") then
        startGame = true
    end
end
local function frameRateCap()
    currFrame = love.timer.getTime()

    nextFrame = currFrame   + frameRate         
    
    if currFrame < nextFrame then
        love.timer.sleep(nextFrame - currFrame)
    end
end




function love.load()
    love.graphics.setDefaultFilter("nearest","nearest")


    tile_selector = TileSelector:init()
    tile_selector:loadTileSheet("assets/all-tiles.png")
    tile_selector:sliceTileSheet(16)

    level =  Level:init()
    level.tile_selector = tile_selector


    map_editor =  MapEditor:init()
    collistion_setter =  CollistionSetter:init()

    map_editor.tile_selector = tile_selector
    map_editor.collistion_setter = collistion_setter

    collistion_setter.map_editor = map_editor
    collistion_setter:initGrid()


    scenes = {level,tile_selector}
    sceneIndex = 0

    scene = scenes[sceneIndex% #scenes + 1]
    scene:update()

end

function love.update(dt)

    input()
    frameRateCap()




    if not editCollistion then
        scene:update()
    end

    if editCollistion then
        collistion_setter:update()        
    end
    



end

function love.draw()
    scene:render()
    if editCollistion then
        collistion_setter:render()
    end


end


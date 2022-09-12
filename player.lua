require "utils"

Player = {}

function Player:new(obj)
    obj = obj or {}
    setmetatable(obj,self)
    self.__index = self

    self.x, self.y , self.w , self.h =  0 , 0 , 26 ,26 
    self.wallCollistionRect = {}
    self.wallCollistionRect.x , self.wallCollistionRect.y , self.wallCollistionRect.w  , self.wallCollistionRect.h = 0 , 0 , self.w + 5 , self.h + 5
    
    self.velX , self.velY = 0 , 0
    
    self.speed = 7

    self.gravityForce = 1.4
    
    self.jumpForce = -18
    self.isJumping = false
    self.isGrounded = true
    
    self.coyoteDefualtTime = 9
    self.coyoteTime = self.coyoteDefualtTime
    
    self.spaceKeyUp = false
    self.collidingWithWall = false
    self.wallCollistionDir = 0
    
    self.wallJumpForceX = 1
    self.wallJumpForceY = -10
    self.wallJumpDurDefault = 6
    self.wallJumpDur = self.wallJumpDurDefault  
    self.isWallJumping = false

    self.isWallSliding = false
    self.wallFriction = 0.5


    return obj
end
function Player:setRect(x,y,w,h)
    self.x = x or self.x
    self.y = y or self.y
    self.w = w or self.w
    self.h = h or self.h
end


function Player:input()
    if love.keyboard.isDown("d","right") then
        self.velX = 1 
        self:slidingOnWall()

    elseif love.keyboard.isDown("a","left") then
        self.velX = -1 
        self:slidingOnWall()
    else
        self.velX = 0 
    end


    if love.keyboard.isDown("space")  then
        if self.isGrounded and self.spaceKeyUp then
        self.spaceKeyUp = false
        self.isJumping = true
            self.isGrounded = false
            self:jump()
        elseif self.collidingWithWall and self.isJumping and self.spaceKeyUp then
            self.isWallJumping = true
            
        end
    else
        self.spaceKeyUp = true
    end 
end 

function Player:slidingOnWall()
    if not self.isJumping or self.velY < 0 or not self.isWallSliding then
        return
    end
    self.velY =  self.velY  * self.wallFriction
end

function Player:wallJump()
    if not self.isWallJumping then
        return
    end
    
    self.wallJumpDur = self.wallJumpDur - love.timer.getDelta() * 60
    self.velX =  self.wallCollistionDir * self.wallJumpForceX
    self.velY =  self.wallJumpForceY
    
    if self.wallJumpDur < 0 then
        self.isWallJumping = false
        self.wallJumpDur = self.wallJumpDurDefault
    end 

end

function Player:jump()
    if not self.jumpHigher then
        self.velY =  self.jumpForce
    else        
        self.velY =  self.jumpForce+ 10
    end
end


function Player:gravity()
    self.velY =  self.velY  + self.gravityForce 
end

function Player:move(tiles)


    self.x = self.x + self.velX * love.timer.getDelta() * 60 * self.speed
   
    self.collidingWithWall = false
    self.isWallSliding = false

    for _ , tile in pairs(tiles) do

        if AABB(self.wallCollistionRect,tile) then
            self.collidingWithWall = true
        end
        if AABB(self,tile) then
                self.isWallSliding = true   
            if self.x > tile.x then
                self.x = tile.x + tile.w
                self.wallCollistionDir = 1
            end
            if self.x < tile.x then
                self.x = tile.x - self.w
                self.wallCollistionDir = -1
            end
        end        
    end

    self.y = self.y + self.velY * love.timer.getDelta() * 60  
    
    self.isGrounded = false
    for _ , tile in pairs(tiles) do
        if AABB(self,tile) then
            if self.y > tile.y then
                self.y = tile.y + tile.h
                self.velY = 0
            end 
            if self.y < tile.y then
                self.y = tile.y - self.h
                self.coyoteTime = self.coyoteDefualtTime
                self.velY = 0
                self.isGrounded = true
                self.isJumping = false
            end
        end        
    end

    if not self.isGrounded and not self.isJumping then
        if self.coyoteTime > 0 then
            self.isGrounded = true
            self.coyoteTime = self.coyoteTime - love.timer.getDelta() * 60
        end
    end
    
    self.wallCollistionRect.x = self.x - 5 / 2
    self.wallCollistionRect.y = self.y -5 / 2

end

function Player:bounderies()

end 
function Player:update(tiles)
    self:input()
    self:wallJump()
    self:gravity()
    self:move(tiles)
    self:bounderies()

end

function Player:render()
    love.graphics.rectangle("fill",self.x,self.y,self.w,self.h)
    -- love.graphics.rectangle("line",self.wallCollistionRect.x,self.wallCollistionRect.y,self.wallCollistionRect.w,self.wallCollistionRect.h)
end



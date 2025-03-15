local le = love.event
local ls = love.system
local lw = love.window
local lg = love.graphics

local vector = require "src.vector"

local Player  = {}
Player.bounds = {x=-15,y=-50, w=30,h=50}
Player.pos    = vector.new()
Player.vel    = vector.new(0,1)
Player.target = vector.new()

Player.game   = nil
Player.mytree = nil

Player.health = 100
Player.energy = 100
Player.body_hidration  = 100
Player.body_temperature = 30

local _player_vector_pool = {}
for i=1,5 do
    table.insert(_player_vector_pool, vector.new())
end

local Player_MT = {}
Player_MT.__index = Player_MT

function Player_MT.get_bounds(self)
    return
        self.pos.x + self.bounds.x,
        self.pos.y + self.bounds.y,
        self.bounds.w,self.bounds.h
end

function Player_MT.update(self, dt)
    if self.pos == self.target then
        for _,it in ipairs(self.game.entities) do
            local abs_len = self.pos:distance(it.pos)
            self.mytree = (self ~= it and abs_len < 30) and it or nil
            if self.mytree then break end
        end return
    end

    self.mytree = nil
    local abs_len = math.abs(
        self.pos:distance_squared(self.target)
    )

    local pool = _player_vector_pool
    self.pos:add(self.vel:mul(400 * dt, pool[1]), pool[2])
    pool[2]:clone(self.pos)
    
    if abs_len <= self.bounds.h*0.3 then
        self.target:clone(self.pos)
    end
end

function Player_MT.set_target(self, tx,ty)
    self.target.x,self.target.y = tx,ty

    local angle = self.pos:look_at(self.target)
    self.vel:set_angle(angle)
end

function Player_MT.draw(self)
    local x,y,w,h = self:get_bounds()
    
    lg.setColor(1, 0x18/0xff, 0x18/0xff, 1)
    lg.rectangle("fill", x,y,w,h, 4)

    lg.setColor(0,0,0)
    lg.print(tostring(self.mytree), x, y)
end

function Player_MT.on_mousepressed(self,x,y,btn)
    local pool = _player_vector_pool
    pool[4].x, pool[4].y = x, y
    local dist = self.mytree and math.abs(self.mytree.pos:distance(pool[4]))
    
    if self.mytree and dist and dist < 30 then
        self.mytree:damage()
    else
        self:set_target(x, y)
    end
end

setmetatable(Player, Player_MT)
return Player

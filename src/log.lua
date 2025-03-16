local vector = require "src.vector"

local lg = love.graphics

local Log_MT = {}
Log_MT.__index = Log_MT

function Log_MT.update(self, dt)
end

function Log_MT.draw(self)
    lg.setColor(1,1,1)
    lg.print("GOD. DAMN IT!", self.pos.x, self.pos.y)
end

local function new(game, x, y, length, wide)
    local log = {}
    log.pos = vector.new(x,y)
    log.length = length
    log.wide = wide

    setmetatable(log, Log_MT)
    return log
end

return {new=new}

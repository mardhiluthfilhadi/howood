local vector = require "src.vector"

local lg = love.graphics

local Log_MT = {}
Log_MT.__index = Log_MT

function Log_MT.update(self, dt)
    if  not self.ready_to_pick and
        self.tree_parent and
        not self.tree_parent.active
    then
        self.ready_to_pick = true
        self.tree_parent = nil
    end
end

function Log_MT.draw(self)
    lg.setColor(1,1,1)
    lg.rectangle("fill", self.pos.x, self.pos.y-self.wide, self.length, self.wide)
end

local function new(game, tree_parent, x, y, length, wide)
    local log = {}
    
    log.game = game
    log.tree_parent = tree_parent
    log.ready_to_pick = false
    log.working_pos = vector.new(x+length/2, y-wide/2)
    
    log.pos    = vector.new(x,y)
    log.wide   = wide
    log.length = length

    setmetatable(log, Log_MT)
    return log
end

return {new=new}

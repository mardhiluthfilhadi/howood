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
    local s = lg.getShader()
    
    self.game.TREE_SHADER:send("angle", math.rad(0))
    lg.setShader(self.game.TREE_SHADER)
    lg.setColor(1,1,1)

    local x,y = self.pos.x, self.pos.y-self.wide
    local w,h = self.length, self.wide
    lg.rectangle("fill", x,y,w,h)

    lg.setShader(s)
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

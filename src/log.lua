local vector = require "src.vector"

local lg = love.graphics

local Log_MT = {}
Log_MT.__index = Log_MT

function Log_MT.pick(self, picker)
    self.ready_to_pick = true
    self.picker = picker
end

function Log_MT.put_down(self, x, y)
    self.picker = nil
    self.ready_to_pick = true
    self.pos.x = x
    self.pos.y = y
    
    self.working_pos.x = self.pos.x+self.length/2
    self.working_pos.y = self.pos.y+self.wide/2
end

function Log_MT.update(self, dt)
    if  not self.ready_to_pick and
        self.tree_parent and
        not self.tree_parent.active
    then
        self.ready_to_pick = true
        self.tree_parent = nil
    end

    if self.picker then
        local x,y,w  = self.picker:get_bounds()
        self.pos.x = x + w - self.length/2
        self.pos.y = y
    end
end

function Log_MT.draw(self)
    lg.setColor(.4, .26, .13, 1)

    local x,y = self.pos.x, self.pos.y-self.wide
    local w,h = self.length, self.wide
    lg.rectangle("fill", x,y,w,h)
end

local function new(game, tree_parent, x, y, length, wide)
    local log = {}
    
    log.game = game
    log.tree_parent = tree_parent

    log.picker = nil
    log.ready_to_pick = false
    log.working_pos = vector.new(x+length/2, y-wide/2)
    
    log.pos    = vector.new(x,y)
    log.wide   = wide
    log.length = length

    setmetatable(log, Log_MT)
    return log
end

return {new=new}

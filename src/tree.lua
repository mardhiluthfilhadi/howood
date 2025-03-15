local vector = require "src.vector"

local lg = love.graphics

local _2RAD = math.pi/180
local TREE_SEGMENTS =   7
local TREE_BASE_LEN =  40
local TREE_LEN_DECR = 0.8
local _90_DEG_ANGLE = -90*_2RAD

local _tree_vector_pool = {}
for i=1,5 do
    table.insert(_tree_vector_pool, vector.new())
end

local Tree_MT = {}
Tree_MT.__index = Tree_MT

local function draw_trunk(self)
    local base_len = TREE_BASE_LEN
    local pool = _tree_vector_pool

    local p0 = pool[1]
    local p1 = pool[2]

    self.pos:clone(p0)
    self.pos:add(p1:set_length(base_len):set_angle(_90_DEG_ANGLE), p1)
    lg.line(p0.x, p0.y, p1.x, p1.y)
    
    for _,it in ipairs(self.segments) do
        local angle = it:angle()
        base_len = base_len * TREE_LEN_DECR
        
        p1:clone(p0)
        p0:sub(p1:set_angle(angle):set_length(base_len), p1)
        lg.line(p0.x, p0.y, p1.x, p1.y)
    end
end

function Tree_MT.draw(self)
    draw_trunk(self)
end

local function new(x,y,base_trunk_h)
    local base_dir = (math.random()>=0.5) and 1 or -1
    
    local tree = {}
    tree.base_trunk_h = base_trunk_h

    tree.pos = vector.new(x,y)
    tree.segments = {}

    local offset  = (15+math.random()*15 * _2RAD)*base_dir
    local segment = vector.from_angle(offset+_90_DEG_ANGLE)
    table.insert(tree.segments, segment)

    for i=1, TREE_SEGMENTS do
        base_dir = base_dir *-1
        offset   = (15+math.random()*15 * _2RAD)*base_dir
        segment  = vector.from_angle(offset+_90_DEG_ANGLE)
        
        table.insert(tree.segments, segment)
    end

    setmetatable(tree, Tree_MT)
    return tree
end

return {new=new}

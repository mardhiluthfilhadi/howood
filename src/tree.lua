local vector = require "src.vector"

local lg = love.graphics

local _2RAD = math.pi/180
local TREE_BASE_WID =   3
local TREE_SEGMENTS =   7
local TREE_BASE_LEN =  40
local TREE_LEN_DEC1 = 0.7
local TREE_LEN_DEC2 = 0.9
local _90_DEG_ANGLE = -90*_2RAD

local _tree_vector_pool = {}
for i=1,12 do
    table.insert(_tree_vector_pool, vector.new())
end

local Tree_MT = {}
Tree_MT.__index = Tree_MT

function Tree_MT.update(self, dt)
    if self.health <= 0 then
        self.base_trunk_a = self.base_trunk_a + dt
    end
end

local function draw_branch(p, angle, len)
    local pool = _tree_vector_pool
    
    local p1 = pool[7]
    local p2 = pool[8]

    p1:set_angle(angle + _90_DEG_ANGLE):set_length(len*1.5, p1)
	p:sub(p1, p1)
	
    p2:set_angle(angle + _90_DEG_ANGLE):set_length( len*1.5, p2)
	p:add(p2, p2)

    lg.line(p1.x, p1.y, p.x , p.y)
    lg.line(p.x , p.y , p2.x, p2.y)
end

local function draw_trunk(self)
    local base_len  = TREE_BASE_LEN
    local base_wide = TREE_BASE_WID
    local pool = _tree_vector_pool

    local p0 = pool[1]
    local p1 = pool[2]
    local l0 = pool[3]
    local r0 = pool[4]
    local l1 = pool[5]
    local r1 = pool[6]

    self.pos:clone(p0)    
    self.pos:add(
        p1:set_length(self.base_trunk_h):set_angle(self.base_trunk_a), p1
    )

    p0:clone(l0).x = p0.x-base_wide
    p0:clone(r0).x = p0.x+base_wide

    base_wide = base_wide * TREE_LEN_DEC2
    
    p1:clone(l1).x = p1.x-base_wide
    p1:clone(r1).x = p1.x+base_wide

    lg.polygon(
        "fill",
        l1.x,l1.y, r1.x,r1.y,
        r0.x,r0.y, l0.x,l0.y
    )
    
    for _,it in ipairs(self.segments) do
        local angle = it:angle()
        base_len = base_len * TREE_LEN_DEC1
        
        p1:clone(p0)
        p0:sub(p1:set_angle(angle):set_length(base_len), p1)

        p0:clone(l0).x = p0.x-base_wide
        p0:clone(r0).x = p0.x+base_wide

        base_wide = base_wide * TREE_LEN_DEC2
        
        p1:clone(l1).x = p1.x-base_wide
        p1:clone(r1).x = p1.x+base_wide

        lg.polygon(
            "fill",
            l1.x,l1.y, r1.x,r1.y,
            r0.x,r0.y, l0.x,l0.y
        )

        draw_branch(p0, angle, base_len)
    end
end

function Tree_MT.draw(self)
    lg.setColor(.5, .9, .1, 1)
    draw_trunk(self)
end

function Tree_MT.damage(self)
    self.health = self.health - 1
end

local function new(x,y,base_trunk_h)
    local base_len = TREE_BASE_LEN
    local base_dir = (math.random()>=0.5) and 1 or -1
    local height = base_trunk_h
    
    local tree = {}
    tree.health = 3
    tree.base_trunk_h = base_trunk_h
    tree.base_trunk_a = _90_DEG_ANGLE

    tree.pos = vector.new(x,y)
    tree.segments = {}

    local offset  = (15+math.random()*5 * _2RAD)*base_dir
    local segment = vector.from_angle(offset+_90_DEG_ANGLE)
    table.insert(tree.segments, segment)

    for i=1, TREE_SEGMENTS do
        base_len = base_len * TREE_LEN_DEC1
        height = height + base_len

        base_dir = base_dir *-1
        offset   = (15+math.random()*5 * _2RAD)*base_dir
        segment  = vector.from_angle(offset+_90_DEG_ANGLE)
        
        table.insert(tree.segments, segment)
    end
    tree._canvas = lg.newCanvas(TREE_BASE_LEN*2, height)

    setmetatable(tree, Tree_MT)
    return tree
end

return {new=new}

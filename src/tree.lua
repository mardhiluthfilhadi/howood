local vector = require "src.vector"

local lg = love.graphics

local TREE_BASE_WID =   3
local TREE_SEGMENTS =   7
local TREE_BASE_LEN =  40
local TREE_LEN_DEC1 = 0.7
local TREE_LEN_DEC2 = 0.9
local _90_DEG_ANGLE = math.rad(-90)

local TREE_STAND   = 0
local TREE_FALLEN  = 1
local TREE_CLEAN   = 2
local TREE_CHOPPED = 4

local _tree_vector_pool = {}
for i=1,12 do
    table.insert(_tree_vector_pool, vector.new())
end


local Tree_MT = {}
Tree_MT.__index = Tree_MT

function Tree_MT.update(self, dt)
    if self.state==TREE_STAND and self.health <= 0 then
        self.base_trunk_a = self.base_trunk_a + self.falling_dir*dt*4
        
        if (self.base_trunk_a >= math.rad(-3) and
            math.rad(10) >= self.base_trunk_a) or
           (self.base_trunk_a <= math.rad(-177) and
            math.rad(-190) <= self.base_trunk_a)
        then
            self.state = TREE_FALLEN
        end
    end
end

local function draw_branch(p, angle, len)
    local pool = _tree_vector_pool
    
    local p1 = pool[7]
    local p2 = pool[8]

    p1:set_angle(angle + _90_DEG_ANGLE):set_length(len*1.5, p1)
	p:sub(p1, p1)
	
    p2:set_angle(angle + _90_DEG_ANGLE):set_length(len*1.5, p2)
	p:add(p2, p2)

    lg.line(p1.x, p1.y, p.x , p.y)
    lg.line(p.x , p.y , p2.x, p2.y)
end

local function draw_trunk(self)
    local base_len   = TREE_BASE_LEN
    local base_len_p = self.base_trunk_h
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
        p1:set_length(self.base_trunk_h)
            :set_angle(self.base_trunk_a),p1
    )

    l0:set_angle(self.base_trunk_a+_90_DEG_ANGLE)
        :set_length(base_wide)

    p0:sub(l0,l0)

    r0:set_angle(self.base_trunk_a+_90_DEG_ANGLE)
        :set_length(base_wide)
        
    p0:add(r0, r0)

    base_wide = base_wide * TREE_LEN_DEC2
    
    l1:set_angle(self.base_trunk_a+_90_DEG_ANGLE)
        :set_length(base_wide)

    p1:sub(l1,l1)

    r1:set_angle(self.base_trunk_a+_90_DEG_ANGLE)
        :set_length(base_wide)
        
    p1:add(r1, r1)

    local s = lg.getShader()

    self.game.TREE_SHADER:send("angle", self.base_trunk_a)
    lg.setShader(self.game.TREE_SHADER)
    if self.chopped < 1 then
        lg.polygon(
            "fill",
            l1.x,l1.y, r1.x,r1.y,
            r0.x,r0.y, l0.x,l0.y
        )
    end

    for i=1, TREE_SEGMENTS do
        local it = self.segments[i]

        local angle = self.base_trunk_a + it:angle()
        base_len = base_len * TREE_LEN_DEC1
        
        p1:clone(p0)
        p0:add(p1:set_angle(angle):set_length(base_len), p1)

        l0:set_angle(angle+_90_DEG_ANGLE):set_length(base_wide)
        p0:sub(l0,l0)

        r0:set_angle(angle+_90_DEG_ANGLE):set_length(base_wide)
        p0:add(r0, r0)

        base_wide = base_wide * TREE_LEN_DEC2
        
        l1:set_angle(angle+_90_DEG_ANGLE):set_length(base_wide)
        p1:sub(l1,l1)

        r1:set_angle(angle+_90_DEG_ANGLE):set_length(base_wide)
        p1:add(r1, r1)

        self.game.TREE_SHADER:send("angle", angle)
        lg.setShader(self.game.TREE_SHADER)
        if i>self.chopped-1 then
            lg.polygon(
                "fill",
                l1.x,l1.y, r1.x,r1.y,
                r0.x,r0.y, l0.x,l0.y
            )

            if self.dirty then
                local log_x = (self.falling_dir<0) and
                    self.working_pos.x-base_len*2 or
                    self.working_pos.x

                self.game:add_tree_log(
                    self, log_x, self.working_pos.y,
                    base_len_p, base_wide*2
                )
                
                p0:clone(self.working_pos)
                
                self.dirty = false
            end
        end

        lg.setShader(s)
        if i>self.fall_branch then
            draw_branch(p0, angle, base_len)
        end

        base_len_p = base_len_p * TREE_LEN_DEC1
    end
end

function Tree_MT.draw(self)
    lg.setColor(.4, .26, .13, 1)
    draw_trunk(self)
end

function Tree_MT.damage(self)
    if self.state==TREE_STAND then
        self.health = self.health - 1
        
    elseif self.state==TREE_FALLEN then
        self.fall_branch = self.fall_branch + 1
        if self.fall_branch > TREE_SEGMENTS then
            self.state = TREE_CLEAN
        end

    elseif self.state==TREE_CLEAN then
        self.chopped = self.chopped + 1
        self.dirty   = true
        if self.chopped > TREE_SEGMENTS then
            self.state  = TREE_CHOPPED
            self.active = false
        end

    end
end

local function new(game, x,y,base_trunk_h)
    local base_dir = (math.random()>=0.5) and 1 or -1
    
    local tree = {}
    tree.game  = game

    tree.active  = true
    tree.state   = TREE_STAND
    tree.health  = 3
    tree.chopped = 0
    tree.fall_branch  = 0
    tree.falling_dir = (x > game.width/2) and -1 or 1
    
    tree.base_trunk_h = base_trunk_h
    tree.base_trunk_a = _90_DEG_ANGLE

    tree.pos = vector.new(x,y)
    tree.segments = {}

    tree.dirty = false
    tree.working_pos = tree.pos:clone()
    
    local offset  = math.rad(5+math.random()*15)*base_dir
    local segment = vector.from_angle(offset)
    table.insert(tree.segments, segment)

    for i=1, TREE_SEGMENTS do
        base_dir = base_dir *-1
        offset   = math.rad(5+math.random()*15)*base_dir
        segment  = vector.from_angle(offset)
        
        table.insert(tree.segments, segment)
    end

    setmetatable(tree, Tree_MT)
    return tree
end

return {new=new}

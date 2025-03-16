local vector = require "src.vector"
local tree = require "src.tree"
local log = require "src.log"

local le = love.event
local ls = love.system
local lw = love.window
local lg = love.graphics

local OS = ls.getOS()

local Game  = {}
Game.width  = 600
Game.height = 600

Game.day      = 0
Game.clock    = 8
Game.minutes  = 0
Game.timer_a  = 0
Game.hardness = 1

Game.player = require "src.player"
Game.player.game = Game

Game.trees = {}
Game.tree_logs = {}
Game.tree_brances = {}

Game.entities = {Game.player}

Game._offsetx = 0
Game._offsety = 0
Game._screen_to_world = 1
Game._world_to_screen = 1
Game._canvas = lg.newCanvas(Game.width, Game.height)

local Game_MT = {}
Game_MT.__index = Game_MT

function Game_MT.load(self)
    collectgarbage("stop")

    local fullscreen = OS == "Android" or  OS == "IOS"
    local resizable  = OS ~= "Android" and OS ~= "IOS"
    local sw,sh =
        (OS == "Android" or OS == "IOS") and 0 or self.width,
        (OS == "Android" or OS == "IOS") and 0 or self.height

    lw.setMode(sw, sh, {
        fullscreen = fullscreen,
        resizable  = resizable ,
        centered   = true      ,
    })

    self.timer_a = love.timer.getTime()
end

function Game_MT.update(self, dt)
    local elapsed_sec = love.timer.getTime()-self.timer_a
    local new_clock = math.floor(elapsed_sec/30)
    self.minutes = elapsed_sec*2
    
    if new_clock > 0 then
        self.clock = self.clock + 1
        self.timer_a = love.timer.getTime()

        if self.clock == 24 then
            self.day = self.day + 1
            self.clock = 0
        end
    end
    
    local sw,sh = lg.getDimensions()
    self._screen_to_world = (sw <= sh) and
        sw/self.width or sh/self.height
        
    self._world_to_screen = (sw <= sh) and
        self.width/sw or self.height/sh

    self._offsetx = (sw > sh) and
        sw/2 - (self.width  * self._screen_to_world)/2 or 0

    self._offsety = (sw < sh) and
        sh/2 - (self.height * self._screen_to_world)/2 or 0

    for _,it in ipairs(self.entities) do
        it:update(dt)
    end
    table.sort(self.entities, function(a,b)
        return a.pos.y < b.pos.y
    end)
end

function Game_MT.draw(self)
    lg.setCanvas(self._canvas)

        lg.clear(0x18/0xff, 0x18/0xff, 0x18/0xff, 1)
        for _,it in ipairs(self.entities) do
            it:draw()
        end

    lg.setCanvas()

    lg.setColor(1,1,1)
    lg.draw(
        self._canvas, self._offsetx, self._offsety, 0,
        self._screen_to_world, self._screen_to_world
    )

    lg.setColor(1, .2, .2, .8)
    lg.rectangle("fill", 0,0, 200, 100, 12)

    lg.setColor(0,0,0,1)
    lg.print("Garbage: " .. collectgarbage("count"), 20, 20)
    lg.print("FPS: " .. love.timer.getFPS(), 20, 40)
    local clock = string.format("Clock (%02d : %02d)", self.clock, self.minutes)
    lg.print(clock, 20, 60)
end

function Game_MT.add_tree_log(self, x, y, length, wide)
    local l = log.new(self,x,y,length,wide)
    table.insert(self.tree_logs, l)
    table.insert(self.entities, l)
end

function Game_MT.add_tree(self,x,y)
    local t = tree.new(self, x,y, 40 + math.random()*40)
    table.insert(self.trees, t)
    table.insert(self.entities, t)
end

function Game_MT.keypressed(self, key)
    if key=="escape" then le.quit() end
end

function Game_MT.mousepressed(self, x, y, btn)
    x = (x - self._offsetx) * self._world_to_screen
    y = (y - self._offsety) * self._world_to_screen
    
    if btn==1 then self.player:on_mousepressed(x,y) end
    if btn==2 then self:add_tree(x,y) end
end

setmetatable(Game, Game_MT)
return Game

local le = love.event
local ls = love.system
local lw = love.window
local lg = love.graphics

local OS = ls.getOS()

local Game  = {}
Game.width  = 400
Game.height = 400

Game.player = require "src.player"

Game._offsetx = 0
Game._offsety = 0
Game._screen_to_world = 1
Game._world_to_screen = 1
Game._canvas = lg.newCanvas(Game.width, Game.height)

local Game_MT = {}
Game_MT.__index = Game_MT

function Game_MT.load(self)
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
end

function Game_MT.update(self, dt)
    local sw,sh = lg.getDimensions()
    self._screen_to_world = (sw <= sh) and
        sw/self.width or sh/self.height
        
    self._world_to_screen = (sw <= sh) and
        self.width/sw or self.height/sh

    self._offsetx = (sw > sh) and
        sw/2 - (self.width  * self._screen_to_world)/2 or 0

    self._offsety = (sw < sh) and
        sh/2 - (self.height * self._screen_to_world)/2 or 0

    self.player:update(dt)
end

function Game_MT.draw(self)
    lg.setCanvas(self._canvas)

        lg.clear(0x18/0xff, 0x18/0xff, 0x18/0xff, 1)
        self.player:draw()

    lg.setCanvas()

    lg.setColor(1,1,1)
    lg.draw(
        self._canvas, self._offsetx, self._offsety, 0,
        self._screen_to_world, self._screen_to_world
    )
end

function Game_MT.keypressed(self, key)
    if key=="escape" then le.quit() end
end

function Game_MT.mousepressed(self, x, y, btn)
    self.player:set_target(x,y)
end

setmetatable(Game, Game_MT)
return Game

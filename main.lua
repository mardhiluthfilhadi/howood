local game = require "src.game"

function love.load()
    game:load()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.keypressed(...)
    game:keypressed(...)
end
function love.mousepressed(...)
    game:mousepressed(...)
end

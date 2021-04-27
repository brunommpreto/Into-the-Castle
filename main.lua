local paused

function love.load(arg)
    scenemanager.set(TitleScene())
end

function love.update()
    local scene = scenemanager.get()

    if scene.update and not paused then
        scene:update()
    end
end

function love.keypressed(k)
    if k == "q" then
        paused = not paused
    end
    if k == "e" then
        lg.captureScreenshot(os.time() .. ".png")
    end
end

function love.draw()
    local scene = scenemanager.get()
    if scene.draw then
        scene:draw()
    end
end

love.run = require("engine")({
    gameWidth = 1024,
    gameHeight = 768,
})

input.addButton("left", {"a"})
input.addButton("right", {"d"})
input.addButton("jump", {"space", "w"})
input.addButton("shoot", {}, {1,2,3})

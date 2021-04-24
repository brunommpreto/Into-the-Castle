GameScene = class()

----------------------------------------------------------------------------------------------------
-- load the game map
----------------------------------------------------------------------------------------------------

local map = json.decode(love.filesystem.read("assets/map.ldtk"))
local levels = {}
local levelTexture = lg.newImage("assets/sprites/tile.png")
for levelIndex, level in ipairs(map.levels) do
    local currentLevel = {}
    levels[levelIndex] = currentLevel

    for _, layer in ipairs(level.layerInstances) do
        if layer.__identifier == "IntGrid" then
            local width, height = layer.__cWid, layer.__cHei

            local sb = lg.newSpriteBatch(levelTexture, width*height)

            -- load the data itself
            currentLevel.width = width
            currentLevel.height = height
            currentLevel.sprite = sb
            for i, v in ipairs(layer.intGridCsv) do
                local x, y = (i-1)%width + 1, math.floor((i-1)/width) + 1
                if not currentLevel[x] then currentLevel[x] = {} end
                currentLevel[x][y] = v

                -- add tiles to the spritebatch
                if v == 1 then
                    sb:add((x-1)*64 - 8, (y-1)*64 - 8)
                end
            end
        end

        if layer.__identifier == "Entities" then
            currentLevel.entities = layer.entityInstances
        end
    end
end

function GameScene:new()
    self.camera = {x=0,y=0}
    lg.setBackgroundColor(lume.color("#A7BFEF"))
    self:setLevel(1)
end

function GameScene:setLevel(index)
    self.levelIndex = index
    local level = self:getLevel()

    -- create all the entities in the list
    self.thingList = {}

    -- add the player if it already exists
    if self.player then table.insert(self.thingList, self.player) end

    for _, entity in ipairs(level.entities) do
        -- try to get the class from the global table, and make sure it exists
        local class = _G[entity.__identifier]
        if class and type(class) == "table" and class.getClass then
            local instance = class(entity.px[1], entity.px[2])

            -- save a reference to the player
            if class == Player then
                self.player = instance
            end

            table.insert(self.thingList, instance)
        else
            print("class " .. entity.__identifier .. " not found!")
        end
    end
end

function GameScene:getLevel()
    return levels[self.levelIndex]
end

function GameScene:update()
    for i, thing in ipairs(self.thingList) do
        thing:update()
    end

    local currentLevel = self:getLevel()
    local px, py = self.player.x - 1024/2, self.player.y - 768/2
    local cx, cy = currentLevel.width*64/2 - 1024/2, currentLevel.height*64/2 - 768/2
    self.camera.x = utils.clamp((px+cx)/2, 0, currentLevel.width*64 - 1024)
    self.camera.y = utils.clamp((py+cy)/2, 0, currentLevel.height*64 - 768)
end

function GameScene:isSolid(x,y)
    local level = self:getLevel()
    local x, y = math.floor(x/64)+1, math.floor(y/64)+1

    if level[x] and level[x][y] then
        return level[x][y] == 1
    end

    return false
end

function GameScene:draw()
    for i=math.min(#levels, self.levelIndex+3), self.levelIndex, -1 do
        lg.push()
        local depth = utils.map(i, self.levelIndex, self.levelIndex+10, 1, 0)^2

        if depth == 1 then
            lg.setColor(0,0,0)
        else
            lg.setColor(utils.colorGradient(1-depth, "#505B72", "#A7BFEF"))
        end

        lg.translate(-self.camera.x*depth, -self.camera.y*depth)
        local sprite = levels[i].sprite
        lg.translate(480, 4.5*64)
        lg.scale(depth)
        lg.translate(-480, -4.5*64)
        lg.draw(sprite)
        lg.pop()
    end

    lg.push()
    lg.translate(-self.camera.x, -self.camera.y)
    for i, thing in ipairs(self.thingList) do
        lg.setColor(1,1,1)
        thing:draw()
    end
    lg.setColor(1,1,1)
    lg.pop()
end

Thing = class()

function Thing:new(x, y)
    self.x = x
    self.y = y
    self.speed = {x=0,y=0}
    self.animIndex = 1
    self.animTimer = 0
end

function Thing:update()
end

function Thing:draw()
    if self.sprite then
        self:subdraw()
    end
end

function Thing:subdraw(x, y, frame, xs, ys)
    lg.draw(self.sprite.source, self.sprite[frame or math.floor(self.animIndex)], x or self.x, y or self.y, 0, xs or 1, ys or 1, self.sprite.size/2, self.sprite.size/2)
end

function Thing:animate(anim)
    self.animTimer = self.animTimer + (anim.speed or 0.1)
    self.animTimer = ((self.animTimer-1) % #anim) + 1
    self.animIndex = anim[math.floor(self.animTimer)]
end

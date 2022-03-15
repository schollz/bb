-- bb2

-- https://processing.org/examples/bouncybubbles.html
SCREEN_WIDTH=128
SCREEN_HEIGHT=64
SCREEN_MIN=0
T0=200 -- temperature
berendsen_coefficient=15
gravity=0.09
local Ball={}

function Ball:new (o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.x=o.x or 0
  o.y=o.y or 0
  o.vx=(math.random()-0.5)
  o.vy=(math.random()-0.5)
  o.diameter=o.diameter or 0
  o.id=o.id or 1
  o.others=o.others
  o.spring=o.spring or 0.09
  o.gravity=o.gravity or 0.09
  o.friction=o.friction or-0.9
  return o
end

function Ball:collide()
  for i=self.id+1,#self.others do
    local dx=self.others[i].x-self.x
    local dy=self.others[i].y-self.y
    local distance=math.sqrt(dx*dx+dy*dy)
    local minDist=self.others[i].diameter/2+self.diameter/2
    if (distance<minDist) then
      local angle=math.atan2(dy,dx)
      local targetX=self.x+math.cos(angle)*minDist
      local targetY=self.y+math.sin(angle)*minDist
      local ax=(targetX-self.others[i].x)*self.spring
      local ay=(targetY-self.others[i].y)*self.spring
      self.vx=self.vx-ax
      self.vy=self.vy-ay
      self.others[i].vx=self.others[i].vx+ax
      self.others[i].vy=self.others[i].vy+ay
    end
  end
end

function Ball:move()
  self.vy=self.vy+gravity
  self.vx=self.vx+(math.random()-0.5)/100
  self.x=self.x+self.vx
  self.y=self.y+self.vy
  if (self.x+self.diameter/2>SCREEN_WIDTH) then
    self.x=SCREEN_WIDTH-self.diameter/2
    self.vx=self.vx*self.friction
  elseif (self.x-self.diameter/2<SCREEN_MIN) then
    self.x=self.diameter/2
    self.vx=self.vx*self.friction
  end
  if (self.y+self.diameter/2>SCREEN_HEIGHT) then
    self.y=SCREEN_HEIGHT-self.diameter/2
    self.vy=self.vy*self.friction
  elseif (self.y-self.diameter/2<SCREEN_MIN) then
    self.y=self.diameter/2
    self.vy=self.vy*self.friction
  end
end

function Ball:redraw()
  screen.level(10)
  screen.circle(self.x,self.y,self.diameter/2)
  screen.fill()
end

function init()
  balls={}
  for i=1,12 do
    table.insert(balls,Ball:new{
      id=i,
      x=math.random(1,128),
      y=math.random(1,64),
      diameter=math.random(8,16),
      others=balls,
    })
  end

  clock.run(function()
    while true do
      clock.sleep(1/25)
      -- https://www2.mpip-mainz.mpg.de/~andrienk/journal_club/thermostats.pdf
      local T=0
      for _,ball in ipairs(balls) do
        ball:collide()
        ball:move()
        local mass=3.14159*(ball.diameter/2)^2
        T=T+mass*math.sqrt(ball.vx^2+ball.vy^2)
      end
      T=T/#balls
      print(T)
      -- local lambda=math.sqrt(T0/T)
      local lambda=math.sqrt(1+(T0/T-1)/berendsen_coefficient)
      for _,ball in ipairs(balls) do
        ball.vx=ball.vx*lambda
        ball.vy=ball.vy*lambda
      end
      redraw()
    end
  end)
end

function redraw()
  screen.clear()
  screen.blend_mode(4)
  for _,ball in ipairs(balls) do
    ball:redraw()
  end
  screen.update()
end

function enc(k,d)
  if k==3 then
    T0=util.clamp(T0+d,0.001,1000)
  end
end

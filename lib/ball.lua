local Ball={}

local function dot2d(a,b)
  return a[1]*b[1]+a[2]*b[2]
end

local function mag2d(v)
  return math.sqrt(v[1]^2+v[2]^2)
end

local function sign(x)
  if x<0 then
    return-1
  elseif x>0 then
    return 1
  end
  return 0
end

function Ball:new (o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.frozen=false
  o.a=o.a or {0,-10}
  o.aslide={0,0}
  o.v=o.v or {0,0} -- velocity
  o.vp=o.vp or {0,0} -- previous velocity
  o.t=0 -- time
  o.p=o.p or {0,0} -- position
  o.pp={o.p[1],o.p[2]} -- previous position
  o.ppp={o.p[1],o.p[2]} -- previous position
  o.dt=1
  return o
end

function Ball:v_mag()
  local v=self:v_ins()
  return math.sqrt((v[1]*v[1])+(v[2]*v[2])),v
end

function Ball:v_ins()
  local v={0,0}
  for i=1,2 do
    v[i]=(self.p[i]-self.pp[i])/self.dt
  end
  return v
end

function Ball:update_position(dt,lines)
  if self.frozen then
    do return end
  end
  self.dt=dt
  for i=1,2 do
    self.ppp[i]=self.pp[i]
    self.pp[i]=self.p[i] -- set previous position
    self.v[i]=self.vp[i]+self.a[i]*self.dt -- update velocity
    self.p[i]=self.p[i]+(self.v[i]+self.vp[i])/2*self.dt -- update position
    self.vp[i]=self.v[i] -- set previous velocity
  end
  self.collided=false
end

function Ball:update_collision(lines)
  if lines==nil or self.collided then
    do return end
  end
  -- check collisions against the lines
  local bline=line_:new{p={{x=self.pp[1],y=self.pp[2]},{x=self.p[1],y=self.p[2]}}}
  for i,line in ipairs(lines) do
    local collision=bline:intersescts_with(line)
    if collision then
      -- http://www.3dkingdoms.com/weekly/weekly.php?a=2
      local V=self.v
      local N=line:uvec_perp_to_p({x=self.pp[1],y=self.pp[2]})
      print("N")
      tab.print(N)
      local vdotn=dot2d(V,N)
      local b={0.95,0.95}
      for i=1,2 do
        self.vp[i]=b[i]*(-2*(vdotn)*N[i]+V[i])
        self.v[i]=self.vp[i]
      end
      print("new v")
      tab.print(self.v)
      self.p={self.pp[1]+self.v[1]*self.dt,self.pp[2]+self.v[2]*self.dt}
      self.pp={self.p[1],self.p[2]}
      self.ppp={self.p[1],self.p[2]}
      self.frozen=false
      self.collided=true
      break
    end
  end
end

function Ball:redraw()
  screen.level(5)
  screen.circle(self.pp[1],self.pp[2],2)
  screen.fill()
  screen.level(15)
  screen.circle(self.p[1],self.p[2],3)
  screen.fill()
end

return Ball

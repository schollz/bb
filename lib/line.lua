local Line={}

local function mag2d(v)
  return math.sqrt(v[1]^2+v[2]^2)
end

function Line:new (o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.l=o.l or 15
  o.w=o.w or 2
  o.p=o.p or {{x=0,y=0},{x=0,y=0}}
  return o
end

-- https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
-- given three collinear points p, q, r, the function checks if
-- point q lies on line segment 'pr'
function Line:on_segment(p,q,r)
  return ((q.x<=math.max(p.x,r.x)) and (q.x>=math.min(p.x,r.x)) and
  (q.y<=math.max(p.y,r.y)) and (q.y>=math.min(p.y,r.y)))
end

function Line:orientation(p,q,r)
  -- to find the orientation of an ordered triplet (p,q,r)
  -- function returns the following values:
  -- 0 : Collinear points
  -- 1 : Clockwise points
  -- 2 : Counterclockwise

  -- See https://www.geeksforgeeks.org/orientation-3-ordered-points/amp/
  -- for details of below formula.

  val=((q.y-p.y)*(r.x-q.x))-((q.x-p.x)*(r.y-q.y))
  if (val>0) then
    -- Clockwise orientation
    return 1
  elseif (val<0) then
    -- Counterclockwise orientation
    return 2
  else
    -- Collinear orientation
    return 0
  end
end

-- The main function that returns true if
-- the line segment 'p1q1' and 'p2q2' intersect.
function Line:do_intersect(p1,q1,p2,q2)

  -- Find the 4 orientations required for
  -- the general and special cases
  o1=self:orientation(p1,q1,p2)
  o2=self:orientation(p1,q1,q2)
  o3=self:orientation(p2,q2,p1)
  o4=self:orientation(p2,q2,q1)

  -- General case
  if ((o1~=o2) and (o3~=o4)) then
    return true
  end

  -- Special Cases

  -- p1 , q1 and p2 are collinear and p2 lies on segment p1q1
  if ((o1==0) and self:on_segment(p1,p2,q1)) then
    return true
  end

  -- p1 , q1 and q2 are collinear and q2 lies on segment p1q1
  if ((o2==0) and self:on_segment(p1,q2,q1)) then
    return true
  end

  -- p2 , q2 and p1 are collinear and p1 lies on segment p2q2
  if ((o3==0) and self:on_segment(p2,p1,q2)) then
    return true
  end

  -- p2 , q2 and q1 are collinear and q1 lies on segment p2q2
  if ((o4==0) and self:on_segment(p2,q1,q2)) then
    return true
  end

  -- If none of the cases
  return false
end

-- vector
function Line:vec()
  local v={self.p[2].x-self.p[1].x,self.p[2].y-self.p[1].y}
  return v
end

-- unit vector
function Line:uvec(v)
  local v=v or self:vec()
  local vmag=mag2d(v)
  v[1]=v[1]/vmag
  v[2]=v[2]/vmag
  return v
end

function Line:point_above(p)
  local m=self:slope()
  local b=self.p[1].y-m*self.p[1].x
  return p.y<m*p.x+b
end

-- unit vector perpindicular to the line that crosses into p
function Line:uvec_perp_to_p(p)
  -- https://stackoverflow.com/questions/1811549/perpendicular-on-a-line-from-a-given-point
  local dx=self.p[2].x-self.p[1].x
  local dy=self.p[2].y-self.p[1].y
  local mag=math.sqrt(dx*dx+dy*dy)
  dx=dx/mag
  dy=dy/mag

  -- translate the point and get the dot product
  local lambda=(dx*(p.x-self.p[1].x))+(dy*(p.y-self.p[2].y))
  local x4=(dx*lambda)+self.p[1].x
  local y4=(dy*lambda)+self.p[1].y
  local vec={p.x-x4,p.y-y4}
  local vmag=mag2d(vec)
  vec[1]=vec[1]/vmag
  vec[2]=vec[2]/vmag*-1
  return vec
  -- local m=-1*self:slope()
  -- print("m",m,self.p[1].x,self.p[1].y)
  -- local b=self.p[1].y-m*self.p[1].x
  -- local mp=-1/m
  -- local bp=p.y-mp*p.x
  -- print("mp",mp,"bp",bp)
  -- local vmag=mag2d({1,mp+bp})
  -- local v={-1/vmag,-(mp+bp)/vmag}
  -- return v
end

-- unit vector normal to x
function Line:uvec_nx()
  local v=v or self:uvec()
  v[2]=v[2]*-1
  return v
end
-- unit vector normal to x
function Line:uvec_nxy()
  local v=v or self:uvec()
  v[2]=v[2]*-1
  v[1]=v[1]*-1
  return v
end

-- unit vector normal to y
function Line:uvec_ny(v)
  local v=v or self:uvec()
  v[1]=v[1]*-1
  return v
end

function Line:angle_with_y_axis()
  local Y1=math.max(self.p[1].y,self.p[2].y)
  local Y2=math.min(self.p[1].y,self.p[2].y)
  local theta=math.acos((Y1-Y2)/math.sqrt((self.p[1].x-self.p[2].x)^2+(Y1-Y2)^2))
  if self:slope()<0 then
    theta=theta-3.14159/2
  end
  return theta
end

function Line:intersescts_with(another_line)
  return self:do_intersect(self.p[1],self.p[2],another_line.p[1],another_line.p[2])
end

function Line:angle_with(another_line)
  local m1=self:slope()
  local m2=another_line:slope()
  if m1*m2==1 then
    do return 0 end
  end
  local theta=math.atan((m2-m1)/(1+m1*m2))
  return theta
end

function Line:center()
  return {x=(self.p[1].x+self.p[2].x)/2,y=(self.p[1].y+self.p[2].y)/2}
end

function Line:slope()
  if self.p[2].x-self.p[1].x==0 then
    return 1000000
  else
    return (self.p[2].y-self.p[1].y)/(self.p[2].x-self.p[1].x)
  end
end

function Line:rotate(theta,mp)
  mp=mp or self:center()
  local p_mp={}
  local p_rot={}
  for i=1,2 do
    p_mp[i]={x=self.p[i].x-mp.x,y=self.p[i].y-mp.y}
  end
  for i=1,2 do
    p_rot[i]={
      x=math.cos(theta)*p_mp[i].x-math.sin(theta)*p_mp[i].y,
      y=math.sin(theta)*p_mp[i].x+math.cos(theta)*p_mp[i].y,
    }
    p_rot[i].x=p_rot[i].x+mp.x
    p_rot[i].y=p_rot[i].y+mp.y
    self.p[i]={x=p_rot[i].x,y=p_rot[i].y}
  end
end

function Line:redraw()
  screen.level(self.l)
  screen.line_width(self.w)
  screen.move(self.p[1].x,self.p[1].y)
  screen.line(self.p[2].x,self.p[2].y)
  screen.stroke()
end

return Line

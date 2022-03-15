-- bb

ball_=include("bb/lib/ball")
line_=include("bb/lib/line")

function init()
  walls={}
  balls={}
  for i=1,1 do
    table.insert(balls,ball_:new{a={0,1},p={64,32}})
  end

  -- table.insert(walls,line_:new{p={{x=-1,y=-1},{x=-1,y=65}}})
  -- table.insert(walls,line_:new{p={{x=129,y=-1},{x=129,y=65}}})
  -- table.insert(walls,line_:new{p={{x=-1,y=-1},{x=129,y=-1}}})
  -- table.insert(walls,line_:new{p={{x=-1,y=65},{x=129,y=65}}})
  -- table.insert(walls,line_:new{p={{x=30,y=1},{x=70,y=100}}})
  -- table.insert(walls,line_:new{p={{x=1,y=0},{x=128,y=74}}})
  -- table.insert(walls,line_:new{p={{x=120,y=-20},{x=128,y=84}}})
  -- table.insert(walls,line_:new{p={{x=1,y=-10},{x=128,y=-40}}})
  -- table.insert(walls,line_:new{p={{x=128,y=-30},{x=1,y=20}}})
  -- table.insert(walls,line_:new{p={{x=1,y=74},{x=128,y=10}}})
  local diff=10
  table.insert(walls,line_:new{p={{x=64-diff,y=0},{x=128-diff,y=64}}})
  table.insert(walls,line_:new{p={{x=0+diff,y=64},{x=64+diff,y=0}}})
  table.insert(walls,line_:new{p={{x=0,y=64-diff},{x=128,y=64-diff}}})
  for i,wall in ipairs(walls) do
    wall:rotate(3.4,{x=64,y=32})
  end

  redraw_clock=clock.run(function()
    while true do
      clock.sleep(1/15)
      update_all()
      redraw()
    end
  end)
end

function update_all()
  for _,ball in ipairs(balls) do
    ball:update_position(1)
  end
  for _,ball in ipairs(balls) do
    ball:update_collision(walls)
  end
  -- for i,wall in ipairs(walls) do
  --   wall:rotate(-0.04,{x=64,y=32})
  -- end
  for _,ball in ipairs(balls) do
    ball:update_collision(walls)
  end
end

function redraw()
  screen.clear()
  for _,w in ipairs(walls) do
    w:redraw()
  end
  for _,b in ipairs(balls) do
    b:redraw()
  end
  screen.update()
end

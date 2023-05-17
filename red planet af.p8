pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
function _init()
  map_setup()
  
--  player setup
  make_player()
  
  nosound = false
  
  game_win=false
  game_over=false
end

function _update()
  if (not game_over) then
    update_map() 
    move_player()
    
  --  updates player
    check_win_lose()
  else
    if (btnp(❎)) extcmd("reset")
  end
end

function _draw()
  cls()
  if (not game_over) then
    draw_map()
    draw_player()
   -- draws player
    if (btn(❎)) show_inventory()
  else 
    draw_win_lose()
  end
  
end

-->8
--map code

function map_setup()
  --timers
  timer=0
  anim_time=30
  
  --map tile settings
  wall=0
  key=1
  door=2
  anim1=3
  anim2=4
  coin=5
  lose=6
  win=7
end

function update_map()
  if (timer<0)then
    toggle_tiles()
    timer=anim_time
  end
  timer-=1
end

function draw_map()
  mapx=flr(p.x/16)*16
  mapy=flr(p.y/16)*16
  camera(mapx*8,mapy*8) 
  
  map(0,0,0,0,128,64)
end

function is_tile(tile_type,x,y)
  tile=mget(x,y)
  has_flag=fget(tile,tile_type)
  return has_flag  
end

function can_move(x,y  )
  return not is_tile(wall,x,y)
end

function swap_tile(x,y)
  tile=mget(x,y)
  mset(x,y,tile+1)
end

function unswap_tile(x,y)
  tile=mget(x,y)
  mset(x,y,tile-1)
end

function get_key(x,y)
  p.keys+=1
  swap_tile(x,y)
  sfx(1)
end

function get_coin(x,y)
  p.coins+=1
  swap_tile(x,y)
  sfx(1)
end


function open_door(x,y)
  p.keys-=1
  swap_tile(x,y)
  sfx(3)
end

-->8
--player code


function make_player()
  p={}
  p.x=3
  p.y=3
  p.dx=0
  p.dy=0
  p.f=0 
  p.keys=0
  p.coins=0
  p.sprite=16
end

function draw_player()
  spr(p.sprite,p.x*8,p.y*8)
end  

function move_player()
  newx=p.x
  newy=p.y

  if (btnp(⬅️)) newx-=1
  if (btnp(➡️)) newx+=1
  if (btnp(⬆️)) newy-=1  
  if (btnp(⬇️)) newy+=1  
  
  interact(newx,newy)
  
  if (can_move(newx,newy)) then
    p.x=mid(0,newx,127)
    p.y=mid(0,newy,63)
  
  else if no_sound == true then
     no_sound = false
  
  else
      sfx(0)
  end
  end
end

function interact(x,y)
  if (is_tile(key,x,y)) then
    no_sound = true
    get_key(x,y)

  elseif (is_tile(coin,x,y)) then
     no_sound = true
     get_coin(x,y)
  elseif (is_tile(door,x,y) and p.keys>0) then
    open_door(x,y) 
  end
end

-->8
--inventory code

function show_inventory()
  invx=mapx*8+40
  invy=mapy*8+8
  
  rectfill (invx,invy,invx+60,invy+36,0)
  print("inventory",invx+7,invy+4,7)
  print("keys "..p.keys,invx+12,invy+14,9)
  print("coins "..p.coins,invx+12,invy+24,9)  
end

-->8
--animation code

function spikesound(x,y)
 if (is_tile(lose,x,y)) then
  sfx(4)
 end
end

function toggle_tiles()
 for x=mapx,mapx+15 do
  for y=mapy,mapy+15 do
   if (is_tile(anim1,x,y)) then
    spikesound(x,y)
    swap_tile(x,y)
 
   elseif (is_tile(anim2,x,y)) then
    unswap_tile(x,y)
    spikesound(x,y)
   end  
  end
 end
end
-->8
--win-lose code

function check_win_lose()
 if (is_tile(win,p.x,p.y)) then
  game_win=true 
  game_over=true
 elseif (is_tile(lose,p.x,p.y)) then
  game_win=false
  game_over=true
 end
end

function draw_win_lose()
  camera()  
  if (game_win)then 
  print('you win!',37,64,7)
  else 
  print('you lose! try again.',37,64,7)
 end
 print('press ❎ to play again',20,75,5)
 
end
   
__gfx__
000000008888888888888888888141888881418833333333848484488dddddd8ffffffff22222222cc1122884499aa0000000000000000000000000000000000
00000000888888888898888888144188881441883333333344445444dd6dddddffffffff44444244cc1122884499aa0000000000000000000000000000000000
00700700888888888889888881444418814444183bb3333384444454dddd1ddd4444444422222222000000000000000000000000000000000000000000000000
0007700088888888882989888144441881444418333bb33344454448ddddddddffffffff42444444ccc1c1121228288400000000000000000000000000000000
00077000888888889882898814411418144114183333333354444444dddddd6dffffffff22222222cc1c11212282884800000000000000000000000000000000
0070070088888888899898881244444112444441333bb333844444441dd1ddddffffffff44444244c1c112122828848400000000000000000000000000000000
000000008888888888229888124144411241444133333bb344445444ddddd1dd44444444222222221c1121228288484400000000000000000000000000000000
000000008888888888882888812244188122441833333333844448488d6dddd8ffffffff42444444c11212282884844900000000000000000000000000000000
000110008888888888888888111c6d11333333333333333333314133dddddddd1111111111111111112122828848449400000000000000000000000000000000
0018c1008666888888888988cccccccc333333333333333333144133dd6ddddd4455554444ffff44121228288484494a00000000000000000000000000000000
0011110086768888888882981dd11c6d333333333bb3333331444413dddd1ddd255665522444445221228288484494a900000000000000000000000000000000
00011010868666668888829811111cd133333333333bb33331444413dddddddd456666544fffff541228288484494a9a00000000000000000000000000000000
001111108666767689888828cccccccc333333333333333314411413dddddd6d255555122fffff12228288484494a9aa00000000000000000000000000000000
0101100087778787298888881c6d111133333333333bb333b444444b1dd1dddd459a55544fffff54000000000000000000000000000000000000000000000000
0001010088888888828888881cd11dd13333333333333bb33bbbbbb3ddddd1dd25555512244444124499aa00088eeff700000000000000000000000000000000
001101108888888888888888cccccccc333333333333333333333333dd6ddddd455555544fffff544499aa00088eeff700000000000000000000000000000000
0000000042422424444444245555555555514155555555558888887888888828dddccdddddd88ddd000000000000000000000000000000000000000000000000
0001100042422424424a94245155555555144155515555518888827288888262ddc88cdddd8cc8dd000000000000000000000000000000000000000000000000
0018c10042422424411515145555515551444415555555558788882882888828dc8cc8cdd8c88c8d000000000000000000000000000000000000000000000000
001111004444444411115151555555555144441555fffa552728888826288888c8c88c8c8c8cc8c8000000000000000000000000000000000000000000000000
00011111151a915111151515555555551441141555f44a558288888882888888ddd88ddddddccddd000000000000000000000000000000000000000000000000
00111000424a9424424a9424555551551244444155a49a558888878888888288dddccdddddd88ddd000000000000000000000000000000000000000000000000
010110004242242442422424555155551241444115aaaa558888272888882628ddd88ddddddccddd000000000000000000000000000000000000000000000000
0011110042422424424224245555555551224415555555158888828888888288dddccdddddd88ddd000000000000000000000000000000000000000000000000
00000000ffffffffffffffffdddddddddddddddddddddddddddddd7ddddddd2d0000000000000000000000000000000000000000000000000000000000000000
00000000f999ffffffffffffd6ddddd1dd6ddddddd6dddddddddd272ddddd2620000000000000000000000000000000000000000000000000000000000000000
0000000049a9444444444444dddddddddddd1ddddddd1dddd7dddd2dd2dddd2d0000000000000000000000000000000000000000000000000000000000000000
00000000f9f99999ffffffffddf7fadddddddddddddddddd272ddddd262ddddd0000000000000000000000000000000000000000000000000000000000000000
00000000f999a9a9ffffffffddf44adddddddd6ddddddd6dd2ddddddd2dddddd0000000000000000000000000000000000000000000000000000000000000000
00000000faaafafaffffffffdda49add1dd1dddd1dd1ddddddddd7ddddddd2dd0000000000000000000000000000000000000000000000000000000000000000
0000000044444444444444441daaaaddddddd1ddddddd1dddddd272ddddd262d0000000000000000000000000000000000000000000000000000000000000000
00000000ffffffffffffffffdddddd6ddd6ddddddd6dddddddddd2ddddddd2dd0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88814188888141888888888884848448848484488888888888888888888888888888888888888888888888888888888888814188888888888888888888888888
88144188881441888888888844445444444454448888888888888888888888888888888888888888889888888888888888144188888888888888888888888888
81444418814444188888888884444454844444548888888888888888888888888888888888888888888988888888888881444418888888888888888888888888
81444418814444188888888844454448444544488888888888888888888888888888888888888888882989888888888881444418888888888888888888888888
14411418144114188888888854444444544444448888888888888888888888888888888888888888988289888888888814411418888888888888888888888888
12444441124444418888888884444444844444448888888888888888888888888888888888888888899898888888888812444441888888888888888888888888
12414441124144418888888844445444444454448888888888888888888888888888888888888888882298888888888812414441888888888888888888888888
81224418812244188888888884444848844448488888888888888888888888888888888888888888888828888888888881224418888888888888888888888888
88814188888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88144188888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
81444418888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
81444418888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
14411418888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
12444441888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
12414441888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
81224418888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
5555555588888888888888888dddddd8888888888888888888888888888888888888888888888888888888888888888888888888888888888881418888888888
515555558888888888888888dd6ddddd888888888888888888988888888888888888888888888888888888888888888888888888888888888814418888888888
555551558888888888888888dddd1ddd888888888888888888898888888888888888888888888888888888888888888888888888888888888144441888888888
555555558888888888888888dddddddd888888888888888888298988888888888888888888888888888888888888888888888888888888888144441888888888
555555558888888888888888dddddd6d888888888888888898828988888888888888888888888888888888888888888888888888888888881441141888888888
5555515588888888888888881dd1dddd888888888888888889989888888888888888888888888888888888888888888888888888888888881244444188888888
555155558888888888888888ddddd1dd888888888888888888229888888888888888888888888888888888888888888888888888888888881241444188888888
5555555588888888888888888d6dddd8888888888888888888882888888888888888888888888888888888888888888888888888888888888122441888888888
55555555888141888888888888888888888888888881418888888888888888888888888888888888888888888888888888888888888888888888888888888888
51555555881441888888888888888888888888888814418888888888888888888898888888888888888888888888888888888888888888888888888888888888
55555155814444188888888888888888888888888144441888888888888888888889888888888888888888888888888888888888888888888888888888888888
55555555814444188888888888888888888888888144441888888888888888888829898888888888888888888888888888888888888888888888888888888888
55555555144114188888888888888888888888881441141888888888888888889882898888888888888888888888888888888888888888888888888888888888
55555155124444418888888888888888888888881244444188888888888888888998988888888888888888888888888888888888888888888888888888888888
55515555124144418888888888888888888888881241444188888888888888888822988888888888888888888888888888888888888888888888888888888888
55555555812244188888888888888888888888888122441888888888888888888888288888888888888888888888888888888888888888888888888888888888
5555555588814188888141888888888888888888888888888dddddd8888888888888888888888888888888888888888888888888888888888888888888888888
515555558814418888144188888888888888888888888888dd6ddddd888888888888888888888888888888888888888888888888889888888888888888888888
555551558144441881444418888888888888888888888888dddd1ddd888888888888888888888888888888888888888888888888888988888888888888888888
555555558144441881444418888888888888888888888888dddddddd888888888888888888888888888888888888888888888888882989888888888888888888
555555551441141814411418888888888888888888888888dddddd6d888888888888888888888888888888888888888888888888988289888888888888888888
5555515512444441124444418888888888888888888888881dd1dddd888888888888888888888888888888888888888888888888899898888888888888888888
555155551241444112414441888888888888888888888888ddddd1dd888888888888888888888888888888888888888888888888882298888888888888888888
5555555581224418812244188888888888888888888888888d6dddd8888888888888888888888888888888888888888888888888888828888888888888888888
55555555555555558881418888814188888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
51555555515555558814418888144188888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555155555551558144441881444418888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555555558144441881444418888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555555551441141814411418888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555155555551551244444112444441888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55515555555155551241444112414441888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555555558122441881224418888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
555555555555555555555555888141888888888888888888888888888dddddd88888888888888888888888888888888888888888888888888888888888888888
51555555515555555155555588144188888888888888888888888888dd6ddddd8888888888888888888888888888888888888888888888888888888888888888
55555155555551555555515581444418888888888888888888888888dddd1ddd8888888888888888888888888888888888888888888888888888888888888888
55555555555555555555555581444418888888888888888888888888dddddddd8888888888888888888888888888888888888888888888888888888888888888
55555555555555555555555514411418888888888888888888888888dddddd6d8888888888888888888888888888888888888888888888888888888888888888
555551555555515555555155124444418888888888888888888888881dd1dddd8888888888888888888888888888888888888888888888888888888888888888
55515555555155555551555512414441888888888888888888888888ddddd1dd8888888888888888888888888888888888888888888888888888888888888888
555555555555555555555555812244188888888888888888888888888d6dddd88888888888888888888888888888888888888888888888888888888888888888
5555555555555555555555555555555588888888888888888888888888888888888888888dddddd8888888888888888888888888888888888888888888888888
515555555155555551555555515555558888888888888888888888888888888888888888dd6ddddd888888888888888888888888888888888888888888888888
555551555555515555555155555551558888888888888888888888888888888888888888dddd1ddd888888888888888888888888888888888888888888888888
555555555555555555555555555555558888888888888888888888888888888888888888dddddddd888888888888888888888888888888888888888888888888
555555555555555555555555555555558888888888888888888888888888888888888888dddddd6d888888888888888888888888888888888888888888888888
5555515555555155555551555555515588888888888888888888888888888888888888881dd1dddd888888888888888888888888888888888888888888888888
555155555551555555515555555155558888888888888888888888888888888888888888ddddd1dd888888888888888888888888888888888888888888888888
5555555555555555555555555555555588888888888888888888888888888888888888888d6dddd8888888888888888888888888888888888888888888888888
55555555555555555555555555555555555555558888888888888888888888888dddddd888888888888888888888888888888888888888888888888888888888
5155555551555555515555555155555551555555888888888888888888888888dd6ddddd88888888888888888888888888988888888888888888888888888888
5555515555555155555551555555515555555155888888888888888888888888dddd1ddd88888888888888888888888888898888888888888888888888888888
5555555555555555555555555555555555555555888888888888888888888888dddddddd88888888888888888888888888298988888888888888888888888888
5555555555555555555555555555555555555555888888888888888888888888dddddd6d88888888888888888888888898828988888888888888888888888888
55555155555551555555515555555155555551558888888888888888888888881dd1dddd88888888888888888888888889989888888888888888888888888888
5551555555515555555155555551555555515555888888888888888888888888ddddd1dd88888888888888888888888888229888888888888888888888888888
55555555555555555555555555555555555555558888888888888888888888888d6dddd888888888888888888888888888882888888888888888888888888888
111c6d11111c6d11111c6d11111c6d11111c6d115555555588888828888888288888882888888828888888288888888888888888888888888888888888888888
cccccccccccccccccccccccccccccccccccccccc5155555588888262888882628888826288888262888882628888888888888888888888888888888888888888
1dd11c6d1dd11c6d1dd11c6d1dd11c6d1dd11c6d5555515582888828828888288288882882888828828888288888888888888888888888888888888888888888
11111cd111111cd111111cd111111cd111111cd15555555526288888262888882628888826288888262888888888888888888888888888888888888888888888
cccccccccccccccccccccccccccccccccccccccc5555555582888888828888888288888882888888828888888888888888888888888888888888888888888888
1c6d11111c6d11111c6d11111c6d11111c6d11115555515588888288888882888888828888888288888882888888888888888888888888888888888888888888
1cd11dd11cd11dd11cd11dd11cd11dd11cd11dd15551555588882628888826288888262888882628888826288888888888888888888888888888888888888888
cccccccccccccccccccccccccccccccccccccccc5555555588888288888882888888828888888288888882888888888888888888888888888888888888888888
111c6d11dddddddddddddddddddddddd111c6d1155555555888888888dddddd8888888888dddddd8555555555555555555555555888141888888888888888888
ccccccccdd6ddddddd6ddddddd6dddddcccccccc5155555588888888dd6ddddd88888888dd6ddddd515555555155555551555555881441888888888888888888
1dd11c6ddddd1ddddddd1ddddddd1ddd1dd11c6d5555515588888888dddd1ddd88888888dddd1ddd555551555555515555555155814444188888888888888888
11111cd1dddddddddddddddddddddddd11111cd15555555588888888dddddddd88888888dddddddd555555555555555555555555814444188888888888888888
ccccccccdddddd6ddddddd6ddddddd6dcccccccc5555555588888888dddddd6d88888888dddddd6d555555555555555555555555144114188888888888888888
1c6d11111dd1dddd1dd1dddd1dd1dddd1c6d111155555155888888881dd1dddd888888881dd1dddd555551555555515555555155124444418888888888888888
1cd11dd1ddddd1ddddddd1ddddddd1dd1cd11dd15551555588888888ddddd1dd88888888ddddd1dd555155555551555555515555124144418888888888888888
ccccccccdd6ddddddd6ddddddd6dddddcccccccc55555555888888888d6dddd8888888888d6dddd8555555555555555555555555812244188888888888888888
111c6d11dddddddddddddddddddddddd111c6d115555555555555555555555558dddddd855555555555555555555555555555555555555558888888888888888
ccccccccd6ddddd1dd6dddddd6ddddd1cccccccc515555555155555551555555dd6ddddd51555555515555555155555551555555515555558888888888888888
1dd11c6ddddddddddddd1ddddddddddd1dd11c6d555551555555515555555155dddd1ddd55555155555551555555515555555155555551558888888888888888
11111cd1ddf7faddddddddddddf7fadd11111cd1555555555555555555555555dddddddd55555555555555555555555555555555555555558888888888888888
ccccccccddf44adddddddd6dddf44addcccccccc555555555555555555555555dddddd6d55555555555555555555555555555555555555558888888888888888
1c6d1111dda49add1dd1dddddda49add1c6d11115555515555555155555551551dd1dddd55555155555551555555515555555155555551558888888888888888
1cd11dd11daaaaddddddd1dd1daaaadd1cd11dd1555155555551555555515555ddddd1dd55515555555155555551555555515555555155558888888888888888
ccccccccdddddd6ddd6ddddddddddd6dcccccccc5555555555555555555555558d6dddd855555555555555555555555555555555555555558888888888888888
111c6d11111c6d11dddddddd111c6d11111c6d11555555555555555555555555ddd11ddd55555555dddddddddddddddd55555555555555555555555533333333
ccccccccccccccccdd6dddddcccccccccccccccc515555555155555551555555dd18c1dd51555555dd6ddddddd6ddddd51555555515555555155555533333333
1dd11c6d1dd11c6ddddd1ddd1dd11c6d1dd11c6d555551555555515555555155dd1111dd55555155dddd1ddddddd1ddd5555515555555155555551553bb33333
11111cd111111cd1dddddddd11111cd111111cd1555555555555555555555555ddd11d1d55555555dddddddddddddddd555555555555555555555555333bb333
ccccccccccccccccdddddd6dcccccccccccccccc555555555555555555555555dd11111d55555555dddddd6ddddddd6d55555555555555555555555533333333
1c6d11111c6d11111dd1dddd1c6d11111c6d111155555155555551555555515511d11ddd555551551dd1dddd1dd1dddd555551555555515555555155333bb333
1cd11dd11cd11dd1ddddd1dd1cd11dd11cd11dd1555155555551555555515555ddd1d1dd55515555ddddd1ddddddd1dd55515555555155555551555533333bb3
ccccccccccccccccdd6dddddcccccccccccccccc555555555555555555555555dd11d11d55555555dd6ddddddd6ddddd55555555555555555555555533333333
5555555555555555dddddddd5555555555555555555555555555555555555555dddddddddddddd2ddddddddddddddddd55555555555555553333333333333333
5155555551555555dd6ddddd5155555551555555515555555155555551555555dd6dddddddddd262dd6dddddd6ddddd151555555515555553333333333333333
5555515555555155dddd1ddd5555515555555155555551555555515555555155dddd1dddd2dddd2ddddd1ddddddddddd55555155555551553bb3333333333333
5555555555555555dddddddd5555555555555555555555555555555555555555dddddddd262dddddddddddddddf7fadd5555555555555555333bb33333333333
5555555555555555dddddd6d5555555555555555555555555555555555555555dddddd6dd2dddddddddddd6dddf44add55555555555555553333333333333333
55555155555551551dd1dddd55555155555551555555515555555155555551551dd1ddddddddd2dd1dd1dddddda49add5555515555555155333bb33333333333
5551555555515555ddddd1dd5551555555515555555155555551555555515555ddddd1dddddd262dddddd1dd1daaaadd555155555551555533333bb333333333
5555555555555555dd6ddddd5555555555555555555555555555555555555555dd6dddddddddd2dddd6ddddddddddd6d55555555555555553333333333333333
5555555555555555dddddddddddddddddddddddddddddddddddddddddddddddddddddddd55555555555555555555555555555555555555553333333333333333
5155555551555555dd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddd51555555515555555155555551555555515555553333333333333333
5555515555555155dddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddd55555155555551555555515555555155555551553333333333333333
5555555555555555dddddddddddddddddddddddddddddddddddddddddddddddddddddddd55555555555555555555555555555555555555553333333333333333
5555555555555555dddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6d55555555555555555555555555555555555555553333333333333333
55555155555551551dd1dddd1dd1dddd1dd1dddd1dd1dddd1dd1dddd1dd1dddd1dd1dddd55555155555551555555515555555155555551553333333333333333
5551555555515555ddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1ddddddd1dd55515555555155555551555555515555555155553333333333333333
5555555555555555dd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddd55555555555555555555555555555555555555553333333333333333
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555553333333333333333
51555555515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555553333333333333333
55555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551553333333333333333
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555553333333333333333
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555553333333333333333
55555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551553333333333333333
55515555555155555551555555515555555155555551555555515555555155555551555555515555555155555551555555515555555155553333333333333333
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555553333333333333333

__gff__
0000000101010000000100000000000000020001010101000500000000000000000301010100481088900000000000000002002000004810000000000000000000000020202020202020200000000000000000202020202020202000000000000000002020202020202020000000000000000020202020202020200000000000
0000002020202020202020000000000000000020202020202020200000000000000000202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0404040401010101010101010101010101010101040404040909090909090909131313131304040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404010101010101010101010101010103010101010104040908080809083109131735171304040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401010101010201010101010101010606010101010201010908080808080809131717171304040423232323040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101020101010606010101010101010908080808080818171717171301040423232323040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010908080809080809131717171301040404042323040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101020103010101010101010505050505010101010918090909090909131335131313131304170404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010101010101010101010101051414141414050101010107010102040413131717171736331304170101040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010105141415141614140501070707010101030413131717171713131304041701040104040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010301020101010105050514141514141415141407070101010101010113131717171728131304041704040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010114141414161415141408080807010101020101010113131717171713131304040404042304040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010102010101010114141414141414141614141414010101010101010413131717171736331304040423232323230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101011414161414141414151414141414141401010102010413131313131313131304230423232323230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101020101010101011414141414151414141414161415141414010101010404040404040404040404232323232323230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101011414141414141414141414141402010101010404040404040404040404042323232323230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010103010101010101010114141414140201010101010101030104040404040404041704042323232323230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010606010101010101010101010114141414010101010101010101010104040404040417171717042323232323230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303010606010101010102010401010101141614010201010101010101010104040404040417171704042323232323230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301010101010101010101010101010101011414010101010101010101010104040404040404040404232323230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2301010701010201010101010101040101011414010101010101020101010123000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2303010101040101020101010101010101011414010101010101010101010123000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2303030101010701010101010102010101011514010101020101010101010123000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2323030301010101010101010101010101010808010101010101010101010123000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2323230301010107010101010101010101011415010101010101010102010123000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2323232301010101010701010101010101011414010101020101010101040123000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2323232323010101070101010201010101051414010101010101011101032323000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313131313232626262626010101010101141414010101010101010101232323000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1335173513230107010723232303010101141414010101010101020103232323000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1333173313232323072323232323010105141601010101020104010104232323000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313171313232323172317172323230514140101030101010103010423232324000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2323172323232323173617332323051414142323232323010123232323232323000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2323171717171717172323232323141414232323232323232323232323232324000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2323232323232323232323232323141423232323232323232323232323232424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000300000c2700a270082500522005200032000220002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500002105001000380503805038050380503805038050380503803038020380103600036000360003400034000340003400034000340003400000000000000000000000000000000000000000000000000000
000900002615026150261501f1501f1501f1503015030150301503715037150371503715037150371403714037130371303712037120371102b10000000000000000000000000000000000000000000000000000
000700000146003470094500940000400094000365002650026002d7002d7002d7002d70029700297002970029700297002970029700287002870028700287002870028700287002670026700267002670026700
0004000007650076500760023650236501a6501765000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--variables

function _init()
		player={
				sp=1,
				x=59,
				y=59,
				w=8,
				h=8,
				flp=false,
				dx=0,
				dy=0,
				max_dx=2,
				max_dy=3,
				acc=0.5,
				boost=4,
				anim=0,
				running=false,
				jumping=false,
				falling=false,
				sliding=false,
				landed=false
		}
		
		gravity=0.3
		friction=0.85
		
		--simple camera
		cam_x=0
		
		--map limits
		map_start=0
		map_end=1024
end

-->8
--update and draw
function _update()
		player_update()
		player_animate()
		
		--simple camera
		cam_x=player.x-64+(player.w/2)
		if cam_x<map_start then
				cam_x=map_start
		end
		if cam_x>map_end-128 then
				cam_x=map_end-128
		end
		camera(cam_x,0)
end

function _draw()
		cls()
		map(0,0)
		spr(player.sp,player.x,player.y,1,1,player.flp)
end
-->8
--collisions

function collide_map(obj,aim,flag)
	--obj = table needs x,y,w,h
	--aim = left,right,up,down
	
	local x=obj.x local y=obj.y
	local w=obj.w	local h=obj.h
	
	local x1=0	local y1=0
	local x2=0 local y2=0
	
	if aim=="left" then
			x1=x-1	y1=y
			x2=x			y2=y+h-1
	
	elseif aim=="right" then
			x1=x+w				y1=y
			x2=x+w+1		y2=y+h-1
			
	elseif aim=="up" then
			x1=x+1				y1=y-1
			x2=x+w-1		y2=y
			
	elseif aim=="down" then
			x1=x						y1=y+h
			x2=x+w				y2=y+h
	end

	--pixels to tiles
	x1/=8				y1/=8
	x2/=8 			y2/=8
	
	if fget(mget(x1,y1), flag)
	or fget(mget(x1,y2), flag)
	or fget(mget(x2,y1), flag)
	or fget(mget(x2,y2), flag) then
			return true
	else
			return false
	end
	
end

-->8
--player

function player_update()
		--physics
		player.dy+=gravity
		player.dx*=friction
		
		--controls
		if btn(⬅️) then
				player.dx-=player.acc
				player.running=true
				player.flp=true
		end
		if btn(➡️) then
				player.dx+=player.acc
				player.running=true
				player.flp=false
		end
		
		--slide
		if player.running
		and not btn(⬅️)
		and not btn(➡️)
		and not player.falling
		and not player.jumping then
				player.running=false
				player.sliding=true
		end
		
		--jump
		if btnp(❎)
		and player.landed then
				player.dy-=player.boost
				player.landed=false
		end
		
		--check collision up and down
		if player.dy>0 then
				player.falling=true
				player.landed=false
				player.jumping=false
				
				player.dy=limit_speed(player.dy,player.max_dy)
				
				if collide_map(player,"down",0) then
						player.landed=true
						player.falling=false
						player.dy=0
						player.y-=(player.y+player.h)%8
				end
		elseif player.dy<0 then
				player.jumping=true
				if collide_map(player,"up",1) then
						player.dy=0
		end
end

		--check collision left and right
		if player.dx<0 then
		
				player.dx=limit_speed(player.dx,player.max_dx)
		
				if collide_map(player,"left",1) then
						player.dx=0
				end
		elseif player.dx>0 then
		
				player.dx=limit_speed(player.dx,player.max_dx)
		
				if collide_map(player,"right",1) then
						player.dx=0
				end		
		end

		-- stop sliding
		if player.sliding then
				if abs(player.dx)<.2
				or player.running then
						player.dx=0
						player.sliding=false
				end
		end

		
		player.x+=player.dx
		player.y+=player.dy
		
		--limit player to map
		if player.x<map_start then
				player.x=map_start
		end
		if player.x>map_end-player.w then
				player.x=map_end-player.w
		end
end

function player_animate()
		if player.jumping then
				player.sp=7
		elseif player.falling then
				player.sp=8
		elseif player.sliding then
				player.sp=9
		elseif player.running then
				if time()-player.anim>.1 then
						player.anim=time()
						player.sp+=1
						if player.sp>6 then
								player.sp=3
						end
			end
		else --player idle
				if time()-player.anim>.3 then
						player.anim=time()
						player.sp+=1
						if player.sp>2 then
								player.sp=1
						end
				end
		end
end

function limit_speed(num,maximum)
		return mid(-maximum,num,maximum)
end
__gfx__
0000000000444440004444400004444400044444000444440004444400044444c004444400000000000000000000000000000000000000000000000000000000
0000000000ccccc000ccccc00ccccccc0c0cccccc00cccccc0cccccc00cccccc0ccccccc04444400000000000000000000000000000000000000000000000000
007007000cf72f200cf72f20c00ff72fc0cff72f0ccff72f0c0ff72f0c0ff72f000ff72f0ccccc00000000000000000000000000000000000000000000000000
000770000cfffff00cfffef0000ffffe000ffffe000ffffe000ffffec00ffffe000ffffecf72f200000000000000000000000000000000000000000000000000
00077000000cc00000cccc000fccc0000fccc0000fccc0000fccc00000ccc0000000ccc0cfffef00000000000000000000000000000000000000000000000000
0070070000cccc000f0cc0f0000cc000000cc000000cc000000cc0000f0cc0000000cc0f00ccccf0000000000000000000000000000000000000000000000000
000000000f0cd0f0000cd0000cc0d00000cd00000dd0c00000dc000000dc000000000cd00f0ccd00000000000000000000000000000000000000000000000000
0000000000c00d0000c00d000000d00000cd00000000c00000dc00000dc00000000000cd0000ccdd000000000000000000000000000000000000000000000000
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
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00bbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbb3bbbbbbb3bbb3b333bb3bbbbb33b0bbbb3b3bbb3bbb000000000000000000000000000000000000000000000000000000000000000000000000000000000
33b333b33bb33bbb33443b3433bbb343bb3b34343b3433bb00000000000000000000000000000000000000000000000000000000000000000000000000000000
4b3444343bb343b3444443b443bb3444bbb33444434443bb00000000000000000000000000000000000000000000000000000000000000000000000000000000
4b3424443b344434494443b4443b3444bb3444444449443b00000000000000000000000000000000000000000000000000000000000000000000000000000000
434444444344494444444b3444434424b344444d444443bb00000000000000000000000000000000000000000000000000000000000000000000000000000000
44444d44444444444445434449444444bb34f4444544443b00000000000000000000000000000000000000000000000000000000000000000000000000000000
4944444444d444f4444444444444e444334444444444444300000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444454464444444444454444444494000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
444494444444224444f4444444f44444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444442e244444444444444744000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4f444444444442244d6644444e444774000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444644444444444d66649444447644000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
444444444494444444ddd44444776444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e444444444444444444444444474444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333334444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbb3bbbbbbbb3bb9999499999999499000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbb3bbbbbbbb3bbb9994999999994999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333334444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3bbbb3bb3bbbbbb9499994994999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb3bbb3bbb3bbbbb9949994999499999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333334444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300000000000049940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003bb3000049940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0033b300003bb3000044940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003bb3000049940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003333000049940000444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003bb3000049940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003b3300003bb3000049440000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003bb3000049940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003bb3000049940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030303030300000000000000000000030303030000000000000000000000000101010100000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
7071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7171000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7171000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7170000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7171000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071006262000000616061606100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070007272000000007000710000000000000000000000000000000000006060000000000000000000000000000060600000000000000000000000000000606000000000000000000000000000006060000000000000000000000000000060600000000000000000000000000000606000000000000000000000000000006060
7170004445000000007100700000000000000000000000000000000000007171000000000000000000000000000071710000000000000000000000000000717100000000000000000000000000007171000000000000000000000000000071710000000000000000000000000000717100000000000000000000000000007171
7071445051434500007100700000700000000000000000000000000000007171000000000000000000000000000071710000000000000000000000000000717100000000000000000000000000007171000000000000000000000000000071710000000000000000000000000000717100000000000000000000000000007171
4241505052505043414140424141404141404143414041434041434343404141414041434140414340414343434041414140414341404143404143434340414141404143414041434041434343404141414041434140414340414343434041414140414341404143404143434340414141404143414041434041434343404141
5352515352505252515053505251505352515153525250515351505052515050525151535252505153515050525150505251515352525051535150505251505052515153525250515351505052515050525151535252505153515050525150505251515352525051535150505251505052515153525250515351505052515050

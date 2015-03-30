-- Set private "Clock" mode
mode = "Clock"

-- Internal module settings
screenshots = false
function Cronometer(millisecs)
	secs = millisecs / 1000
	mins = secs / 60
	hours = math.floor(mins / 60)
	mins = math.floor(mins % 60)
	secs = math.floor(secs % 60)
	millisecs = math.floor(millisecs % 1000)
	if mins < 10 then
		mins = "0"..mins
	end
	if secs < 10 then
		secs = "0"..secs
	end
	while string.len(tostring(millisecs)) < 3 do
		millisecs = "0"..millisecs
	end
	return hours..":"..mins..":"..secs..":"..millisecs
end
cronometer = false
crono_time = math.tointeger(0)

-- Module background code
function BackgroundClock()
	if my_alarm_time[1] == nil then -- Countdown
		if Timer.getTime(count_crono) / 1000 > my_alarm_time[3] then
			Sound.play(alarm_sound,LOOP,0x08,0x09)
			ShowWarning("Countdown ended.")
			CloseBGApp("Clock")
		end
	else -- Alarm
	
		-- Blit Alarm alert on Main Menu
		if module == "Main Menu" then
			Screen.fillEmptyRect(5,200,210,230,black,TOP_SCREEN)
			Screen.fillRect(6,199,211,229,white,TOP_SCREEN)
			Font.print(ttf,8,214,"Alarm: "..my_alarm_time[1]..":"..my_alarm_time[2]..":"..my_alarm_time[3],black,TOP_SCREEN)
		end
		
		h,m,s = System.getTime()
		if h == tonumber(my_alarm_time[1]) and m == tonumber(my_alarm_time[2]) and s == tonumber(my_alarm_time[3]) then
			Sound.play(alarm_sound,LOOP,0x08,0x09)
			ShowWarning("Alarm clock!")
			CloseBGApp("Clock")
		end
	end
end

function ClockGC()
	if Sound.isPlaying(alarm_sound) then
		Sound.pause(alarm_sound)
	end
	Sound.close(alarm_sound)
	if my_alarm_time[1] == nil then
		Timer.destroy(count_crono)
	end
	set_alarm = nil
	alarm_start = nil
end

-- Module main cycle
function AppMainCycle()
	
	-- Draw top screen box
	Screen.fillEmptyRect(5,395,40,220,black,TOP_SCREEN)
	Screen.fillRect(6,394,41,219,white,TOP_SCREEN)
	
	-- Draw controls info
	h,m,s = System.getTime()
	if m < 10 then
		m = "0"..m
	end
	if s < 10 then
		s = "0"..s
	end
	Font.print(ttf,9,45,"Current time: "..h..":"..m..":"..s,black,TOP_SCREEN)
	if cronometer then
		crono_time = Timer.getTime(crono)
		Font.print(ttf,9,70,"A = Resume/Pause Chronometer",black,TOP_SCREEN)
	else
		Font.print(ttf,9,70,"A = Start Chronometer",black,TOP_SCREEN)
	end
	Font.print(ttf,9,85,"X = Set Countdown",black,TOP_SCREEN)
	Font.print(ttf,9,100,"Y = Set Alarm",black,TOP_SCREEN)
	Font.print(ttf,9,115,"L = Start Countdown/Alarm",black,TOP_SCREEN)
	Font.print(ttf,9,130,"R = Stop Countdown/Alarm",black,TOP_SCREEN)
	Font.print(ttf,9,145,"SELECT = Reset Chronometer",black,TOP_SCREEN)
	Font.print(ttf,9,160,"B = Return Main Menu",black,TOP_SCREEN)
	
	-- Reset x,y coordinates
	y = 50
	x = 15
	
	-- Sets keyboard triggering
	i = 1
	z = 1
	x_c = x+195
	y_c = y-5
	while (i <= 12) do
		exec = false
		Screen.fillEmptyRect(x_c,x_c+30,y_c,y_c+25,black,BOTTOM_SCREEN)
		Screen.fillRect(x_c+1,x_c+29,y_c+1,y_c+24,white,BOTTOM_SCREEN)
		if Controls.check(pad,KEY_TOUCH) and not Controls.check(oldpad,KEY_TOUCH) then
			c1,c2 = Controls.readTouch()
			if c1 >= x_c and c2 >= y_c then
				if c1 < x_c + 25 and c2 < y_c + 25 then
					exec = true
				end
			end
		end
		if exec then
			if set_alarm ~= nil then
				if set_alarm and j < 7 and i < 11 then
					if i == 10 then
						alarm_table[j] = 0
					else
						alarm_table[j] = i
					end
					j=j+1
					if alarm_table[1] >= 2 then
						alarm_table[1] = 2
						if alarm_table[2] > 3 then
							alarm_table[2] = 3
						end
					end
					if alarm_table[3] > 5 then
						alarm_table[3] = 5
					end
					if alarm_table[5] > 5 then
						alarm_table[5] = 5
					end
				elseif set_alarm and i > 10 then
					if i == 11 then
						if j > 1 then
							alarm_table[j-1] = 0
							j = j - 1
						end
					else
						j = 1
						alarm_table = {0,0,0,0,0,0}
					end
				else
					if i < 10 then
						if countdown_time == 0 then
							countdown_time = i
						else
							countdown_time = tonumber(tostring(countdown_time)..i)
						end
					else
						if i == 11 then
							countdown_time = math.floor(countdown_time / 10)
						elseif i == 12 then
							countdown_time = 0
						else
							countdown_time = tonumber(tostring(countdown_time)..0)
						end
					end
				end
			end
		end
		i=i+1
		z=z+1
		x_c = x_c + 30
		if z > 3 then
			x_c = x+195
			y_c = y_c + 25
			z = 1
		end
	end
	
	-- Draw alarm config
	if set_alarm ~= nil then
		Screen.fillEmptyRect(5,100,75,95,black,BOTTOM_SCREEN)
		Screen.fillRect(6,99,76,94,white,BOTTOM_SCREEN)
		if set_alarm then
			k = 1
			my_alarm = ""
			while k < 7 do
				my_alarm = my_alarm .. alarm_table[k]
				if (k == 2 or k == 4) then
					my_alarm = my_alarm .. ":"
				end
				k = k + 1
			end
			Font.print(ttf,9,80,my_alarm,black,BOTTOM_SCREEN)
		else
			
		end
	end
	
	-- Draw numeric keyboard
	Font.print(ttf,x+200,y,"1",black,BOTTOM_SCREEN)
	Font.print(ttf,x+230,y,"2",black,BOTTOM_SCREEN)
	Font.print(ttf,x+260,y,"3",black,BOTTOM_SCREEN)
	Font.print(ttf,x+200,y+25,"4",black,BOTTOM_SCREEN)
	Font.print(ttf,x+230,y+25,"5",black,BOTTOM_SCREEN)
	Font.print(ttf,x+260,y+25,"6",black,BOTTOM_SCREEN)
	Font.print(ttf,x+200,y+50,"7",black,BOTTOM_SCREEN)
	Font.print(ttf,x+230,y+50,"8",black,BOTTOM_SCREEN)
	Font.print(ttf,x+260,y+50,"9",black,BOTTOM_SCREEN)
	Font.print(ttf,x+200,y+75,"0",black,BOTTOM_SCREEN)
	Font.print(ttf,x+230,y+75,"D",black,BOTTOM_SCREEN)
	Font.print(ttf,x+260,y+75,"C",black,BOTTOM_SCREEN)
		
	-- Draw Cronometer/Alarm stats
	Font.print(ttf,9,185,"Chronometer: "..Cronometer(crono_time),black,TOP_SCREEN)
	if alarm_start ~= nil then
		if my_alarm_time[1] == nil then
			Font.print(ttf,9,198,"Countdown set for: "..my_alarm_time[3].." seconds.",black,TOP_SCREEN)
		else	
			Font.print(ttf,9,198,"Alarm set for: "..my_alarm_time[1]..":"..my_alarm_time[2]..":"..my_alarm_time[3],black,TOP_SCREEN)
		end
	end
	
	-- Sets controls triggering
	if Controls.check(pad,KEY_R) and not Controls.check(oldpad,KEY_R) and alarm_start ~= nil then
		CloseBGApp("Clock")
	elseif Controls.check(pad,KEY_L) and not Controls.check(oldpad,KEY_L) and set_alarm ~= nil then
		alarm_sound = Sound.openWav(main_dir.."/sounds/alarm.wav")
		if set_alarm then
			alarm_start = false
			hours = alarm_table[1]..alarm_table[2]
			minutes = alarm_table[3]..alarm_table[4]
			secs = alarm_table[5]..alarm_table[6]
			my_alarm_time = {hours,minutes,secs}
		else
			my_alarm_time = {nil,nil,countdown_time}
			count_crono = Timer.new()
			alarm_start = false
		end
		set_alarm = nil
		table.insert(bg_apps,{BackgroundClock,ClockGC,"Clock"}) -- Adding Clock module to background apps
	elseif Controls.check(pad,KEY_A) and not Controls.check(oldpad,KEY_A) then
		if not cronometer then
			crono = Timer.new()
			cronometer = true
		else
			if Timer.isPlaying(crono) then
				Timer.pause(crono)
			else
				Timer.resume(crono)
			end
		end
	elseif Controls.check(pad,KEY_SELECT) and not Controls.check(oldpad,KEY_SELECT) then
		if cronometer then
			Timer.reset(crono)
		end
	elseif Controls.check(pad,KEY_Y) and not Controls.check(oldpad,KEY_Y) then
		set_alarm = true
		alarm_table = {0,0,0,0,0,0}
		j=1
	elseif Controls.check(pad,KEY_X) and not Controls.check(oldpad,KEY_X) then
		set_alarm = false
		countdown_time = 0
	elseif Controls.check(pad,KEY_B) or Controls.check(pad,KEY_START) then
		if cronometer then
			Timer.destroy(crono)
		end
		CallMainMenu()
	end
end
-- Create system folders if doesn't exist
System.createDirectory("/VIDEO")
System.createDirectory("/MUSIC")
System.createDirectory("/DCIM")

-- Open config file and system files
dofile("/config.sun")
theme_dir = main_dir.."/themes/"..theme
bg = Screen.loadImage(theme_dir.."/images/bg.jpg")
if System.doesFileExist(theme_dir.."/images/music.jpg") then
	ext = ".jpg"
else
	ext = ".png"
end
music = Screen.loadImage(theme_dir.."/images/music"..ext)
video = Screen.loadImage(theme_dir.."/images/video"..ext)
info = Screen.loadImage(theme_dir.."/images/info"..ext)
fb = Screen.loadImage(theme_dir.."/images/fb"..ext)
game = Screen.loadImage(theme_dir.."/images/game"..ext)
photo = Screen.loadImage(theme_dir.."/images/photo"..ext)
cia = Screen.loadImage(theme_dir.."/images/cia"..ext)
extdata = Screen.loadImage(theme_dir.."/images/extdata"..ext)
calc = Screen.loadImage(theme_dir.."/images/calc"..ext)
mail = Screen.loadImage(theme_dir.."/images/mail"..ext)
themes = Screen.loadImage(theme_dir.."/images/themes"..ext)
clock = Screen.loadImage(theme_dir.."/images/clock"..ext)
ftp = Screen.loadImage(theme_dir.."/images/ftp"..ext)
charge = Screen.loadImage(theme_dir.."/images/charge"..ext)
b0 = Screen.loadImage(theme_dir.."/images/0"..ext)
b1 = Screen.loadImage(theme_dir.."/images/1"..ext)
b2 = Screen.loadImage(theme_dir.."/images/2"..ext)
b3 = Screen.loadImage(theme_dir.."/images/3"..ext)
b4 = Screen.loadImage(theme_dir.."/images/4"..ext)
b5 = Screen.loadImage(theme_dir.."/images/5"..ext)
ttf = Font.load(theme_dir.."/fonts/main.ttf")
dofile(theme_dir.."/colors.lua")
Font.setPixelSizes(ttf,18)

-- Setting some system vars, funcs, etc...
bg_apps = {}
topbar_icons = {}
old_headset = Controls.headsetStatus()
in_game = false
refresh_screen = true
Sound.init()
app_index = 1
version = "0.2"
ui_enabled = true
screenshots = true
oldpad = KEY_A
module = "Main Menu"
months = {"January", "February","March","April","May","June","July", "August", "September", "October", "November", "December"}
days_table = {}
dv,d,m,y = System.getDate()
if (y % 400 == 0) or (y % 100 ~= 0 and y % 4 == 0) then
	month_days = {31,29,31,30,31,30,31,31,30,31,30,31}
else
	month_days = {31,28,31,30,31,30,31,31,30,31,30,31}
end
i = 1
if i == d then
	if dv == 7 then
		dv = 0
	end
	table.insert(days_table,dv)
else
	tmp = ((d - i) % 7)
	if tmp > dv then
		my_dv = 7 + dv - tmp 
	else
		my_dv = dv - tmp
	end
	if my_dv > 6 then
		my_dv = 0
	end
	table.insert(days_table,my_dv)
end
i = 2
while i <= month_days[m] do
	my_dv = days_table[i-1] + 1
	if my_dv > 6 then
		my_dv = 0
	end
	table.insert(days_table,my_dv)
	i=i+1
end
-- Loading internal extra Sunshell functions
dofile(main_dir.."/scripts/funcs.lua")

-- Set detected build in use
build_idx = System.checkBuild()
if build_idx == 0 then
	build = "3DSX"
elseif build_idx == 1 then
	build = "CIA"
end

-- Setting modules as apps
tools = {}
table.insert(tools,{game,"/modules/game.lua","Applications"})
table.insert(tools,{info,"/modules/info.lua","Console Info"})
table.insert(tools,{photo,"/modules/photo.lua","Photos"})
table.insert(tools,{music,"/modules/music.lua","Musics"})
table.insert(tools,{video,"/modules/video.lua","Videos"})
table.insert(tools,{fb,"/modules/fb.lua","Filebrowser"})
table.insert(tools,{cia,"/modules/cia.lua","CIA Manager"})
table.insert(tools,{extdata,"/modules/extdata.lua","Extdata Manager"})
table.insert(tools,{calc,"/modules/calc.lua","Calc"})
table.insert(tools,{clock,"/modules/clock.lua","Clock"})
table.insert(tools,{ftp,"/modules/ftp.lua","FTP Server"})
table.insert(tools,{mail,"/modules/mail.lua","Mail"})
table.insert(tools,{themes,"/modules/themes.lua","Theme Manager"})

-- Main cycle
while true do
	Screen.refresh()
	pad = Controls.read()
	
	-- Headset tracking for Music module auto-start
	if old_headset and not Controls.headsetStatus() then -- Removing headset
		for i,app in pairs(bg_apps) do
			if app[3] == "Music" then
				if Sound.isPlaying(current_song) then
					Sound.pause(current_song)
				end
				break
			end
		end
		old_headset = false
	elseif not old_headset and Controls.headsetStatus() then -- Inserting headset
		done = false
		for i,app in pairs(bg_apps) do
			if app[3] == "Music" then
				if not Sound.isPlaying(current_song) then
					Sound.resume(current_song)
				end
				done = true
				break
			end
		end
		if not done then
			dofile(main_dir.."/scripts/music_api.lua")
		end
		old_headset = true
	end
	
	-- Blit background
	if ui_enabled then
		Screen.drawPartialImage(0,0,0,0,400,240,bg,TOP_SCREEN)
		if refresh_screen then
			Screen.drawPartialImage(0,0,40,240,320,240,bg,BOTTOM_SCREEN)
		end
	end
	
	-- Executing background apps
	for i,bg_app_code in pairs(bg_apps) do
		bg_app_code[1]()
	end
	
	-- Main menu
	if mode == nil then
		if widget == nil then
			
			-- Blit calendar
			dv,d,m,ye = System.getDate()
			i = 1
			x = 80
			y = 85
			Screen.fillEmptyRect(x-10,x+240,y-45,y+115,black,TOP_SCREEN)
			Screen.fillRect(x-9,x+239,y-44,y+114,white,TOP_SCREEN)
			Font.print(ttf,x+85,y-40,months[m].." "..ye,black,TOP_SCREEN)
			Font.print(ttf,x,y-20,"S",selected,TOP_SCREEN)
			Font.print(ttf,x+35,y-20,"M",selected,TOP_SCREEN)
			Font.print(ttf,x+70,y-20,"T",selected,TOP_SCREEN)
			Font.print(ttf,x+105,y-20,"W",selected,TOP_SCREEN)
			Font.print(ttf,x+140,y-20,"T",selected,TOP_SCREEN)
			Font.print(ttf,x+175,y-20,"F",selected,TOP_SCREEN)
			Font.print(ttf,x+210,y-20,"S",selected,TOP_SCREEN)
			while i <= month_days[m] do
				if i == d then
					Font.print(ttf,x + (days_table[i]) * 35,y,i,selected,TOP_SCREEN)
				else
					Font.print(ttf,x + (days_table[i]) * 35,y,i,black,TOP_SCREEN)
				end
				if days_table[i] == 6 then
					y = y + 20
				end
				i=i+1
			end
			
		end
		
		-- Blit app icons and sets up controls triggering
		x = 4
		y = 10
		for i,tool in pairs(tools) do
			if x > 300 then
				x = 4
				y = y + 58
			end
			if app_index == i then
				Screen.fillRect(x-3,x+50,y-3,y+50,selected,BOTTOM_SCREEN)
			end
			Screen.drawImage(x,y,tool[1],BOTTOM_SCREEN)
			if Controls.check(pad,KEY_TOUCH) and not Controls.check(oldpad,KEY_TOUCH) then
				tx,ty = Controls.readTouch()
				if tx >= x and tx <= x+48 and ty >= y and ty <= y+48 then
					module = tool[3]
					dofile(main_dir..tool[2])
				end
			end
			x = x + 53
		end
		
		-- Setting digital pad controls triggering
		if Controls.check(pad,KEY_DUP) and not Controls.check(oldpad,KEY_DUP) then
			app_index = app_index - 6
			if app_index < 1 then
				while (app_index + 6) <= #tools do
					app_index = app_index + 6
				end
			end
		elseif Controls.check(pad,KEY_DDOWN) and not Controls.check(oldpad,KEY_DDOWN) then
			app_index = app_index + 6
			if app_index > #tools then
				app_index = app_index % 6
			end
		elseif Controls.check(pad,KEY_DLEFT) and not Controls.check(oldpad,KEY_DLEFT) then
			app_index = app_index - 1
			if app_index % 6 == 0 then
				app_index = app_index + 6
				if app_index > #tools then
					app_index = #tools
				end
			end
		elseif Controls.check(pad,KEY_DRIGHT) and not Controls.check(oldpad,KEY_DRIGHT) then
			app_index = app_index + 1
			if app_index % 6 == 1 then
				app_index = app_index - 6
			end
			if app_index > #tools then
				app_index = math.floor(app_index / 6) * 6 + 1
			end
		end
		
		-- Setting app starting by pressing A button
		if Controls.check(pad,KEY_A) and not Controls.check(oldpad,KEY_A) then
			module = tools[app_index][3]
			dofile(main_dir..tools[app_index][2])
		end
	else
	
		-- App cycles
		AppMainCycle()
		
	end
	
	-- Blit topbar info
	if ui_enabled then
	
		-- Blit clock
		hours,minutes,seconds = System.getTime()
		if minutes < 10 then
			minutes = "0"..minutes
		end
		if seconds < 10 then
			seconds = "0"..seconds
		end
		formatted_time = hours..":"..minutes..":"..seconds
		Font.print(ttf,276-#topbar_icons*21,3,formatted_time,white,TOP_SCREEN)
			
		-- Blit topbar icons
		for i,icon in pairs(topbar_icons) do
			Screen.drawImage(350-i*21,2,icon[1],TOP_SCREEN)
		end
		
		Font.print(ttf,4,3,"Sunshell v."..version.." - "..module,white,TOP_SCREEN)
		if  System.isBatteryCharging() then
			Screen.drawImage(350,2,charge,TOP_SCREEN)
		else
			battery_lv = System.getBatteryLife()
			if battery_lv == 0 then
				Screen.drawImage(350,2,b0,TOP_SCREEN)
			elseif battery_lv == 1 then
				Screen.drawImage(350,2,b1,TOP_SCREEN)
			elseif battery_lv == 2 then
				Screen.drawImage(350,2,b2,TOP_SCREEN)
			elseif battery_lv == 3 then
				Screen.drawImage(350,2,b3,TOP_SCREEN)
			elseif battery_lv == 4 then
				Screen.drawImage(350,2,b4,TOP_SCREEN)
			else
				Screen.drawImage(350,2,b5,TOP_SCREEN)
			end
		end
		if Network.isWifiEnabled() then
			Screen.fillRect(340-#topbar_icons*21,345-#topbar_icons*21,2,18,green_wifi,TOP_SCREEN)
			Screen.fillRect(333-#topbar_icons*21,338-#topbar_icons*21,8,18,green_wifi,TOP_SCREEN)
			Screen.fillRect(326-#topbar_icons*21,331-#topbar_icons*21,14,18,green_wifi,TOP_SCREEN)
		else
		end
	end
	
	-- Sets up universal controls
	if Controls.check(pad,KEY_START) and not in_game and not Controls.check(oldpad,KEY_START) then
		GarbageCollection()
		for i,bg_apps_code in pairs(bg_apps) do
			bg_apps_code[2]()
		end
		for i,icon in pairs(topbar_icons) do
			Screen.freeImage(icon[1])
		end
		Sound.term()
		Font.unload(ttf)
		if start_dir == "/" and build == "3DSX" then -- boot.3dsx patch
			System.reboot()
		else
			System.exit()
		end
	elseif Controls.check(pad,KEY_L) and not Controls.check(oldpad,KEY_L) and screenshots then
		screen_index = 0
		while System.doesFileExist("/DCIM/Sunshell_"..screen_index..".jpg") do
			screen_index = screen_index + 1
		end
		System.takeScreenshot("/DCIM/Sunshell_"..screen_index..".jpg",true)
	end
	
	Screen.waitVblankStart()
	Screen.flip()
	oldpad = pad
	if in_game then
		in_game = false
	end
end
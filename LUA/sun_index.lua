-- Create system folders if doesn't exist
System.createDirectory("/VIDEO")
System.createDirectory("/MUSIC")
System.createDirectory("/DCIM")

-- Open config file and system files
dofile("/config.sun")
bg = Screen.loadImage(main_dir.."/images/bg.jpg")
music = Screen.loadImage(main_dir.."/images/music.jpg")
video = Screen.loadImage(main_dir.."/images/video.jpg")
info = Screen.loadImage(main_dir.."/images/info.jpg")
fb = Screen.loadImage(main_dir.."/images/fb.jpg")
game = Screen.loadImage(main_dir.."/images/game.jpg")
photo = Screen.loadImage(main_dir.."/images/photo.jpg")
cia = Screen.loadImage(main_dir.."/images/cia.jpg")
calc = Screen.loadImage(main_dir.."/images/calc.jpg")
mail = Screen.loadImage(main_dir.."/images/mail.jpg")
clock = Screen.loadImage(main_dir.."/images/clock.jpg")
ftp = Screen.loadImage(main_dir.."/images/ftp.jpg")
charge = Screen.loadImage(main_dir.."/images/charge.jpg")
b0 = Screen.loadImage(main_dir.."/images/0.jpg")
b1 = Screen.loadImage(main_dir.."/images/1.jpg")
b2 = Screen.loadImage(main_dir.."/images/2.jpg")
b3 = Screen.loadImage(main_dir.."/images/3.jpg")
b4 = Screen.loadImage(main_dir.."/images/4.jpg")
b5 = Screen.loadImage(main_dir.."/images/5.jpg")

-- Setting some system vars, funcs, etc...
bg_apps = {}
Sound.init()
black = Color.new(0,0,0)
white = Color.new(255,255,255)
green = Color.new(0,166,81)
selected = Color.new(255,0,0)
selected_item = Color.new(237,28,36,128)
version = "0.1"
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
	build = "3DS"
else
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
table.insert(tools,{calc,"/modules/calc.lua","Calc"})
table.insert(tools,{clock,"/modules/clock.lua","Clock"})
table.insert(tools,{ftp,"/modules/ftp.lua","FTP Server"})
table.insert(tools,{mail,"/modules/mail.lua","Mail"})

-- Main cycle
while true do
	Screen.refresh()
	Controls.init()
	pad = Controls.read()
	
	-- Blit background
	if ui_enabled then
		Screen.drawPartialImage(0,0,0,0,400,240,bg,TOP_SCREEN)
		Screen.drawPartialImage(0,0,40,240,320,240,bg,BOTTOM_SCREEN)
	end
	
	-- Executing background apps
	for i,bg_app_code in pairs(bg_apps) do
		bg_app_code[1]()
	end
	
	-- Main menu
	if mode == nil then
		if widget == nil then
		
			-- Blit clock
			hours,minutes,seconds = System.getTime()
			if minutes < 10 then
				minutes = "0"..minutes
			end
			if seconds < 10 then
				seconds = "0"..seconds
			end
			formatted_time = hours..":"..minutes..":"..seconds
			Screen.fillEmptyRect(255,395,85,125,black,TOP_SCREEN)
			Screen.fillRect(256,394,86,124,white,TOP_SCREEN)
			Screen.debugPrint(259,89,"Digital Clock",selected,TOP_SCREEN)
			Screen.debugPrint(259,109,formatted_time,black,TOP_SCREEN)
			
			-- Blit calendar
			dv,d,m,ye = System.getDate()
			i = 1
			x = 10
			y = 85
			Screen.fillEmptyRect(x-5,x+240,y-45,y+115,black,TOP_SCREEN)
			Screen.fillRect(x-4,x+239,y-44,y+114,white,TOP_SCREEN)
			Screen.debugPrint(x+50,y-40,months[m].." "..ye,black,TOP_SCREEN)
			Screen.debugPrint(x,y-20,"S",selected,TOP_SCREEN)
			Screen.debugPrint(x+35,y-20,"M",selected,TOP_SCREEN)
			Screen.debugPrint(x+70,y-20,"T",selected,TOP_SCREEN)
			Screen.debugPrint(x+105,y-20,"W",selected,TOP_SCREEN)
			Screen.debugPrint(x+140,y-20,"T",selected,TOP_SCREEN)
			Screen.debugPrint(x+175,y-20,"F",selected,TOP_SCREEN)
			Screen.debugPrint(x+210,y-20,"S",selected,TOP_SCREEN)
			while i <= month_days[m] do
				if i == d then
					Screen.debugPrint(x + (days_table[i]) * 35,y,i,selected,TOP_SCREEN)
				else
					Screen.debugPrint(x + (days_table[i]) * 35,y,i,black,TOP_SCREEN)
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
			if x < 300 then
				Screen.drawImage(x,y,tool[1],BOTTOM_SCREEN)
				if Controls.check(pad,KEY_TOUCH) and not Controls.check(oldpad,KEY_TOUCH) then
					tx,ty = Controls.readTouch()
					if tx >= x and tx <= x+48 and ty >= y and ty <= y+48 then
						module = tool[3]
						dofile(main_dir..tool[2])
					end
				end
			else
				x = 4
				y = y + 58
				Screen.drawImage(x,y,tool[1],BOTTOM_SCREEN)
				if Controls.check(pad,KEY_TOUCH) and not Controls.check(oldpad,KEY_TOUCH) then
					tx,ty = Controls.readTouch()
					if tx >= x and tx <= x+48 and ty >= y and ty <= y+48 then
						module = tool[3]
						dofile(main_dir..tool[2])
					end
				end
			end
			x = x + 53
		end
	else
	
		-- App cycles
		AppMainCycle()
		
	end
	
	-- Blit topbar info
	if ui_enabled then
		Screen.debugPrint(2,6,"Sunshell v."..version.." - "..module,white,TOP_SCREEN)
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
			Screen.fillRect(340,345,2,18,green,TOP_SCREEN)
			Screen.fillRect(333,338,8,18,green,TOP_SCREEN)
			Screen.fillRect(326,331,14,18,green,TOP_SCREEN)
		end
	end
	
	-- Sets up universal controls
	if Controls.check(pad,KEY_START) then
		GarbageCollection()
		for i,bg_apps_code in pairs(bg_apps) do
			bg_apps_code[2]()
		end
		Sound.term()
		if start_dir == "/" and build == "3DSX" then -- boot.3dsx patch
			System.reboot()
		else
			System.exit()
		end
	elseif Controls.check(pad,KEY_L) and not Controls.check(oldpad,KEY_L) and screenshots then
		screen_index = 0
		while System.doesFileExist("/DCIM/Sunshell_"..screen_index..".bmp") do
			screen_index = screen_index + 1
		end
		System.takeScreenshot("/DCIM/Sunshell_"..screen_index..".bmp")
	end
	
	Screen.waitVblankStart()
	Screen.flip()
	oldpad = pad
end
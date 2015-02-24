-- Create system folders if doesn't exist
System.createDirectory("/VIDEO")
System.createDirectory("/MUSIC")

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
charge = Screen.loadImage(main_dir.."/images/charge.jpg")
b0 = Screen.loadImage(main_dir.."/images/0.jpg")
b1 = Screen.loadImage(main_dir.."/images/1.jpg")
b2 = Screen.loadImage(main_dir.."/images/2.jpg")
b3 = Screen.loadImage(main_dir.."/images/3.jpg")
b4 = Screen.loadImage(main_dir.."/images/4.jpg")
b5 = Screen.loadImage(main_dir.."/images/5.jpg")

-- Setting some system vars, funcs, etc...
yellow = Color.new(255,242,0)
black = Color.new(0,0,0)
white = Color.new(255,255,255)
selected = Color.new(255,0,0)
selected_item = Color.new(237,28,36,128)
version = "0.1"
oldpad = KEY_A
module = "Main Menu"
function GarbageCollection()
	Screen.freeImage(bg)
	Screen.freeImage(b0)
	Screen.freeImage(b1)
	Screen.freeImage(b2)
	Screen.freeImage(b3)
	Screen.freeImage(b4)
	Screen.freeImage(b5)
	Screen.freeImage(charge)
	for i,tool in pairs(tools) do
		Screen.freeImage(tool[1])
	end
end
function CropPrint(x, y, text, color, screen)
	if string.len(text) > 25 then
		Screen.debugPrint(x, y, string.sub(text,1,25) .. "...", color, screen)
	else
		Screen.debugPrint(x, y, text, color, screen)
	end
end
function LastSpace(text)
	found = false
	start = -1
	while string.sub(text,start,start) ~= " " do
		start = start - 1
	end
	return start
end
function ErrorGenerator(text)
	y = 68
	error_lines = {}
	while string.len(text) > 30 do
		endl = 31 + LastSpace(string.sub(text,1,30))
		table.insert(error_lines,{string.sub(text,1,endl), y})
		text = string.sub(text,endl+1,-1)
		y = y + 15
	end
	if string.len(text) > 0 then
		table.insert(error_lines,{text, y})
	end
end
function LinesGenerator(text,y)
	error_lines = {}
	while string.len(text) > 40 do
		endl = 41 + LastSpace(string.sub(text,1,40))
		table.insert(error_lines,{string.sub(text,1,endl), y})
		text = string.sub(text,endl+1,-1)
		y = y + 15
	end
	if string.len(text) > 0 then
		table.insert(error_lines,{text, y})
	end
	return error_lines
end
function ShowError(text)
	confirm = false
	ErrorGenerator(text)
	max_y = error_lines[#error_lines][2] + 40
	while not confirm do
		Screen.refresh()
		Screen.fillEmptyRect(5,315,50,max_y,black,BOTTOM_SCREEN)
		Screen.fillRect(6,314,51,max_y-1,white,BOTTOM_SCREEN)
		Screen.debugPrint(8,53,"Error",selected,BOTTOM_SCREEN)
		for i,line in pairs(error_lines) do
			Screen.debugPrint(8,line[2],line[1],black,BOTTOM_SCREEN)
		end
		Controls.init()
		Screen.fillEmptyRect(147,176,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
		Screen.debugPrint(150,max_y - 20,"OK",black,BOTTOM_SCREEN)
		if (Controls.check(Controls.read(),KEY_TOUCH)) then
			x,y = Controls.readTouch()
			if x >= 147 and x <= 176 and y >= max_y - 23 and y <= max_y - 8 then
				confirm = true
			end
		end
		Screen.flip()
		Screen.waitVblankStart()
	end
end

-- Set detected build in use
if string.len(System.currentDirectory()) > 1 then
	build = "3DSX"
else
	if System.isGWMode() then
		build = "3DS"
	else
		build = "CIA"
	end
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
table.insert(tools,{mail,"/modules/mail.lua","Mail"})

-- Main cycle
while true do
	Screen.refresh()
	Controls.init()
	pad = Controls.read()
	
	-- Blit background
	Screen.drawPartialImage(0,0,0,0,400,240,bg,TOP_SCREEN)
	Screen.drawPartialImage(0,0,40,240,320,240,bg,BOTTOM_SCREEN)
	
	-- Main menu
	if mode == nil then
	
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
	Screen.debugPrint(2,6,"Sunshell v."..version.." - "..module,yellow,TOP_SCREEN)
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
	
	-- Sets up universal controls
	if Controls.check(pad,KEY_START) then
		GarbageCollection()
		System.exit()
	elseif Controls.check(pad,KEY_L) and not Controls.check(oldpad,KEY_L) then
		System.takeScreenshot("/DCIM/101NIN03/Sunshell.bmp")
	end
	
	Screen.waitVblankStart()
	Screen.flip()
	oldpad = pad
end
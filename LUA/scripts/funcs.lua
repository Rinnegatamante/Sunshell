-- Internal SunShell variables
-- ui_enabled = true/false -- Sets Sunshell UI state (CallMainMenu force automatically ui_enabled to true value)
-- screenshots = true/false -- Sets Sunshell screenshot function through L button state (CallMainMenu force automatically screenshots to true value)

-- Internal SunShell extra functions

start_dir = System.currentDirectory()

-- * CallMainMenu
-- Sets SunShell to Main Menu mode, usefull to exit from a module
function CallMainMenu()
	mode = nil
	module = "Main Menu"
	ui_enabled = true
	screenshots = true
	System.currentDirectory(start_dir)
end

-- * CloseBGApp
-- Close a selected BG App
function CloseBGApp(my_app)
	for i, apps in pairs(bg_apps) do
		if apps[3] == my_app then
			apps[2]()
			table.remove(bg_apps,i)
			break
		end
	end
end

-- * FormatTime
-- Format a number of seconds in a time-like string (Example: 123 seconds = 02:03)
function FormatTime(seconds)
	minute = math.floor(seconds/60)
	seconds = seconds%60
	hours = math.floor(minute/60)
	minute = minute%60
	if minute < 10 then
		minute = "0"..minute
	end
	if seconds < 10 then
		seconds = "0"..seconds
	end
	if hours == 0 then
		return minute..":"..seconds
	else
		return hours..":"..minute..":"..seconds
	end
end

-- * GarbageCollection
-- Free all allocated SunShell elements
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

-- * CropPrint
-- Used to print long strings on BOTTOM_SCREEN, it automatically crop too long strings
function CropPrint(x, y, text, color, screen)
	if string.len(text) > 50 then
		Font.print(ttf,x+2, y, string.sub(text,1,50) .. "...", color, screen)
	else
		Font.print(ttf,x+2, y, text, color, screen)
	end
end

-- * TopCropPrint
-- Used to print long strings on TOP_SCREEN, it automatically crop too long strings
function TopCropPrint(x, y, text, color, screen)
	if string.len(text) > 100 then
		Font.print(ttf,x+2, y, string.sub(text,1,100) .. "...", color, screen)
	else
		Font.print(ttf,x+2, y, text, color, screen)
	end
end

-- * DebugCropPrint
-- Used to print long strings on BOTTOM_SCREEN, it automatically crop too long strings
function DebugCropPrint(x, y, text, color, screen)
	if string.len(text) > 25 then
		Screen.debugPrint(x, y, string.sub(text,1,25) .. "...", color, screen)
	else
		Screen.debugPrint(x, y, text, color, screen)
	end
end

-- * DebugTopCropPrint
-- Used to print long strings on TOP_SCREEN, it automatically crop too long strings
function DebugTopCropPrint(x, y, text, color, screen)
	if string.len(text) > 42 then
		Screen.debugPrint(x, y, string.sub(text,1,42) .. "...", color, screen)
	else
		Screen.debugPrint(x, y, text, color, screen)
	end
end

-- * LastSpace
-- Return index of last space for text argument
function LastSpace(text)
	found = false
	start = -1
	while string.sub(text,start,start) ~= " " do
		start = start - 1
	end
	return start
end

-- * ErrorGenerator
-- PRIVATE FUNCTION: DO NOT USE
function ErrorGenerator(text)
	y = 68
	error_lines = {}
	while string.len(text) > 50 do
		endl = 51 + LastSpace(string.sub(text,1,50))
		table.insert(error_lines,{string.sub(text,1,endl), y})
		text = string.sub(text,endl+1,-1)
		y = y + 15
	end
	if string.len(text) > 0 then
		table.insert(error_lines,{text, y})
	end
end

-- * ShowError
-- Shows a SunShell error with a customizable text
function ShowError(text)
	confirm = false
	ErrorGenerator(text)
	max_y = error_lines[#error_lines][2] + 40
	while not confirm do
		Screen.refresh()
		Screen.fillEmptyRect(5,315,50,max_y,black,BOTTOM_SCREEN)
		Screen.fillRect(6,314,51,max_y-1,white,BOTTOM_SCREEN)
		Font.print(ttf,8,53,"Error",selected,BOTTOM_SCREEN)
		for i,line in pairs(error_lines) do
			Font.print(ttf,8,line[2],line[1],black,BOTTOM_SCREEN)
		end
		Screen.fillEmptyRect(147,176,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
		Font.print(ttf,155,max_y - 23,"OK",black,BOTTOM_SCREEN)
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

-- * ShowWarning
-- Shows a SunShell warning with a customizable text
function ShowWarning(text)
	confirm = false
	ErrorGenerator(text)
	max_y = error_lines[#error_lines][2] + 40
	while not confirm do
		Screen.refresh()
		Screen.fillEmptyRect(5,315,50,max_y,black,BOTTOM_SCREEN)
		Screen.fillRect(6,314,51,max_y-1,white,BOTTOM_SCREEN)
		Font.print(ttf,8,53,"Warning",selected,BOTTOM_SCREEN)
		for i,line in pairs(error_lines) do
			Font.print(ttf,8,line[2],line[1],black,BOTTOM_SCREEN)
		end
		Screen.fillEmptyRect(147,176,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
		Font.print(ttf,155,max_y - 23,"OK",black,BOTTOM_SCREEN)
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

-- * LinesGenerator
-- Similar to CropPrint but for TOP_SCREEN, you can see Applications src to know how to use it
function LinesGenerator(text,y)
	error_lines = {}
	while string.len(text) > 60 do
		endl = 61 + LastSpace(string.sub(text,1,60))
		table.insert(error_lines,{string.sub(text,1,endl), y})
		text = string.sub(text,endl+1,-1)
		y = y + 15
	end
	if string.len(text) > 0 then
		table.insert(error_lines,{text, y})
	end
	return error_lines
end

-- * DebugLinesGenerator
-- Similar to CropPrint but for TOP_SCREEN, you can see Mail src to know how to use it
function DebugLinesGenerator(text,y)
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

-- * AddIconTopbar
-- Add an Icon to Topbar
function AddIconTopbar(filename,id)
	table.insert(topbar_icons, {Screen.loadImage(filename),id})
end

-- * FreeIconTopbar
-- Delete an Icon from Topbar
function FreeIconTopbar(my_app)
	for i, icon in pairs(topbar_icons) do
		if icon[2] == my_app then
			Screen.freeImage(icon[1])
			table.remove(topbar_icons,i)
			break
		end
	end
end

-- * OneshotPrint
-- Optimized generic print function for code which needs to be executed only one time
function OneshotPrint(my_func)
	my_func()
	Screen.flip()
	Screen.refresh()
	my_func()
end
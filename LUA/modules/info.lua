-- Set private "Info" mode
mode = "Info"

-- Internal module settings
mac_addr = Network.getMacAddress()
model = System.getModel()
region = System.getRegion()
fw = System.getFirmware()
kernel = System.getKernel()
free_space = System.getFreeSpace()
sorting = "Bytes"
if free_space > 1024 then
	sorting = "KBs"
	free_space = free_space / 1024
	if free_space > 1024 then
		sorting = "MBs"
		free_space = free_space / 1024
	end
end
free_space = string.format("%8.2f", free_space)

-- Module main cycle
function AppMainCycle()
	
	-- Draw top screen box
	Screen.fillEmptyRect(5,395,40,220,black,TOP_SCREEN)
	Screen.fillRect(6,394,41,219,white,TOP_SCREEN)
	
	-- Draw console info
	if model == 0 then
		Screen.debugPrint(9,45,"Model: Old 3DS",black,TOP_SCREEN)
	else
		Screen.debugPrint(9,45,"Model: New 3DS",black,TOP_SCREEN)
	end
	if region == 1 then
		Screen.debugPrint(9,60,"Region: USA",black,TOP_SCREEN)
	elseif region == 2 then
		Screen.debugPrint(9,60,"Region: EUR",black,TOP_SCREEN)
	else
		Screen.debugPrint(9,60,"Region: JPN",black,TOP_SCREEN)
	end
	Screen.debugPrint(9,75,"Firmware Version: " .. fw,black,TOP_SCREEN)
	Screen.debugPrint(9,90,"Kernel Version: " .. kernel,black,TOP_SCREEN)
	Screen.debugPrint(9,105,"Free Space: "..free_space.." "..sorting,black,TOP_SCREEN)
	Screen.debugPrint(9,120,"MAC Address: "..mac_addr,black,TOP_SCREEN)
	-- Sets controls triggering
	if Controls.check(pad,KEY_B) or Controls.check(pad,KEY_START) then
		mode = nil
		module = "Main Menu"
	end
end
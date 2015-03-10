-- Set private "FTP" mode
mode = "FTP"

-- Module background code
function BackgroundFTP()
	last_shared = Network.updateFTP()
	
	-- Blit FTP alert on Main Menu
		if module == "Main Menu" then
			Screen.fillEmptyRect(255,395,45,65,black,TOP_SCREEN)
			Screen.fillRect(256,394,46,64,white,TOP_SCREEN)
			Screen.debugPrint(259,50,"FTP: ON",black,TOP_SCREEN)
		end
end

function FTPGC()
	Network.termFTP()
	last_shared = nil
end

-- Internal module settings
if Network.isWifiEnabled() then
	if last_shared == nil then
		last_shared = "Waiting for connection..."
		Network.initFTP()
		table.insert(bg_apps,{BackgroundFTP,FTPGC,"FTP Server"}) -- Adding FTP module to background apps
	end
else
	ShowError("You need to be connected to an Hotspot to use FTP server.")
	CallMainMenu()
end

-- Module main cycle
function AppMainCycle()
	
	-- Draw top screen box
	Screen.fillEmptyRect(5,395,40,220,black,TOP_SCREEN)
	Screen.fillRect(6,394,41,219,white,TOP_SCREEN)
	
	-- Draw FTP info
	Screen.debugPrint(9,45,"IP: "..Network.getIPAddress(),black,TOP_SCREEN)
	Screen.debugPrint(9,60,"Port: 5000",black,TOP_SCREEN)
	ftp_cmd = LinesGenerator(last_shared,90)
	for i,line in pairs(ftp_cmd) do
		Screen.debugPrint(9,line[2],line[1],black,TOP_SCREEN)
	end
	
	-- Draw bottom screen box and command info
	Screen.fillEmptyRect(5,315,40,92,black,BOTTOM_SCREEN)
	Screen.fillRect(6,314,41,91,white,BOTTOM_SCREEN)
	Screen.debugPrint(9,45,"A = Restart FTP server",black,BOTTOM_SCREEN)
	Screen.debugPrint(9,60,"SELECT = Return Main Menu",black,BOTTOM_SCREEN)
	Screen.debugPrint(9,75,"B = Term FTP server",black,BOTTOM_SCREEN)
	
	-- Sets controls triggering
	if Controls.check(pad,KEY_A) and not Controls.check(oldpad,KEY_A) then
		CloseBGApp("FTP Server")
		dofile(main_dir.."/modules/ftp.lua")
	elseif Controls.check(pad,KEY_SELECT) and not Controls.check(oldpad,KEY_SELECT) then
		CallMainMenu()
	elseif Controls.check(pad,KEY_B) or Controls.check(pad,KEY_START) then
		CloseBGApp("FTP Server")
		CallMainMenu()
	end
end
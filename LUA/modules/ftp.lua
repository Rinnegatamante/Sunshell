-- Set private "FTP" mode
mode = "FTP"

-- Module background code
function BackgroundFTP()
	last_shared = Network.updateFTP()
end

function FTPGC()
	Socket.term()
	last_shared = nil
end

-- Internal module settings
FreeIconTopbar("FTP")
if Network.isWifiEnabled() then
	if build == "Ninjhax 2" then
		ShowError("Network features currently unavailable on Ninjhax 2.")
		CallMainMenu()
	else
		if last_shared == nil then
			last_shared = "Waiting for connection..."
			Socket.init()
			table.insert(bg_apps,{BackgroundFTP,FTPGC,"FTP Server"}) -- Adding FTP module to background apps
		end
	end
else
	ShowError("You need to be connected to an Hotspot to use FTP server.")
	CallMainMenu()
end

-- Rendering functions
function AppTopScreenRender()	
	Graphics.fillRect(5,395,40,220,black)
	Graphics.fillRect(6,394,41,219,white)
end

function AppBottomScreenRender()
	Graphics.fillRect(5,315,40,92,black)
	Graphics.fillRect(6,314,41,91,white)
end

-- Module main cycle
function AppMainCycle()
	
	-- Draw FTP info
	Font.print(ttf,9,45,"IP: "..Network.getIPAddress(),black,TOP_SCREEN)
	Font.print(ttf,9,60,"Port: 5000",black,TOP_SCREEN)
	ftp_cmd = LinesGenerator(last_shared,90)
	for i,line in pairs(ftp_cmd) do
		Font.print(ttf,9,line[2],line[1],black,TOP_SCREEN)
	end
	
	-- Draw bottom screen commands info	
	Font.print(ttf,9,45,"A = Restart FTP server",black,BOTTOM_SCREEN)
	Font.print(ttf,9,60,"SELECT = Return Main Menu",black,BOTTOM_SCREEN)
	Font.print(ttf,9,75,"B = Term FTP server",black,BOTTOM_SCREEN)
	
	-- Sets controls triggering
	if Controls.check(pad,KEY_A) and not Controls.check(oldpad,KEY_A) then
		CloseBGApp("FTP Server")
		dofile(main_dir.."/modules/ftp.lua")
	elseif Controls.check(pad,KEY_SELECT) and not Controls.check(oldpad,KEY_SELECT) then
		AddIconTopbar(theme_dir.."/images/ftp_icon.jpg","FTP")
		CallMainMenu()
	elseif Controls.check(pad,KEY_B) or Controls.check(pad,KEY_START) then
		CloseBGApp("FTP Server")
		CallMainMenu()
	end
end
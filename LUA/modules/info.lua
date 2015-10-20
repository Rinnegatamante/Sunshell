-- Set private "Info" mode
mode = "Info"

-- Internal module settings
mac_addr = Network.getMacAddress()
if Network.isWifiEnabled() then
	oldn = true
	ip_addr = Network.getIPAddress()
else
	oldn = false
	ip_addr = "0.0.0.0"
end
usr = System.getUsername()
day, mnth = System.getBirthday()
model = System.getModel()
region = System.getRegion()
fw1,fw2,fw3 = System.getFirmware()
fw = fw1 .. "." .. fw2 .. "-" .. fw3
k1,k2,k3 = System.getKernel()
kernel = k1 .. "." .. k2 .. "-" .. k3
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

-- Rendering functions
function AppTopScreenRender()	
	Graphics.fillRect(5,395,40,220,black)
	Graphics.fillRect(6,394,41,219,white)
end

function AppBottomScreenRender()
end

-- Module main cycle
function AppMainCycle()
	
	-- Draw console info
	if model == 1 then
		Font.print(ttf,9,45,"Model: 3DS XL",black,TOP_SCREEN)	
	elseif model == 2 then
		Font.print(ttf,9,45,"Model: New 3DS",black,TOP_SCREEN)
	elseif model == 3 then
		Font.print(ttf,9,45,"Model: 2DS",black,TOP_SCREEN)
	elseif model == 4 then
		Font.print(ttf,9,45,"Model: New 3DS XL",black,TOP_SCREEN)
	else
		Font.print(ttf,9,45,"Model: 3DS",black,TOP_SCREEN)
	end
	if region == 1 then
		Font.print(ttf,9,60,"Region: USA",black,TOP_SCREEN)
	elseif region == 2 then
		Font.print(ttf,9,60,"Region: EUR",black,TOP_SCREEN)
	else
		Font.print(ttf,9,60,"Region: JPN",black,TOP_SCREEN)
	end
	
	-- Update IP Address
	if oldn and not Network.isWifiEnabled() then
		ip_addr = "0.0.0.0"
		oldn = false
	elseif Network.isWifiEnabled() and not oldn then
		oldn = true
		if build ~= "Ninjhax 2" then
			Socket.init()
			ip_addr = Network.getIPAddress()
			Socket.term()
		else
			ip_addr = "0.0.0.0"
		end
	end
	
	-- Draw info
	Font.print(ttf,9,75,"Username: " .. usr,black,TOP_SCREEN)
	Font.print(ttf,9,90,"Birthday: " .. day .. " " .. months[mnth],black,TOP_SCREEN)
	Font.print(ttf,9,105,"Firmware Build: " .. fw,black,TOP_SCREEN)
	Font.print(ttf,9,120,"Kernel Build: " .. kernel,black,TOP_SCREEN)
	Font.print(ttf,9,135,"Free Space: "..free_space.." "..sorting,black,TOP_SCREEN)
	Font.print(ttf,9,150,"MAC Address: "..mac_addr,black,TOP_SCREEN)
	Font.print(ttf,9,165,"IP Address: "..ip_addr,black,TOP_SCREEN)
	Font.print(ttf,9,180,"Build: "..build,black,TOP_SCREEN)
	
	-- Sets controls triggering
	if Controls.check(pad,KEY_B) or Controls.check(pad,KEY_START) then
		CallMainMenu()
	end
	
end
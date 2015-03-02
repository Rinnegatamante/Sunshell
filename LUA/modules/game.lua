-- Set private "Game" mode
mode = "Game"

-- Internal module settings
master_index_g = 0
p_g = 1
if build == "3DS" then
	ShowError("You're using 3DS build. 3DS build cannot start any type of 3DS executable.")
	CallMainMenu()
else
	my_apps = {}
	if build == "3DSX" then
		dir = System.listDirectory("/3ds/")
		for i,file in pairs(dir) do
			if file.directory then
				if System.doesFileExist("/3ds/"..(file.name).."/"..(file.name)..".3dsx") then
					if System.doesFileExist("/3ds/"..(file.name).."/"..(file.name)..".smdh") then
						app = System.extractSMDH("/3ds/"..(file.name).."/"..(file.name)..".smdh")
						table.insert(my_apps,{true,file.name,app.title,app.desc,app.author,app.icon})
					else
						table.insert(my_apps,{true,file.name,file.name,"","",nil})
					end
				end
			end
		end
	else
		dir = System.listCIA()
		for i,file in pairs(dir) do
			if file.mediatype == 1 then
				table.insert(my_apps,{false,file.access_id,file.product_id,"","0x"..string.sub(string.format('%02X',file.unique_id),1,-3),nil})
			end
		end
	end
end

-- Module main cycle
function AppMainCycle()
	
	-- Draw top screen box
	Screen.fillEmptyRect(5,395,40,220,black,TOP_SCREEN)
	Screen.fillRect(6,394,41,219,white,TOP_SCREEN)
	
	-- Draw bottom screen listmenu and top screen info
	base_y = 0
	for l, file in pairs(my_apps) do
		if (base_y > 226) then
			break
		end
		if (l >= master_index_g) then
			if (l==p_g) then
				base_y2 = base_y
				if (base_y) == 0 then
					base_y = 2
				end
				Screen.fillRect(0,319,base_y-2,base_y2+12,selected_item,BOTTOM_SCREEN)
				CropPrint(9,45,file[3],selected,TOP_SCREEN)
				CropPrint(9,60,file[5],black,TOP_SCREEN)
				desc = LinesGenerator(file[4],90)
				for i,line in pairs(desc) do
					Screen.debugPrint(9,line[2],line[1],black,TOP_SCREEN)
				end
				if file[6] ~= nil then
					Screen.fillEmptyRect(341,390,43,92,black,TOP_SCREEN)
					Screen.drawImage(342,44,file[6],TOP_SCREEN)
				end
				color = selected
				if (base_y) == 2 then
					base_y = 0
				end
			else
				color = black
			end
			if file[1] then
				CropPrint(0,base_y,file[2],color,BOTTOM_SCREEN)
			else
				CropPrint(0,base_y,file[3],color,BOTTOM_SCREEN)
			end
			base_y = base_y + 15
		end
	end
	
	-- Sets controls triggering
	if Controls.check(pad,KEY_B) or Controls.check(pad,KEY_START) then
		CallMainMenu()
		for l, file in pairs(my_apps) do
			if file[6] ~= nil then
				Screen.freeImage(file[6])
			end
		end
	elseif Controls.check(pad,KEY_A) then
		GarbageCollection()
		for l, file in pairs(my_apps) do
			if file[6] ~= nil then
				Screen.freeImage(file[6])
			end
		end
		if my_apps[p][1] then
			GarbageCollection()
			for i,bg_apps_code in pairs(bg_apps) do
				bg_apps_code[2]()
			end
			Sound.term()
			System.launch3DSX("/3ds/"..my_apps[p_g][2].."/"..my_apps[p_g][2]..".3dsx")
		else
			GarbageCollection()
			for i,bg_apps_code in pairs(bg_apps) do
				bg_apps_code[2]()
			end
			Sound.term()
			System.launchCIA(my_apps[p_g][2],1)
		end
	elseif (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
		p_g = p_g - 1
		if (p >= 16) then
			master_index_g = p_g - 15
		end
	elseif (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
		p_g = p_g + 1
		if (p_g >= 17) then
			master_index_g = p_g - 15
		end
	end
	if (p_g < 1) then
		p_g = #my_apps
		if (p_g >= 17) then
			master_index_g = p_g - 15
		end
	elseif (p_g > #my_apps) then
		master_index_g = 0
		p = 1
	end
end
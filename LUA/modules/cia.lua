-- Set private "Cia" mode
mode = "Cia"

-- Internal module settings
master_index_cia = 0
p_cia = 1
if build == "3DS" or build == "3DSX" then
	ShowError("This module is reserved to CIA build users.")
	CallMainMenu()
else
	cia_table = System.listCIA()
	not_extracted = true
	function TableConcat(t1,t2)
		for i=1,#t2 do
			t1[#t1+1] = t2[i]
		end
		return t1
	end
	function listDirectory(dir)
		dir = System.listDirectory(dir)
		folders_table = {}
		files_table = {}
		for i,file in pairs(dir) do
			if file.directory then
				table.insert(folders_table,file)
			elseif (string.sub(file.name,-4) == ".cia") or (string.sub(file.name,-4) == ".CIA") then
				table.insert(files_table,file)
			end
		end
		table.sort(files_table, function (a, b) return (a.name:lower() < b.name:lower() ) end)
		table.sort(folders_table, function (a, b) return (a.name:lower() < b.name:lower() ) end)
		return_table = TableConcat(folders_table,files_table)
		return return_table
	end
	function UpdateSpace()
		free_space = System.getFreeSpace()
		f = "Bytes"
		f_free_space = free_space
		if free_space > 1024 then
			f_free_space = free_space / 1024
			f = "KBs"
			if f_free_space > 1024 then
				f_free_space = f_free_space / 1024
				f = "MBs"
			end
		end
	end
	UpdateSpace()
	files_table = listDirectory("/")
	int_mode = "CIA"
	function GetCategory(c)
		if c==0 then
			return "Application"
		elseif c==1 then
			return "System"
		elseif c==2 then
			return "Demo"
		elseif c==3 then
			return "Patch"
		elseif c==4 then
			return "TWL"
		end
	end
	function OpenDirectory(text,archive_id)
		i=0
		if text == ".." then
			j=-2
			while string.sub(System.currentDirectory(),j,j) ~= "/" do
				j=j-1
			end
			System.currentDirectory(string.sub(System.currentDirectory(),1,j))
		else
			System.currentDirectory(System.currentDirectory()..text.."/")
		end
		files_table = listDirectory(System.currentDirectory())
		if System.currentDirectory() ~= "/" then
			local extra = {}
			extra.name = ".."
			extra.size = 0
			extra.directory = true
			table.insert(files_table,extra)
		end
	end
end

-- Module main cycle
function AppMainCycle()

	-- Reset internal variables
	sm_index = 1
	base_y = 0
	
	-- Draw top screen box
	Screen.fillEmptyRect(5,395,40,220,black,TOP_SCREEN)
	Screen.fillRect(6,394,41,219,white,TOP_SCREEN)
	
	-- Draw bottom screen listmenu and top screen info
	Screen.debugPrint(9,175,"Free Space: "..f_free_space.." "..f,black,TOP_SCREEN)
	base_y = 0
	if int_mode == "SDMC" then
		for l, file in pairs(files_table) do
			if (base_y > 226) then
				break
			end
			if (l >= master_index_cia) then
				if (l==p_cia) then
					base_y2 = base_y
					if (base_y) == 0 then
						base_y = 2
					end
					Screen.fillRect(0,319,base_y-2,base_y2+12,selected_item,BOTTOM_SCREEN)
					color = selected
					if (base_y) == 2 then
						base_y = 0
					end
				else
					color = black
				end
				CropPrint(0,base_y,file.name,color,BOTTOM_SCREEN)
				base_y = base_y + 15
			end
		end
		Screen.debugPrint(9,190,"SDMC listing",black,TOP_SCREEN)
		if not files_table[p_cia].directory then
			if not_extracted == true then
				cia_data = System.extractCIA(System.currentDirectory()..files_table[p_cia].name)
			end
			Screen.debugPrint(9,45,"Title: "..cia_data.title,black,TOP_SCREEN)
			Screen.debugPrint(9,60,"Unique ID: 0x"..string.sub(string.format('%02X',cia_data.unique_id),1,-3),black,TOP_SCREEN)
			tmp = io.open(System.currentDirectory()..files_table[p_cia].name,FREAD)
			size = io.size(tmp)
			f_size = size
			f2 = "Bytes"
			if size > 1024 then
				f_size = size / 1024
				f2 = "KBs"
				if f_size > 1024 then
					f_size = f_size / 1024
					f2 = "MBs"
				end
			end
			Screen.debugPrint(9,75,"Filesize: "..f_size.." "..f2,black,TOP_SCREEN)
			io.close(tmp)
		end
	else
		for l, file in pairs(cia_table) do
			if (base_y > 226) then
				break
			end
			if (l >= master_index_cia) then
				if (l==p_cia) then
					base_y2 = base_y
					if (base_y) == 0 then
						base_y = 2
					end
					Screen.fillRect(0,319,base_y-2,base_y2+12,selected_item,BOTTOM_SCREEN)
					color = selected
					if (base_y) == 2 then
						base_y = 0
					end
				else
					color = black
				end
				CropPrint(0,base_y,file.product_id,color,BOTTOM_SCREEN)
				base_y = base_y + 15
			end
		end
		Screen.debugPrint(9,190,"Imported CIA listing",black,TOP_SCREEN)
		Screen.debugPrint(9,45,"Unique ID: 0x"..string.sub(string.format('%02X',cia_table[p_cia].unique_id),1,-3),black,TOP_SCREEN)
		Screen.debugPrint(9,60,"Product ID: "..cia_table[p_cia].product_id,black,TOP_SCREEN)
		Screen.debugPrint(9,75,"Category: "..GetCategory(cia_table[p_cia].category),black,TOP_SCREEN)
		if (cia_table[p_cia].platform == 3) then
			Screen.debugPrint(9,90,"Platform: DSi",black,TOP_SCREEN)
		else
			Screen.debugPrint(9,90,"Platform: 3DS",black,TOP_SCREEN)
		end
		if cia_table[p_cia].mediatype == 1 then
			Screen.debugPrint(9,105,"Location: SDMC",Color.new(0,0,255),TOP_SCREEN)
		else
			Screen.debugPrint(9,105,"Location: NAND",Color.new(255,0,0),TOP_SCREEN)
		end
	end
	
	-- Sets controls triggering
	if Controls.check(pad,KEY_B) or Controls.check(pad,KEY_START) then
		CallMainMenu()
	elseif (Controls.check(pad,KEY_A) and not Controls.check(oldpad,KEY_A)) then
		oldpad = KEY_A
		if (int_mode == "SDMC") then
			sm_index = 1
			if (files_table[p_cia].directory) then
				OpenDirectory(files_table[p_cia].name)
				p_cia = 1
				master_index_cia = 0
			else
				if free_space - size > 0 then
					while true do
						Screen.waitVblankStart()
						Screen.refresh()
						Controls.init()
						pad = Controls.read()
						Screen.fillEmptyRect(60,260,50,82,black,BOTTOM_SCREEN)
						Screen.fillRect(61,259,51,81,white,BOTTOM_SCREEN)
						if (sm_index == 1) then
							Screen.fillRect(61,259,51,66,selected_item,BOTTOM_SCREEN)
							Screen.debugPrint(63,53,"Confirm",selected,BOTTOM_SCREEN)
							Screen.debugPrint(63,68,"Cancel",black,BOTTOM_SCREEN)
							if (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
								sm_index = 2
							elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
								TopCropPrint(9,100,"Importing " .. files_table[p_cia].name.."...",black,TOP_SCREEN)
								Screen.debugPrint(9,115,"Please wait...",black,TOP_SCREEN)
								Screen.flip()
								Screen.waitVblankStart()
								System.installCIA(System.currentDirectory()..files_table[p_cia].name)
								UpdateSpace()
								break
							end
						else
							Screen.fillRect(61,259,66,81,selected_item,BOTTOM_SCREEN)
							Screen.debugPrint(63,53,"Confirm",black,BOTTOM_SCREEN)
							Screen.debugPrint(63,68,"Cancel",selected,BOTTOM_SCREEN)
							if (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
								sm_index = 1
							elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
								break
							end
						end
						oldpad = pad
						Screen.flip()
					end
				end
			end
		else
			while true do
				Screen.waitVblankStart()
				Screen.refresh()
				Controls.init()
				pad = Controls.read()
				Screen.fillEmptyRect(60,260,50,82,black,BOTTOM_SCREEN)
				Screen.fillRect(61,259,51,81,white,BOTTOM_SCREEN)
				if (sm_index == 1) then
					Screen.fillRect(61,259,51,66,selected_item,BOTTOM_SCREEN)
					Screen.debugPrint(63,53,"Confirm",selected,BOTTOM_SCREEN)
					Screen.debugPrint(63,68,"Cancel",black,BOTTOM_SCREEN)
					if (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
						sm_index = 2
					elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
						System.uninstallCIA(cia_table[p_cia].access_id,cia_table[p_cia].mediatype)
						UpdateSpace()
						break
					end
				else
					Screen.fillRect(61,259,66,81,selected_item,BOTTOM_SCREEN)
					Screen.debugPrint(63,53,"Confirm",selected,BOTTOM_SCREEN)
					Screen.debugPrint(63,68,"Cancel",black,BOTTOM_SCREEN)
					if (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
						sm_index = 1
					elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
						break
					end
				end
				Screen.flip()
				oldpad = pad
			end
			cia_table = System.listCIA()
			if p_cia > #cia_table then
				p_cia = p_cia - 1
			end
		end
	elseif (Controls.check(pad,KEY_Y) and not Controls.check(oldpad,KEY_Y)) then
		oldpad = KEY_A
		if (int_mode == "SDMC") then
			sm_index = 1
			if not (files_table[p_cia].directory) and (free_space - size > 0) then
				while true do
					Screen.waitVblankStart()
					Screen.refresh()
					Controls.init()
					pad = Controls.read()
					Screen.fillEmptyRect(60,260,50,82,black,BOTTOM_SCREEN)
					Screen.fillRect(61,259,51,81,white,BOTTOM_SCREEN)
					if (sm_index == 1) then
						Screen.fillRect(61,259,51,66,selected_item,BOTTOM_SCREEN)
						Screen.debugPrint(63,53,"Confirm",selected,BOTTOM_SCREEN)
						Screen.debugPrint(63,68,"Cancel",black,BOTTOM_SCREEN)
						if (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
							sm_index = 2
						elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
							TopCropPrint(9,100,"Importing " .. files_table[p_cia].name.."...",black,TOP_SCREEN)
							Screen.debugPrint(9,115,"Please wait...",black,TOP_SCREEN)
							Screen.flip()
							Screen.waitVblankStart()
							System.installCIA(System.currentDirectory()..files_table[p_cia].name,0)
							System.deleteFile(System.currentDirectory()..files_table[p_cia].name)
							UpdateSpace()
							files_table = listDirectory(System.currentDirectory())
							if System.currentDirectory() ~= "/" then
								local extra = {}
								extra.name = ".."
								extra.size = 0
								extra.directory = true
								table.insert(files_table,extra)
							end
							if (p_cia > #files_table) then
								p_cia = p_cia - 1
							end
							break
						end
					else
						Screen.fillRect(61,259,66,81,selected_item,BOTTOM_SCREEN)
						Screen.debugPrint(63,53,"Confirm",selected,BOTTOM_SCREEN)
						Screen.debugPrint(63,68,"Cancel",black,BOTTOM_SCREEN)
						if (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
							sm_index = 1
						elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
							break
						end
					end
					oldpad = pad
					Screen.flip()
				end
			end
		else
			System.launchCIA(cia_table[p_cia].unique_id,cia_table[p_cia].mediatype)
		end
	elseif (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
		not_extracted = true
		p_cia = p_cia - 1
		if (p_cia >= 16) then
			master_index_cia = p_cia - 15
		end
	elseif (Controls.check(pad,KEY_DLEFT)) and not (Controls.check(oldpad,KEY_DLEFT)) then
		not_extracted = true
		p_cia = p_cia - 16
		if p_cia < 1 then
			p_cia = 1
		end
		if (p_cia >= 16) then
			master_index_cia = p_cia - 15
		else
			master_index_cia = 0
		end
	elseif (Controls.check(pad,KEY_DRIGHT)) and not (Controls.check(oldpad,KEY_DRIGHT)) then
		not_extracted = true
		p_cia = p_cia + 16
		if ((p_cia > #files_table) and (int_mode == "SDMC")) then
			p_cia = #files_table
		elseif ((p_cia > #cia_table) and (int_mode == "CIA")) then
			p_cia = #cia_table
		end
		if (p_cia >= 17) then
			master_index_cia = p_cia - 15
		end
	elseif (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
		not_extracted = true
		p_cia = p_cia + 1
		if (p_cia >= 17) then
			master_index_cia = p_cia - 15
		end
	end
	if (p_cia < 1) then
		if (int_mode == "SDMC") then
			p_cia = #files_table
		else
			p_cia = #cia_table
		end
		if (p_cia >= 17) then
			master_index_cia = p_cia - 15
		end
	elseif ((p_cia > #files_table) and (int_mode == "SDMC")) or ((p_cia > #cia_table) and (int_mode == "CIA")) then
		master_index_cia = 0
		p_cia = 1
	end
	if (Controls.check(pad,KEY_SELECT)) and not (Controls.check(oldpad,KEY_SELECT)) then
		if int_mode=="CIA" then
			int_mode = "SDMC"
		else
			int_mode = "CIA"
			cia_table = System.listCIA()
		end
		p_cia = 1
		master_index_cia = 0
	end
end
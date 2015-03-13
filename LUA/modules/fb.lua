-- Set private "FB" mode
mode = "FB"

-- Internal module settings
update_bottom_screen = true
ui_enabled = false
red = Color.new(255,0,0)
green = Color.new(0,255,0)
menu_color = Color.new(255,255,255)
selected_color = Color.new(0,255,0)
selected_item = Color.new(0,0,200,50)
copy_or_move = false
function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end
function SortDirectory(dir)
	folders_table = {}
	files_table = {}
	for i,file in pairs(dir) do
		if file.directory then
			table.insert(folders_table,file)
		else
			table.insert(files_table,file)
		end
	end
	table.sort(files_table, function (a, b) return (a.name:lower() < b.name:lower() ) end)
	table.sort(folders_table, function (a, b) return (a.name:lower() < b.name:lower() ) end)
	return_table = TableConcat(folders_table,files_table)
	return return_table
end
files_table = SortDirectory(System.listDirectory("/"))
System.currentDirectory("/")
p = 1
current_file = nil
current_type = nil
big_image = false
master_index = 0
sm_index = 1
if build == "CIA" then
	sm_voices = {"Video Player","Music Player","Image Viewer","Text Reader","LUA Interpreter","HEX Viewer","3DSX Launcher","SMDH Decoder","ZIP Extractor","Info Viewer","Cancel"}
else
	sm_voices = {"Video Player","Music Player","Image Viewer","Text Reader","LUA Interpreter","HEX Viewer","CIA Installer","SMDH Decoder","ZIP Extractor","Info Viewer","Cancel"}
end
hex_values = {}
hex_text = {}
updateTXT = false
select_mode = false
update_main_extdata = true
action_check = false
move_base = nil
copy_base = nil
x_print = 0
y_print = 0
copy_type = 0
move_type = 0
txt_index = 0
txt_words = 0
txt_i = 0
old_indexes = {}
MAX_RAM_ALLOCATION = 10485760
function DumpFile(input,archive)
	inp = io.open(extdata_directory..input,FREAD,archive)
	if System.doesFileExist("/"..input) then
		System.deleteFile("/"..input)
	end
	out = io.open("/"..string.format('%02X',archive).."_"..input,FCREATE)
	size = io.size(inp)
	index = 0
	while (index+(MAX_RAM_ALLOCATION/2) < size) do
		io.write(out,index,io.read(inp,index,MAX_RAM_ALLOCATION/2),(MAX_RAM_ALLOCATION/2))
		index = index + (MAX_RAM_ALLOCATION/2)
	end
	if index < size then
		io.write(out,index,io.read(inp,index,size-index),(size-index))
	end
	io.close(inp)
	io.close(out)
end
function CopyFile(input,output)
	inp = io.open(input,FREAD)
	if System.doesFileExist(output) then
		System.deleteFile(output)
	end
	out = io.open(output,FCREATE)
	size = io.size(inp)
	index = 0
	while (index+(MAX_RAM_ALLOCATION/2) < size) do
		io.write(out,index,io.read(inp,index,MAX_RAM_ALLOCATION/2),(MAX_RAM_ALLOCATION/2))
		index = index + (MAX_RAM_ALLOCATION/2)
	end
	if index < size then
		io.write(out,index,io.read(inp,index,size-index),(size-index))
	end
	io.close(inp)
	io.close(out)
end
function CopyDir(input,output)
	files = System.listDirectory(input)
	System.createDirectory(output)
	for z, file in pairs(files) do
		if (file.directory) then
			CopyDir(input.."/"..file.name,output.."/"..file.name)
		else
			CopyFile(input.."/"..file.name,output.."/"..file.name)
		end
	end
end
function ForceOpenFile(text, size, mode)
	if mode == "SMDH" then
		FBGC()
		current_type = "SMDH"
		current_file = System.extractSMDH(System.currentDirectory()..text)
		smdh_show = Console.new(TOP_SCREEN)
		Console.append(smdh_show,"Title: "..current_file.title.."\n\n")
		Console.append(smdh_show,"Description: "..current_file.desc.."\n\n")
		Console.append(smdh_show,"Author: "..current_file.author)
	elseif mode == "3DSX" and not System.isGWMode() then
		FBGC()
		Screen.freeImage(bg)
		Sound.term()
		System.launch3DSX(System.currentDirectory()..text)
	elseif mode == "BMPV" then
		FBGC()
		current_file = io.open(System.currentDirectory()..text,FREAD)
		magic = io.read(current_file,0,4)
		io.close(current_file)
		if magic == "BMPV" then
			current_file = BMPV.load(System.currentDirectory()..text)
			current_type = "BMPV"
			BMPV.start(current_file,NO_LOOP,0x08,0x09)
		else
			current_file = JPGV.load(System.currentDirectory()..text)
			current_type = "JPGV"
			JPGV.start(current_file,NO_LOOP,0x08,0x09)
		end
	elseif mode == "WAV" then
		FBGC()
		current_file = io.open(System.currentDirectory()..text,FREAD)
		magic = io.read(current_file,8,4)
		io.close(current_file)
		if magic == "AIFF" then
			mem_blocks = 2
			while (size * 2) > MAX_RAM_ALLOCATION do
				mem_blocks = mem_blocks + 2
				size = size / 2
			end
			current_file = Sound.openAiff(System.currentDirectory()..text,mem_blocks)
			current_type = "WAV"
			Sound.play(current_file,NO_LOOP,0x08,0x09)
		else
			mem_blocks = 2
			while (size * 2) > MAX_RAM_ALLOCATION do
				mem_blocks = mem_blocks + 2
				size = size / 2
			end
			current_file = Sound.openWav(System.currentDirectory()..text,mem_blocks)
			current_type = "WAV"
			Sound.play(current_file,NO_LOOP,0x08,0x09)
		end
	elseif mode == "IMG" then
		FBGC()
		current_type = "IMG"
		current_file = Screen.loadImage(System.currentDirectory()..text)
		if Screen.getImageWidth(current_file) > 400 then
			width = 400
			big_image = true
		end
		if Screen.getImageHeight(current_file) > 240 then
			height = 240
			big_image = true
		end
	elseif mode == "LUA" then
		FBGC()
		Screen.freeImage(bg)
		Sound.term()
		reset_dir = System.currentDirectory()
		System.currentDirectory(string.sub(System.currentDirectory(),1,-2))
		dofile(System.currentDirectory().."/"..text)
		System.currentDirectory(reset_dir)
		current_type = "LUA"
		Sound.init()
	elseif mode == "TXT" then
		FBGC()
		current_file = io.open(System.currentDirectory()..text,FREAD)
		text_console = Console.new(TOP_SCREEN)
		current_type = "TXT"
		txt_index = 0
		txt_words = 0
		updateTXT = true
	elseif mode == "HEX" then
		FBGC()
		current_file = io.open(System.currentDirectory()..text,FREAD)
		current_type = "HEX"
		txt_index = 0
		updateTXT = true
	elseif mode == "INFO" then
		FBGC()
		current_file = io.open(System.currentDirectory()..text,FREAD)
		current_type = "INFO"
		f_size = io.size(current_file)
		f = "Bytes"
		if (f_size > 1024) then
			f_size = f_size / 1024
			f = "KBs"
		end
		if (f_size > 1024) then
			f_size = f_size / 1024
			f = "MBs"
		end
		io.close(current_file)
		text_console = Console.new(TOP_SCREEN)
		Console.append(text_console,"Filename: "..text.."\n")
		i = -1
		while string.sub(text,i,i) ~= "." do
			i = i - 1
		end
		i = i + 1
		Console.append(text_console,"Format: "..string.upper(string.sub(text,i)).."\n")
		Console.append(text_console,"Size: "..f_size.." "..f.."\n")
	elseif mode == "ZIP" then
		FBGC()
		pass = System.startKeyboard("")
		System.extractZIP(System.currentDirectory()..text,System.currentDirectory()..string.sub(text,1,-5),pass)
		files_table = System.listDirectory(System.currentDirectory())
		if System.currentDirectory() ~= "/" then
			local extra = {}
			extra.name = ".."
			extra.size = 0
			extra.directory = true
			table.insert(files_table,extra)
		end
		files_table = SortDirectory(files_table)
	elseif mode == "CIA" then
		FBGC()
		sm_index = 1
		cia_data = System.extractCIA(System.currentDirectory()..text)
		oldpad = KEY_A
		while true do
			Screen.refresh()
			Screen.waitVblankStart()
			Screen.clear(TOP_SCREEN)
			Screen.debugPrint(0,0,"Title: "..cia_data.title,white,TOP_SCREEN)
			Screen.debugPrint(0,15,"Unique ID: 0x"..string.sub(string.format('%02X',cia_data.unique_id),1,-3),white,TOP_SCREEN)
			Controls.init()
			pad = Controls.read()
			Screen.fillEmptyRect(60,260,50,82,black,BOTTOM_SCREEN)
			Screen.fillRect(61,259,51,81,white,BOTTOM_SCREEN)
			if (sm_index == 1) then
				Screen.fillRect(61,259,51,66,green,BOTTOM_SCREEN)
				Screen.debugPrint(63,53,"Confirm",red,BOTTOM_SCREEN)
				Screen.debugPrint(63,68,"Cancel",black,BOTTOM_SCREEN)
				if (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
					sm_index = 2
				elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
					System.installCIA(System.currentDirectory()..text)
					break
				end
			else
				Screen.fillRect(61,259,66,81,green,BOTTOM_SCREEN)
				Screen.debugPrint(63,53,"Confirm",black,BOTTOM_SCREEN)
				Screen.debugPrint(63,68,"Cancel",red,BOTTOM_SCREEN)
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
function DeleteDir(dir)
	files = System.listDirectory(dir)
	for z, file in pairs(files) do
		if (file.directory) then
			DeleteDir(dir.."/"..file.name)
		else
			System.deleteFile(dir.."/"..file.name)
		end
	end
	System.deleteDirectory(dir)
end
function OpenFile(text, size)
	if string.sub(text,-5) == ".smdh" or string.sub(text,-5) == ".SMDH" then
		FBGC()
		current_type = "SMDH"
		current_file = System.extractSMDH(System.currentDirectory()..text)
		smdh_show = Console.new(TOP_SCREEN)
		Console.append(smdh_show,"Title: "..current_file.title.."\n\n")
		Console.append(smdh_show,"Description: "..current_file.desc.."\n\n")
		Console.append(smdh_show,"Author: "..current_file.author)
	elseif string.sub(text,-4) == ".zip" or string.sub(text,-4) == ".ZIP" then
		FBGC()
		pass = System.startKeyboard("")
		System.extractZIP(System.currentDirectory()..text,System.currentDirectory()..string.sub(text,1,-5),pass)
		files_table = System.listDirectory(System.currentDirectory())
		if System.currentDirectory() ~= "/" then
			local extra = {}
			extra.name = ".."
			extra.size = 0
			extra.directory = true
			table.insert(files_table,extra)
		end
		files_table = SortDirectory(files_table)
	elseif (string.sub(text,-5) == ".3dsx" or string.sub(text,-5) == ".3DSX") and not System.isGWMode() then
		FBGC()
		Screen.freeImage(bg)
		Sound.term()
		System.launch3DSX(System.currentDirectory()..text)
	elseif string.sub(text,-5) == ".bmpv" or string.sub(text,-5) == ".BMPV" then
		FBGC()
		current_file = BMPV.load(System.currentDirectory()..text)
		current_type = "BMPV"
		BMPV.start(current_file,NO_LOOP,0x08,0x09)
	elseif string.sub(text,-5) == ".jpgv" or string.sub(text,-5) == ".JPGV" then
		FBGC()
		current_file = JPGV.load(System.currentDirectory()..text)
		current_type = "JPGV"
		JPGV.start(current_file,NO_LOOP,0x08,0x09)
	elseif string.sub(text,-4) == ".wav" or string.sub(text,-4) == ".WAV" then
		FBGC()
		mem_blocks = 2
		while (size * 2) > MAX_RAM_ALLOCATION do
			mem_blocks = mem_blocks + 2
			size = size / 2
		end
		current_file = Sound.openWav(System.currentDirectory()..text,mem_blocks)
		current_type = "WAV"
		Sound.play(current_file,NO_LOOP,0x08,0x09)
	elseif string.sub(text,-4) == ".aif" or string.sub(text,-4) == ".AIF" or string.sub(text,-5) == ".aiff" or string.sub(text,-5) == ".AIFF" then
		FBGC()
		mem_blocks = 2
		while (size * 2) > MAX_RAM_ALLOCATION do
			mem_blocks = mem_blocks + 2
			size = size / 2
		end
		current_file = Sound.openAiff(System.currentDirectory()..text,mem_blocks)
		current_type = "WAV"
		Sound.play(current_file,NO_LOOP,0x08,0x09)
	elseif string.sub(text,-4) == ".png" or string.sub(text,-4) == ".PNG" or string.sub(text,-4) == ".BMP" or string.sub(text,-4) == ".bmp" or string.sub(text,-4) == ".JPG" or string.sub(text,-4) == ".jpg" then
		FBGC()
		current_type = "IMG"
		current_file = Screen.loadImage(System.currentDirectory()..text)
		width = Screen.getImageWidth(current_file)
		height = Screen.getImageHeight(current_file)
		if width > 400 then
			width = 400
			big_image = true
		end
		if height > 240 then
			height = 240
			big_image = true
		end
	elseif string.sub(text,-4) == ".lua" or string.sub(text,-4) == ".LUA" then
		FBGC()
		Screen.freeImage(bg)
		Sound.term()
		reset_dir = System.currentDirectory()
		System.currentDirectory(string.sub(System.currentDirectory(),1,-2))
		dofile(System.currentDirectory().."/"..text)
		System.currentDirectory(reset_dir)
		current_type = "LUA"
		Sound.init()
	elseif string.sub(text,-4) == ".txt" or string.sub(text,-4) == ".TXT" then
		FBGC()
		current_file = io.open(System.currentDirectory()..text,FREAD)
		text_console = Console.new(TOP_SCREEN)
		current_type = "TXT"
		txt_index = 0
		txt_words = 0
		updateTXT = true
	elseif string.sub(text,-4) == ".cia" or string.sub(text,-4) == ".CIA" then
		FBGC()
		sm_index = 1
		cia_data = System.extractCIA(System.currentDirectory()..text)
		oldpad = KEY_A
		while true do
			Screen.refresh()
			Screen.waitVblankStart()
			Screen.clear(TOP_SCREEN)
			Screen.debugPrint(0,0,"Title: "..cia_data.title,white,TOP_SCREEN)
			Screen.debugPrint(0,15,"Unique ID: 0x"..string.sub(string.format('%02X',cia_data.unique_id),1,-3),white,TOP_SCREEN)
			Controls.init()
			pad = Controls.read()
			Screen.fillEmptyRect(60,260,50,82,black,BOTTOM_SCREEN)
			Screen.fillRect(61,259,51,81,white,BOTTOM_SCREEN)
			if (sm_index == 1) then
				Screen.fillRect(61,259,51,66,green,BOTTOM_SCREEN)
				Screen.debugPrint(63,53,"Confirm",red,BOTTOM_SCREEN)
				Screen.debugPrint(63,68,"Cancel",black,BOTTOM_SCREEN)
				if (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
					sm_index = 2
				elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
					System.installCIA(System.currentDirectory()..text)
					break
				end
			else
				Screen.fillRect(61,259,66,81,green,BOTTOM_SCREEN)
				Screen.debugPrint(63,53,"Confirm",black,BOTTOM_SCREEN)
				Screen.debugPrint(63,68,"Cancel",red,BOTTOM_SCREEN)
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
	files_table = System.listDirectory(System.currentDirectory())
	if System.currentDirectory() ~= "/" then
		local extra = {}
		extra.name = ".."
		extra.size = 0
		extra.directory = true
		table.insert(files_table,extra)
	end
	files_table = SortDirectory(files_table)
end
function FBGC()
	if current_type == "SMDH" then
		Console.destroy(smdh_show)
		Screen.freeImage(current_file.icon)
	elseif current_type == "BMPV" then
		if BMPV.isPlaying(current_file) then
			BMPV.stop(current_file)
		end
		BMPV.unload(current_file)
	elseif current_type == "JPGV" then
		if JPGV.isPlaying(current_file) then
			JPGV.stop(current_file)
		end
		JPGV.unload(current_file)
	elseif current_type == "WAV" then
		if Sound.isPlaying(current_file) then
			Sound.pause(current_file)
		end
		Sound.close(current_file)
	elseif current_type == "IMG" then
		Screen.freeImage(current_file)
		big_image = false
		y_print = 0
		x_print = 0
	elseif current_type == "TXT" then
		io.close(current_file)
		Console.destroy(text_console)
		old_indexes = {}
		txt_i = 0
	elseif current_type == "INFO" then
		Console.destroy(text_console)
	elseif current_type == "HEX" then
		io.close(current_file)
		old_indexes = {}
		txt_i = 0
	end
	current_type = nil
end
function ThemePrint(x, y, text, color, screen)
	if string.len(text) > 40 then
		Screen.debugPrint(x, y, string.sub(text,1,40) .. "...", color, screen)
	else
		Screen.debugPrint(x, y, text, color, screen)
	end
end
function BuildLines(file, index)
	MAX_LENGTH = 1200
	SIZE = io.size(file)
	if ((index + MAX_LENGTH) < SIZE) then
		READ_LENGTH = MAX_LENGTH
	else
		READ_LENGTH = SIZE - index
	end
	if (index < SIZE) then
		Console.clear(text_console)
		Console.append(text_console,io.read(file,index,READ_LENGTH))
		txt_words = Console.show(text_console)
	else
		txt_words = 0
	end
	if (txt_words > 0) then
		table.insert(old_indexes, index)
		index = index + txt_words
		txt_i = txt_i + 1
	end
	return index
end
function BuildHex(file, index)
	MAX_LENGTH = 120
	SIZE = io.size(file)
	if ((index + MAX_LENGTH) < SIZE) then
		READ_LENGTH = MAX_LENGTH
	else
		READ_LENGTH = SIZE - index
	end
	if (index < SIZE) then
		hex_text = {}
		hex_values = {}
		text = io.read(file,index,READ_LENGTH)
		t = 1
		while (t <= 15) do
			if ((t*8) > string.len(text)) then
				temp = string.sub(text,1+(t-1)*8,-1)
			else
				temp = string.sub(text,1+(t-1)*8,t*8)
			end
			t2 = 1
			while t2 <= string.len(temp) do
				table.insert(hex_values,string.byte(temp,t2))
				t2 = t2 + 1
			end
			table.insert(hex_text,temp)
			t = t + 1
		end
		table.insert(old_indexes, index)
		index = index + READ_LENGTH
		txt_i = txt_i + 1
	end
	return index
end

-- Module main cycle
function AppMainCycle()
	base_y = 0
	i = 1
	Screen.clear(TOP_SCREEN)
	if (current_type == "SMDH") then
			Console.show(smdh_show)
			Screen.debugPrint(0,170,"Icon:",white,TOP_SCREEN)
			Screen.drawImage(0,185,current_file.icon,TOP_SCREEN)
	elseif (current_type == "BMPV") then
		BMPV.draw(0,0,current_file,TOP_SCREEN)
	elseif (current_type == "JPGV") then
		JPGV.draw(0,0,current_file,TOP_SCREEN)
	elseif (current_type == "WAV") then
		Sound.updateStream(current_file)
		Screen.debugPrint(0,0,"Title: ",white,TOP_SCREEN)
		ThemePrint(0,15,Sound.getTitle(current_file),white,TOP_SCREEN)
		Screen.debugPrint(0,40,"Author: ",white,TOP_SCREEN)
		ThemePrint(0,55,Sound.getAuthor(current_file),white,TOP_SCREEN)
		Screen.debugPrint(0,80,"Time: "..FormatTime(Sound.getTime(current_file)).." / "..FormatTime(Sound.getTotalTime(current_file)),white,TOP_SCREEN)
		Screen.debugPrint(0,95,"Samplerate: "..Sound.getSrate(current_file),white,TOP_SCREEN)
		if Sound.getType(current_file) == 1 then
			stype = "Mono"
		else
			stype = "Stereo"
		end
		Screen.debugPrint(0,110,"Audiotype: "..stype,white,TOP_SCREEN)
	elseif (current_type == "IMG") then
		if big_image then
			Screen.drawPartialImage(0,0,x_print,y_print,width,height,current_file,TOP_SCREEN)
			x,y = Controls.readCirclePad()
			if (x < - 100) and (x_print > 0) then
				x_print = x_print - 1
			end
			if (y > 100) and (y_print > 0) then
				y_print = y_print - 1
			end
			if (x > 100) and (x_print + width < Screen.getImageWidth(current_file)) then
				x_print = x_print + 1
			end
			if (y < - 100) and (y_print + height < Screen.getImageHeight(current_file)) then
				y_print = y_print + 1
			end
		else
			Screen.drawImage(0,0,current_file,TOP_SCREEN)
		end
	elseif (current_type == "INFO") then
		Console.show(text_console)
	elseif (current_type == "TXT") then
		if (updateTXT) then
			txt_index = BuildLines(current_file,txt_index)
			updateTXT = false
		end
		Console.show(text_console)
	elseif (current_type == "HEX") then
		if (updateTXT) then
			txt_index = BuildHex(current_file,txt_index)
			updateTXT = false
		end
		for l, line in pairs(hex_text) do
			Screen.debugPrint(280,(l-1)*15,string.gsub(line,"\0"," "),white,TOP_SCREEN)
			temp = 1
			while (temp <= string.len(line)) do
				if (temp % 2 == 0) then
					Screen.debugPrint(0+(temp-1)*30,(l-1)*15,string.format('%02X', hex_values[(l-1)*8+temp]),white,TOP_SCREEN)
				else
					Screen.debugPrint(0+(temp-1)*30,(l-1)*15,string.format('%02X', hex_values[(l-1)*8+temp]),red,TOP_SCREEN)
				end
				temp = temp + 1
			end
		end
		Screen.debugPrint(0,225,"Offset: 0x" .. string.format('%X', old_indexes[#old_indexes]) .. " (" .. (old_indexes[#old_indexes]) .. ")",white,TOP_SCREEN)
	else
		Screen.debugPrint(0,0,"Basic Controls:",white,TOP_SCREEN)
		Screen.debugPrint(0,15,"A = Open file/folder",white,TOP_SCREEN)
		Screen.debugPrint(0,30,"SELECT = Open file with...",white,TOP_SCREEN)
		Screen.debugPrint(0,45,"R = Create new folder",white,TOP_SCREEN)
		Screen.debugPrint(0,60,"X = File operations",white,TOP_SCREEN)
		Screen.debugPrint(0,75,"B = Return Main Menu",white,TOP_SCREEN)
		Screen.debugPrint(0,90,"---------------------------------",white,TOP_SCREEN)
		Screen.debugPrint(0,105,"Opened file Controls:",white,TOP_SCREEN)
		Screen.debugPrint(0,120,"X = Cancel file copy/move",white,TOP_SCREEN)
		Screen.debugPrint(0,135,"Y = Confirm file copy/move",white,TOP_SCREEN)
		Screen.debugPrint(0,150,"Left/Right = Pause/Resume",white,TOP_SCREEN)
		Screen.debugPrint(0,165,"Left/Right = Extract icon (SMDH)",white,TOP_SCREEN)
		Screen.debugPrint(0,180,"Left/Right = Scroll file",white,TOP_SCREEN)
	end
	if update_bottom_screen then
		Screen.clear(BOTTOM_SCREEN)
		for l, file in pairs(files_table) do
			if (base_y > 226) then
				break
			end
			if (l >= master_index) then
				if (l==p) then
					base_y2 = base_y
					if (base_y) == 0 then
						base_y = 2
					end
					Screen.fillRect(0,319,base_y-2,base_y2+12,selected_item,BOTTOM_SCREEN)
					color = selected_color
					if (base_y) == 2 then
						base_y = 0
					end
				else
					color = menu_color
				end
				CropPrint(0,base_y,file.name,color,BOTTOM_SCREEN)
				base_y = base_y + 15
			end
		end
		if move_base ~= nil then
			Screen.debugPrint(300,0,"M",selected_color,BOTTOM_SCREEN)
		elseif copy_base ~= nil then
			Screen.debugPrint(300,0,"C",selected_color,BOTTOM_SCREEN)
		end
		update_bottom_screen = false
	end
	-- Select Mode Controls Functions
	if (select_mode) then
		Screen.fillEmptyRect(60,260,50,217,black,BOTTOM_SCREEN)
		Screen.fillRect(61,259,51,216,white,BOTTOM_SCREEN)
		for l, voice in pairs(sm_voices) do
			if (l == sm_index) then
				Screen.fillRect(61,259,51+(l-1)*15,51+l*15,green,BOTTOM_SCREEN)
				Screen.debugPrint(63,53+(l-1)*15,voice,red,BOTTOM_SCREEN)
			else
				Screen.debugPrint(63,53+(l-1)*15,voice,black,BOTTOM_SCREEN)
			end
		end
		if (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
			sm_index = sm_index - 1
		elseif (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
			sm_index = sm_index + 1
		elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
			if (sm_index == 1) then
				ForceOpenFile(files_table[p].name,files_table[p].size,"BMPV")
			elseif (sm_index == 2) then
				ForceOpenFile(files_table[p].name,files_table[p].size,"WAV")
			elseif (sm_index == 3) then
				ForceOpenFile(files_table[p].name,files_table[p].size,"IMG")
			elseif (sm_index == 4) then
				ForceOpenFile(files_table[p].name,files_table[p].size,"TXT")
			elseif (sm_index == 5) then
				ForceOpenFile(files_table[p].name,files_table[p].size,"LUA")
			elseif (sm_index == 6) then
				ForceOpenFile(files_table[p].name,files_table[p].size,"HEX")
			elseif (sm_index == 7) then
				if build == "CIA" then
					ForceOpenFile(files_table[p].name,files_table[p].size,"CIA")
				else
					ForceOpenFile(files_table[p].name,files_table[p].size,"3DSX")
				end
			elseif (sm_index == 8) then
				ForceOpenFile(files_table[p].name,files_table[p].size,"SMDH")
			elseif (sm_index == 9) then
				ForceOpenFile(files_table[p].name,files_table[p].size,"ZIP")
			elseif (sm_index == 10) then
				ForceOpenFile(files_table[p].name,files_table[p].size,"INFO")
			end
			sm_index = 1
			select_mode = false
			update_bottom_screen = true
		elseif (Controls.check(pad,KEY_START)) then
			FBGC()
			Screen.freeImage(bg)
			Sound.term()
			System.exit()
		end
		if (sm_index < 1) then
			sm_index = 11
		elseif (sm_index > 11) then
			sm_index = 1
		end
	-- Action Check
	elseif (action_check) then
		Screen.fillEmptyRect(60,260,50,127,black,BOTTOM_SCREEN)
		Screen.fillRect(61,259,51,126,white,BOTTOM_SCREEN)
		if sm_index > 5 then
			sm_index = 1
		elseif sm_index < 1 then
			sm_index = 5
		end
		colors = {black,black,black,black,black}
		colors[sm_index] = red
		Screen.fillRect(61,259,36+sm_index*15,51+sm_index*15,green,BOTTOM_SCREEN)
		Screen.debugPrint(63,53,"Delete",colors[1],BOTTOM_SCREEN)
		Screen.debugPrint(63,68,"Rename",colors[2],BOTTOM_SCREEN)
		Screen.debugPrint(63,83,"Copy",colors[3],BOTTOM_SCREEN)
		Screen.debugPrint(63,98,"Move",colors[4],BOTTOM_SCREEN)
		Screen.debugPrint(63,113,"Cancel",colors[5],BOTTOM_SCREEN)
		if (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
			sm_index = sm_index + 1
		elseif (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
			sm_index = sm_index - 1
		elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
			if sm_index == 1 then
				update_bottom_screen = true
				if (files_table[p].directory) then
					if (files_table[p].name ~= "..") then
						DeleteDir(System.currentDirectory()..files_table[p].name)
					end
				else
					System.deleteFile(System.currentDirectory()..files_table[p].name)
				end
				while (#files_table > 0) do
					table.remove(files_table)
				end
				files_table = System.listDirectory(System.currentDirectory())
				if System.currentDirectory() ~= "/" then
					local extra = {}
					extra.name = ".."
					extra.size = 0
					extra.directory = true
					table.insert(files_table,extra)
				end
				files_table = SortDirectory(files_table)
				if (p > #files_table) then
					p = p - 1
				end
				action_check = false
			elseif sm_index == 2 then
				update_bottom_screen = true
				if (files_table[p].name ~= "..") then
					new_name = System.startKeyboard(files_table[p].name)
					pad = KEY_A
					oldpad = KEY_A
					if (files_table[p].directory) then
						System.renameDirectory(System.currentDirectory() .. files_table[p].name,System.currentDirectory() .. new_name)
					else
						System.renameFile(System.currentDirectory() .. files_table[p].name,System.currentDirectory() .. new_name)
					end
					files_table = System.listDirectory(System.currentDirectory())
					if System.currentDirectory() ~= "/" then
						local extra = {}
						extra.name = ".."
						extra.size = 0
						extra.directory = true
						table.insert(files_table,extra)
					end
					files_table = SortDirectory(files_table)
				end
				action_check = false
				sm_index = 1
			elseif sm_index == 3 then
				if (files_table[p].directory) then
					if (files_table[p].name ~= "..") then
						copy_name = files_table[p].name
						copy_base = System.currentDirectory() .. files_table[p].name
						copy_type = 0
					end
				else
					copy_type = 1
					copy_name = files_table[p].name
					copy_base = System.currentDirectory() .. files_table[p].name
				end
				action_check = false
				sm_index = 1
			elseif sm_index == 4 then
				if (files_table[p].name ~= "..") then
					update_bottom_screen = true
					move_base = System.currentDirectory() .. files_table[p].name
					move_name = files_table[p].name
					if (files_table[p].directory) then
						move_type = 0
					else
						move_type = 1
					end
				end
				action_check = false
				sm_index = 1
			elseif sm_index == 5 then
				update_bottom_screen = true
				sm_index = 1
				action_check = false
			end
		end
	else
	-- Base Controls Functions
		if (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
			update_bottom_screen = true
			p = p - 1
			if (p >= 16) then
				master_index = p - 15
			end
		elseif (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
			update_bottom_screen = true
			p = p + 1
			if (p >= 17) then
				master_index = p - 15
			end
		end
		if (p < 1) then
			p = #files_table
			if (p >= 17) then
				master_index = p - 15
			end
		elseif (p > #files_table) then
			master_index = 0
			p = 1
		end
		if (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
			if (files_table[p].directory) then
				OpenDirectory(files_table[p].name,0)
				p=1
				master_index=0
			else
				OpenFile(files_table[p].name,files_table[p].size)
			end
		elseif (Controls.check(pad,KEY_X)) and not (Controls.check(oldpad,KEY_X)) then
			if (move_base == nil) and (copy_base == nil) then
				action_check = true
			else
				update_bottom_screen = true
				move_base = nil
				move_name = nil
				copy_base = nil
				copy_name = nil
			end			
		elseif (Controls.check(pad,KEY_Y)) and not (Controls.check(oldpad,KEY_Y)) then
			if (move_base ~= nil) then
				update_bottom_screen = true
				if (move_type == 0) then
					System.renameDirectory(move_base,System.currentDirectory() .. move_name)
				else
					System.renameFile(move_base,System.currentDirectory() .. move_name)
				end
				move_base = nil
				files_table = System.listDirectory(System.currentDirectory())
				if System.currentDirectory() ~= "/" then
					local extra = {}
					extra.name = ".."
					extra.size = 0
					extra.directory = true
					table.insert(files_table,extra)
				end
				files_table = SortDirectory(files_table)
			end
			if (copy_base ~= nil) then
				copy_end = System.currentDirectory() .. copy_name
				if copy_end == copy_base then
					temp_copy = "Copy_" .. copy_name
					copy_end = System.currentDirectory() .. temp_copy
					if (copy_type == 1) then
						while System.doesFileExist(copy_end) do
							temp_copy = "Copy_" .. temp_copy
							copy_end = System.currentDirectory() .. temp_copy
						end
					end
				end
				if (copy_type == 0) then
					CopyDir(copy_base,copy_end)
				else
					CopyFile(copy_base,copy_end)
				end
				files_table = System.listDirectory(System.currentDirectory())
				if System.currentDirectory() ~= "/" then
					local extra = {}
					extra.name = ".."
					extra.size = 0
					extra.directory = true
					table.insert(files_table,extra)
				end
				files_table = SortDirectory(files_table)
				copy_name = nil
				copy_base = nil
			end
		elseif (Controls.check(pad,KEY_B)) and not (Controls.check(oldpad,KEY_B)) then
			FBGC()
			CallMainMenu()
		elseif (Controls.check(pad,KEY_DLEFT)) and not (Controls.check(oldpad,KEY_DLEFT)) then
			if (current_type == "SMDH") then
				update_bottom_screen = true
				name = System.startKeyboard("icon.bmp")
				Screen.saveBitmap(current_file.icon,System.currentDirectory()..name)
				oldpad = KEY_A
				files_table = System.listDirectory(System.currentDirectory())
					if System.currentDirectory() ~= "/" then
						local extra = {}
						extra.name = ".."
						extra.size = 0
						extra.directory = true
						table.insert(files_table,extra)
					end
				files_table = SortDirectory(files_table)
			elseif (current_type == "TXT") or (current_type == "HEX") then
				if (txt_i > 1) then			
					updateTXT = true
					table.remove(old_indexes)
					txt_index = table.remove(old_indexes)
					txt_i = txt_i - 2
				end
			elseif (current_type == "WAV") then
				if (Sound.isPlaying(current_file)) then
					Sound.pause(current_file)
				else
					Sound.resume(current_file)
				end
			elseif (current_type == "BMPV") then
				if (BMPV.isPlaying(current_file)) then
					BMPV.pause(current_file)
				else
					BMPV.resume(current_file)
				end
			elseif (current_type == "JPGV") then
				if (JPGV.isPlaying(current_file)) then
					JPGV.pause(current_file)
				else
					JPGV.resume(current_file)
				end
			end
		elseif (Controls.check(pad,KEY_DRIGHT)) and not (Controls.check(oldpad,KEY_DRIGHT)) then
			if (current_type == "SMDH") then
				update_bottom_screen = true
				name = System.startKeyboard("icon.bmp")
				Screen.saveBitmap(current_file.icon,System.currentDirectory()..name)
				oldpad = KEY_A
				files_table = System.listDirectory(System.currentDirectory())
					if System.currentDirectory() ~= "/" then
						local extra = {}
						extra.name = ".."
						extra.size = 0
						extra.directory = true
						table.insert(files_table,extra)
					end
				files_table = SortDirectory(files_table)
			elseif (current_type == "TXT") or (current_type == "HEX") then
				updateTXT = true
			elseif (current_type == "WAV") then
				if (Sound.isPlaying(current_file)) then
					Sound.pause(current_file)
				else
					Sound.resume(current_file)
				end
			elseif (current_type == "BMPV") then
				if (BMPV.isPlaying(current_file)) then
					BMPV.pause(current_file)
				else
					BMPV.resume(current_file)
				end
			elseif (current_type == "JPGV") then
				if (JPGV.isPlaying(current_file)) then
					JPGV.pause(current_file)
				else
					JPGV.resume(current_file)
				end
			end		
		elseif (Controls.check(pad,KEY_SELECT)) and not (Controls.check(oldpad,KEY_SELECT)) then
			if (files_table[p].directory == false) then
				select_mode = true
			end
		elseif (Controls.check(pad,KEY_R)) and not (Controls.check(oldpad,KEY_R)) then
			update_bottom_screen = true
			name = System.startKeyboard("New Folder")
			System.createDirectory(System.currentDirectory()..name)
			pad = KEY_A
			files_table = System.listDirectory(System.currentDirectory())
				if System.currentDirectory() ~= "/" then
					local extra = {}
					extra.name = ".."
					extra.size = 0
					extra.directory = true
					table.insert(files_table,extra)
				end
			files_table = SortDirectory(files_table)
		elseif (Controls.check(pad,KEY_TOUCH)) then
			update_bottom_screen = true
			x,y = Controls.readTouch()
			new_index = math.ceil(y/15)
			if (new_index <= #files_table) then
				if master_index > 0 then
					p = new_index + master_index - 1
				else
					p = new_index
				end
			end	
		end
	end	
	if not (Controls.check(pad,KEY_TOUCH)) then
		update_bottom_screen = true
		master_index = p - 15
	end
end
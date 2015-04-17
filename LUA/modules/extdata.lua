-- Set private "Extdata" mode
mode = "Extdata"

-- Internal module settings
if extdata_backup == nil then
	ShowWarning("Extdata listing will take time to be generated. Press OK to start list generation.")
	files_table = System.scanExtdata()
	extdata_backup = files_table
end
update_bottom_screen = true
update_top_screen = true
ui_enabled = false
extdata_directory = "/"
white = Color.new(255,255,255)
black = Color.new(0,0,0)
red = Color.new(255,0,0)
green = Color.new(0,255,0)
menu_color = Color.new(255,255,255)
selected_color = Color.new(0,255,0)
selected_item = Color.new(0,0,200,50)
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
MAX_RAM_ALLOCATION = 10485760
copy_type = 0
move_type = 0
txt_index = 0
txt_words = 0
txt_i = 0
old_indexes = {}
p = 1
master_index = 0
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
function RestoreFile(input,archive)
	inp = io.open("/"..string.format('%02X',archive).."_"..input,FREAD)
	out = io.open(extdata_directory..input,FWRITE,archive)
	if io.size(inp) <= io.size(out) then
		size = io.size(inp)
		index = 0
		while (index+(MAX_RAM_ALLOCATION/2) < size) do
			io.write(out,index,io.read(inp,index,MAX_RAM_ALLOCATION/2),(MAX_RAM_ALLOCATION/2))
			index = index + (MAX_RAM_ALLOCATION/2)
		end
		if index < size then
			io.write(out,index,io.read(inp,index,size-index),(size-index))
		end
	end
	io.close(inp)
	io.close(out)
end
function RestoreFolder(input,archive)
	files = System.listDirectory("/"..string.format('%02X',archive).."_"..input)
	for z, file in pairs(files) do
		if (file.directory) then
			RestoreFolder(input.."/"..file.name,archive)
		else
			RestoreFile(input.."/"..file.name,archive)
		end
	end
end
function OpenExtdataFile(text, archive)
	ExtGC()
	current_file = io.open(extdata_directory..text,FREAD,archive)
	txt_index = 0
	updateTXT = true
end
function OpenDirectory(text,archive_id)
	i=0
	if text == ".." then
		j=-2
		while string.sub(extdata_directory,j,j) ~= "/" do
			j=j-1
		end
		extdata_directory = string.sub(extdata_directory,1,j)
	else
		extdata_directory = extdata_directory..text.."/"
	end
	if extdata_directory == "/" then
		files_table = extdata_backup
	else
		files_table = System.listExtdataDir(extdata_directory,archive_id)
		local extra = {}
		extra.name = ".."
		extra.size = 0
		extra.directory = true
		extra.archive = archive_id
		table.insert(files_table,extra)
	end
end
function ExtGC()
	if current_file ~= nil then
		update_top_screen = true
		io.close(current_file)
		old_indexes = {}
		txt_i = 0
	end
	current_file = nil
end
function DumpFolder(input,archive)
	files = System.listExtdataDir(extdata_directory..input,archive)
	System.createDirectory("/"..string.format('%02X',archive).."_"..input)
	for z, file in pairs(files) do
		if (file.directory) then
			DumpFolder(input.."/"..file.name,archive)
		else
			DumpFile(input.."/"..file.name,archive)
		end
	end
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
function PrintTop()
	Screen.clear(TOP_SCREEN)
	if (current_file == nil) then
		Font.print(ttf,0,0,"Basic Controls:",white,TOP_SCREEN)
		Font.print(ttf,0,15,"A = Open file/folder",white,TOP_SCREEN)
		Font.print(ttf,0,30,"X = Restore file/folder from SD card",white,TOP_SCREEN)
		Font.print(ttf,0,45,"Y = Dump file/folder to SD card",white,TOP_SCREEN)
		Font.print(ttf,0,60,"B = Return Main Menu",white,TOP_SCREEN)
		Font.print(ttf,0,75,"Left/Right = Scroll file",white,TOP_SCREEN)
	else
		for l, line in pairs(hex_text) do
			Font.print(ttf,280,(l-1)*15,string.gsub(line,"\0"," "),white,TOP_SCREEN)
			temp = 1
			while (temp <= string.len(line)) do
				if (temp % 2 == 0) then
					Font.print(ttf,0+(temp-1)*30,(l-1)*15,string.format('%02X', hex_values[(l-1)*8+temp]),white,TOP_SCREEN)
				else
					Font.print(ttf,0+(temp-1)*30,(l-1)*15,string.format('%02X', hex_values[(l-1)*8+temp]),red,TOP_SCREEN)
				end
				temp = temp + 1
			end
		end
		Font.print(ttf,0,225,"Offset: 0x" .. string.format('%X', old_indexes[#old_indexes]) .. " (" .. (old_indexes[#old_indexes]) .. ")",white,TOP_SCREEN)
	end
end
function PrintBottom()
	base_y = 0
	Screen.clear(BOTTOM_SCREEN)
	for l, file in pairs(files_table) do
		if (base_y > 226) then
			break
		end
		if (l >= master_index) then
			if (l==p) then
				Screen.fillRect(0,319,base_y,base_y+15,selected_item,BOTTOM_SCREEN)
				color = selected_color
			else
				color = menu_color
			end
			if file.name == ".." then
				CropPrint(0,base_y,file.name,color,BOTTOM_SCREEN)
			else
				CropPrint(0,base_y,file.name.." ["..string.format('%02X',file.archive).."]",color,BOTTOM_SCREEN)
			end
			base_y = base_y + 15
		end
	end
end

-- Module main cycle
function AppMainCycle()
	if update_top_screen then
		if (updateTXT) then
			txt_index = BuildHex(current_file,txt_index)
			updateTXT = false
		end
		OneshotPrint(PrintTop)
		update_top_screen = false
	end
	if update_bottom_screen then
		OneshotPrint(PrintBottom)
		update_bottom_screen = false
	end
	
	-- Base Controls Functions
	if (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
		p = p - 1
		if (p >= 16) then
			master_index = p - 15
		end
		update_bottom_screen = true
	elseif (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
		p = p + 1
		if (p >= 17) then
			master_index = p - 15
		end
		update_bottom_screen = true
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
			OpenDirectory(files_table[p].name,files_table[p].archive)
			p=1
			master_index=0
			update_bottom_screen = true
		else
			OpenExtdataFile(files_table[p].name,files_table[p].archive)
		end
	elseif (Controls.check(pad,KEY_X)) and not (Controls.check(oldpad,KEY_X)) then
		if (files_table[p].directory) then
			RestoreFolder(files_table[p].name,files_table[p].archive)
		else
			RestoreFile(files_table[p].name,files_table[p].archive)
		end
	elseif (Controls.check(pad,KEY_Y)) and not (Controls.check(oldpad,KEY_Y)) then
		if (files_table[p].directory) then
			DumpFolder(files_table[p].name,files_table[p].archive)
		else
			DumpFile(files_table[p].name,files_table[p].archive)
		end
	elseif (Controls.check(pad,KEY_B)) and not (Controls.check(oldpad,KEY_B)) then
			ExtGC()
			CallMainMenu()
	elseif (Controls.check(pad,KEY_DLEFT)) and not (Controls.check(oldpad,KEY_DLEFT)) then
		if current_file ~= nil then
			update_top_screen = true
			if (txt_i > 1) then			
				updateTXT = true
				table.remove(old_indexes)
				txt_index = table.remove(old_indexes)
				txt_i = txt_i - 2
			end
		end
	elseif (Controls.check(pad,KEY_DRIGHT)) and not (Controls.check(oldpad,KEY_DRIGHT)) then
		if current_file ~= nil then
			update_top_screen = true
			updateTXT = true
		end
	elseif (Controls.check(pad,KEY_TOUCH)) then
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
	if not (Controls.check(pad,KEY_TOUCH)) then
		master_index = p - 15
	end
end

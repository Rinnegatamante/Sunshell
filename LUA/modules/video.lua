-- Set private "Video" mode
mode = "Video"

-- Internal module settings
master_index_v = 0
if Screen.get3DLevel() > 0 then
	Screen.enable3D()
end
old_3d = Screen.get3DLevel()
p_v = 1
update_frame = false
ui_enabled = false
DisableRenderer()
not_started_v = true
tmp = System.listDirectory("/VIDEO")
my_videos = {}
hide = false
for i,file in pairs(tmp) do
	if not file.directory then
		tmp_file = io.open("/VIDEO/"..file.name,FREAD)
		magic = io.read(tmp_file,0,4)
		if magic == "BMPV" then
			table.insert(my_videos,{file.name,"BMPV"})
		elseif magic == "JPGV" then
			table.insert(my_videos,{file.name,"JPGV"})
		end
		io.close(tmp_file)
	end
end
if #my_videos > 0 then
	current_type = my_videos[1][2]
	if current_type == "BMPV" then
		current_file = BMPV.load("/VIDEO/"..my_videos[1][1])
		current_size =  BMPV.getSize(current_file)
	elseif current_type == "JPGV" then
		current_file = JPGV.load("/VIDEO/"..my_videos[1][1])
		current_size =  JPGV.getSize(current_file)
	end
else
	ShowError("VIDEO folder is empty.")
	CallMainMenu()
end

frame_succession = Timer.new()
current_frame = 60

-- Rendering functions
function AppTopScreenRender()	
	Graphics.fillRect(5,395,40,220,black)
	Graphics.fillRect(6,394,41,219,white)
end

function AppBottomScreenRender()
end

-- Module main cycle
function AppMainCycle()
	slide_status = Screen.get3DLevel()
	
	-- Clear bottom screen
	Screen.clear(BOTTOM_SCREEN)
	if not_started_v then
		
		-- Update preview info
		if update_frame then
			Timer.reset(frame_succession)
			update_frame = false
			current_type = my_videos[p_v][2]
			if current_type == "BMPV" then
				current_file = BMPV.load("/VIDEO/"..my_videos[p_v][1])
				current_size =  BMPV.getSize(current_file)
			elseif current_type == "JPGV" then
				current_file = JPGV.load("/VIDEO/"..my_videos[p_v][1])
				current_size =  JPGV.getSize(current_file)
			end
			current_frame = 60
			Timer.reset(frame_succession)
		end
			
		-- Showing Preview frames
		if current_type == "BMPV" then
			BMPV.showFrame(0,0,current_file,current_frame,TOP_SCREEN)
		elseif current_type == "JPGV" then
			if (slide_status == 0) then
				JPGV.showFrame(0,0,current_file,current_frame,TOP_SCREEN,false)
			else
				JPGV.showFrame(0,0,current_file,current_frame,TOP_SCREEN,true)
			end
		end
		if Timer.getTime(frame_succession) > 5000 then
			current_frame = math.ceil(current_frame + (current_size / 10))
			if current_frame > current_size then
				current_frame = 1
			end
			Timer.reset(frame_succession)
		end
			
		-- Showing files list
		base_y = 0
		for l, file in pairs(my_videos) do
			if (base_y > 226) then
				break
			end
			if (l >= master_index_v) then
				if (l==p_v) then
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
					color = white
				end
				DebugCropPrint(0,base_y,file[1],color,BOTTOM_SCREEN)
				base_y = base_y + 15
			end
		end
		
	else
		
		-- Video playback
		if current_type == "JPGV" then
			if (slide_status == 0) then
				JPGV.draw(0,0,current_file,TOP_SCREEN,false)
			else
				JPGV.draw(0,0,current_file,TOP_SCREEN,true)
			end
		else
			BMPV.draw(0,0,current_file,TOP_SCREEN)
		end
		
		if not hide then
			-- Video playback info (JPGV side)
			if current_type == "JPGV" then
				Screen.debugPrint(0,10,"A = Pause/Resume",white,BOTTOM_SCREEN)
				Screen.debugPrint(0,25,"Y = Close video",white,BOTTOM_SCREEN)
				Screen.debugPrint(0,40,"B = Return Main Menu",white,BOTTOM_SCREEN)
				Screen.debugPrint(0,55,"X = Hide Bottom Screen",white,BOTTOM_SCREEN)
				Screen.debugPrint(0,100,"Infos:",white,BOTTOM_SCREEN)
				Screen.debugPrint(0,114,"FPS: "..JPGV.getFPS(current_file),white,BOTTOM_SCREEN)
				cur_time_sec = math.ceil(JPGV.getFrame(current_file) / JPGV.getFPS(current_file))
				cur_time_min = 0
				while (cur_time_sec >= 60) do
					cur_time_sec = cur_time_sec - 60
					cur_time_min = cur_time_min + 1
				end
				if (cur_time_sec < 10) then
					Screen.debugPrint(0,128,"Time: " .. cur_time_min .. ":0" .. cur_time_sec .. " / " .. tot_time_min .. ":" .. tot_time_sec,white,BOTTOM_SCREEN)
				else
					Screen.debugPrint(0,128,"Time: " .. cur_time_min .. ":" .. cur_time_sec .. " / " .. tot_time_min .. ":" .. tot_time_sec,white,BOTTOM_SCREEN)
				end
				Screen.debugPrint(0,142,"Samplerate: "..JPGV.getSrate(current_file),white,BOTTOM_SCREEN)
				percentage = ((JPGV.getFrame(current_file) * 100) / JPGV.getSize(current_file))
				Screen.debugPrint(0,200,"Percentage: " ..math.ceil(percentage) .. "%",white,BOTTOM_SCREEN)
				Screen.fillEmptyRect(2,318,214,234,white,BOTTOM_SCREEN)
				move = ((314 * percentage) / 100)
				Screen.fillRect(3,3 + math.ceil(move),215,233,white,BOTTOM_SCREEN)
				
			-- Video playback info (BMPV side)
			elseif current_type == "BMPV" then
				Screen.debugPrint(0,10,"A = Pause/Resume",white,BOTTOM_SCREEN)
				Screen.debugPrint(0,25,"Y = Close video",white,BOTTOM_SCREEN)
				Screen.debugPrint(0,40,"B = Return Main Menu",white,BOTTOM_SCREEN)
				Screen.debugPrint(0,55,"X = Power off Bottom Screen",white,BOTTOM_SCREEN)
				Screen.debugPrint(0,100,"Infos:",white,BOTTOM_SCREEN)
				Screen.debugPrint(0,114,"FPS: "..BMPV.getFPS(current_file),white,BOTTOM_SCREEN)
				cur_time_sec = math.ceil(BMPV.getFrame(current_file) / BMPV.getFPS(current_file))
				cur_time_min = 0
				while (cur_time_sec >= 60) do
					cur_time_sec = cur_time_sec - 60
					cur_time_min = cur_time_min + 1
				end
				if (cur_time_sec < 10) then
					Screen.debugPrint(0,128,"Time: " .. cur_time_min .. ":0" .. cur_time_sec .. " / " .. tot_time_min .. ":" .. tot_time_sec,white,BOTTOM_SCREEN)
				else
					Screen.debugPrint(0,128,"Time: " .. cur_time_min .. ":" .. cur_time_sec .. " / " .. tot_time_min .. ":" .. tot_time_sec,white,BOTTOM_SCREEN)
				end
				Screen.debugPrint(0,142,"Samplerate: "..BMPV.getSrate(current_file),white,BOTTOM_SCREEN)
				percentage = math.ceil((BMPV.getFrame(current_file) * 100) / BMPV.getSize(current_file))
				Screen.debugPrint(0,200,"Percentage: " ..percentage .. "%",white,BOTTOM_SCREEN)
				Screen.fillEmptyRect(2,318,214,234,white,BOTTOM_SCREEN)
				move = ((314 * percentage) / 100)
				Screen.fillRect(3,3 + math.ceil(move),215,233,white,BOTTOM_SCREEN)
			end
		end
			
	end
	
	-- 3D effect support
	if slide_status == 0 and old_3d ~= 0 then
		Screen.disable3D()
	elseif slide_status > 0 and old_3d == 0 then
		Screen.enable3D()
	end
	
	-- Sets controls triggering
	if (Controls.check(pad,KEY_Y)) and not (Controls.check(oldpad,KEY_Y)) and not (not_started_v) then
		Timer.reset(frame_succession)
		not_started_v = true
		if hide then
			Controls.enableScreen(BOTTOM_SCREEN)
			hide = false
		end
		if current_type == "JPGV" then
			JPGV.stop(current_file)
		else
			BMPV.stop(current_file)
		end
	elseif (Controls.check(pad,KEY_X)) and not (Controls.check(oldpad,KEY_X)) and not (not_started_v) then
		if hide then
			Controls.enableScreen(BOTTOM_SCREEN)
		else
			Controls.disableScreen(BOTTOM_SCREEN)
		end
		hide = not hide
	elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
		if not_started_v then
			not_started_v = false
			if current_type == "JPGV" then
				JPGV.start(current_file,NO_LOOP,0x08,0x09)
				tot_time_sec = math.ceil(JPGV.getSize(current_file) / JPGV.getFPS(current_file))
				tot_time_min = 0
				while (tot_time_sec >= 60) do
					tot_time_sec = tot_time_sec - 60
					tot_time_min = tot_time_min + 1
				end
			elseif current_type == "BMPV" then
				BMPV.start(current_file,NO_LOOP,0x08,0x09)
				tot_time_sec = math.ceil(BMPV.getSize(current_file) / BMPV.getFPS(current_file))
				tot_time_min = 0
				while (tot_time_sec >= 60) do
					tot_time_sec = tot_time_sec - 60
					tot_time_min = tot_time_min + 1
				end
			end	
		else
			if current_type == "JPGV" then
				if JPGV.isPlaying(current_file) then
					JPGV.pause(current_file)
				else
					JPGV.resume(current_file)
				end
			else
				if BMPV.isPlaying(current_file) then
					BMPV.pause(current_file)
				else
					BMPV.resume(current_file)
				end
			end
		end
	elseif Controls.check(pad,KEY_B) or Controls.check(pad,KEY_START) then
		if (slide_status > 0) then
			Screen.disable3D()
		end
		if hide then
			Controls.enableScreen(BOTTOM_SCREEN)
		end
		CallMainMenu()
		Timer.destroy(frame_succession)
		if current_type == "JPGV" then
			JPGV.stop(current_file)
			JPGV.unload(current_file)
		elseif current_type == "BMPV" then
			BMPV.stop(current_file)
			BMPV.unload(current_file)
		end
	elseif (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) and not_started_v then
		if current_type == "JPGV" then
			JPGV.unload(current_file)
		elseif current_type == "BMPV" then
			BMPV.unload(current_file)
		end
		p_v = p_v - 1
		if (p_v >= 16) then
			master_index_v = p_v - 15
		end
		update_frame = true
	elseif (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) and not_started_v then
		if current_type == "JPGV" then
			JPGV.unload(current_file)
		elseif current_type == "BMPV" then
			BMPV.unload(current_file)
		end
		p_v = p_v + 1
		if (p_v >= 17) then
			master_index_v = p_v - 15
		end
		update_frame = true
	end
	if (p_v < 1) then
		p_v = #my_videos
		if (p_v >= 17) then
			master_index_v = p_v - 15
		end
	elseif (p_v > #my_videos) then
		master_index_v = 0
		p_v = 1
	end
	old_3d = slide_status
end
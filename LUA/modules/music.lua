-- Set private "Music" mode
mode = "Music"

-- Internal module settings
FreeIconTopbar("Music")
SetBottomRefresh(false)
master_index_m = 0
update_list = true
text_for_top_screen = ""
p_m = 1
if not_started == nil then
	not_started = true
end
my_songs = {}
cycle_mode = {"No Cycle","All","Subfolder","Song"}
if cycle_index == nil then
	cycle_index = 1
end
function AddSongsFromDir(dir,album)
	tmp = System.listDirectory(dir)
	for i,file in pairs(tmp) do
		if not file.directory then
			tmp_file = io.open(dir.."/"..file.name,FREAD)
			magic = io.read(tmp_file,0,4)
			if magic == "RIFF" then
				table.insert(my_songs,{file.name,"WAV",album,dir})
			elseif magic == "FORM" then
				table.insert(my_songs,{file.name,"AIFF",album,dir})
			elseif magic == "OggS" then
				table.insert(my_songs,{file.name,"OGG",album,dir})
			end
			io.close(tmp_file)
		else
			AddSongsFromDir(dir.."/"..file.name,file.name)
		end
	end
end
AddSongsFromDir("/MUSIC",nil)
blue = Color.new(0,0,255)

-- Module background code
function BackgroundMusic()
	Sound.updateStream()
	
	-- Cycle mode
	if cycle_index > 1 then
		if Sound.getTime(current_song) >= Sound.getTotalTime(current_song) then
			update_list = true
			Sound.pause(current_song)
			Sound.close(current_song)
			if cycle_index == 2 then
				song_idx = song_idx + 1
				if song_idx > #my_songs then
					song_idx = 1
				end
			elseif cycle_index == 3 then
				tmp_idx = song_idx + 1
				found = false
				while tmp_idx < #my_songs do
					if my_songs[tmp_idx][3] == current_subfolder then
						song_idx = tmp_idx
						found = true
						break
					end
					tmp_idx = tmp_idx + 1
				end
				if not found then
					tmp_idx = 1
					while tmp_idx < #my_songs do
						if my_songs[tmp_idx][3] == current_subfolder then
							song_idx = tmp_idx
							found = true
							break
						end
						tmp_idx = tmp_idx + 1
					end	
				end
			end
			if my_songs[song_idx][2] == "WAV" then
				current_song = Sound.openWav(my_songs[song_idx][4].."/"..my_songs[song_idx][1],true)
			elseif my_songs[song_idx][2] == "AIFF" then
				current_song = Sound.openAiff(my_songs[song_idx][4].."/"..my_songs[song_idx][1],true)
			elseif my_songs[song_idx][2] == "OGG" then
				current_song = Sound.openOgg(my_songs[song_idx][4].."/"..my_songs[song_idx][1],true)
			end
			Sound.play(current_song,NO_LOOP,0x08,0x09)
			current_subfolder = my_songs[song_idx][3]
		end
	end
end

function ShowFileList()
	base_y = 0
	for l, file in pairs(my_songs) do
		if (base_y > 226) then
			break
		end
		if (l >= master_index_m) then
			if (l==p_m) then
				if file[3] ~= nil then
					text_for_top_screen = "Subfolder: "..file[3]
				else
					text_for_top_screen = "Subfolder: None"
				end
				Screen.fillRect(0,319,base_y,base_y+15,selected_item,BOTTOM_SCREEN)
				color = selected
			else
				if (l==song_idx) then
					color = blue
				else
					color = black
				end
			end
			CropPrint(0,base_y,file[1],color,BOTTOM_SCREEN)
			base_y = base_y + 15
		end
	end
end

-- Internal Module GarbageCollection
function MusicGC()
	if current_song ~= nil then
		Sound.pause(current_song)
		Sound.close(current_song)
		current_song = nil
	end
end

-- Module main cycle
function AppMainCycle()
	
	-- Draw top screen box
	Screen.fillEmptyRect(5,395,40,220,black,TOP_SCREEN)
	Screen.fillRect(6,394,41,219,white,TOP_SCREEN)
	
	-- Draw Cycle Mode info
	Font.print(ttf,9,200,"Cycle mode: "..cycle_mode[cycle_index],black,TOP_SCREEN)
	
	-- Showing files list
	if update_list then
		BottomBGRefresh()
		OneshotPrint(ShowFileList)
		update_list = false
	end
	
	-- Showing Song info
	if not not_started then
		TopCropPrint(9,45,"Title: "..Sound.getTitle(current_song),black,TOP_SCREEN)
		TopCropPrint(9,60,"Author: "..Sound.getAuthor(current_song),black,TOP_SCREEN)
		if my_songs[song_idx][3] ~= nil then
			Font.print(ttf,9,75,"Subfolder: "..my_songs[song_idx][3],black,TOP_SCREEN)
		else
			Font.print(ttf,9,75,"Subfolder: None",black,TOP_SCREEN)
		end
		if Sound.getType(current_song) == 1 then
			TopCropPrint(9,90,"Audiotype: Mono",black,TOP_SCREEN)
		else
			TopCropPrint(9,90,"Audiotype: Stereo",black,TOP_SCREEN)
		end
		TopCropPrint(9,105,"Time: "..FormatTime(Sound.getTime(current_song)).." / "..FormatTime(Sound.getTotalTime(current_song)),black,TOP_SCREEN)
		TopCropPrint(9,120,"Samplerate: "..Sound.getSrate(current_song),black,TOP_SCREEN)	
	else
		Font.print(ttf,9,45,text_for_top_screen,black,TOP_SCREEN)
	end
	
	-- Sets controls triggering
	if (Controls.check(pad,KEY_SELECT)) and not (Controls.check(oldpad,KEY_SELECT)) and not (not_started) then
		CallMainMenu()
		AddIconTopbar(theme_dir.."/images/music_icon.jpg","Music")
	elseif (Controls.check(pad,KEY_X)) and not (Controls.check(oldpad,KEY_X)) and not (not_started) then
		if Sound.isPlaying(current_song) then
			Sound.pause(current_song)
		else
			Sound.resume(current_song)
		end
	elseif (Controls.check(pad,KEY_Y)) and not (Controls.check(oldpad,KEY_Y)) and not (not_started) then
		not_started = true
		CloseBGApp("Music")
		current_song = nil
	elseif (Controls.check(pad,KEY_DLEFT)) and not (Controls.check(oldpad,KEY_DLEFT)) then
		cycle_index = cycle_index - 1
		if cycle_index < 1 then
			cycle_index = 4
		end
	elseif (Controls.check(pad,KEY_DRIGHT)) and not (Controls.check(oldpad,KEY_DRIGHT)) then
		cycle_index = cycle_index + 1
		if cycle_index > 4 then
			cycle_index = 1
		end
	elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
		if current_song ~= nil then
			MusicGC()
		end
		not_started = false
		if my_songs[p_m][2] == "WAV" then
			current_song = Sound.openWav(my_songs[p_m][4].."/"..my_songs[p_m][1],true)
		elseif my_songs[p_m][2] == "AIFF" then
			current_song = Sound.openAiff(my_songs[p_m][4].."/"..my_songs[p_m][1],true)
		elseif my_songs[p_m][2] == "OGG" then
			current_song = Sound.openOgg(my_songs[p_m][4].."/"..my_songs[p_m][1],true)
		end	
		Sound.play(current_song,NO_LOOP,0x08,0x09)
		current_subfolder = my_songs[p_m][3]
		song_idx = p_m
		table.insert(bg_apps,{BackgroundMusic,MusicGC,"Music"}) -- Starting background Music module
	elseif Controls.check(pad,KEY_B) or Controls.check(pad,KEY_START) then
		CallMainMenu()
		not_started = true
		if current_song ~= nil then
			CloseBGApp("Music")
		end
	elseif (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
		p_m = p_m - 1
		if (p_m >= 16) then
			master_index_m = p_m - 15
		end
		update_list = true
	elseif (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
		p_m = p_m + 1
		if (p_m >= 17) then
			master_index_m = p_m - 15
		end
		update_list = true
	end
	if (p_m < 1) then
		p_m = #my_songs
		if (p_m >= 17) then
			master_index_m = p_m - 15
		end
	elseif (p_m > #my_songs) then
		master_index_m = 0
		p_m = 1
	end
end
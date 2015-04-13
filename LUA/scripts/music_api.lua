-- Music module API used to trigger Music module with headset changing status --

-- Module background code
function BackgroundMusic()
	Sound.updateStream()
	
	-- Cycle mode
	if cycle_index > 1 then
		if Sound.getTime(current_song) >= Sound.getTotalTime(current_song) then
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
			end
			Sound.play(current_song,NO_LOOP,0x08,0x09)
			current_subfolder = my_songs[song_idx][3]
		end
	end
end

not_started = false
cycle_index = 2
my_songs = {}
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
			end
			io.close(tmp_file)
		else
			AddSongsFromDir(dir.."/"..file.name,file.name)
		end
	end
end
AddSongsFromDir("/MUSIC",nil)
if my_songs[1][2] == "WAV" then
	current_song = Sound.openWav(my_songs[1][4].."/"..my_songs[1][1],true)
elseif my_songs[1][2] == "AIFF" then
	current_song = Sound.openAiff(my_songs[1][4].."/"..my_songs[1][1],true)
end
Sound.play(current_song,NO_LOOP,0x08,0x09)
current_subfolder = my_songs[1][3]
song_idx = 1
AddIconTopbar(main_dir.."/images/music_icon.jpg","Music")
table.insert(bg_apps,{BackgroundMusic,MusicGC,"Music"}) -- Starting background Music module
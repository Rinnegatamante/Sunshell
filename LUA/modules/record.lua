-- Set private "Record" mode
mode = "Record"

-- Internal module settings
local does_reg_exist = false
local is_recording = false
local state = "Stopped"

-- Rendering functions
function AppTopScreenRender()	
	Graphics.fillRect(5,395,40,220,black)
	Graphics.fillRect(6,394,41,219,white)
end

function AppBottomScreenRender()
end

-- Module main cycle
function AppMainCycle()
	
	-- Checking if recording finished
	if is_recording then
		if state == "Recording" and not Mic.isRecording() then
			does_reg_exist = true
			state = "Stopped"
			cur_sound = Mic.stop()
			is_recording = false
		end
	end
	
	-- Showing Controls and Info
	if not is_recording then
		TopCropPrint(9,45,"Press A to start recording",black,TOP_SCREEN)
	else
		TopCropPrint(9,45,"Press A to stop recording",black,TOP_SCREEN)
		TopCropPrint(9,60,"Press R to pause/resume recording",black,TOP_SCREEN)
	end
	if does_reg_exist then
		TopCropPrint(9,75,"Press X to listen recorded sound",black,TOP_SCREEN)
		TopCropPrint(9,90,"Press Y to save recorded sound",black,TOP_SCREEN)
	end
	TopCropPrint(9,200,"State: "..state,black,TOP_SCREEN)
	
	-- Sets controls triggering
	if Controls.check(pad,KEY_B) or Controls.check(pad,KEY_START) then
		if is_recording then
			tmp = Mic.stop()
			Sound.close(tmp)
		elseif does_reg_exist then
			if Sound.isPlaying(cur_sound) then
				Sound.pause(cur_sound)
			end
			Sound.close(cur_sound)
		end
		CallMainMenu()
	elseif Controls.check(pad,KEY_R) or Controls.check(pad,KEY_R) then
		if is_recording then
			if Mic.isRecording() then
				Mic.pause()
				state = "Paused"
			else
				Mic.resume()
				state = "Recording"
			end
		end
	elseif Controls.check(pad,KEY_X) or Controls.check(pad,KEY_X) then
		if does_reg_exist then
			Sound.play(cur_sound, NO_LOOP)
		end
	elseif Controls.check(pad,KEY_Y) or Controls.check(pad,KEY_Y) then
		if does_reg_exist then
			h,m,s = System.getTime()
			Sound.saveWav(cur_sound,"/MUSIC/"..h.."-"..m.."-"..s..".wav")
			ShowWarning("Sound saved successfully!")
		end
	elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
		if is_recording then
			cur_sound = Mic.stop()
			is_recording = false
			does_reg_exist = true
			state = "Stopped"
		else
			if does_reg_exist then
				Sound.close(cur_sound)
				does_reg_exist = false
			end
			is_recording = true
			Mic.start(10, 32730)
			state = "Recording"
		end
	end
end
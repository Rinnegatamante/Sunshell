-- Set private "Camera" mode
mode = "Camera"

-- Internal module settings
update_bottom_screen = true
ui_enabled = false
screenshots = false
SetBottomRefresh(false)
SetTopRefresh(false)
Camera.init(TOP_SCREEN, OUTER_CAM, PHOTO_MODE_NORMAL, false)
local scene = OUTER_CAM
local photo_mode = PHOTO_MODE_NORMAL
local resolution = VGA_RES
local function GetPhotoMode(pm)
	if pm == PHOTO_MODE_NORMAL then
		return "Normal"
	elseif pm == PHOTO_MODE_PORTRAIT then
		return "Portrait"
	elseif pm == PHOTO_MODE_LANDSCAPE then
		return "Landscape"
	elseif pm == PHOTO_MODE_NIGHTVIEW then
		return "Night Mode"
	elseif pm == PHOTO_MODE_LETTER then
		return "Letter"
	end
end
local function GetResolution(pm)
	if pm == VGA_RES then
		return "VGA (640x480)"
	elseif pm == QVGA_RES then
		return "QVGA (320x240)"
	elseif pm == QQVGA_RES then
		return "QQVGA (160x120)"
	elseif pm == CIF_RES then
		return "CIF (352x288)"
	elseif pm == QCIF_RES then
		return "QCIF (176x144)"
	elseif pm == DS_RES then
		return "NDS (256x192)"
	elseif pm == HDS_RES then
		return "HDS (512x384)"
	elseif pm == CTR_RES then
		return "3DS (400x240)"
	end
end

function UpdateBottomScreen()

	-- Clear bottom screen
	Screen.clear(BOTTOM_SCREEN)

	-- Show controls info
	Screen.debugPrint(0,0, "Controls:", selected, BOTTOM_SCREEN)
	Screen.debugPrint(0,25, "L = Take Photo", white, BOTTOM_SCREEN)
	Screen.debugPrint(0,40, "X = Swap camera scene", white, BOTTOM_SCREEN)
	Screen.debugPrint(0,55, "Y = Change Photo Mode", white, BOTTOM_SCREEN)
	Screen.debugPrint(0,70, "A = Change Photo Resolution", white, BOTTOM_SCREEN)
	
	-- Show Photo settings
	Screen.debugPrint(0,100, "Settings:", selected, BOTTOM_SCREEN)
	Screen.debugPrint(0,125, "Photo Mode: " .. GetPhotoMode(photo_mode), white, BOTTOM_SCREEN)
	Screen.debugPrint(0,140, "Resolution: " .. GetResolution(resolution), white, BOTTOM_SCREEN)
	
end

-- Rendering functions
function AppTopScreenRender()	
end

function AppBottomScreenRender()
end

-- Module main cycle
function AppMainCycle()

	if update_bottom_screen then
		OneshotPrint(UpdateBottomScreen)
		update_bottom_screen = false
	end
	
	-- Show camera scene
	Camera.getOutput()
	
	-- Sets controls triggering
	if Controls.check(pad, KEY_L) then
		h,m,s = System.getTime()
		Camera.takePhoto("/DCIM/"..h.."-"..m.."-"..s.."-"..".jpg", resolution, true)
	elseif Controls.check(pad, KEY_Y) and not Controls.check(oldpad, KEY_Y) then
		photo_mode = photo_mode + 1
		if photo_mode > PHOTO_MODE_LETTER then
			photo_mode = PHOTO_MODE_NORMAL
		end
		Camera.init(TOP_SCREEN, OUTER_CAM, PHOTO_MODE_NORMAL, false)
		update_bottom_screen = true
	elseif Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A) then
		resolution = resolution + 1
		if resolution > CTR_RES then
			resolution = VGA_RES
		end
		update_bottom_screen = true
	elseif Controls.check(pad, KEY_X) and not Controls.check(oldpad, KEY_X) then
		Camera.term()
		if scene == OUTER_CAM then
			scene = INNER_CAM
		else
			scene = OUTER_CAM
		end
		Camera.init(TOP_SCREEN, scene, photo_mode, false)
	elseif Controls.check(pad,KEY_B) or Controls.check(pad,KEY_START) then
		Camera.term()
		CallMainMenu()
	end
	
end
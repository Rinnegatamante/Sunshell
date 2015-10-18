-- Set private "Themes" mode
mode = "Themes"

-- Internal module settings
master_index_t = 0
p_t = 1
my_themes = {}
tmp = System.listDirectory(main_dir.."/themes")
for i,file in pairs(tmp) do
	if file.directory then
		table.insert(my_themes,file.name)
	end
end

function UpdateBottomScreen()

	-- Showing files list
	base_y = 0
	for l, file in pairs(my_themes) do
		if (base_y > 226) then
			break
		end
		if (l >= master_index_t) then
			if (l==p_t) then
				Screen.fillRect(0,319,base_y,base_y+15,selected_item,BOTTOM_SCREEN)
				color = selected
			else
				color = black
			end
			CropPrint(0,base_y,file,color,BOTTOM_SCREEN)
			base_y = base_y + 15
		end
	end
		
end

-- Rendering functions
function AppTopScreenRender()	
end

function AppBottomScreenRender()
end

-- Module main cycle
function AppMainCycle()

	UpdateBottomScreen()
	
	-- Sets controls triggering
	if (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
		GarbageCollection()
		Font.unload(ttf)
		System.deleteFile(start_dir.."/config.sun")
		config_file = io.open(start_dir.."/config.sun",FCREATE)
		io.write(config_file,0,"main_dir = \""..main_dir.."\"\ntheme = \""..my_themes[p_t].."\"",string.len(main_dir)+string.len(my_themes[p_t])+24)
		io.close(config_file)
		theme_dir = main_dir.."/themes/"..my_themes[p_t]
		bg = Screen.loadImage(theme_dir.."/images/bg.jpg")
		if System.doesFileExist(theme_dir.."/images/music.jpg") then
			ext = ".jpg"
		else
			ext = ".png"
		end
		music = Screen.loadImage(theme_dir.."/images/music"..ext)
		video = Screen.loadImage(theme_dir.."/images/video"..ext)
		info = Screen.loadImage(theme_dir.."/images/info"..ext)
		fb = Screen.loadImage(theme_dir.."/images/fb"..ext)
		game = Screen.loadImage(theme_dir.."/images/game"..ext)
		photo = Screen.loadImage(theme_dir.."/images/photo"..ext)
		cia = Screen.loadImage(theme_dir.."/images/cia"..ext)
		extdata = Screen.loadImage(theme_dir.."/images/extdata"..ext)
		calc = Screen.loadImage(theme_dir.."/images/calc"..ext)
		mail = Screen.loadImage(theme_dir.."/images/mail"..ext)
		themes = Screen.loadImage(theme_dir.."/images/themes"..ext)
		clock = Screen.loadImage(theme_dir.."/images/clock"..ext)
		ftp = Screen.loadImage(theme_dir.."/images/ftp"..ext)
		charge = Screen.loadImage(theme_dir.."/images/charge"..ext)
		b0 = Screen.loadImage(theme_dir.."/images/0"..ext)
		b1 = Screen.loadImage(theme_dir.."/images/1"..ext)
		b2 = Screen.loadImage(theme_dir.."/images/2"..ext)
		b3 = Screen.loadImage(theme_dir.."/images/3"..ext)
		b4 = Screen.loadImage(theme_dir.."/images/4"..ext)
		b5 = Screen.loadImage(theme_dir.."/images/5"..ext)
		tools = {}
		table.insert(tools,{game,"/modules/game.lua","Applications"})
		table.insert(tools,{info,"/modules/info.lua","Console Info"})
		table.insert(tools,{photo,"/modules/photo.lua","Photos"})
		table.insert(tools,{music,"/modules/music.lua","Musics"})
		table.insert(tools,{video,"/modules/video.lua","Videos"})
		table.insert(tools,{fb,"/modules/fb.lua","Filebrowser"})
		table.insert(tools,{cia,"/modules/cia.lua","CIA Manager"})
		table.insert(tools,{extdata,"/modules/extdata.lua","Extdata Manager"})
		table.insert(tools,{calc,"/modules/calc.lua","Calc"})
		table.insert(tools,{clock,"/modules/clock.lua","Clock"})
		table.insert(tools,{ftp,"/modules/ftp.lua","FTP Server"})
		table.insert(tools,{mail,"/modules/mail.lua","Mail"})
		table.insert(tools,{themes,"/modules/themes.lua","Theme Manager"})
		ttf = Font.load(theme_dir.."/fonts/main.ttf")
		dofile(theme_dir.."/colors.lua")
		Font.setPixelSizes(ttf,18)
	elseif Controls.check(pad,KEY_B) or Controls.check(pad,KEY_START) then
		CallMainMenu()
	elseif (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
		p_t = p_t - 1
		if (p_t >= 16) then
			master_index_t = p_t - 15
		end
		update_bottom_screen = true
	elseif (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
		p_t = p_t + 1
		if (p_t >= 17) then
			master_index_t = p_t - 15
		end
		update_bottom_screen = true
	end
	if (p_t < 1) then
		p_t = #my_themes
		if (p_t >= 17) then
			master_index_t = p_t - 15
		end
	elseif (p_t > #my_themes) then
		master_index_t = 0
		p_t = 1
	end
end
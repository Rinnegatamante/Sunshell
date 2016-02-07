-- Set private "Mail" mode
mode = "Mail"

-- Internal module settings
if Network.isWifiEnabled() then
	object = "Mail Object"
	to = "sample@gmail.com"
	body = "This is my e-mail body."
else
	ShowError("You need to be connected on Internet to send mails.")
	CallMainMenu()
end
CallKeyboard(70,20)
state = "Main"
screenshots = false

-- Rendering functions
function AppTopScreenRender()	
	Graphics.fillRect(5,395,40,220,black)
	Graphics.fillRect(6,394,41,219,white)
end

function AppBottomScreenRender()
	ShowKeyboard()
	Graphics.fillRect(5,315,190,230,black)
	Graphics.fillRect(6,314,191,229,white)
end

-- Module main cycle
function AppMainCycle()
	
	-- Draw mail elements
	TopCropPrint(9,45,"Obj: "..object,black,TOP_SCREEN)
	TopCropPrint(9,60,"To: "..to,black,TOP_SCREEN)
	Font.print(ttf,9,75,"Body:",black,TOP_SCREEN)
	CropPrint(9,195,"State: "..state,black,BOTTOM_SCREEN)
	text = LinesGenerator(body,90)
	for i,line in pairs(text) do
		Font.print(ttf,9,line[2],line[1],black,TOP_SCREEN)
	end
	
	-- Keyboard input
	if state ~= "Main" then
		in_game = true -- Disable START button function
		CropPrint(9,213,"Press L to confirm",black,BOTTOM_SCREEN)
		if Controls.check(pad,KEY_L) and not Controls.check(oldpad,KEY_L) then
			state = "Main"
		end
		input = KeyboardInput()
		if input > 0 then
			if state == "Body" then
				tmp = body
			elseif state == "To" then
				tmp = to
			else
				tmp = object
			end
			if input == 0x09 then
				if string.len(tmp) > 1 then
					tmp = string.sub(tmp,1,string.len(tmp)-1)
				else
					tmp = ""
				end
			else
				tmp = tmp .. string.char(input)
			end
			if state == "Body" then
				body = tmp
			elseif state == "To" then
				to = tmp
			else
				object = tmp
			end
		end
	end
	
	-- Sets controls triggering
	if state == "Main" then
		if Controls.check(pad,KEY_A) and not Controls.check(oldpad,KEY_A) then
			state = "Body"
		elseif Controls.check(pad,KEY_X) then
			state = "To"
		elseif Controls.check(pad,KEY_Y) then
			state = "Obj"
		elseif Controls.check(pad,KEY_R) and not Controls.check(oldpad,KEY_R) then
			if Network.isWifiEnabled() then
				if Network.sendMail(to,object,body) then
					ShowWarning("Mail sent successfully!")
				else
					ShowError("An error has occurred while sending mail.")
				end	
			else
				ShowError("You need to be connected on Internet to send mails.")
			end
		elseif Controls.check(pad,KEY_B) or Controls.check(pad,KEY_START) then
			CloseKeyboard()
			CallMainMenu()
		end
	end
end
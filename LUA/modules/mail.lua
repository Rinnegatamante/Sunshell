-- Set private "Mail" mode
mode = "Mail"

-- Internal module settings
if Network.isWifiEnabled() then
	if build == "3DSX" then
		object = "Mail Object"
		to = "sample@gmail.com"
		body = "This is my e-mail body."
	else
		ShowError("This module is reserved for 3DSX build.")
		CallMainMenu()
	end
else
	ShowError("You need to be connected on Internet to send mails.")
	CallMainMenu()
end

-- Module main cycle
function AppMainCycle()

	-- Draw top screen box
	Screen.fillEmptyRect(5,395,40,220,black,TOP_SCREEN)
	Screen.fillRect(6,394,41,219,white,TOP_SCREEN)
	
	-- Draw bottom screen box
	Screen.fillEmptyRect(5,315,40,125,black,BOTTOM_SCREEN)
	Screen.fillRect(6,314,41,124,white,BOTTOM_SCREEN)
	
	-- Draw controls information
	Screen.debugPrint(9,45,"A = Edit Body",black,BOTTOM_SCREEN)
	Screen.debugPrint(9,60,"X = Edit Destination",black,BOTTOM_SCREEN)
	Screen.debugPrint(9,75,"Y = Edit Object",black,BOTTOM_SCREEN)
	Screen.debugPrint(9,90,"R = Send Mail",black,BOTTOM_SCREEN)
	Screen.debugPrint(9,105,"B = Return to Main Menu",black,BOTTOM_SCREEN)
	
	-- Draw mail elements
	TopCropPrint(9,45,"Obj: "..object,black,TOP_SCREEN)
	TopCropPrint(9,60,"To: "..to,black,TOP_SCREEN)
	Screen.debugPrint(9,75,"Body:",black,TOP_SCREEN)
	text = LinesGenerator(body,90)
	for i,line in pairs(text) do
		Screen.debugPrint(9,line[2],line[1],black,TOP_SCREEN)
	end
	
	-- Sets controls triggering
	if Controls.check(pad,KEY_A) and not Controls.check(oldpad,KEY_A) then
		body = System.startKeyboard(body)
	elseif Controls.check(pad,KEY_X) then
		to = System.startKeyboard(to)
		pad = KEY_A
		oldpad = pad
	elseif Controls.check(pad,KEY_Y) then
		object = System.startKeyboard(object)
		pad = KEY_A
		oldpad = pad
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
		CallMainMenu()
	end
end
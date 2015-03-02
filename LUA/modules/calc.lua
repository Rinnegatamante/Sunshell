-- Set private "Calc" mode
mode = "Calc"

-- Internal module settings
decimal = false
result = 0
showing = 0
oper_mode = false
n_switch = true

function molt(x,y)
	return x*y
end
function div(x,y)
	return x/y
end
function mmod(x,y)
	return x%y
end
function plus(x,y)
	return x+y
end
function sot(x,y)
	return x-y
end
function pow(x,y)
	return x^y
end
function change(x)
	return -x
end
function ten(x)
	return 10^x
end
function fact(x)
	i = 1
	res = 1
	while i <= x do
		res = res * i
		i = i + 1
	end
	return res
end
function sqr(x,y)
	return pow(x,(1/y))
end
function rad3(x,y)
	return pow(x,(1/3))
end
function logX(x,y)
	return (math.log(x)/math.log(y))
end
function dec(x)
	decimal = true
end
function del(x)
	to_del = -2
	if string.len(tostring(x)) < 2 then
		x = 0
	elseif string.sub(tostring(x),-2,-2) == "." then
		to_del = -3
	end
	return tonumber(string.sub(tostring(x),1,to_del))
end
function hex_del(x)	
	if x <= 15 and x >= 0 then
		return 0
	elseif x < 0 then
		return (x*16)-1
	else
		return (x/16)-1
	end
end
function free(x)
	return 0
end
function ris(x,y) -- x,y stubs
	decimal = false
	result = 0
	oper_mode = false
	n_switch = true
	return showing
end
calc_mode = "Scientific"
s_table = {{ten,1,nil}, -- 1 = Operator, 2 = N° Arguments, 3 = Value 
		   {math.sin,1,nil},
		   {pow,2,nil},
		   {fact,1,nil},
		   {nil,0,7},
		   {nil,0,8},
		   {nil,0,9},
		   {math.abs,1,nil}, 
		   {math.cos,1,nil},
		   {math.sqrt,1,nil},
		   {sqr,2,nil},
		   {nil,0,4},
		   {nil,0,5},
		   {nil,0,6},
		   {math.tan,1,nil}, 
		   {rad3,1,nil},
		   {logX,2,nil},
		   {math.log,1,nil},
		   {nil,0,1},
		   {nil,0,2},
		   {nil,0,3},
		   {math.asin,1,nil},
		   {math.acos,1,nil},
		   {math.atan,1,nil},
		   {math.exp,1,nil},
		   {change,1,nil},
		   {nil,0,0},
		   {dec,1,nil},
		   {plus,2,nil},
		   {sot,2,nil},
		   {molt,2,nil},
		   {div,2,nil},
		   {del,1,nil},
		   {free,1,nil},
		   {ris,2,nil}
		  }
d_table = {{plus,2,nil}, -- 1 = Operator, 2 = N° Arguments, 3 = Value 
		   {sot,2,nil},
		   {nil,0,7},
		   {nil,0,8},
		   {nil,0,9},
		   {molt,2,nil},
		   {div,2,nil},
		   {nil,0,4},
		   {nil,0,5},
		   {nil,0,6},
		   {nil,0,0xA},
		   {nil,0,0xB},
		   {nil,0,1},
		   {nil,0,2},
		   {nil,0,3},
		   {nil,0,0xC},
		   {nil,0,0xD},
		   {change,1,nil},
		   {nil,0,0},
		   {mmod,2,nil},
		   {nil,0,0xE},
		   {nil,0,0xF},
		   {hex_del,1,nil},
		   {free,1,nil},
		   {ris,2,nil}
		  }
-- Module main cycle
function AppMainCycle()

	-- Reset x,y coordinates
	y = 50
	x = 15
	
	-- Draw top screen box
	Screen.fillEmptyRect(5,395,40,80,black,TOP_SCREEN)
	Screen.fillRect(6,394,41,79,white,TOP_SCREEN)
	
	-- Draw calculator display
	if calc_mode == "Developer" then
		Screen.debugPrint(10,45,"Hex: "..string.format('%X',math.tointeger(showing)),black,TOP_SCREEN)
		Screen.debugPrint(10,60,"Dec: "..math.tointeger(showing),black,TOP_SCREEN)
	else
		Screen.debugPrint(10,45,showing,black,TOP_SCREEN)
	end
	-- Draw calculator mode
	Screen.fillEmptyRect(x-10,x+300,y-45,y-25,black,BOTTOM_SCREEN)
	Screen.fillRect(x-9,x+299,y-44,y-26,white,BOTTOM_SCREEN)
	Screen.debugPrint(x-5,y-40,"Mode: "..calc_mode,black,BOTTOM_SCREEN)
	
	-- Developer Mode
	if calc_mode == "Developer" then
	
		-- Sets keyboard controls and draw rects for buttons
		i = 1
		z = 1
		x_c = x+95
		y_c = y-5
		while (i <= #d_table) do
			exec = false
			if z < 3 then
				Screen.fillEmptyRect(x_c,x_c+50,y_c,y_c+25,black,BOTTOM_SCREEN)
				Screen.fillRect(x_c+1,x_c+49,y_c+1,y_c+24,white,BOTTOM_SCREEN)
			else
				Screen.fillEmptyRect(x_c,x_c+30,y_c,y_c+25,black,BOTTOM_SCREEN)
				Screen.fillRect(x_c+1,x_c+29,y_c+1,y_c+24,white,BOTTOM_SCREEN)
			end
			if Controls.check(pad,KEY_TOUCH) and not Controls.check(oldpad,KEY_TOUCH) then
				c1,c2 = Controls.readTouch()
				if c1 >= x_c and c2 >= y_c then
					if z < 3 then
						if c1 < x_c + 45 and c2 < y_c + 25 then
							exec = true
						end
					else
						if c1 < x_c + 25 and c2 < y_c + 25 then
							exec = true
						end
					end
				end
			end
			if exec then
				if d_table[i][3] == nil then
					if d_table[i][2] == 2 then
						if oper_mode then
							showing = math.ceil(operator(result,showing))
							operator = d_table[i][1]
							n_switch = false
						else
							result = showing
							showing = 0
							operator = d_table[i][1]
							oper_mode = true						
						end
					else
						if oper_mode and n_switch then
							showing = math.ceil(operator(result,showing))
							operator = nil
							n_switch = false
						end
						showing = math.ceil(d_table[i][1](showing))
						oper_mode = false
					end
				else
					if showing == 0 then
						showing = d_table[i][3]
					else
						if oper_mode and not n_switch then
							n_switch = true
							result = showing
							showing = 0
						end
						if string.len(tostring(math.ceil(showing))) > 8 then
							showing = math.huge
						else
							showing = showing * 16 + d_table[i][3]
						end
					end
				end
			end
			i=i+1
			z=z+1
			if z > 3 then
				x_c = x_c + 30
				if z > 5 then
					x_c = x+95
					y_c = y_c + 25
					z = 1
				end
			else
				x_c = x_c + 50
			end
		end
	
		-- Draw calculator keyboard
		Screen.debugPrint(x+100,y,"+",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+150,y,"-",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+200,y,"7",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+230,y,"8",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+260,y,"9",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+100,y+25,"*",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+150,y+25,"/",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+200,y+25,"4",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+230,y+25,"5",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+260,y+25,"6",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+100,y+50,"A",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+150,y+50,"B",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+200,y+50,"1",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+230,y+50,"2",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+260,y+50,"3",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+100,y+75,"C",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+150,y+75,"D",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+200,y+75,"-X",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+230,y+75,"0",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+260,y+75,"%",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+100,y+100,"E",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+150,y+100,"F",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+200,y+100,"De",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+230,y+100,"Ca",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+260,y+100,"=",black,BOTTOM_SCREEN)
	
	-- Scientific Mode
	elseif calc_mode == "Scientific" then
		
		-- Sets keyboard controls and draw rects for buttons
		i = 1
		z = 1
		x_c = x-5
		y_c = y-5
		while (i <= #s_table) do
			exec = false
			if z < 5 then
				Screen.fillEmptyRect(x_c,x_c+50,y_c,y_c+25,black,BOTTOM_SCREEN)
				Screen.fillRect(x_c+1,x_c+49,y_c+1,y_c+24,white,BOTTOM_SCREEN)
			else
				Screen.fillEmptyRect(x_c,x_c+30,y_c,y_c+25,black,BOTTOM_SCREEN)
				Screen.fillRect(x_c+1,x_c+29,y_c+1,y_c+24,white,BOTTOM_SCREEN)
			end
			if Controls.check(pad,KEY_TOUCH) and not Controls.check(oldpad,KEY_TOUCH) then
				c1,c2 = Controls.readTouch()
				if c1 >= x_c and c2 >= y_c then
					if z < 5 then
						if c1 < x_c + 45 and c2 < y_c + 25 then
							exec = true
						end
					else
						if c1 < x_c + 25 and c2 < y_c + 25 then
							exec = true
						end
					end
				end
			end
			if exec then
				if s_table[i][3] == nil then
					if s_table[i][1] == dec then
						if operator == nil then
							decimal = true
						else
							showing = operator(result,showing)
							operator = nil
							n_switch = true
							oper_mode = false
							decimal = true
						end
					elseif s_table[i][1] == ris then
						showing = operator(result,showing)
						result = 0
						ris(0,0)
					elseif s_table[i][2] == 2 then
						if oper_mode then
							showing = operator(result,showing)
							operator = s_table[i][1]
							n_switch = false
						else
							result = showing
							showing = 0
							operator = s_table[i][1]
							oper_mode = true						
						end
					else
						if oper_mode and n_switch then
							showing = operator(result,showing)
							operator = nil
						end
						showing = s_table[i][1](showing)
						oper_mode = false
					end
				else
					if showing == 0 then
						showing = s_table[i][3]
					else
						if oper_mode and not n_switch then
							n_switch = true
							result = showing
							showing = 0
						end
						if string.len(tostring(math.ceil(showing))) > 8 then
							showing = math.huge
						else
							if decimal then
								showing = tonumber(tostring(showing).."."..s_table[i][3])
								decimal = false
							else
								showing = tonumber(tostring(showing)..s_table[i][3])
							end
						end
					end
				end
			end
			i=i+1
			z=z+1
			if z > 5 then
				x_c = x_c + 30
				if z > 7 then
					x_c = x-5
					y_c = y_c + 25
					z = 1
				end
			else
				x_c = x_c + 50
			end
		end
		
		-- Draw calculator keyboard
		Screen.debugPrint(x,y,"10^",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+50,y,"sin",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+100,y,"^",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+150,y,"n!",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+200,y,"7",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+230,y,"8",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+260,y,"9",black,BOTTOM_SCREEN)
		Screen.debugPrint(x,y+25,"abs",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+50,y+25,"cos",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+100,y+25,"rad",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+150,y+25,"radX",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+200,y+25,"4",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+230,y+25,"5",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+260,y+25,"6",black,BOTTOM_SCREEN)
		Screen.debugPrint(x,y+50,"rad3",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+50,y+50,"tan",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+100,y+50,"log",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+150,y+50,"ln",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+200,y+50,"1",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+230,y+50,"2",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+260,y+50,"3",black,BOTTOM_SCREEN)
		Screen.debugPrint(x,y+75,"asin",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+50,y+75,"acos",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+100,y+75,"atan",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+150,y+75,"e^",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+200,y+75,"-X",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+230,y+75,"0",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+260,y+75,",",black,BOTTOM_SCREEN)
		Screen.debugPrint(x,y+100,"+",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+50,y+100,"-",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+100,y+100,"*",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+150,y+100,"/",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+200,y+100,"D",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+230,y+100,"C",black,BOTTOM_SCREEN)
		Screen.debugPrint(x+260,y+100,"=",black,BOTTOM_SCREEN)
	
	end
	
	-- Sets controls triggering
	if Controls.check(pad,KEY_B) or Controls.check(pad,KEY_START) then
		CallMainMenu()
	elseif Controls.check(pad,KEY_SELECT) and not Controls.check(oldpad,KEY_SELECT) then
		decimal = false
		result = 0
		showing = 0
		oper_mode = false
		n_switch = true
		if calc_mode == "Scientific" then
			calc_mode = "Developer"
		else
			calc_mode = "Scientific"
		end
	end
end
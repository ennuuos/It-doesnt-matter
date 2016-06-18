menu = {}

menu.cursor = {}
menu.cursor.default = {}
menu.cursor.default.width = 20
menu.cursor.default.height = 20
menu.cursor.default.color = {r = 255, g = 0, b = 0}
menu.cursor.width = menu.cursor.default.width
menu.cursor.height = menu.cursor.default.height
menu.cursor.color = menu.cursor.default.color
menu.cursor.dotradius = 2
menu.cursor.borderlength = 5
menu.cursor.x = 0
menu.cursor.y = 0
menu.cursor.renderx = 0
menu.cursor.rendery = 0
menu.cursor.onbutton = false
menu.button = {}
menu.commands = {}


function menu.commands.start()
	game.start()
end

function menu.commands.dropdown(i)
	menu.button[i].dropped = not menu.button[i].dropped
end

function menu.update()
	menu.cursor.get()
	menu.cursor.hover()
end


function menu.draw()
	menu.button.drawAll()
	menu.cursor.draw()
end


function menu.cursor.get()
	menu.cursor.x, menu.cursor.y = love.mouse.getPosition( )
end


function menu.cursor.hover()
	i = 1
	menu.cursor.onbutton = false
	while i <= #menu.button do
		if util.contains(menu.cursor.x, menu.cursor.y, menu.button[i].x, menu.button[i].y, menu.button[i].width, menu.button[i].height) then
			menu.cursor.onbutton = i
			menu.cursor.buttonparent = nil
		end

		--if the button has child buttons and is dropped down
		if menu.button[i].dropped then
			di = 1
			while di <= table.getn(menu.button[i].dropbuttons) do
				if util.contains(menu.cursor.x, menu.cursor.y, menu.button[i].dropbuttons[di].x, menu.button[i].dropbuttons[di].y, menu.button[i].dropbuttons[di].width, menu.button[i].dropbuttons[di].height) then
					menu.cursor.onbutton = di
					menu.cursor.buttonparent = i
				end
				di = di + 1
			end
		end

		i = i + 1
	end
	menu.cursor.set()
end


function menu.cursor.set()
	if menu.cursor.onbutton and not menu.cursor.buttonparent then
		menu.cursor.width = menu.button[menu.cursor.onbutton].width
		menu.cursor.height = menu.button[menu.cursor.onbutton].height
		menu.cursor.color = {r = 0, g = 255, b = 0}
		menu.cursor.renderx = menu.button[menu.cursor.onbutton].x + menu.button[menu.cursor.onbutton].width/2
		menu.cursor.rendery = menu.button[menu.cursor.onbutton].y + menu.button[menu.cursor.onbutton].height/2
	elseif menu.cursor.onbutton and menu.cursor.buttonparent then
		menu.cursor.width = menu.button[menu.cursor.buttonparent].dropbuttons[menu.cursor.onbutton].width
		menu.cursor.height = menu.button[menu.cursor.buttonparent].dropbuttons[menu.cursor.onbutton].height
		menu.cursor.color = {r = 0, g = 255, b = 0}
		menu.cursor.renderx = menu.button[menu.cursor.buttonparent].dropbuttons[menu.cursor.onbutton].x + menu.button[menu.cursor.buttonparent].dropbuttons[menu.cursor.onbutton].width/2
		menu.cursor.rendery = menu.button[menu.cursor.buttonparent].dropbuttons[menu.cursor.onbutton].y + menu.button[menu.cursor.buttonparent].dropbuttons[menu.cursor.onbutton].height/2
	else
		menu.cursor.reset()
	end
end


function menu.cursor.reset()
	menu.cursor.width = menu.cursor.default.width
	menu.cursor.height = menu.cursor.default.height
	menu.cursor.color = menu.cursor.default.color
	menu.cursor.renderx = menu.cursor.x
	menu.cursor.rendery = menu.cursor.y
end


function menu.button.new(x, y, w, h, t, c, ddParent)
	if not ddParent then
	i = #menu.button + 1
		menu.button[i] = {}
		menu.button[i].x = x
		menu.button[i].y = y
		menu.button[i].width = w
		menu.button[i].height = h
		menu.button[i].text = t
		menu.button[i].command = c
		menu.button[i].dropped = false
		menu.button[i].dropbuttons = {}
		return i
	else
		--if this button is a child button
		i = table.getn(menu.button[ddParent].dropbuttons) + 1
		menu.button[ddParent].dropbuttons[i] = {}
		menu.button[ddParent].dropbuttons[i].x = x
		menu.button[ddParent].dropbuttons[i].y = y
		menu.button[ddParent].dropbuttons[i].width = w
		menu.button[ddParent].dropbuttons[i].height = h
		menu.button[ddParent].dropbuttons[i].text = t
		menu.button[ddParent].dropbuttons[i].command = c
		menu.button[ddParent].dropbuttons[i].dropped = false
		menu.button[ddParent].dropbuttons[i].dropbuttons = {}
	end	
end


function menu.button.drawAll()
	i = 1
	while i <= #menu.button do
		menu.button.draw(i)

		--draw any child buttons if active
		if menu.button[i].dropped then
			di = 1
			while di <= table.getn(menu.button[i].dropbuttons) do
				menu.button.draw(i, di)
				di = di + 1
			end
		end

		i = i + 1
	end
end

--di is the index of a child button, if exists
function menu.button.draw(i, di)
	if di then
		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle("fill", menu.button[i].dropbuttons[di].x, menu.button[i].dropbuttons[di].y, menu.button[i].dropbuttons[di].width, menu.button[i].dropbuttons[di].height)
		love.graphics.setColor(0,0,0)
		love.graphics.printf(menu.button[i].dropbuttons[di].text, menu.button[i].dropbuttons[di].x, menu.button[i].dropbuttons[di].y + 7, menu.button[i].dropbuttons[di].width, 'center')
	else
		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle("fill", menu.button[i].x, menu.button[i].y, menu.button[i].width, menu.button[i].height)
		love.graphics.setColor(0,0,0)
		love.graphics.printf(menu.button[i].text, menu.button[i].x, menu.button[i].y + 7, menu.button[i].width, 'center')
	end
end

function menu.cursor.draw()
	love.graphics.setColor(menu.cursor.color.r, menu.cursor.color.g, menu.cursor.color.b)

	love.graphics.line(menu.cursor.renderx - menu.cursor.width/2, menu.cursor.rendery - menu.cursor.height/2, menu.cursor.renderx - menu.cursor.width/2, menu.cursor.rendery - menu.cursor.height/2 + menu.cursor.borderlength)
	love.graphics.line(menu.cursor.renderx - menu.cursor.width/2, menu.cursor.rendery - menu.cursor.height/2, menu.cursor.renderx - menu.cursor.width/2 + menu.cursor.borderlength, menu.cursor.rendery - menu.cursor.height/2)

	love.graphics.line(menu.cursor.renderx + menu.cursor.width/2, menu.cursor.rendery - menu.cursor.height/2, menu.cursor.renderx + menu.cursor.width/2, menu.cursor.rendery - menu.cursor.height/2 + menu.cursor.borderlength)
	love.graphics.line(menu.cursor.renderx + menu.cursor.width/2, menu.cursor.rendery - menu.cursor.height/2, menu.cursor.renderx + menu.cursor.width/2 - menu.cursor.borderlength, menu.cursor.rendery - menu.cursor.height/2)

	love.graphics.line(menu.cursor.renderx + menu.cursor.width/2, menu.cursor.rendery + menu.cursor.height/2, menu.cursor.renderx + menu.cursor.width/2, menu.cursor.rendery + menu.cursor.height/2 - menu.cursor.borderlength)
	love.graphics.line(menu.cursor.renderx + menu.cursor.width/2, menu.cursor.rendery + menu.cursor.height/2, menu.cursor.renderx + menu.cursor.width/2 - menu.cursor.borderlength, menu.cursor.rendery + menu.cursor.height/2)

	love.graphics.line(menu.cursor.renderx - menu.cursor.width/2, menu.cursor.rendery + menu.cursor.height/2, menu.cursor.renderx - menu.cursor.width/2, menu.cursor.rendery + menu.cursor.height/2 - menu.cursor.borderlength)
	love.graphics.line(menu.cursor.renderx - menu.cursor.width/2, menu.cursor.rendery + menu.cursor.height/2, menu.cursor.renderx - menu.cursor.width/2 + menu.cursor.borderlength, menu.cursor.rendery + menu.cursor.height/2)
	if menu.cursor.onbutton == false then
		love.graphics.circle("fill", menu.cursor.renderx, menu.cursor.rendery, menu.cursor.dotradius, 4)
	end

end

function menu.mousepressed(x, y, button, istouch)
	--if the button is not a child button
	if menu.cursor.onbutton and not menu.cursor.buttonparent then
		menu.button[menu.cursor.onbutton].command(menu.cursor.onbutton)
	elseif menu.cursor.onbutton and menu.cursor.buttonparent then
		menu.button[menu.cursor.buttonparent].dropbuttons[menu.cursor.onbutton].command(menu.cursor.onbutton)
	end
end

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
	while i <= table.getn(menu.button) do
		if util.contains(menu.cursor.x, menu.cursor.y, menu.button[i].x, menu.button[i].y, menu.button[i].width, menu.button[i].height) then
			menu.cursor.onbutton = i
		end
		i = i + 1
	end
	menu.cursor.set()
end

function menu.cursor.set()
	if menu.cursor.onbutton then
		menu.cursor.width = menu.button[menu.cursor.onbutton].width
		menu.cursor.height = menu.button[menu.cursor.onbutton].height
		menu.cursor.color = {r = 0, g = 255, b = 0}
		menu.cursor.renderx = menu.button[menu.cursor.onbutton].x + menu.button[menu.cursor.onbutton].width/2
		menu.cursor.rendery = menu.button[menu.cursor.onbutton].y + menu.button[menu.cursor.onbutton].height/2
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


function menu.button.new(x, y, w, h, t, c)
	i = table.getn(menu.button) + 1
	menu.button[i] = {}
	menu.button[i].x = x
	menu.button[i].y = y
	menu.button[i].width = w
	menu.button[i].height = h
	menu.button[i].text = t
	menu.button[i].command = c
end

function menu.button.drawAll()
	i = 1
	while i <= table.getn(menu.button) do
		menu.button.draw(i)
		i = i + 1
	end
end

function menu.button.draw(i)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", menu.button[i].x, menu.button[i].y, menu.button[i].width, menu.button[i].height)
	love.graphics.setColor(0,0,0)
	love.graphics.printf(menu.button[i].text, menu.button[i].x, menu.button[i].y + 7, menu.button[i].width, 'center')

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
	if menu.cursor.onbutton then
		menu.button[menu.cursor.onbutton].command()
	end
end
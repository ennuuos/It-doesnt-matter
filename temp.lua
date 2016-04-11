function menu.update()
	menu.cursor.update()

	i = 1
	while i <= table.getn(menu.button) do

		i = i + 1
	end
end

function menu.button.drawall()
	i = 1
	while i <= table.getn(menu.button) do
		menu.button.draw(i)
		i = i + 1
	end
end

function menu.button.draw(i)
	love.graphics.setColor(button[i].r, button[i].g, button[i].b)
	love.graphics.rectangle('fill', button[i].x, button[i].y, button[i].width, button[i].height)
end

function menu.button.center(i)
	return button[i].x + button[i].width / 2, button[i].y + button[i].height/2
end

function menu.cursor.hover()
	i = 1
	while i <= table.getn(menu.button) do
		if util.contains(cursor.x, cursor.y, button[i].x, button[i].y, button[i].width, button[i].height)
			return i
		end
		i = i + 1
	end

	return nil
end
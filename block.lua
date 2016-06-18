block = {}

block.types = {}
block.types['standard'] = {}
block.types['standard'].width = 20
block.types['standard'].height = 20
block.types['standard'].health = 1000
block.types['standard'].color = {r = 20, g = 20, b = 20}
block.types['standard'].matter = 100

--block 'constructor'
function block.new(x, y, type)
	block[#block + 1] = {
		type = type,
		x = x - block.types[type].width / 2,
		y = y - block.types[type].height / 2,
		width = block.types[type].width,
		height = block.types[type].height,
		color = block.types[type].color,
		matter = block.types['standard'].matter,
		health = block.types[type].health,
	}
end

--record any health damage and react appropriately
function block.damage(i, damage)
	block[i].health = block[i].health - damage
	if block[i].health <= 0 then
		--if the block should be dead, kill it
		block.destroy(i)
	end
end

--destroy the block and create any drops
function block.destroy(i)
	--create a matter drop
	block.dropmatter(i)
	--destroy the block
	table.remove(block, i)
end

--creates a matter drop
function block.dropmatter(i)
	--call pickup constructor with block's properties
	x,y=block.center(i)
	pi = pickup.new('matter', x, y)
	pickup[pi].vmatter = block[i].matter
	pickup[pi].width = block[i].matter / 4
	pickup[pi].height = block[i].matter / 4
	pickup[pi].width = pickup[pi].width - block[i].matter / 8
	pickup[pi].height = pickup[pi].height - block[i].matter / 8

end

--iterates and remove all blocks, without fancy destruction
function block.clear()
	while #block > 0 do
		table.remove(block, i)
	end
end

--recreate the starting level
function block.reset()
	block.clear()

	--four starting blocks in a plus shape
	block.new(settings.windowwidth / 2, settings.windowheight / 3, "standard")
	block.new(settings.windowwidth / 2, 2 *settings.windowheight / 3, "standard")
	block.new(settings.windowwidth / 3, settings.windowheight / 2, "standard")
	block.new(2 * settings.windowwidth / 3, settings.windowheight / 2, "standard")
end


function block.center(i)
	return block[i].x + block[i].width/2, block[i].y + block[i].height/2
end


function block.drawAll()
	--iterate through each block and call draw function for each
	i = 1
	while i <= #block do
		block.draw(i)
		i = i + 1
	end
end

--draws block to screen
function block.draw(i)
	love.graphics.setColor(block[i].color.r, block[i].color.g, block[i].color.b)
	love.graphics.rectangle("fill", block[i].x, block[i].y, block[i].width, block[i].height)
end

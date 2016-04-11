player = {}


player.width = 20
player.height = 20
player.x = settings.windowwidth/2
player.y = settings.windowheight/2
player.health = 1000
player.speed = 230
player.color = {r = 200, g = 100, b = 200}
player.weaponDT = 1000 -- time since last fire. Used for fire rate.
player.equippedIndex = 1
player.weapons = { -- player's inventory
	{	name =  'minigun',
		ammo = 150	},
}
player.equippedWeapon = player.weapons[player.equippedIndex].name
player.score = 0
player.matter = 1000
player.upgradespeed = 50

--block building stats
player.matterCost = 100 -- cost of 1mu
player.healthBonus = 500
player.maxRange = 250 -- max distance to place blocks

--draw that shit awww yeeahh baby
function player.draw()
	love.graphics.setColor(player.color.r, player.color.g, player.color.b)
	love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
end

--NOT CALLED
--[[
	TODO: Remove this, or call it
]]
function player.drawScore()
	love.graphics.print(player.score, 50, 50)
end

function player.move(dt)
	x, y = player.getInput() -- get input returns an x and y

	magnitude = player.normalizedSpeed(x,y) -- gets a scalar to multiply the movement by (so it doesn't go faster diagonally)
	--apply movement
	player.x = player.x + magnitude * dt * x
	player.y = player.y + magnitude * dt * y
	--clamp to stop the player from leaving. THEY CAN NEVER LEEEEEAAAAAVVVVEEEE!!!!! MWAHAHAHAHAHAHAHAHAHAHAHAHAAAAA
	player.x, player.y = util.clamprectangle(player.x, player.y, player.width, player.height, 0, settings.windowwidth, 0, settings.windowheight)

end
--herp derp
function player.damage(damage)
	player.health = player.health - damage -- When someone insults you, you're emotionally damaged

	if player.health <= 0 then -- are you okay? dude, you look sick, I think we should get you to a hospital
		player.lose() -- BILLY NOOOOOOOOOOOOOOO!!!!!!
	end
end

function player.lose() -- This function is effectively the grim reaper. awkies.
	player.speed = 0
end

function player.getInput() -- gets input...   well what else would it do?
	--returns an x and a y of 0, -1 or 1.
	x = 0
	y = 0
	if love.keyboard.isDown(settings.keys.left1) or love.keyboard.isDown(settings.keys.left2) then
		x = x -1
	end
	if love.keyboard.isDown(settings.keys.right1) or love.keyboard.isDown(settings.keys.right2) then
		x = x + 1
	end

	if love.keyboard.isDown(settings.keys.up1) or love.keyboard.isDown(settings.keys.up2) then
		y = y - 1
	end
	if love.keyboard.isDown(settings.keys.down1) or love.keyboard.isDown(settings.keys.down2) then
		y = y + 1
	end
	return x, y
end

function player.center() return player.x + player.width/2, player.y + player.height/2 end -- returns the center of the player rect as a coord, instead of the top left corner. useful

function player.collideAll() -- iterate and call collide
	i = 1
	while i <= table.getn(block) do
		player.collide(i)
		i = i + 1
	end
end

function player.collide(i) -- does what it says. The player collides with blocks
	values = { -- These are the values to compare to find the least intruded side
		player.x + player.width - block[i].x, -- Left
		block[i].x + block[i].width - player.x, -- Right
		player.y + player.height - block[i].y, -- Top
		block[i].y + block[i].height - player.y -- Bottom
	}

	-- check if collided
	if player.x + player.width > block[i].x and player.x < block[i].x + block[i].width and player.y + player.height > block[i].y and player.y < block[i].y + block[i].height then
		lowest = 1 -- the least intruded side (currently)
		hi = 2 -- the next value to compare (from values table)
		while hi <= 4 do -- there are 4 values. 
			if values[hi] < values[lowest] then -- if this value is lower, it means the corresponfing side has less intrusion.
				lowest = hi 						--in that case we set the least intruded side as this one
			end
			hi = hi + 1
		end 

		--check what lowest is
		 		--  and set the player position to be somewhere not intruded.
		 				-- (it will be 'pushed' back to the side of least intrusion.)
		if 		lowest == 1 then
			player.x = block[i].x - player.width
		elseif 	lowest == 2 then
			player.x = block[i].x + block[i].width
		elseif 	lowest == 3 then
			player.y = block[i].y - player.height
		elseif 	lowest == 4 then
			player.y = block[i].y + block[i].height
		end

	end

end

--updates the player
function player.update(dt)
	player.move(dt)
	cursor.get()
	player.operateWeapon(dt)
	player.upgrade(dt)
	player.collideAll()
end

function player.clamp()
	player.matter = util.clamplow(player.matter, 0)
	player.health = util.clamplow(player.health, 0)
end

--does weapon stuff
function player.operateWeapon(dt)
	player.weaponDT = player.weaponDT + dt -- increment weapon delta
	if game.playtime > 0.5 then
		if love.mouse.isDown(1) then
			if player.weaponDT > weapon[player.equippedWeapon].rate then -- checks if the required time has passed to fire the weapon again.
				if player.weapons[player.equippedIndex].ammo > 0 then -- checks if there is enough ammo
					player.weaponDT = 0 -- resets weapon delta
					x, y = player.center() -- gets player center
					projectile.new(weapon[player.equippedWeapon].type, x, y, cursor.x, cursor.y, true) -- creates a new projectile at player center pointed to cursor, with isPlayer as true
					player.weapons[player.equippedIndex].ammo = player.weapons[player.equippedIndex].ammo - 1
				end
			end
		end
	end
end

function player.normalizedSpeed(x,y) -- returns player.speed if x or y is 0 else returns player.speed/root2
	if x ~= 0 and y ~= 0 then
		--pythagoras
		magnitude = player.speed / util.root2
	else
		magnitude = player.speed
	end
	return magnitude
end

function player.upgrade(dt)
	closest = false
	if love.mouse.isDown(2) then
		i = 1
		while i <= table.getn(block) do
			if util.collides(cursor.x - cursor.width/2, cursor.y - cursor.height/2, cursor.width, cursor.height, block[i].x, block[i].y, block[i].width, block[i].height) then
				if closest then
					ax,ay = block.center(i)
					bx,by = block.center(closest)
					if util.distance(cursor.x, cursor.y, ax, ay) < util.distance(cursor.x, cursor.y, bx, by) then
						closest = i
					end
				else
					closest = i
				end
			end
			i = i + 1
		end
		if closest then
			i = closest
			x,y = block.center(i)
			cursor.x = x
			cursor.y = y
			cursor.width = block[i].width
			cursor.height = block[i].height
			if player.matter > 0 then
				bi = 1
				collides = false
				while bi <= table.getn(block) do
					if bi ~= i then
						if util.collides(block[i].x - dt * 25, block[i].y - dt * 25, block[i].width + dt * 50, block[i].height + dt * 50, block[bi].x, block[bi].y, block[bi].width, block[bi].height) then
							collides =  true
						end
					end
					bi = bi + 1
				end
				if collides == false and util.distance(player.x, player.y, block[i].x + block[i].width / 2, block[i].y + block[i].height / 2) < player.maxRange then
					block[i].x = block[i].x - dt * 25
					block[i].y = block[i].y - dt * 25

					block[i].width = block[i].width + dt * 50
					block[i].height = block[i].height + dt * 50

					block[i].matter = block[i].matter + player.matterCost * dt / 2
					block[i].health = block[i].health + player.healthBonus * dt / 2

					player.matter = player.matter - dt * player.matterCost
				end
			end
		else
			cursor.reset()
		end
	else
		cursor.reset()
	end
end

--initialize cursor properties
cursor = {}
cursor.width = 20
cursor.height = 20
cursor.cornerLength = 5
cursor.pointRadius = 1
cursor.pointSegments = 4 -- needed for circle rendering

cursor.standard = {}
cursor.standard.width = 20
cursor.standard.height = 20
cursor.standard.cornerLength = 5
cursor.standard.pointRadius = 1
cursor.standard.pointSegments = 4 -- needed for circle rendering

function cursor.get() -- pretty simple. sets cursor.x and cursor.y as x and y of mouse. saves time.
	cursor.x, cursor.y = love.mouse.getPosition( )
	return cursor.x, cursor.y
end

function cursor.reset() -- pretty simple. sets cursor.x and cursor.y as x and y of mouse. saves time.
	cursor.width = cursor.standard.width
	cursor.height = cursor.standard.height
end

function cursor.drawaimline()
	love.graphics.setColor(50,50,50)
	love.graphics.line(player.x + player.width/2, player.y + player.height/2, cursor.x, cursor.y)

end

function cursor.draw()

	if player.canbuild(cursor.x, cursor.y) then -- checks if the player can currently build, and if so changes the cursor colour
		--[[
			TODO: set block based colours
		]]
		love.graphics.setColor(100,10,100)
	else
		--[[
			TODO: set this to a variable
		]]
		love.graphics.setColor(150,10,10)
	end
	-- A bunch of lines and shit are drawn to screen. This is just the cursor being drawn. Nothing much to worry about
	love.graphics.line(cursor.x - cursor.width/2, cursor.y - cursor.height/2, cursor.x - cursor.width/2, cursor.y - cursor.height/2 + cursor.cornerLength)
	love.graphics.line(cursor.x - cursor.width/2, cursor.y - cursor.height/2, cursor.x - cursor.width/2 + cursor.cornerLength, cursor.y - cursor.height/2)

	love.graphics.line(cursor.x + cursor.width/2, cursor.y - cursor.height/2, cursor.x + cursor.width/2, cursor.y - cursor.height/2 + cursor.cornerLength)
	love.graphics.line(cursor.x + cursor.width/2, cursor.y - cursor.height/2, cursor.x + cursor.width/2 - cursor.cornerLength, cursor.y - cursor.height/2)

	love.graphics.line(cursor.x + cursor.width/2, cursor.y + cursor.height/2, cursor.x + cursor.width/2, cursor.y + cursor.height/2 - cursor.cornerLength)
	love.graphics.line(cursor.x + cursor.width/2, cursor.y + cursor.height/2, cursor.x + cursor.width/2 - cursor.cornerLength, cursor.y + cursor.height/2)

	love.graphics.line(cursor.x - cursor.width/2, cursor.y + cursor.height/2, cursor.x - cursor.width/2, cursor.y + cursor.height/2 - cursor.cornerLength)
	love.graphics.line(cursor.x - cursor.width/2, cursor.y + cursor.height/2, cursor.x - cursor.width/2 + cursor.cornerLength, cursor.y + cursor.height/2)

	love.graphics.circle("fill", cursor.x, cursor.y, cursor.pointRadius, cursor.pointSegments)
end

function cycleWeapon (dir) -- changes to next or previous weapon. Triggered by a love.keypressed call
	if dir then -- direction is true if the cyclenext key is pressed, or false if it is cycleback
		player.equippedIndex = player.equippedIndex + 1
	else
		player.equippedIndex = player.equippedIndex - 1
	end
	if player.equippedIndex < 1 then -- loops from bottom to top
		player.equippedIndex = table.getn(player.weapons)
	end
	if player.equippedIndex > table.getn(player.weapons) then --loops from top to bottom
		player.equippedIndex = 1
	end
	player.equippedWeapon = player.weapons[player.equippedIndex].name -- changes the equipped weapon to the new index
end

function player.makeblock(x, y) -- creates a new block
	if player.canbuild(x, y) then -- checks if the player can build at the given x, y
		--[[
			TODO: BLOCK SIZES
		]]
		block.new(x, y, 'standard') -- makes a new standard block
		player.matter = player.matter - player.matterCost -- decrements matter by matter cost
	end
end

function player.canbuild(x, y) -- checks if player can build at the given x, y
	px, py = player.center()
	if player.matter >= player.matterCost and util.distance(px, py, x, y) <= player.maxRange then -- checks matter cost and distance of x,y from player
		if util.collides(player.x, player.y, player.width, player.height, x - cursor.width/2, y - cursor.width/2, cursor.width, cursor.height) == false then -- checks collision
			i = 1
			while i <= table.getn(block) do -- checks all block collision
				if util.collides(block[i].x, block[i].y, block[i].width, block[i].height, x - cursor.width/2, y - cursor.width/2, cursor.width, cursor.height) then
					if util.contains(cursor.x, cursor.y, block[i].x, block[i].y, block[i].width, block[i].height) then
						if util.distptrect(player.x, player.y, block[i].x, block[i].y, block[i].width, block[i].height) < player.maxRange then
							return false, true
						else
							return false, false
						end
					else
						return false, false
					end
				end
				i = i + 1
			end
			i = 1
			while i <= table.getn(enemy) do -- checks all enemy collision
				if util.collides(enemy[i].x, enemy[i].y, enemy.types[enemy[i].type].width, enemy.types[enemy[i].type].height, x - cursor.width/2, y - cursor.width/2, cursor.width, cursor.height) then
					return false, false
				end
				i = i + 1
			end

			return true, false
		end
	end
	return false
end

function player.keypressed( key ) -- called by love.  
	if key == settings.keys.cycleforward then --self explanatory?
		cycleWeapon(true)
	end
	if key == settings.keys.cycleback then
		cycleWeapon(false)
	end
end

function player.mousepressed(x ,y, button, istouch) -- called by love
	if button == 2 then -- if mouse 2 is pressed
		player.makeblock(x, y)	--then make a block at mouse x, mouse y
	end
end
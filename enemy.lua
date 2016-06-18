enemy = {}

--properties in relation to player movement
buffer = 200	--distance from player at which point movement is engaged
mindistance = 100	--closest they'll move to player

--enemy types and their stats
enemy.types = {
	'standard',
	'heavy',
	'intellectual',
	'speedyfucker',
	'brick',
	'sniper',
	'victor von deathenstein',
}

enemy.types['standard'] = {
	width = 20,
	height = 20,
	speed = 80,
	tick = 5,  --time between enemy[i] decisions
	health = 80,
	fireRate = 0.3,	--time between shots
	projectileType = "standard",
	scoreValue = 10,
	color = {r = 10, g = 100, b = 12},
	weapon = 'standard',
	deathfunction = function(i) enemy.droppoints(i) end,
}

enemy.types['heavy'] = {
	width = 40,
	height = 40,
	speed = 80,
	tick = 5,  --time between enemy[i] decisions
	health = 180,
	scoreValue = 20,
	color = {r = 255, g = 100, b = 12},
	weapon = 'minigun',
	deathfunction = function(i) enemy.dropblock(i) enemy.droppoints(i) enemy.dropweapon(i) end,
}


enemy.types['victor von deathenstein'] = {
	width = 35,
	height = 35,
	speed = 100,
	tick = 2,  --time between enemy[i] decisions
	health = 420,
	scoreValue = 100,
	color = {r = 0, g = 0, b = 0},
	weapon = 'deathinator',
	deathfunction = function(i) enemy.droppoints(i) enemy.dropweapon(i) enemy.dropblock(i) end,
}


enemy.types['intellectual'] = {
	enemy.types['intellectual'].width = 15,
	enemy.types['intellectual'].height = 15,
	enemy.types['intellectual'].speed = 60,
	enemy.types['intellectual'].tick = 0.5,  --time between enemy[i] decisions
	enemy.types['intellectual'].health = 40,
	enemy.types['intellectual'].scoreValue = 20,
	enemy.types['intellectual'].color = {r = 0, g = 100, b = 100},
	enemy.types['intellectual'].weapon = 'standard',
	enemy.types['intellectual'].deathfunction = function(i) enemy.droppoints(i) enemy.drophealth(i) end,
}


enemy.types['sniper'] = {
	width = 15,
	height = 15,
	speed = 60,
	tick = 10,  --time between enemy[i] decisions
	health = 40,
	scoreValue = 20,
	color = {r = 0, g = 25, b = 25},
	weapon = 'rifle',
	deathfunction = function(i) enemy.droppoints(i) enemy.dropweapon(i) end,
}


enemy.types['speedyfucker'] = {
	enemy.width = 15,
	enemy.height = 15,
	enemy.speed = 160,
	enemy.tick = 0.5,  --time between enemy[i] decisions
	enemy.health = 40,
	enemy.scoreValue = 20,
	enemy.color = {r = 255, g = 30, b = 30},
	enemy.weapon = 'standard',
	enemy.vspeed = 25,
	enemy.types['speedyfucker'].deathfunction = function(i) enemy.droppoints(i) enemy.dropspeed(i) end
}


enemy.types['brick'] = {
width = 55,
height = 55,
speed = 160,
tick = 10,  --time between enemy[i] decisions
health = 800,
scoreValue = 20,
color = {r = 100, g = 50, b = 50},
weapon = 'smallstick',
deathfunction = function(i) enemy.droppoints(i) enemy.dropmaxhealth(i) end,
}


--pickup drop functions
function enemy.dropblock(i)
	x, y = enemy.center(i)
	block.new(x, y, 'standard')
end


function enemy.droppoints(i)
	x, y = enemy.center(i)
	x = x + math.random(-10,10)/10
	y = y + math.random(-10,10)/10

	pi = pickup.new('points', x, y)
	pickup[pi].vscore = enemy[i].score
end


function enemy.dropspeed(i)
	x, y = enemy.center(i)
	x = x + math.random(-10,10)/10
	y = y + math.random(-10,10)/10

	pi = pickup.new('speed', x, y)
	pickup[pi].vspeed = enemy[i].vspeed
end


function enemy.dropmaxhealth(i)
	x, y = enemy.center(i)
	x = x + math.random(-10,10)/10
	y = y + math.random(-10,10)/10

	pi = pickup.new('maxhealth', x, y)
end


function enemy.dropweapon(i)
	x, y = enemy.center(i)
	x = x + math.random(-10,10)/10
	y = y + math.random(-10,10)/10

	pi = pickup.new('weapon', x, y)
	pickup[pi].vweapon = enemy.types[enemy[i].type].weapon
	pickup[pi].ammo = math.random(weapon[pickup[pi].vweapon].minammo, weapon[pickup[pi].vweapon].maxammo)
end


function enemy.drophealth(i)
	x, y = enemy.center(i)
	x = x + math.random(-10,10)/10
	y = y + math.random(-10,10)/10

	pi = pickup.new('health', x, y)
	pickup[pi].vhealth = math.random(5,100)
end

--controlled enemy spawn
function enemy.new(x, y, type)
	enemy[#enemy + 1] = {
		x = x,
		y = y,
		type = type,
		health = enemy.types[type].health,
		tickCounter = 0,
		fireCounter = 1000,
		behaviour = "move",
		score = enemy.types[type].scoreValue,
		vspeed = enemy.types[type].vspeed,
	}
end

--spawn a new enemy at a random position
function enemy.newrandom()
	i = #enemy + 1
	randmax = #enemy.types
	randmax = math.min(randmax, enemy.spawn.currentwave)
	enemy.new(math.random(0, settings.windowwidth), math.random(0, settings.windowheight), enemy.types[math.random(1, randmax)])
end

--draw enemy to screen
function enemy.draw(i)
	love.graphics.setColor(enemy.types[enemy[i].type].color.r, enemy.types[enemy[i].type].color.g, enemy.types[enemy[i].type].color.b)
	love.graphics.rectangle("fill", enemy[i].x, enemy[i].y, enemy.types[enemy[i].type].width, enemy.types[enemy[i].type].height)
end

--iterate and call draw for each enemy
function enemy.drawAll()
	i = 1
	while i <= #enemy do
		enemy.draw(i)
		i = i + 1
	end
end

--return the center of the enemy rect
function enemy.center(i)
	return enemy[i].x + enemy.types[enemy[i].type].width/2, enemy[i].y + enemy.types[enemy[i].type].height/2
end

--record any damage and react appropriately
function enemy.damage(i, damage)
	enemy[i].health = enemy[i].health - damage
	if enemy[i].health <= 0 then
		enemy.destroy(i)
	end
end

--creates pickups, increases score, and deletes the enemy
function enemy.destroy(i)
	player.score = player.score + enemy.types[enemy[i].type].scoreValue
	enemy.types[enemy[i].type].deathfunction(i)
	table.remove(enemy, i)
end

--iterate through each enemy and block and check for collisions
function enemy.collideall()
	ei = 1	--enemy index
	while ei <= #enemy do
		bi = 1	--block index
		while bi <= #block do
			enemy.collide(ei, bi)
			bi = bi + 1
		end
		ei = ei + 1
	end
end

--check for a collision between an enemy and a block, and adjust the enemy so they no longer collide
function enemy.collide(ei, bi)
	--rect points for calculation, used to determine which side the rect is on from the center of the block
	values = {
		enemy[ei].x + enemy.types[enemy[ei].type].width - block[bi].x,	--Left
		block[bi].x + block[bi].width - enemy[ei].x,	--Right
		enemy[ei].y + enemy.types[enemy[ei].type].height - block[bi].y,	--Top
		block[bi].y + block[bi].height - enemy[ei].y	--Bottom
	}

	--collision check
	if enemy[ei].x + enemy.types[enemy[ei].type].width > block[bi].x and enemy[ei].x < block[bi].x + block[bi].width and enemy[ei].y + enemy.types[enemy[ei].type].height > block[bi].y and enemy[ei].y < block[bi].y + block[bi].height then
		lowest = 1		--side with least intrusion
		hi = 2
		while hi <= 4 do 	--iterate through the four values
			--if new value intrudes less, set it to lowest
			if values[hi] < values[lowest] then
				lowest = hi
			end
			hi = hi + 1
		end

		--push player to the side of least intrusion
		if 		lowest == 1 then
			enemy[ei].x = block[bi].x - enemy.types[enemy[ei].type].width
		elseif 	lowest == 2 then
			enemy[ei].x = block[bi].x + block[bi].width
		elseif 	lowest == 3 then
			enemy[ei].y = block[bi].y - enemy.types[enemy[ei].type].height
		elseif 	lowest == 4 then
			enemy[ei].y = block[bi].y + block[bi].height
		end

	end
end

--drives the enemy ai, makes them decide what to do next
function enemy.choice(i)
	--pick randomly whether to move or shoot
	choice = math.random(0,1)
	if choice == 0 then
		enemy[i].behaviour = "move"
	end
	if choice == 1 then
		enemy[i].behaviour = "shoot"
	end

	--if player is too close during decision making, move
	ex, ey = enemy.center(i)
	px, py = player.center()
	if util.distance(px, py, ex, ey) < mindistance then
		enemy[i].behaviour = 'move'
	end
end

--moves the player
function enemy.move(dt, i)
	px, py = player.center()
	ex, ey = enemy.center(i)
	x, y = util.diffxy(ex, ey, px, py)
	distance = util.distance(px, py, ex, ey)

	--if in buffer distance, use point movement
	if distance < buffer then
		--for x and y, get a distance from plus or minus (mindistance to buffer)
		--set enemy movement goal to player pos plus random x and y
		if enemy[i].goalx == nil then
			random = math.random(-buffer, buffer)
			--if too close, make it the mindistance
			if math.abs(random) < mindistance then
				random = mindistance * math.abs(random)/random
			end
			enemy[i].goalx = px + random
			random = math.random(-buffer, buffer)
			--if too close, make it the mindistance
			if math.abs(random) < mindistance then
				random = mindistance * math.abs(random)/random
			end
			enemy[i].goaly = py + random
		end

		--if enemy has reached their goal (with a bit of tolerance), change behaviour to shoot or idle
		if enemy[i].goalx - 3 <= ex and ex <= enemy[i].goalx + 3 and enemy[i].goaly - 3 <= ey and ey <= enemy[i].goaly + 3 then
			enemy[i].goalx = nil
			enemy[i].goaly = nil
			doesshoot = math.random(0,1)
			if doesshoot == 1 then
				enemy[i].behaviour = 'shoot'
			else
				enemy[i].behaviour = 'idle'
			end
		end
	end

	--if the player runs away too fast, go back to persuit movement
	if distance > 1.5 * buffer then
		enemy[i].goalx = nil
		enemy[i].goaly = nil
	end

	--if enemy has goal, move towards goal
	if enemy[i].goalx then
		x, y = util.diffxy(ex, ey, enemy[i].goalx, enemy[i].goaly)
	end

	--get them as +ve or -ve 1
	x = math.abs(x)/x
	y = math.abs(y)/y
	magnitude = enemy.normalizedSpeed(x, y, i)
	--apply movement
	enemy[i].x = enemy[i].x + magnitude * dt * x
	enemy[i].y = enemy[i].y + magnitude * dt * y
	--clamp
	enemy[i].x, enemy[i].y = util.clamprectangle(enemy[i].x, enemy[i].y, enemy.types[enemy[i].type].width, enemy.types[enemy[i].type].height, 0, settings.windowwidth, 0, settings.windowheight)
end

--normalise the speed
function enemy.normalizedSpeed(x, y, i)
	if x ~= 0 and y ~= 0 then
		--pythagoras
		magnitude = enemy.types[enemy[i].type].speed / util.root2
	else
		magnitude = enemy.types[enemy[i].type].speed
	end
	return magnitude
end

--code to execute if the enemy decides to shoot at the player
function enemy.shoot(dt, i)
	--add time to fire counter, since it counts the cooldown time
	enemy[i].fireCounter = enemy[i].fireCounter + dt
	--if the enemy's weapon can shoot again, i.e cooled down, fire at player and reset weapon cooldown
	if enemy[i].fireCounter >= weapon[enemy.types[enemy[i].type].weapon].rate then
		px, py = player.center()
		ex, ey = enemy.center(i)
		projectile.new(weapon[enemy.types[enemy[i].type].weapon].type, ex, ey, px, py, false)
		enemy[i].fireCounter = 0
	end
end

--frame-byframe enemy code
function enemy.update(dt, i)
	--make another decision if enemy's think time is up, and reset think cooldown
	enemy[i].tickCounter = enemy[i].tickCounter + dt
	if enemy[i].tickCounter >= enemy.types[enemy[i].type].tick then
		enemy.choice(i)	--changes enemy behaviour
		enemy[i].tickCounter = 0
	end

	--if the enemy is choosing to move, move
	if enemy[i].behaviour == "move" then
		enemy.move(dt, i)
	end
	--if choosing to shoot, well, shoot
	if enemy[i].behaviour == "shoot" then
		enemy.shoot(dt, i)
	end
end

--iterate through each enemy, calling update code
function enemy.updateAll(dt)
	i = 1
	while i <= #enemy do
		enemy.update(dt, i)
		i = i + 1
	end
	enemy.collideall()
end

enemy.spawn = {}
enemy.spawn.cooltime = 10
enemy.spawn.wavemaxtime = 40
enemy.spawn.wavedelta = 0
enemy.spawn.cooldelta = enemy.spawn.cooltime/2
enemy.spawn.currentwave = 1
function enemy.spawn.update(dt)
	if #enemy > 0 then
		enemy.spawn.wavedelta = enemy.spawn.wavedelta + dt
		enemy.spawn.cooldelta = 0
		if enemy.spawn.wavedelta > enemy.spawn.wavemaxtime then
			enemy.spawn.newwave(enemy.spawn.currentwave)
			enemy.spawn.currentwave = enemy.spawn.currentwave + 1
			enemy.spawn.wavedelta = 0
		end
	else
		enemy.spawn.cooldelta = enemy.spawn.cooldelta + dt
		enemy.spawn.wavedelta = 0
		if enemy.spawn.cooldelta > enemy.spawn.cooltime then
			enemy.spawn.newwave(enemy.spawn.currentwave)
			enemy.spawn.currentwave = enemy.spawn.currentwave + 1
		end
	end
end


function enemy.spawn.newwave(wave)
	i = 1
	while i < enemy.spawn.currentwave * settings.difficulty do
		enemy.newrandom()
	end
end

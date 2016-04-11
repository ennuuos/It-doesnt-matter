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
	'sniper',
	'victor von deathenstein',
	--'telepotato'
}

enemy.types['standard'] = {}
enemy.types['standard'].width = 20
enemy.types['standard'].height = 20
enemy.types['standard'].speed = 80
enemy.types['standard'].tick = 5  --time between enemy[i] decisions
enemy.types['standard'].health = 80
enemy.types['standard'].fireRate = 0.3	--time between shots
enemy.types['standard'].projectileType = "standard"
enemy.types['standard'].scoreValue = 10
enemy.types['standard'].color = {r = 10, g = 100, b = 12}
enemy.types['standard'].weapon = 'standard'
enemy.types['standard'].deathfunction = function(i) enemy.droppoints(i) end

enemy.types['heavy'] = {}
enemy.types['heavy'].width = 40
enemy.types['heavy'].height = 40
enemy.types['heavy'].speed = 80
enemy.types['heavy'].tick = 5  --time between enemy[i] decisions
enemy.types['heavy'].health = 180
enemy.types['heavy'].scoreValue = 20
enemy.types['heavy'].color = {r = 255, g = 100, b = 12}
enemy.types['heavy'].weapon = 'minigun'
enemy.types['heavy'].deathfunction = function(i) enemy.dropblock(i) enemy.droppoints(i) enemy.dropweapon(i) end

enemy.types['victor von deathenstein'] = {}
enemy.types['victor von deathenstein'].width = 35
enemy.types['victor von deathenstein'].height = 35
enemy.types['victor von deathenstein'].speed = 100
enemy.types['victor von deathenstein'].tick = 2  --time between enemy[i] decisions
enemy.types['victor von deathenstein'].health = 420
enemy.types['victor von deathenstein'].scoreValue = 100
enemy.types['victor von deathenstein'].color = {r = 0, g = 0, b = 0}
enemy.types['victor von deathenstein'].weapon = 'deathinator'
enemy.types['victor von deathenstein'].deathfunction = function(i) enemy.droppoints(i) enemy.dropweapon(i) enemy.dropblock(i) end

enemy.types['telepotato'] = {}
enemy.types['telepotato'].width = 8
enemy.types['telepotato'].height = 8
enemy.types['telepotato'].speed = 1000
enemy.types['telepotato'].tick = 0.1  --time between enemy[i] decisions
enemy.types['telepotato'].health = 1000
enemy.types['telepotato'].scoreValue = 10000
enemy.types['telepotato'].color = {r = 255, g = 0, b = 255}
enemy.types['telepotato'].weapon = 'standard'
enemy.types['telepotato'].deathfunction = function(i)  end


enemy.types['intellectual'] = {}
enemy.types['intellectual'].width = 15
enemy.types['intellectual'].height = 15
enemy.types['intellectual'].speed = 60
enemy.types['intellectual'].tick = 0.5  --time between enemy[i] decisions
enemy.types['intellectual'].health = 40
enemy.types['intellectual'].scoreValue = 20
enemy.types['intellectual'].color = {r = 0, g = 100, b = 100}
enemy.types['intellectual'].weapon = 'standard'
enemy.types['intellectual'].deathfunction = function(i) enemy.droppoints(i) end

enemy.types['sniper'] = {}
enemy.types['sniper'].width = 15
enemy.types['sniper'].height = 15
enemy.types['sniper'].speed = 60
enemy.types['sniper'].tick = 10  --time between enemy[i] decisions
enemy.types['sniper'].health = 40
enemy.types['sniper'].scoreValue = 20
enemy.types['sniper'].color = {r = 0, g = 25, b = 25}
enemy.types['sniper'].weapon = 'rifle'
enemy.types['sniper'].deathfunction = function(i) enemy.droppoints(i) enemy.dropweapon(i) end

enemy.types['speedyfucker'] = {}
enemy.types['speedyfucker'].width = 15
enemy.types['speedyfucker'].height = 15
enemy.types['speedyfucker'].speed = 160
enemy.types['speedyfucker'].tick = 0.5  --time between enemy[i] decisions
enemy.types['speedyfucker'].health = 40
enemy.types['speedyfucker'].scoreValue = 20
enemy.types['speedyfucker'].color = {r = 255, g = 30, b = 30}
enemy.types['speedyfucker'].weapon = 'standard'
enemy.types['speedyfucker'].deathfunction = function(i) enemy.droppoints(i) end

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
function enemy.dropweapon(i)
	x, y = enemy.center(i)
	x = x + math.random(-10,10)/10
	y = y + math.random(-10,10)/10

	pi = pickup.new('weapon', x, y)
	pickup[pi].vweapon = enemy.types[enemy[i].type].weapon
	pickup[pi].ammo = math.random(weapon[pickup[pi].vweapon].minammo, weapon[pickup[pi].vweapon].maxammo)
end


--controlled enemy spawn
function enemy.new(x, y, type)
	i = table.getn(enemy) + 1

	enemy[i] = {}
	enemy[i].x = x
	enemy[i].y = y
	enemy[i].type = type
	enemy[i].health = enemy.types[type].health
	enemy[i].tickCounter = 0
	enemy[i].fireCounter = 1000
	enemy[i].behaviour = "move"
	enemy[i].score = enemy.types[type].scoreValue
end

--spawn a new enemy at a random position
function enemy.newrandom()
	i = table.getn(enemy) + 1
	randmax = table.getn(enemy.types)
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
	while i <= table.getn(enemy) do
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
	while ei <= table.getn(enemy) do
		bi = 1	--block index
		while bi <= table.getn(block) do
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
	while i <= table.getn(enemy) do
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
	if table.getn(enemy) > 0 then
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
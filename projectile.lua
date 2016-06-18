projectile = {}

projectile.types = {}

projectile.types['standard'] = {
	speed = 300,
	radius = 3,
	color = {r = 255, g = 255, b = 255},
	damage = 20,
}

projectile.types['fast'] = {
	speed = 500,
	radius = 5,
	color = {r = 255, g = 0, b = 0},
	damage = 35,
}

projectile.types['revolver'] = {
	speed = 550,
	radius = 7,
	color = {r = 255, g = 204, b = 0},
	damage = 60,
}

projectile.types['deathinator'] = {
	speed = 600,
	radius = 7,
	color = {r = 0, g = 0, b = 0},
	damage = 100,
}

projectile.types['rifle'] = {
	speed = 300,
	radius = 7,
	color = {r = 0, g = 0, b = 255},
	damage = 10000,
}

--create a new projectile
function projectile.new(type, x, y, tx, ty, bIsPlayer)

	i = #projectile + 1
	projectile[i] = {}
	projectile[i].x = x
	projectile[i].y = y
	--whether is player owned, i.e can hurt the player
	projectile[i].isPlayer = bIsPlayer
	projectile[i].type = type
	projectile[i].radius = projectile.types[type].radius
	--set velocity of projectile
	projectile[i].vX, projectile[i].vY = util.normalize(util.diffxy(x, y, tx, ty))
	projectile[i].x, projectile[i].y = projectile[i].x + projectile[i].vX, projectile[i].y + projectile[i].vY
	projectile[i].vX = projectile[i].vX * projectile.types[type].speed
	projectile[i].vY = projectile[i].vY * projectile.types[type].speed
end

--iterate through and call update function for each
function projectile.updateAll(dt)
	for i = 1, #projectile do
		if projectile[i] then
			projectile.update(i, dt)
		end
	end
end


function projectile.update(i, dt)
	--move projectile
	projectile[i].x = projectile[i].x + projectile[i].vX * dt
	projectile[i].y = projectile[i].y + projectile[i].vY * dt
	projectile.checkcollisions(i)
	if projectile[i] then
		--if the projectile still exists, check if it hits the edges of the window
		if util.collides(projectile[i].x, projectile[i].y, 0, 0, 0, 0, settings.windowwidth, settings.windowheight) == false then
			table.remove(projectile, i)
		end
	end
end

--iterate and call draw function
function projectile.drawAll()
	i = 1
	while i <= #projectile do
		projectile.draw(i)
		i = i + 1
	end
end


function projectile.draw(i)
	love.graphics.setColor(projectile.types[projectile[i].type].color.r, projectile.types[projectile[i].type].color.g, projectile.types[projectile[i].type].color.b)
	if projectile[i].type == 'deathinator' then
		util.randcol()
	end
	love.graphics.circle("fill", projectile[i].x, projectile[i].y, projectile.types[projectile[i].type].radius,20)
end

--destroys the projectile, and performs any other required operations (currently none)
function projectile.destroy(i)
	if projectile[i].type ~= 'rifle' then
		table.remove(projectile, i)
	end
end

--returns a bounding box for the projectile
function projectile.rect(i)
	return projectile[i].x - projectile[i].radius, projectile[i].y - projectile[i].radius, projectile[i].radius * 2, projectile[i].radius * 2
end


function projectile.checkcollisions(i)
	if projectile[i] then
		--if player owned, check against enemies and v. v.
		if projectile[i].isPlayer then
			projectile.collisionallenemies(i)
		else
			projectile.collisionplayer(i)
		end
	end
	--in case the projectile gets deleted in the earlier collision check, check it exists
	if projectile[i] then
		--check against blocks
		projectile.collisionallblocks(i)
	end
end

--check collision against player
function projectile.collisionplayer(i)
	x, y, w, h = projectile.rect(i)
	--if it collides, destroy the projectile and damage the player
	if util.collides(x, y, w, h, player.x, player.y, player.width, player.height) then
		player.damage(projectile.types[projectile[i].type].damage)
		projectile.destroy(i)
	end
end


function projectile.collisionallenemies(i)
	ei = 1
	while ei <= #enemy do
		if projectile[i] then
			projectile.collisionenemy(i, ei)
		end
		ei = ei + 1
	end
end


function projectile.collisionenemy(i, ei)
	x, y, w, h = projectile.rect(i)
	if util.collides(x, y, w, h, enemy[ei].x, enemy[ei].y, enemy.types[enemy[ei].type].width, enemy.types[enemy[ei].type].height) then
		enemy.damage(ei, projectile.types[projectile[i].type].damage)
		projectile.destroy(i)
	end
end


function projectile.collisionallblocks(i)
	bi = 1
	while bi <= #block do
		if projectile[i] then
			projectile.collisionblock(i, bi)
		end
		bi = bi + 1
	end
end


function projectile.collisionblock(i, bi)
	x, y, w, h = projectile.rect(i)
	if util.collides(x, y, w, h, block[bi].x, block[bi].y, block[bi].width, block[bi].height) then

		block.damage(bi, projectile.types[projectile[i].type].damage)
		projectile.destroy(i)
	end
end

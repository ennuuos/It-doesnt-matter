--require('player')

pickup = {}

pickup.types = {}
pickup.types['points'] = {}
pickup.types['points'].width = 10
pickup.types['points'].height = 10
pickup.types['points'].color = {r = 20, g = 180, b = 180}
pickup.types['points'].func = function(i) pickup.addscore(i) end
pickup.types['points'].vscore = 85

pickup.types['matter'] = {}
pickup.types['matter'].width = 10
pickup.types['matter'].height = 10
pickup.types['matter'].color = {r = 94, g = 42, b = 64}
pickup.types['matter'].func = function(i) pickup.addmatter(i) end
pickup.types['matter'].vmatter = 40

pickup.types['weapon'] = {}
pickup.types['weapon'].width = 10
pickup.types['weapon'].height = 10
pickup.types['weapon'].color = {r = 255, g = 204, b = 0}
pickup.types['weapon'].func = function(i) pickup.getweapon(i) end
pickup.types['weapon'].vweaponname = 'minigun'

pickup.magnetspeed = 130
pickup.magnetrange = 70

function pickup.addscore(i)
	player.score = player.score + pickup[i].vscore
	table.remove(pickup, i)
end

function pickup.addmatter(i)
	player.matter = player.matter + pickup[i].vmatter
	table.remove(pickup, i)
end


function pickup.getweapon(i)
	hasWeapon = false
	weapIndex = 0
	c = 1
	while c <= table.getn(player.weapons) do
		if player.weapons[c].name == pickup[i].vweapon then
			hasWeapon = true
			weapIndex = c
		end
		c = c + 1
	end

	if hasWeapon then
		--give ammo maybe
		player.weapons[weapIndex].ammo = player.weapons[weapIndex].ammo + math.random(weapon[pickup[i].vweapon].minammo, weapon[pickup[i].vweapon].maxammo)
	else
		newweap = table.getn(player.weapons) + 1
		player.weapons[newweap] = {}
		player.weapons[newweap].name = pickup[i].vweapon
		player.weapons[newweap].ammo = math.random(weapon[pickup[i].vweapon].minammo, weapon[pickup[i].vweapon].maxammo)
	end

	table.remove(pickup, i)
end

function pickup.new(type, x, y)
	i = table.getn(pickup) + 1
	pickup[i] = {}
	pickup[i].type = type

	pickup[i].width = pickup.types[pickup[i].type].width
	pickup[i].height = pickup.types[pickup[i].type].height

	pickup[i].x = x - pickup[i].width / 2
	pickup[i].y = y - pickup[i].height / 2
	return i
end

function pickup.drawAll()
	i = 1
	while i <= table.getn(pickup) do
		pickup.draw(i)
		i = i + 1
	end
end

function pickup.draw(i)
	love.graphics.setColor(pickup.types[pickup[i].type].color.r, pickup.types[pickup[i].type].color.g, pickup.types[pickup[i].type].color.b)
	love.graphics.rectangle("fill", pickup[i].x, pickup[i].y, pickup[i].width, pickup[i].height)
end



function pickup.updateAll()
	i = 1
	while i <= table.getn(pickup) do
		pickup.update(i)
		i = i + 1
	end
	pickup.collideall()
end

function pickup.update(i)
	pickup.checkplayer(i)
end

function pickup.checkplayer(i)

	px, py = player.center()
	x,y = pickup.center(i)
	if util.distance(px, py, x, y) < pickup.magnetrange then
		if px > x then
			pickup[i].x = pickup[i].x + pickup.magnetspeed * game.dt
		elseif px < pickup[i].x then
			pickup[i].x = pickup[i].x - pickup.magnetspeed * game.dt
		end
		if py > y then
			pickup[i].y = pickup[i].y + pickup.magnetspeed * game.dt
		elseif py < y then
			pickup[i].y = pickup[i].y - pickup.magnetspeed * game.dt
		end
	end

	if util.collides(pickup[i].x, pickup[i].y, pickup[i].width, pickup[i].height, player.x, player.y, player.width, player.height) then
		pickup.types[pickup[i].type].func(i, pickup[i].value)
	end
end

function pickup.center(i)
	return pickup[i].x + pickup[i].width/2, pickup[i].y + pickup[i].height/2
end

--iterate through each pickup and block and check for collisions
function pickup.collideall()
	pi = 1	--pickup index
	while pi <= table.getn(pickup) do
		bi = 1	--block index
		while bi <= table.getn(block) do
			pickup.collideblock(pi, bi)
			bi = bi + 1
		end
		pi = pi + 1
	end

	pi = 1	--pickup index
	while pi <= table.getn(pickup) do
		bi = 1	--block index
		while bi <= table.getn(pickup) do
			if bi ~= pi then
				pickup.collidepickup(pi, bi)
			end
			bi = bi + 1
		end
		pi = pi + 1
	end

end

--check for a collision between an pickup and a block, and adjust so they no longer collide
function pickup.collideblock(pi, bi)
	--rect points for calculation, used to determine which side the rect is on from the center of the block
	values = {
		pickup[pi].x + pickup[pi].width - block[bi].x,	--Left
		block[bi].x + block[bi].width - pickup[pi].x,	--Right
		pickup[pi].y + pickup[pi].height - block[bi].y,	--Top
		block[bi].y + block[bi].height - pickup[pi].y	--Bottom
	}

	--collision check
	if pickup[pi].x + pickup[pi].width > block[bi].x and pickup[pi].x < block[bi].x + block[bi].width and pickup[pi].y + pickup[pi].height > block[bi].y and pickup[pi].y < block[bi].y + block[bi].height then
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
			pickup[pi].x = block[bi].x - pickup[pi].width
		elseif 	lowest == 2 then
			pickup[pi].x = block[bi].x + block[bi].width
		elseif 	lowest == 3 then
			pickup[pi].y = block[bi].y - pickup[pi].height
		elseif 	lowest == 4 then
			pickup[pi].y = block[bi].y + block[bi].height
		end

	end

end

function pickup.collidepickup(pi, bi)
	values = {
		pickup[pi].x + pickup[pi].width - pickup[bi].x,	--Left
		pickup[bi].x + pickup[bi].width - pickup[pi].x,	--Right
		pickup[pi].y + pickup[pi].height - pickup[bi].y,	--Top
		pickup[bi].y + pickup[bi].height - pickup[pi].y	--Bottom
	}

	--collision check
	if pickup[pi].x + pickup[pi].width > pickup[bi].x and pickup[pi].x < pickup[bi].x + pickup[bi].width and pickup[pi].y + pickup[pi].height > pickup[bi].y and pickup[pi].y < pickup[bi].y + pickup[bi].height then
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
			pickup[pi].x = pickup[bi].x - pickup[pi].width
		elseif 	lowest == 2 then
			pickup[pi].x = pickup[bi].x + pickup[bi].width
		elseif 	lowest == 3 then
			pickup[pi].y = pickup[bi].y - pickup[pi].height
		elseif 	lowest == 4 then
			pickup[pi].y = pickup[bi].y + pickup[bi].height
		end

	end
end
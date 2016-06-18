game ={} -- an object used to handle data in main, instead of using global variables.
game.running = false
game.started = false
game.playtime = 0

function game.init()
	math.randomseed(os.time()) -- New seed because math.random sucks shittakke mushrooooms
	love.window.setMode(settings.windowwidth, settings.windowheight) -- We can change the window properties in the settings.
	love.window.setTitle(settings.title) -- of course, we need a title
	menu.button.new(settings.windowwidth/2 - 50,settings.windowheight/2-15,100,30,"Start Game", menu.commands.start)
	love.mouse.setVisible(false) -- Removes the mouse so we can see the cursor.
	love.mouse.setGrabbed(true)
	love.graphics.setBackgroundColor(30,30,30)
end


function game.start()
	block.reset() -- resets the block handler. This will call block.remove and then add any default blocks.
	game.running = true
	game.started = true
end


function game.pause()
	game.running =  false
end


function game.unpause()
	game.running = true
end


function game.togglepause()
	if game.running then
		game.pause()
	else
		game.unpause()
	end
end


function game.clamp()
	player.clamp()
end


function game.updatedt(dt)
	game.dt = dt
	if game.started then
		game.playtime = game.playtime + dt
	end
	game.fps = love.timer.getFPS()
end


function game.printstats()
	love.graphics.setColor(255,255,255)
	love.graphics.print(
		'FPS: '..game.fps..
		'\nHP: '..player.health..
		'/'..player.maxhealth..
		'\nScore: '..player.score..
		'\nWave: '..enemy.spawn.currentwave..
		'\nMatter: '..math.floor(player.matter)..
		'\nWeapon: '..player.equippedWeapon..
		'\nAmmo: '..player.weapons[player.equippedIndex].ammo..
		'\nSpeed: '..player.speed
		 ,15,15)
end


function game.keypressed(key)
	if key == settings.keys.start then --self explanatory?
		if game.started == false then
			game.start()
		end
	end
	if key == settings.keys.pause then --self explanatory?
		game.togglepause()
	end
end


function love.keypressed( key ) -- called by love.
	game.keypressed(key)
	player.keypressed(key)
end


function love.mousepressed(x ,y, button, istouch) -- called by love
	if game.started then
		player.mousepressed(x, y, button, istouch)
	else
		menu.mousepressed(x, y, button, istouch)
	end
end

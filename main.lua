
require('settings')
require('game')
require('player')
require('enemy')
require('block')

require('pickup')
require('util')
require('projectile')
require('weapon')
require('menu')

function love.load(arg) -- Load the level
	game.init()

end

function love.update(dt)
	if game.started then
		if game.running then
			player.update(dt) -- updates the player
			enemy.updateAll(dt) -- updates each enemy
			projectile.updateAll(dt) -- updates each projectile
			pickup.updateAll(dt) -- updates each pickup
			enemy.spawn.update(dt)
			game.clamp()
		end
	else
		menu.update()
	end
	game.updatedt(dt)
end

function love.draw()

	--draw all of everything
	if game.started then
		block.drawAll()
		pickup.drawAll()
		player.draw()
		projectile.drawAll()
		enemy.drawAll()
		cursor.draw()
		game.printstats()
	else
		menu.draw()
	end
	

end
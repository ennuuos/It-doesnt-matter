util = {}
util.root2 = math.sqrt(2)

util.math = {}

function util.clamp(n, low, high) return math.min(math.max(n, low), high) end
function util.clamplow(n, low) return math.max(n, low) end
function util.clamphigh(n, high) return math.min(n, high) end
function util.clamprectangle(x, y, w, h ,lx, hx, ly, hy) return math.min(math.max(x, lx), hx - w), math.min(math.max(y, ly), hy - h) end
function util.distance(xa, ya, xb, yb) return math.sqrt(math.pow(xa - xb, 2) + math.pow(ya - yb, 2)) end
function util.diffxy(xa, ya, xb, yb)  return xb - xa, yb - ya end
function util.modarg(x, y) if x==0 then return y else return util.distance(0,0,x,y), math.atan(y/x) end end
function util.cartesian(mod, arg) return mod * math.cos(arg), mod * math.sin(arg) end

function util.normalize(x, y) return x/util.distance(0,0,x,y),y/util.distance(0,0,x,y) end
function util.collides(x1, y1, w1, h1, x2, y2, w2, h2) return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1 end

function util.contains(x, y, rx, ry, rw, rh) return rx < x and x < rx + rw and ry < y and y < ry + rh end

function util.randcol() return love.graphics.setColor(math.random(255), math.random(255), math.random(255)) end

function util.distptrect(x, y, rx, ry, rw, rh)
	if rx < x and x < rx + rw then
		xbetween = true
	else
		xbetween = false
	end

	if x < rx then
		xside = false
	end
	if rx + rw < x then
		xside = true
	end

	if ry < y and y < ry + rh then
		ybetween = true
	else
		ybetween = false
	end

	if y < ry then
		yside = false
	end
	if ry + rh < y then
		yside = true
	end

	if xbetween then
		if yside then
			distance = y - (ry + rh)
		else
			distance = ry - y
		end
	elseif ybetween then
		if xside then
			distance = x - (rx + rw)
		else
			distance = rx - x
		end
	else
		if xside and yside then
			distance = util.distance(x, y, rx + rw, ry + rh)
		elseif xside then
			distance = util.distance(x, y, rx + rw, ry)
		elseif yside then
			distance = util.distance(x, y, rx, ry + rh)
		else
			distance = util.distance(x, y, rx, ry)
		end
	end

	return distance
end	
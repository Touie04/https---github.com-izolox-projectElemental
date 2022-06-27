local module = {}

function module:lerp(a, b, c)
	return a + (b - a) * c
end

function module:quadBezier(t, p0, p1, p2)
	local l1 = module:lerp(p0, p1, t)
	local l2 = module:lerp(p1, p2, t)
	local quad = module:lerp(l1, l2, t)
	return quad
end

function module:cubicBezier(t, p0, p1, p2, p3,p4)
	local l1 = module:lerp(p0, p1, t)
	local l2 = module:lerp(p1, p2, t)
	local l3 = module:lerp(p2, p3, t)
	local l4 = module:lerp(p3,p4,t)
	local a = module:lerp(l1, l2, t)
	local b = module:lerp(l2, l3, t)
	local c = module:lerp(l3,l4,t)
	local cubic = module:lerp(a, b, t)
	local cubic2 = module:lerp(b, c, t)
	return module:lerp(cubic,cubic2,t)
end


function module:BuildCurve(CurveType,StartP,EndP)
	if not StartP   then
	
	end
end
	return module
	

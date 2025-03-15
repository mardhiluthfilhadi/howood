-- 2D Vector functions library for Lua
-- Using standard math library and LÖVE2D's love.math when needed

local Vec_MT = {}
Vec_MT.__index = Vec_MT

local function new(x,y)
    return setmetatable({x=x or 0, y=y or x or 0}, Vec_MT)
end

function Vec_MT.clone(v, dst)
    dst = dst or new()
    dst.x,dst.y = v.x,v.y
    return dst
end

function Vec_MT.add(v1, v2, dst)
    dst = dst or new()
    dst.x,dst.y = v1.x + v2.x, v1.y + v2.y

    return dst
end

function Vec_MT.sub(v1, v2, dst)
    dst = dst or new()
    dst.x,dst.y = v1.x - v2.x, v1.y - v2.y

    return dst
end

function Vec_MT.mul(v1, scalar, dst)
    dst = dst or new()
    dst.x,dst.y = v1.x * scalar, v1.y * scalar

    return dst
end

function Vec_MT.div(v1, scalar, dst)
    assert(scalar ~= 0, "Division by zero")
    dst = dst or new()
    dst.x,dst.y = v1.x / scalar, v1.y / scalar

    return dst
end

-- Basic operations
function Vec_MT.__add(v1, v2)
    return v1:add(v2)
end

function Vec_MT.__sub(v1, v2)
    return v1:sub(v2)
end

function Vec_MT.__mul(v, scalar)
    return v:mul(scalar)
end

function Vec_MT.__div(v, scalar)
    assert(scalar ~= 0, "Division by zero")
    return v:div(scalar)
end

function Vec_MT.negate(v, dst)
    dst = dst or new()
    dst.x,dst.y = -v.x, -v.y
    return dst
end

-- Magnitude operations
function Vec_MT.length(v)
    return math.sqrt(v.x * v.x + v.y * v.y)
end

function Vec_MT.set_length(v, len)
    local angle = v:angle()
    v.x = math.cos(angle)*len
    v.y = math.sin(angle)*len

    return v
end

function Vec_MT.length_squared(v)
    return v.x * v.x + v.y * v.y
end

function Vec_MT.distance(v1, v2)
    local dx, dy = v1.x - v2.x, v1.y - v2.y
    return math.sqrt(dx * dx + dy * dy)
end

function Vec_MT.distance_squared(v1, v2)
    local dx, dy = v1.x - v2.x, v1.y - v2.y
    return dx * dx + dy * dy
end

function Vec_MT.normalize(v, dst)
    dst = dst or new()
    local len = v:length()
    if len > 0.0001 then
        dst.x,dst.y = v.x / len, v.y / len
    end
    return dst
end

-- Products
function Vec_MT.dot(v1, v2)
    return v1.x * v2.x + v1.y * v2.y
end

function Vec_MT.cross(v1, v2)
    -- For 2D vectors, cross product is a scalar representing the z component
    return v1.x * v2.y - v1.y * v2.x
end

-- Transformations
function Vec_MT.reflect(v, normal, dst)
    dst = dst or new()
    
    local normaled = normal:normalize()
    local dot2 = 2 * v:dot(normaled)

    dst.x = v.x - dot2 * normaled.x
    dst.y = v.y - dot2 * normaled.y
    return dst
end

function Vec_MT.project(v, onto)
    local normalized = onto:normalize()
    local dot_product = v:dot(normalized)
    return normalized * dot_product
end

function Vec_MT.reject(v, from)
    local projection = v:project(from)
    return v - projection
end

function Vec_MT.rotate(v, angle, dst)
    dst = dst or new()
    
    local cos_angle = math.cos(angle)
    local sin_angle = math.sin(angle)

    dst.x = v.x * cos_angle - v.y * sin_angle
    dst.y = v.x * sin_angle + v.y * cos_angle

    return dst
end

function Vec_MT.rotate_around(v, center, angle)
    -- Rotate a vector around a center point
    local t = v - center
    local r = t:rotate(angle)
    return r + center
end

function Vec_MT.look_at(eye, target)
    local delta = target - eye
    local direction = delta:normalize()
    -- In 2D, we don't need a full matrix, just the angle
    return math.atan2(direction.y, direction.x)
end

-- Interpolation
function Vec_MT.lerp(v1, v2, t, dst)
    dst = dst or new()
    
    t = math.max(0, math.min(1, t))
    
    dst.x = v1.x + (v2.x - v1.x) * t
    dst.y = v1.y + (v2.y - v1.y) * t
end

function Vec_MT.slerp(v1, v2, t)
    -- Simplified for 2D
    local v1n,v2n = v1:normalize(),v2:normalize()
    local dot = v1n:dot(v2n)
    dot = math.max(-1, math.min(1, dot)) -- Clamp to avoid domain errors
    
    local theta = math.acos(dot) * t
    local relative = (v2 - (v1 * dot)):normalize()
    
    return  (v1 * math.cos(theta)) + (relative * math.sin(theta))
end

function Vec_MT.nlerp(v1, v2, t)
    return v1.lerp(v2, t):normalize()
end

-- Angular functions
function Vec_MT.angle(v)
    return math.atan2(v.y, v.x)
end

function Vec_MT.set_angle(v, angle)
    local len = v:length()
    v.x = math.cos(angle)*len
    v.y = math.sin(angle)*len

    return v
end

function Vec_MT.angle_between(v1, v2)
    local dot = v1:normalize():dot(v2:normalize())
    return math.acos(math.max(-1, math.min(1, dot)))
end

local function from_angle(angle, len, dst)
    dst = dst or new()
    dst.x = math.cos(angle) * (len or 1)
    dst.y = math.sin(angle) * (len or 1)

    return dst
end

-- Spatial functions
function Vec_MT.perpendicular(v, dst)
    dst = dst or new()
    dst.x, dst.y = -v.y, v.x

    return dst
end

function Vec_MT.closest_point_on_line(point, line_start, line_end)
    local line_vec  = line_end - line_start
    local point_vec = point - line_start

    local t = math.max(0, math.min(1, point_vec:dot(line_vec) / line_vec:length_squared()))

    return line_start + (line_vec * t)
end

function Vec_MT.point_to_line_distance(point, line_start, line_end)
    local closest = point:closest_point_on_line(line_start, line_end)
    return point:distance(closest)
end

function Vec_MT.line_intersection(a_start, a_end, b_start, b_end, dst)
    dst = dst or new()
    
    local dx1, dy1 = a_end.x - a_start.x, a_end.y - a_start.y
    local dx2, dy2 = b_end.x - b_start.x, b_end.y - b_start.y
    
    local denominator = dy2 * dx1 - dx2 * dy1
    
    if denominator == 0 then
        return nil -- Lines are parallel
    end
    
    local da = a_start.y - b_start.y
    local db = a_start.x - b_start.x
    
    local t1 = (dx2 * da - dy2 * db) / denominator
    local t2 = (dx1 * da - dy1 * db) / denominator
    
    if t1 >= 0 and t1 <= 1 and t2 >= 0 and t2 <= 1 then
        dst.x = a_start.x + t1 * dx1
        dst.y = a_start.y + t1 * dy1
    end
    
    return dst
end

-- Component-wise operations
function Vec_MT.min(v1, v2, dst)
    dst = dst or new()
    dst.x = math.min(v1.x, v2.x)
    dst.y = math.min(v1.y, v2.y)

    return dst
end

function Vec_MT.max(v1, v2, dst)
    dst = dst or new()
    dst.x = math.max(v1.x, v2.x)
    dst.y = math.max(v1.y, v2.y)

    return dst
end

function Vec_MT.clamp(v, min, max, dst)
    dst = dst or new()
    dst.x = math.max(min.x, math.min(max.x, v.x))
    dst.y = math.max(min.y, math.min(max.y, v.y))
    return dst
end

function Vec_MT.abs(v, dst)
    dst = dst or new()
    dst.x,dst.y = math.abs(v.x), math.abs(v.y)
    return dst
end

function Vec_MT.floor(v, dst)
    dst = dst or new()
    dst.x,dst.y = math.floor(v.x), math.floor(v.y)
    return dst
end

-- Utility functions
function Vec_MT.__eq(v1, v2, epsilon)
    epsilon = epsilon or 0.0001
    return math.abs(v1.x - v2.x) < epsilon and
           math.abs(v1.y - v2.y) < epsilon
end

function Vec_MT.to_string(v)
    return string.format("(%.3f, %.3f)", v.x, v.y)
end

function Vec_MT.to_polar(v)
    return v:length(), math.atan2(v.y, v.x)
end

return {new = new, from_angle = from_angle}

function AABB(obj1,obj2)
    return obj1.x < obj2.x + obj2.w and obj1.x + obj1.w > obj2.x and obj1.y < obj2.y + obj2.h and obj1.y + obj1.h > obj2.y
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
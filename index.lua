local instance = {}



instance.merge = function(table1,...)
    for _,table2 in ipairs({...}) do
        for key,value in pairs(table2) do
            if (type(key) == "number") then
                table.insert(table1,value)
            else
                table1[key] = value
            end
        end
    end
    return table1
end

instance.clone = function(org)
    return {unpack(org)}
end

instance.sort = function(_table, sort)
    local list = {}
    for k, v in pairs(_table) do
        table.insert(list, {index = k, value = v})
    end
    table.sort(
        list,
        sort or function(a, b)
                return #a.value > #b.value
            end
    )
    return list
end

instance.exists = function(theTable, value, column)
    for i, v in ipairs(theTable) do
        if (v == value or v[column] == value) then
            return true, i
        end
    end
    return false
end

instance.length = function(t)
    if type(t) ~= "table" then
        return false
    end
    local n = 0
    for _ in pairs(t) do
        n = n + 1
    end
    return n
end

instance.copy = function(tab, recursive)
    local ret = {}
    for key, value in pairs(tab) do
        if (type(value) == "table") and recursive then
            ret[key] = table.copy(value)
        else
            ret[key] = value
        end
    end
    return ret
end

instance.compare = function(a1, a2)
    if type(a1) == "table" and type(a2) == "table" then
        if instance.length(a1) == 0 and instance.length(a2) == 0 then
            return true
        elseif instance.length(a1) ~= instance.length(a2) then
            return false
        end

        for _, v in pairs(a1) do
            local v2 = a2[_]
            if type(v) == type(v2) then
                if type(v) == "table" and type(v2) == "table" then
                    if instance.length(v) ~= instance.length(v2) then
                        return false
                    end
                    if instance.length(v) > 0 and instance.length(v2) > 0 then
                        if not table.compare(v, v2) then
                            return false
                        end
                    end
                elseif type(v) == "string" or type(v) == "number" and type(v2) == "string" or type(v2) == "number" then
                    if v ~= v2 then
                        return false
                    end
                else
                    return false
                end
            else
                return false
            end
        end
        return true
    end
    return false
end

instance.deepmerge = function(from, to, options)
    options = type(options) == "table" and options or {allowNew = true}
    from = type(from) == "table" and from or {}
    to = type(to) == "table" and to or {}

    local result = from

    for key, value in pairs(to) do
        local from_type = type(from[key])
        local to_type = type(value)

        if
            (from_type == "nil" and not options.allowNew) and -- It's okay to merge previous nonexistent values if 'allowNew' is specified
                from_type ~= to_type
         then
            error(
                string.format(
                    "'table.deepmerge' failed to merge incompatible types from '%s' to '%s' on key '%s'",
                    from_type,
                    to_type,
                    key
                )
            )
        end

        if to_type == "table" then
            result[key] = table.deepmerge(from[key], value)
        else
            result[key] = to[key]
        end
    end

    return result
end

instance.elements = function(t, elemType, _aux)
    local elem = _aux or {}
    for k, v in pairs(t) do
        if (type(v) == "table") then
            instance.elements(v, elemType, elem)
        else
            if (type(v) == "userdata") then
                if elemType then
                    if (getElementType(v) == elemType) then
                        table.insert(elem, v)
                    end
                else
                    table.insert(elem, v)
                end
            end
        end
    end
    return elem
end

instance.empty = function(a)
    if type(a) ~= "table" then
        return false
    end

    return next(a) == nil
end

instance.fromString = function(str)
    if type(str) ~= "string" then
        return false
    end
    return (loadstring)("return " .. str)()
end

instance.toString = function(tab)
    if type(tab) ~= "table" then
        return false
    end
    local str = "{"
    for k, v in pairs(tab) do
        local kType = (type(k) == "string") and "'%s'" or (type(k) == "number") and "%s"
        if type(v) == "string" then
            str = string.format(str .. "[%s]='%s',", string.format(kType, k), v)
        elseif type(v) == "number" then
            str = string.format(str .. "[%s]=%s,", string.format(kType, k), v)
        elseif type(v) == "table" then
            str = string.format(str .. "[%s]=%s,", string.format(kType, k), instance.toString(v))
        end
    end
    return (str == "{" and "{}" or string.sub(str, 1, -2) .. "}")
end

instance.toStringArray = function(arr)
    if type(arr) ~= "table" then
        return false
    end
    local str = "{"
    for _, v in ipairs(arr) do
        if type(v) == "string" then
            str = string.format(str .. "'%s',", v)
        elseif type(v) == "number" then
            str = string.format(str .. "%s,", tonumber(v))
        elseif type(v) == "table" then
            str = string.format(str .. "%s,", instance.toString(v))
        end
    end
    return (str == "{" and "{}" or string.sub(str, 1, -2) .. "}")
end

instance.getRandomRows = function(table, rowsCount)
    if (#table > rowsCount) then
        local t = {}
        local random
        while (rowsCount > 0) do
            random = math.random(#table)
            if (not t[random]) then
                t[random] = random
                rowsCount = rowsCount - 1
            end
        end
        local rows = {}
        for i, v in pairs(t) do
            rows[#rows + 1] = v
        end
        return rows
    else
        return table
    end
end

instance.map = function(tab, depth, func, ...)
    for key, value in pairs(tab) do
        if (type(value) == "table" and depth ~= 0) then
            tab[key] = table.map(value, depth - 1, func, ...)
        else
            tab[key] = func(value, ...)
        end
    end
    return tab
end

instance.random = function(theTable)
    return theTable[math.random(#theTable)]
end

instance.removeValue = function(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            table.remove(tab, index)
            return index
        end
    end
    return false
end

instance.protect = function(tbl)
    return setmetatable(
        {},
        {
            __index = tbl, -- read access gets original table item
            __newindex = function(t, n, v)
                error("attempting to change constant " .. tostring(n) .. " to " .. tostring(v), 2)
            end -- __newindex, error protects from editing
        }
    )
end

instance.handler = function(t, f)
	local f = f
	assert(type(t) == 'table', 'check argument 1 table got '..tostring(t))
	assert(type(f) == 'function', 'check argument 2 function got '..tostring(f))

	local copy = {}
	for k,v in pairs(t) do
		copy[k] = v
		t[k] = nil
	end

	local mt = getmetatable(t) or {}

	mt.lock = true
	mt.copy = copy
	mt.__newindex = function(t, k, v)
		if not getmetatable(t).lock then
			local oldValue = getmetatable(t).copy[k]
			getmetatable(t).copy[k] = v
			return f(t, k, oldValue, v)
		end
	end,
	
	setmetatable(t,mt)

	for k,v in pairs(copy) do
		t[k] = v
	end

	getmetatable(t).lock = nil
	return true
end

module.exports("tablefy", instance)

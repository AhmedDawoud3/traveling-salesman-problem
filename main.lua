Vector = require "vector"
suit = require 'suit'
sqrt = math.sqrt

ALPHABIT = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U',
            'V', 'W', 'X', 'Y', 'Z'}

function love.load()

    -- Change The Title of the window
    love.window.setTitle("Traveling Salesman Problem")

    -- Change window resolution
    love.window.setMode(1280, 720)

    -- Fonts
    font0 = love.graphics.newFont("font0.ttf", 30)
    font1 = love.graphics.newFont("font1.ttf", 30)
    love.graphics.setFont(font1)

    -- Create a table to keap track of the cities
    cities = {}

    -- A table for the shortest tour
    bestTour = {}

    order = {}
    originalOrder = {}
    count = 0

    finished = false

    -- Values for print
    searched = 0
    availableToSearch = 0
    progress = 0
    ETA = 0
    Duration = 0
    bstDst = nil

    love.window.setVSync(0)

    solve = false

    -- a table we'll use to keep track of which keys have been pressed this
    -- frame, to get around the fact that Love's default callback won't let us
    -- test for input from within other functions
    love.keyboard.keysPressed = {}
    love.mouse.keysPressed = {}
    love.mouse.keysReleased = {}
end

function love.update(dt)
    -- Add a city at mouse position when the mouse is pressed
    if love.mouse.wasPressed(2) then
        table.insert(cities, Vector(love.mouse.getPosition()))
        order = shallowcopy(originalOrder)
        table.insert(order, #cities)
        bestTour = {}
        availableToSearch = fact(#cities)
        searched = 0
        bstDst = 999999999
        finished = false
        solve = false
        Duration = 0
        -- if #cities > 2 then
        --     bstDst = calcDistance(cities)
        -- end
        originalOrder = shallowcopy(order)
    end

    if suit.Button("Solve", {}, 15, 270, 120, 40).hit then
        solve = true
        -- Search(#cities - 1)
    end
    -- i = math.floor(math.random(#cities))
    -- j = math.floor(math.random(#cities))

    -- reset keys pressed
    love.keyboard.keysPressed = {}
    love.mouse.keysPressed = {}
    love.mouse.keysReleased = {}
    if solve then
        for _ = 0, 50000 do
            NextOrder()
        end
        if progress ~= 100 then
            Duration = Duration + dt
            if progress then
                ETA = Duration * availableToSearch / searched - Duration
            end
        end
    else
        ETA = 0
    end
end

function love.draw()
    love.graphics.clear(38 / 255, 38 / 255, 38 / 255)

    -- Display the available data
    love.graphics.setColor(186 / 255, 129 / 255, 98 / 255)
    love.graphics.setFont(font1)
    love.graphics.print("Solving for " .. #cities .. (#cities == 1 and " city" or " cities"), 10, 10)

    -- TEXT: Search
    love.graphics.print("Seached: ", 10, 50)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(font0)
    love.graphics.print(tostring(searched) .. " / " .. tostring(availableToSearch), 150, 50)
    
    -- TEXT: Progress
    love.graphics.setColor(186 / 255, 129 / 255, 98 / 255)
    love.graphics.setFont(font1)
    love.graphics.print("Progress: ", 10, 90)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(font0)
    love.graphics.print(string.sub(tostring(progress), 1, 4) .. "%", 160, 90)
    
    -- TEXT: Duration
    love.graphics.setColor(186 / 255, 129 / 255, 98 / 255)
    love.graphics.setFont(font1)
    love.graphics.print("Duration: ", 10, 140)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(font0)
    love.graphics.print(string.sub(tostring(Duration), 1, 5) .. " sec", 160, 140)
    
    -- TEXT: Estimated Time
    love.graphics.setColor(186 / 255, 129 / 255, 98 / 255)
    love.graphics.setFont(font1)
    love.graphics.print("ETA: ", 10, 180)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(font0)
    love.graphics.print(string.sub(tostring(ETA), 1, 5) .. " sec", 160, 180)
    
    -- TEXT: Shortest Distance
    love.graphics.setColor(186 / 255, 129 / 255, 98 / 255)
    love.graphics.setFont(font1)
    love.graphics.print("Best Distance: ", 10, 220)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(font0)
    love.graphics.print((bstDst and tostring(bstDst) or "N/A") .. (bstDst and " km" or ""), 230, 220)

    -- Visualize the cities as circles
    -- Loop through the cities and draw them
    love.graphics.setColor(1, 1, 1)
    for i, v in ipairs(cities) do
        love.graphics.circle("fill", v.x, v.y, 15)
    end
    for i, v in ipairs(bestTour) do
        if i ~= 1 then
            love.graphics.line(cities[v].x, cities[v].y, prvX, prvY)
        else
            love.graphics.line(cities[v].x, cities[v].y, cities[bestTour[#bestTour]].x, cities[bestTour[#bestTour]].y)
        end
        prvX, prvY = cities[v].x, cities[v].y
    end
    love.graphics.setColor(1, 1, 1, 0.1)
    for i, v in ipairs(order) do
        if i ~= 1 then
            love.graphics.line(cities[v].x, cities[v].y, prvX, prvY)
        else
            love.graphics.line(cities[v].x, cities[v].y, cities[order[#order]].x, cities[order[#order]].y)
        end
        prvX, prvY = cities[v].x, cities[v].y
    end

    -- Make a string to hold the numbers and concatinate the numbers to it
    string = "Current Etiration: "
    for i, v in ipairs(order) do
        string = string .. tostring(ALPHABIT[tonumber(v)])
    end
    -- Draw the string in the middle od the screen and draw the FPS
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(string, 0, 80, 1280, 'center')
    suit.draw()
end

-- A function to deep cope a table
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--[[
    A function to calculate the distance between two cities
]]
function calcDistance(points, order)
    local sum = 0
    for i = 1, #order - 1 do
        cityA = points[order[i]]
        cityB = points[order[i + 1]]
        sum = sum + LookUpDistance(cityA, cityB)
    end
    return sum
end

--[[
    function to look up the distance between all cities
]]
function LookUpDistance(pt1, pt2)
    return sqrt((pt1.x - pt2.x) ^ 2 + (pt1.y - pt2.y) ^ 2)
end

--[[
    defines a factorial function
]]
function fact(n)
    if n <= 0 then
        return 1
    else
        return n * fact(n - 1)
    end
end

function NextOrder()
    if finished then
        return
    end
    --[[
        Step 1: Find the largest x such that values[x]<values[x+1].
        (If there is no such x, values is the last permutation.)
    ]]
    for i = 1, #order - 1 do
        if order[i] < order[i + 1] then
            x = i
        end
    end

    if not x then
        finished = true
        return
    end

    --[[
        Step 2: Find the largest y such that P[x]<P[y].
    ]]
    y = -1
    for j = 1, #order do
        if order[x] < order[j] then
            y = j
        end
    end

    --[[
        Step 3: Swap P[x] and P[y].
    ]]
    order[x], order[y] = order[y], order[x]

    --[[
        Step 4: Reverse P[x+1 .. n].
    ]]
    endArray = ReverseTable(table.slice(order, x + 1))
    order = table.slice(order, 1, x)
    order = TableConcat(order, endArray)
    if calcDistance(cities, order) < bstDst then
        bstDst = calcDistance(cities, order)
        bestTour = shallowcopy(order)
    end
    searched = math.min(searched + 1, availableToSearch)
    progress = 100 * searched / availableToSearch
end

--[[
    A custom function that will let us test for individual keystrokes outside
    of the default `love.keypressed` callback, since we can't call that logic
    elsewhere by default.
]]
function love.mousepressed(x, y, key)
    love.mouse.keysPressed[key] = true
end

function love.mousereleased(x, y, key)
    love.mouse.keysReleased[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.mouse.wasPressed(key)
    return love.mouse.keysPressed[key]
end

function love.mouse.wasReleased(key)
    return love.mouse.keysReleased[key]
end

--[[
    Function to concatinate two table together
]]
function TableConcat(t1, t2)
    for i = 1, #t2 do
        table.insert(t1, t2[i])
    end
    return t1
end

--[[
    @Luiz Menezes
    https://stackoverflow.com/a/41943392/14137273
]]
function tprint(tbl, indent)
    if not indent then
        indent = 0
    end
    local toprint = string.rep(" ", indent) .. "{\r\n"
    indent = indent + 2
    for k, v in pairs(tbl) do
        toprint = toprint .. string.rep(" ", indent)
        if (type(k) == "number") then
            toprint = toprint .. "[" .. k .. "] = "
        elseif (type(k) == "string") then
            toprint = toprint .. k .. "= "
        end
        if (type(v) == "number") then
            toprint = toprint .. v .. ",\r\n"
        elseif (type(v) == "string") then
            toprint = toprint .. "\"" .. v .. "\",\r\n"
        elseif (type(v) == "table") then
            toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
        else
            toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
        end
    end
    toprint = toprint .. string.rep(" ", indent - 2) .. "}"
    return toprint
end

--[[
    @Advert
    https://stackoverflow.com/a/24823383/14137273
]]
function table.slice(tbl, first, last, step)
    local sliced = {}

    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced + 1] = tbl[i]
    end

    return sliced
end

--[[
    @Daniel Schuller
    https://gist.github.com/balaam/3122129
]]
function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

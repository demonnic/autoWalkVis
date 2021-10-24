autoWalkVis = autoWalkVis or {
  alpha = 255,
  roomsVisited = {},
  highScore = 0,
  defaultMax = 5,
  active = false,
  eventIDs = {},
}

local function getBadnessLevel(num, max)
  local halfWay = (max+1) / 2
  local stepSize = 255 / (halfWay - 1)
  local r,g,b = 0,255,0
  if num <= 1 then
    return r,g,b
  end
  if num > max then
    return 255,0,0
  end
  if num < halfWay then
    r = math.floor((num - 1) * stepSize)
    return r,g,b
  else
    r = 255
    g = 255 - math.floor((num - halfWay) * stepSize)
    return r,g,b
  end
end

local function getAlertGradientTable(max)
  local result = {}
  for i = 1, max do
    result[i] = {getBadnessLevel(i, max)}
  end
  return result
end

function autoWalkVis:start()
  self.badnessTable = getAlertGradientTable(self.defaultMax)
  self:clearHighlights()
  self.roomsVisited = {}
  self.highScore = 0
  self.active = true
  self:registerEvents()
  self:roomVisited(getPlayerRoom())
end

function autoWalkVis:stop(clear)
  self.active = false
  if clear then
    self:clearHighlights()
  end
  self:unregisterEvents()
end

function autoWalkVis:registerEvents()
  self:unregisterEvents()
  local IDs = {}
  local info = function()
    local roomNum = tonumber(gmcp.Room.Info.num)
    self:roomVisited(roomNum)
  end
  local stopped = function()
    self:stop(false)
  end
  IDs.roomInfo = registerAnonymousEventHandler("gmcp.Room.Info", info)
  IDs.demonWalkerStopped = registerAnonymousEventHandler("demonwalker.finished", stopped)
end

function autoWalkVis:unregisterEvents()
  for _,ID in pairs(self.eventIDs) do
    killAnonymousEventHandler(ID)
  end
  self.eventIDs = {}
end

function autoWalkVis:resetGradientAndHighlights()
  self.badnessTable = getAlertGradientTable(self.highScore)
  self:clearHighlights()
  for roomID, timesVisited in pairs(self.roomsVisited) do
    self:highlightRoom(roomID, timesVisited)
  end
end

function autoWalkVis:clearHighlights()
  for roomID,_ in pairs(self.roomsVisited) do
    unHighlightRoom(roomID)
  end
end

function autoWalkVis:roomVisited(roomID)
  if not self.active or self.lastVisited == roomID then
    return
  end
  self.lastVisited = roomID
  local timesVisited = self.roomsVisited[roomID] or 0
  timesVisited = timesVisited + 1
  self.roomsVisited[roomID] = timesVisited
  if timesVisited > self.highScore then
    self.highScore = timesVisited
  end
  self:highlightRoom(roomID, timesVisited)
end

function autoWalkVis:highlightRoom(roomID, timesVisited)
  local max = #self.badnessTable
  if timesVisited > max then
    timesVisited = max
  end
  local r,g,b = unpack(self.badnessTable[timesVisited])
  local alpha = self.alpha
  highlightRoom(roomID, r, g, b, r, g, b, 0.9, alpha, alpha)
end

function autoWalkVis:echo(msg)
  local header = "<yellow>(<green>Walk Visualizer<yellow>)<reset>: "
  cecho(header .. msg .. "\n")
end

function autoWalkVis:report()
  local ones, twoes, threes, fours, fives = {}, {}, {}, {}, {}
  local results = {ones, twoes, threes, fours, fives}
  local total_rooms = 0
  local total_moves = 0
  local most_visited = {}
  for roomID,times in pairs(self.roomsVisited) do
    total_rooms = total_rooms + 1
    total_moves = total_moves + times
    if times == self.highScore then
      most_visited[#most_visited+1] = roomID
    end
    if times >= 5 then
      results[5][roomID] = times
    else
      local dest = results[times]
      dest[#dest+1] = roomID
    end
  end
  local numOnes, numTwoes, numThrees, numFours, numFives = #ones, #twoes, #threes, #fours, table.size(fives)
  self:echo("Report for current visualization:")
  self:echo("")
  self:echo("Rooms visited     : " .. total_rooms)
  self:echo("Times moved       : " .. total_moves)
  self:echo("Visited 1 time    : " .. numOnes)
  self:echo("Visited 2 times   : " .. numTwoes)
  self:echo("Visited 3 times   : " .. numThrees)
  self:echo("Visited 4 times   : " .. numFours)
  self:echo("Visited 5+ times  : " .. numFives)
  self:echo("Most visited rooms: " .. table.concat(most_visited, ', '))
  self:echo("Most times visited: " .. self.highScore)
end
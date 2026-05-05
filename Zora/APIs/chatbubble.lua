--- Made by Zedorfska --- What the fuck is a "metatable?" ---
local chatBubble = {}
chatBubble.__index = chatBubble

function chatBubble:create(msg, startPos)
  local instance = setmetatable({}, self)
  
  instance.startPos = startPos
  instance.opacity = 0
  
  local bubble = models:newPart("chatbubble_" .. tostring(world.getTime()), "World")
  local camera = bubble:newPart("cam"):setParentType("CAMERA") -- TODO: 
  local text = camera:newText("bubble")
  text:setText(msg)
      :setAlignment("CENTER")
      :setBackground(true)
      :setSeeThrough(false)
      :setScale(0.33, 0.33, 0.33)
      :setOpacity(0)
      :setBackgroundColor(0, 0, 0, 0.5)
  
  instance.bubble = bubble
  instance.text = text
  instance.maxLifetime = 120
  instance.lifetime = instance.maxLifetime
  instance.fadeIn = 2
  instance.fadeOut = 40
  
  bubble:setPos(startPos.x * 16, startPos.y * 16, startPos.z * 16)

  table.insert(chatBubble, instance)

  return instance
end

function chatBubble:say(msg)
  playerPos = player:getPos()
  playerLookDir = player:getLookDir()

  local minDist = 1
  local maxDist = 1
  local spread = 2
  local depth = minDist + math.random() * (maxDist - minDist)
  local height = 0.5

  local bubblePos = playerPos + vec(
    playerLookDir.x * depth + (math.random() - 0.5) * spread,
    2 + (math.random() - 0.5) * height,
    playerLookDir.z * depth + (math.random() - 0.5) * spread
  )
  
  chatbubble:create(msg, bubblePos)
end

function chatBubble:say_bold(msg)
  chatBubble:say('{"bold":true,"text":"' .. msg .. '"}')
end

function events.tick()
  for i = #chatBubble, 1, -1 do
    local b = chatBubble[i]

    b.lifetime = b.lifetime - 1

    --local progress = b.lifetime / b.maxLifetime
    local t = 1 - (b.lifetime / b.maxLifetime)
    --local rise = (1 - progress) * 4
    local rise = (t ^ 0.1) * 8

    b.bubble:setPos(b.startPos.x * 16, b.startPos.y * 16 + rise, b.startPos.z * 16)

    -- Fade anims
    if b.lifetime > b.maxLifetime - b.fadeIn then
      local opacity = 1 - (b.lifetime - (b.maxLifetime - b.fadeIn)) / b.fadeIn
      b.text:setOpacity(opacity)
      b.text:setBackgroundColor(0, 0, 0, 0.5 * opacity)
    elseif b.lifetime <= b.fadeOut then
      local opacity = b.lifetime / b.fadeOut
      b.text:setOpacity(opacity)
      b.text:setBackgroundColor(0, 0, 0, 0.5 * opacity)
    else
      b.text:setOpacity(1)
      b.text:setBackgroundColor(0, 0, 0, 0.5)
    end

    if b.lifetime <= 0 then
      models:removeChild(b.bubble)
      table.remove(chatBubble, i)
    end
  end
end

return chatBubble

--- Made by Zedorfska --- What the fuck is a "metatable?" ---
local zed = {}
zed.__index = zed

function zed:new(value)
  local instance = setmetatable({}, self)
  instance.value = value
  log("Create new Zed with value " .. value)
  return instance
end

function zed:print_value()
  log("I am a Zed and my value is " .. self.value)
end

local aZed = zed:new(2)
aZed:print_value()
local secondZed = zed:new(3)

log()

logTable(zed)

--- --- --- --- --- ---

local chatBubble = {}
chatBubble.__index = chatBubble

function chatBubble:create(startPos)
  local instance = setmetatable({}, self)
  
  log("Created chatbubble")--
  instance.startPos = startPos
  instance.opacity = 0
  
  local bubble = models:newPart("chatbubble_" .. tostring(world.getTime()), "World")
  local camera = bubble:newPart("cam"):setParentType("CAMERA") -- TODO: 
  local text = camera:newText("bubble")
  text:setText("asdf")
      :setAlignment("CENTER")
      :setBackground(true)
      --:setBackgroundColor(0, 0, 0, 0.5)
      :setSeeThrough(false)
      :setScale(0.33, 0.33, 0.33)
      :setOpacity(100)
      :setBackgroundColor(0, 0, 0, 1)
  
  instance.bubble = bubble
  instance.text = text
  
  bubble:setPos(startPos.x * 16, startPos.y * 16, startPos.z * 16)

  return instance
end

specific_bubble = chatBubble:create(vec(-90, 64, -85))
specific_bubble.text:setText("sdfg")

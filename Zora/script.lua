runLater = require("APIs.runLater")
confetti = require("APIs.confetti")
log("Zora model")

nameplate.ALL:setText("Zora")
nameplate.ENTITY:setPos(0, 0.2, 0)

vanilla_model.PLAYER:setVisible(false)
vanilla_model.ARMOR:setVisible(false)
vanilla_model.HELMET_ITEM:setVisible(true)
vanilla_model.CAPE:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)

local chatBubbles = {}

function events.entity_init()
  -- Experimental: Hiding the Figura logo. From some random person in the Discord
  --[[local name = nameplate.ENTITY:getText() or player:getName()
  local height = 4
  local scale = 0.4
  nameplate.ENTITY:setVisible(false)
  local part = models:newPart("","CAMERA")
  local text = part:newText("")
  text:setText(name)
    :setAlignment("CENTER")
    :setScale(scale)
    :setBackground(true)
    :setPos(0,scale*(client.getTextHeight(name)-9),0)
  function events.tick()
    part:setPivot(0,height + (player:isCrouching() and 34.1 or 39.2),0)
    text:setOpacity(player:isCrouching() and 0.5 or 1)
    text:setSeeThrough(not player:isSneaking())
    part:setVisible(client.isHudEnabled())
  end]]

  local blockTex = textures["Particles.Block"]
  local dims = blockTex:getDimensions()
  confetti.registerSprite("block_flake", blockTex, vec(1, 1, dims.x, dims.y))
end

was_blocking = false

function events.tick()
  --=== Chat bubble tick logic ===--
  for i = #chatBubbles, 1, -1 do
    local bubble = chatBubbles[i]
    bubble.lifetime = bubble.lifetime - 1

    local progress = bubble.lifetime / bubble.totalLifetime
    local rise = (1 - progress) * 4

    bubble.root:setPos(
      bubble.startPos.x * 16,
      bubble.startPos.y * 16 + rise,
      bubble.startPos.z * 16
    )

    local FADE_IN = 2
    local FADE_OUT = 40

    if bubble.lifetime > bubble.totalLifetime - FADE_IN then
      local opacity = 1 - (bubble.lifetime - (bubble.totalLifetime - FADE_IN)) / FADE_IN
      bubble.task:setOpacity(opacity)
      bubble.task:setBackgroundColor(0, 0, 0, 0.5 * opacity)
    elseif bubble.lifetime <= FADE_OUT then
      local opacity = bubble.lifetime / FADE_OUT
      bubble.task:setOpacity(opacity)
      bubble.task:setBackgroundColor(0, 0, 0, 0.5 * opacity)
    else
      bubble.task:setOpacity(1)
      bubble.task:setBackgroundColor(0, 0, 0, 0.5)
    end

    if bubble.lifetime <= 0 then
      models:removeChild(bubble.root)
      table.remove(chatBubbles, i)
    end
  end 

  --=== Shield blocking ===--
  if player:isBlocking() and not was_blocking then
    sounds:playSound("Sounds.Generic_Shove_1", player:getPos())

    local pos = player:getPos()

    -- TODO: Make this work like chat bubbles probably
    local angle = math.random() * 2 * math.pi
    local radius = math.random() * 1.5
    local spawnPos = pos + vec(
      math.cos(angle) * radius,
      math.random() * 2,
      math.sin(angle) * radius
    )

    confetti.newParticle("block_flake", spawnPos, vec(0, 0, 0), {
      lifetime = 40,
      acceleration = vec(0, -0.001, 0),
      friction = 0.92,
      scaleOverTime = -0.005,
      scale = 0.5,
      rotationOverTime = vec(math.random(-3,3), math.random(-3,3), math.random(-3,3)),
      billboard = true,
    })
    was_blocking = true
  elseif not player:isBlocking() then
    was_blocking = false
  end
end

function events.render(delta, context)
  --code goes here
end


--===            ===--
--=== ANIMATIONS ===--
--===            ===--

--=== Shut eye on damage animation ===--
is_taking_damage = false
function events.damage()
  if not is_taking_damage then
    is_taking_damage = true
    models.model.root.Head.Eyes.Open:setVisible(false)
    models.model.root.Head.Eyes.Closed:setVisible(true)

    runLater(10, function()
      models.model.root.Head.Eyes.Open:setVisible(true)
      models.model.root.Head.Eyes.Closed:setVisible(false)
      is_taking_damage = false
    end)
  end
end


--===      ===--
--=== MISC ===--
--===      ===--

--=== Chat bubble spawn logic ===--
function events.chat_send_message(msg)
  message_type = "default"
  if msg:match"?$" then
    message_type = "question"
  end
  if msg == msg:upper() or msg:match"!$" then
    message_type = "exclamation"
  end

  local pos = player:getPos()
  local look = player:getLookDir()

  local minDist = 0.6
  local maxDist = 0.6
  local spread = 2
  local depth = minDist + math.random() * (maxDist - minDist)
  local height = 0.5

  local spawnPos = pos + vec(
    look.x * depth + (math.random() - 0.5) * spread,
    2.2 + (math.random() - 0.5) * height,
    look.z * depth + (math.random() - 0.5) * spread
  )

  -- fucked up bullshit
  local root = models:newPart("chatbubble_" .. tostring(world.getTime()), "World")
  local camPart = root:newPart("cam"):setParentType("CAMERA")

  local displayMsg = msg
  local displayScale = 0.33
  if msg:sub(-2) == "!!" then
    displayMsg = '{"bold":true,"text":"' .. msg .. '"}'
    displayScale = 0.5
  end
  if msg:sub(-2) == ".." or msg:sub(-3) == "..?" then
    displayMsg = '{"italic":true,"text":"' .. msg .. '"}'
    displayScale = 0.25
  end

  local task = camPart:newText("bubble")
  task:setText(displayMsg)
      :setAlignment("CENTER")
      :setBackground(true)
      :setBackgroundColor(0, 0, 0, 0.5)
      :setSeeThrough(false)
      :setScale(displayScale, displayScale, displayScale)
      :setOpacity(0)
      :setBackgroundColor(0, 0, 0, 0)

  root:setPos(
    spawnPos.x * 16,
    (spawnPos.y + 2.4) * 16,
    spawnPos.z * 16
  )

  table.insert(chatBubbles, {
    root = root,
    task = task,
    lifetime = 100,
    totalLifetime = 100,
    startPos = spawnPos,
  })
  
  if message_type == "default" then
    sounds:playSound("Sounds.Speak.Default", player:getPos())
  elseif message_type == "exclamation" then
    sounds:playSound("Sounds.Speak.Exclamation", player:getPos())
  else
    sounds:playSound("Sounds.Speak.Question", player:getPos())
  end
  
  return msg
end


--=== Play notification when mentioned ===--
function pings.playRingtone()
  sounds:playSound("Sounds.ringers3", player:getPos())
end

function events.chat_receive_message(raw, text)
  if not text:find("^{\"translate\":\"chat.type.text\",") then
    return
  end

  sender_name = raw:match("<(.-)>")
  if sender_name == client.getViewer():getName() then
    return
  end

  sanitised = raw:match(">(.+)")
  if sanitised:find("[Zz][Ee][Dd]") then
    pings.playRingtone()
  end
end

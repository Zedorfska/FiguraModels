-- Zora avatar by Zedorfska
-- This avatar does require modfying chat messages to be on.

-- List of APIs used below:
runLater = require("APIs.runLater")
confetti = require("APIs.confetti")
chatbubble = require("APIs.chatbubble")

nameplate.ALL:setText("Zora")
nameplate.ENTITY:setPos(0, 0.2, 0)

vanilla_model.PLAYER:setVisible(false)
vanilla_model.ARMOR:setVisible(false)
vanilla_model.HELMET_ITEM:setVisible(true)
vanilla_model.CAPE:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)

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
  local message_type = "default"
  if msg:match("?$") then
    chatbubble:say(msg)
    sounds:playSound("Sounds.Speak.Question", player:getPos())
  elseif msg == msg:upper() or msg:match("!$") then
    chatbubble:say_bold(msg)
    sounds:playSound("Sounds.Speak.Exclamation", player:getPos())
  else
    chatbubble:say(msg)
    sounds:playSound("Sounds.Speak.Default", player:getPos())
  end

  local modifier = msg:sub(1, 1)
  if modifier == ";" then
    local cleanMsg = msg:sub(2)
    return cleanMsg
  end
  return
end


--=== Play notification when mentioned ===--
function pings.playRingtone() -- Required outside due to chat_recieve_message() being clientside
  sounds:playSound("Sounds.ringers3", player:getPos())
end

function events.chat_receive_message(raw, text)
  if not player:isLoaded() then
    return
  end
  
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

-- Ziwa avatar by Zedorfska
-- This avatar does require modfying chat messages to be on.

-- List of APIs used below:
chatbubble = require("APIs.chatbubble")

nameplate.ALL:setText("pipi Siwa")
nameplate.ENTITY:setPos(0, 0.2, 0)

vanilla_model.PLAYER:setVisible(false)
vanilla_model.ARMOR:setVisible(false)
vanilla_model.HELMET_ITEM:setVisible(true)
vanilla_model.CAPE:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)

function events.entity_init()

end

function events.tick()

end

function events.render(delta, context)
  --code goes here
end


--===            ===--
--=== ANIMATIONS ===--
--===            ===--



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
  elseif modifier == "/" then
    return msg
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

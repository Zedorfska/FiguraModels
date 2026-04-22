local runLater = require("runLater")
--log("Zora model")

--hide vanilla model
vanilla_model.PLAYER:setVisible(false)

--hide vanilla armor model
vanilla_model.ARMOR:setVisible(false)
--re-enable the helmet item
vanilla_model.HELMET_ITEM:setVisible(true)

--hide vanilla cape model
vanilla_model.CAPE:setVisible(false)

--hide vanilla elytra model
vanilla_model.ELYTRA:setVisible(false)

--entity init event, used for when the avatar entity is loaded for the first time
function events.entity_init()
  --player functions goes here
end

--tick event, called 20 times per second
function events.tick()
  --code goes here
end

--render event, called every time your avatar is rendered
--it have two arguments, "delta" and "context"
--"delta" is the percentage between the last and the next tick (as a decimal value, 0.0 to 1.0)
--"context" is a string that tells from where this render event was called (the paperdoll, gui, player render, first person)
function events.render(delta, context)
  --code goes here
end

-- Shut eye on damage animation
function events.damage()
  models.model.root.Head.Eyes.Open:setVisible(false)
  models.model.root.Head.Eyes.Closed:setVisible(true)
  
  runLater(20, function()
    models.model.root.Head.Eyes.Open:setVisible(true)
    models.model.root.Head.Eyes.Closed:setVisible(false)
  end)  
end

-- Play notification when mentioned
function events.chat_receive_message(raw, text)
  if raw:find("%[lua%]") or raw:find("%[Debug%]") or (not raw:find("<") and not raw:find(">")) then
    return
  end

  -- TODO: Make work for other usernames
  -- TODO: Check that a player containing "zed" isnt sending the message
  --log(client.getViewer())
  if raw:find("<Zedorf>") then
    return
  end

  sanitised = raw:match(">(.+)")

  if sanitised:find("zed") or sanitised:find("Zed") then
    sounds:playSound("lawnotify", player:getPos())
    log("Message with Zed")
  end
end

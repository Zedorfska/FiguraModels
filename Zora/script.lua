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

-- Play notification when mentioned
function events.chat_receive_message(raw, text)
  if not text:find("^{\"translate\":\"chat.type.text\",") then
    return
  end

  sender_name = raw:match("<(.-)>")
  if sender_name == client.getViewer():getName() then
    return
  end

  sanitised = raw:match(">(.+)")
  if sanitised:find("zed") or sanitised:find("Zed") then
    sounds:playSound("ringers3", player:getPos())
  end
end

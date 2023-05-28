replacer = {}
replacer.blacklist = {}

-- playing with tnt and creative building are usually contradictory
-- (except when doing large-scale landscaping in singleplayer)
replacer.blacklist["tnt:boom"] = true
replacer.blacklist["tnt:gunpowder"] = true
replacer.blacklist["tnt:gunpowder_burning"] = true
replacer.blacklist["tnt:tnt"] = true

-- prevent accidental replacement of your protector
replacer.blacklist["protector:protect"] = true
replacer.blacklist["protector:protect2"] = true

-- adds a tool for inspecting nodes and entities
dofile(minetest.get_modpath("replacer") .. "/inspect.lua")

-- add support for HUD messenges
dofile(minetest.get_modpath("replacer") .. "/hud.lua")

-- Automatic conversions of nodes to be placed by placer such as selecting dirt with grass but placing dirt
replacer.conversions = {}

replacer.add_conversion = function(selected_node_name, placed_node_name)
    replacer.conversions[selected_node_name] = placed_node_name
end
-- biome top nodes to be converted
replacer.add_conversion("default:dirt_with_grass", "default:dirt")
replacer.add_conversion("default:dirt_with_grass_footsteps", "default:dirt")
replacer.add_conversion("default:dirt_with_rainforest_litter", "default:dirt")
replacer.add_conversion("default:dirt_with_snow", "default:dirt")
replacer.add_conversion("default:dirt_with_coniferous_litter", "default:dirt")
replacer.add_conversion("default:dry_dirt_with_dry_grass", "default:dry_dirt")
replacer.add_conversion("default:permafrost_with_stones", "default:permafrost")
replacer.add_conversion("default:permafrost_with_moss", "default:permafrost")
-- biome decor nodes to be converted
replacer.add_conversion("default:grass_2", "default:grass_1")
replacer.add_conversion("default:grass_3", "default:grass_1")
replacer.add_conversion("default:grass_4", "default:grass_1")
replacer.add_conversion("default:grass_5", "default:grass_1")
replacer.add_conversion("default:dry_grass_2", "default:dry_grass_1")
replacer.add_conversion("default:dry_grass_3", "default:dry_grass_1")
replacer.add_conversion("default:dry_grass_4", "default:dry_grass_1")
replacer.add_conversion("default:dry_grass_5", "default:dry_grass_1")
replacer.add_conversion("default:fern_2", "default:fern_1")
replacer.add_conversion("default:marram_grass_2", "default:marram_grass_1")
replacer.add_conversion("default:marram_grass_3", "default:marram_grass_1")

-- Tool
minetest.register_tool("replacer:replacer", {
   description = "Node replacement tool",
   inventory_image = "replacer_replacer.png",
   use_texture_alpha = true,
   stack_max = 1, -- it has to store information - thus only one can be stacked
   liquids_pointable = true, -- it is ok to paint in/with water
   node_placement_prediction = nil,
   metadata = "default:dirt", -- default replacement: common dirt
   on_place = function(itemstack, placer, pointed_thing)
      if (placer == nil or pointed_thing == nil) then
         return itemstack -- nothing consumed
      end
      if( pointed_thing.type ~= "node" ) then
         -- minetest.chat_send_player( name, "  Error: No node selected.");
          replacer.set_hud(name, "  Error: No node selected.");
          return nil;
      end
      local name = placer:get_player_name()
      local mode = replacer.get_mode(placer)
      local keys = placer:get_player_control()
      if mode == "legacy" then
         if( not( keys["sneak"] )) then
            return replacer.replace( itemstack, placer, pointed_thing, 0  );
        end
        return replacer.set_replacement_node(itemstack, placer, pointed_thing)
      end
      -- just place the stored node if now new one is to be selected
      if (not (keys["sneak"])) then

         return replacer.replace(itemstack, placer, pointed_thing, 0)
      else
         return replacer.replace(itemstack, placer, pointed_thing, above)
      end
   end,

   on_use = function(itemstack, user, pointed_thing)
      local name = user:get_player_name()
      local keys = user:get_player_control()
      local mode = replacer.get_mode(user)
      if (pointed_thing.type ~= "node") then
         replacer.set_hud(name, "  Error: No node selected.")
         return nil
      end
      if mode == "legacy" then 
         return replacer.replace( itemstack, user, pointed_thing, above );
      end
      if (keys["sneak"]) then
         return replacer.set_replacement_node(itemstack, user, pointed_thing)
      else
         return replacer.replace(itemstack, user, pointed_thing, above)
      end
   end
})

replacer.set_replacement_node = function(itemstack, user, pointed_thing)
    local item = itemstack:to_table()
    local name = user:get_player_name()
    local pos  = minetest.get_pointed_thing_position(pointed_thing, under)
    local node = minetest.get_node_or_nil(pos)
    local metadata = "default:dirt 0 0";
    if (node ~= nil and node.name) then
        local node_name = node.name
        -- check for automatic conversions
        if replacer.conversions[node_name] ~= nil then
            node_name = replacer.conversions[node_name]
        end

        if minetest.get_node_group(node_name, "not_in_replacer") ~= 0 then
            return replacer.set_hud(name, "Error: " .. node_name .. " cannot be selected")
        end
        metadata = node_name..' '..node.param1..' '..node.param2;
    end
    itemstack:set_metadata(metadata)
    --minetest.chat_send_player( name, "Node replacement tool set to: '"..metadata.."'.");
    replacer.set_hud(name, "Node replacement tool set to: '"..metadata.."'.");
    return itemstack; -- nothing consumed but data changed
end

replacer.replace = function(itemstack, user, pointed_thing, mode)

    if (user == nil or pointed_thing == nil) then
        return nil
    end
    local name = user:get_player_name()

    if (pointed_thing.type ~= "node") then
        replacer.set_hud(name, "  Error: No node.")
        return nil
    end

    local pos = minetest.get_pointed_thing_position(pointed_thing, mode)
    local node = minetest.get_node_or_nil(pos)
    if (node == nil) then
        replacer.set_hud(name, "Error: Target node not yet loaded. Please wait a moment for the server to catch up.")
        return nil
    end

    local item = itemstack:to_table()

    -- make sure it is defined
    if (not (item["metadata"]) or item["metadata"] == "") then
        item["metadata"] = "default:dirt 0 0"
    end

    -- regain information about nodename, param1 and param2
    local daten = item["metadata"]:split(" ")
    -- the old format stored only the node name
    if (#daten < 3) then
        daten[2] = 0
        daten[3] = 0
    end

    -- if someone else owns that node then we can not change it
    if replacer.node_is_owned(pos, user) then
        return nil
    end

    if (node.name and node.name ~= "" and replacer.blacklist[node.name]) then
        replacer.set_hud(name, "Replacing blocks of the type '" .. (node.name or "?") ..
            "' is not allowed on this server. Replacement failed.")
        return nil
    end

    if (replacer.blacklist[daten[1]]) then
        replacer.set_hud(name, "Placing blocks of the type '" .. (daten[1] or "?") ..
            "' with the replacer is not allowed on this server. Replacement failed.")
        return nil
    end

    -- do not replace if pointed node is same as current replacement node unless orientation is changed
    if (node.name == daten[1]) then
        -- the node itself remains the same, but the orientation was changed
        if (node.param1 ~= daten[2] or node.param2 ~= daten[3]) then
            minetest.add_node(pos, {
                name = node.name,
                param1 = daten[2],
                param2 = daten[3]
            })
        end
        return nil
     -- do not replace nodes that would be converted to current replacement node if selected by replacer
    elseif (replacer.conversions[node.name] == daten[1]) then
        -- if orientation is changed then maintain pointed node type
        if (node.param1 ~= daten[2] or node.param2 ~= daten[3]) then
            minetest.add_node(pos, {
                name = node.name,
                param1 = daten[2],
                param2 = daten[3]
            })
        end
        return nil
    end

    -- Do not replace node that has inventory that is not empty
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local inv_lists = inv:get_lists()
    for listname, inv_list in pairs(inv_lists) do
        if (inv:is_empty(listname) == false) then
            replacer.set_hud(name,
                "Error: Replacing a node containing items in inventory is not allowed. Replacement failed"
            )
            return nil
        end
    end

    -- in survival mode, the player has to provide the node he wants to place
    if (not (minetest.settings:get_bool("creative_mode")) and not (minetest.check_player_privs(name, {
        creative = true
    }))) then
        -- does the player carry at least one of the desired nodes with him?
        if (not (user:get_inventory():contains_item("main", daten[1]))) then
            replacer.set_hud(name, "You have no further '" .. (daten[1] or "?") .. "'. Replacement failed.")
            return nil
        end

        -- give the player the item by simulating digging if possible
        if (node.name ~= "air" and node.name ~= "ignore" and node.name ~= "default:lava_source" and node.name ~=
            "default:lava_flowing" and node.name ~= "default:river_water_source" and node.name ~=
            "default:river_water_flowing" and node.name ~= "default:water_source" and node.name ~=
            "default:water_flowing") then

            minetest.node_dig(pos, node, user)

            local digged_node = minetest.get_node_or_nil(pos)
            if (not (digged_node) or digged_node.name == node.name) then

                replacer.set_hud(name,
                    "Replacing '" .. (node.name or "air") .. "' with '" .. (item["metadata"] or "?") ..
                        "' failed.\nUnable to remove old node.")
                return nil
            end

        end

        -- consume the item
        user:get_inventory():remove_item("main", daten[1] .. " 1")

    end

    minetest.add_node(pos, {
        name = daten[1],
        param1 = daten[2],
        param2 = daten[3]
    })
    return nil -- no item shall be removed from inventory
end

-- protection checking from Vanessa Ezekowitz' homedecor mod
-- see http://forum.minetest.net/viewtopic.php?pid=26061 or https://github.com/VanessaE/homedecor for details!

replacer.node_is_owned = function(pos, placer)
    if (not (placer) or not (pos)) then
        return true
    end
    local pname = placer:get_player_name()
    if (type(minetest.is_protected) == "function") then
        local res = minetest.is_protected(pos, pname)
        if (res) then

            replacer.set_hud(pname, "Cannot replace node. It is protected.")
        end
        return res
    end

    local ownername = false
    if type(IsPlayerNodeOwner) == "function" then -- node_ownership mod
        if HasOwner(pos, placer) then -- returns true if the node is owned
            if not IsPlayerNodeOwner(pos, pname) then
                if type(getLastOwner) == "function" then -- ...is an old version
                    ownername = getLastOwner(pos)
                elseif type(GetNodeOwnerName) == "function" then -- ...is a recent version
                    ownername = GetNodeOwnerName(pos)
                else
                    ownername = "someone"
                end
            end
        end

    elseif type(isprotect) == "function" then -- glomie's protection mod
        if not isprotect(5, pos, placer) then
            ownername = "someone"
        end
    end

    if ownername ~= false then
        minetest.chat_send_player(pname, "Sorry, " .. ownername .. " owns that spot.")
        return true
    else
        return false
    end
end

-- Handle mode setting/getting
replacer.set_mode = function(player, mode_name)
   if mode_name ~= "legacy" and mode_name ~= "paint" then
      return replacer.set_hud(player:get_player_name(), "Invalid replacer mode!")
   end   
   local meta = player:get_meta()
   meta:set_string('replacer_mode', mode_name)
   replacer.set_hud(player:get_player_name(), "Replacer set to " .. mode_name .. " mode.")
end

replacer.get_mode = function(player)
   local meta = player:get_meta()
   local mode_name = meta:get_string("replacer_mode")
   if mode_name == nil then
      mode_name = "paint"
      replacer.set_mode(player, mode_name)
   end
   return mode_name
end
      
-- Chat command to set mode
minetest.register_chatcommand("replacer_mode", {
   params = "<mode_name>",
   description = "Sets replacer mode. Modes include 'legacy' or 'paint'",
   func = function(name, param)
      if param ~= "legacy" and param ~= "paint" then
         return minetest.chat_send_player(name, "Invalid replacer mode: 'legacy' or 'paint'")
      end
      replacer.set_mode(minetest.get_player_by_name(name), param)
   end
})

-- Crafting
minetest.register_craft({
    output = 'replacer:replacer',
    recipe = {{'default:chest', '', ''}, {'', 'default:stick', ''}, {'', '', 'default:chest'}}
})


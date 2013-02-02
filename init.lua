
-- adds a function to check ownership of a node; taken from VanessaEs homedecor mod
dofile(minetest.get_modpath("replacer").."/check_owner.lua");


minetest.register_tool( "replacer:replacer",
{
    description = "Node replacement tool",
    groups = {}, 
    inventory_image = "default_tool_steelaxe.png", --TODO
    wield_image = "",
    wield_scale = {x=1,y=1,z=1},
    stack_max = 1, -- it has to store information - thus only one can be stacked
    liquids_pointable = true, -- it is ok to painit in/with water
    -- TODO
    tool_capabilities = {
        full_punch_interval = 1.0,
        max_drop_level=0,
        groupcaps={
            -- For example:
            fleshy={times={[2]=0.80, [3]=0.40}, maxwear=0.05, maxlevel=1},
            snappy={times={[2]=0.80, [3]=0.40}, maxwear=0.05, maxlevel=1},
            choppy={times={[3]=0.90}, maxwear=0.05, maxlevel=0}
        }
    },
    node_placement_prediction = nil,
    metadata = "default:dirt", -- default replacement: common dirt

    on_place = function(itemstack, placer, pointed_thing)

       if( placer == nil or pointed_thing == nil) then
          return itemstack; -- nothing consumed
       end
       local name = placer:get_player_name();
       --minetest.chat_send_player( name, "You PLACED this on "..minetest.serialize( pointed_thing )..".");
 
       if( pointed_thing.type ~= "node" ) then
          minetest.chat_send_player( name, "  Error: No node selected.");
          return nil;
       end

       local pos  = minetest.get_pointed_thing_position( pointed_thing, above );
       local node = minetest.env:get_node_or_nil( pos );
       
       --minetest.chat_send_player( name, "  Target node: "..minetest.serialize( node ).." at pos "..minetest.serialize( pos ).."."); 

       local item = itemstack:to_table();
       -- make sure metadata is always set
       if( node ~= nil and node.name ) then
          item[ "metadata" ] = node.name;
       else
          item[ "metadata" ] = "default:dirt";
       end
       itemstack:replace( item );

       minetest.chat_send_player( name, "Node replacement tool set to: '"..( node.name or "?").."'."); 

       return itemstack; -- nothing consumed but data changed
    end,
     

--    on_drop = func(itemstack, dropper, pos),

    on_use = function(itemstack, user, pointed_thing)

       if( user == nil or pointed_thing == nil) then
          return nil;
       end
       local name = user:get_player_name();
       --minetest.chat_send_player( name, "You USED this on "..minetest.serialize( pointed_thing )..".");
 
       if( pointed_thing.type ~= "node" ) then
          minetest.chat_send_player( name, "  Error: No node.");
          return nil;
       end

       local pos  = minetest.get_pointed_thing_position( pointed_thing, above );
       local node = minetest.env:get_node_or_nil( pos );
       
       --minetest.chat_send_player( name, "  Target node: "..minetest.serialize( node ).." at pos "..minetest.serialize( pos ).."."); 

       if( node == nil ) then

          minetest.chat_send_player( name, "Error: Target node not yet loaded. Please wait a moment for the server to catch up.");
          return nil;
       end


       local item = itemstack:to_table();

       -- do not replace if there is nothing to be done
       if( node.name == item[ "metadata"] ) then

          minetest.chat_send_player( name, "Node already is '"..( item[ "metadata"] or "?" ).."'. Nothing to do.");
          return nil;
       end

       -- if someone else owns that node then we can not change it
       if( replacer_homedecor_node_is_owned(pos, user)) then

          return nil;
       end
   

       -- in survival mode, the player has to provide the node he wants to be placed
       if( not(minetest.setting_getbool("creative_mode") )) then
 
          -- players usually don't carry dirt_with_grass around; it's safe to assume normal dirt here
          if( item["metadata"] == "default:dirt_with_grass" ) then
             item["metadata"] = "default:dirt";
          end

          -- does the player carry at least one of the desired nodes with him?
          if( not( user:get_inventory():contains_item("main", item["metadata"]))) then
 

             minetest.chat_send_player( name, "You have no further '"..( item[ "metadata"] or "?" ).."'. Replacement failed.");
             return nil;
          end

          -- consume the item
          user:get_inventory():remove_item("main", item["metadata"].." 1");


          -- give the player the item by simulating digging if possible
          if(   node.name ~= "air" 
            and node.name ~= "ignore"
            and node.name ~= "default:lava_source" 
            and node.name ~= "default:lava_flowing"
            and node.name ~= "default:water_source"
            and node.name ~= "default:water_flowing" ) then

             minetest.node_dig( pos, node, user );
          end
          --user:get_inventory():add_item( "main", node.name.." 1");
       end

       minetest.chat_send_player( name, "Replacing node '"..( node.name or "air" ).."' with '"..( item[ "metadata"] or "?" ).."'.");

       --minetest.env:place_node( pos, { name =  item[ "metadata" ] } );
       minetest.env:add_node( pos, { name =  item[ "metadata" ] } );
       return nil; -- no item shall be removed from inventory
    end,
})

minetest.register_craft({
        output = 'replacer:replacer',
        recipe = {
                { 'default:stick' },
                { 'default:stick' },
                { 'bucket:bucket_empty' },
        }
})

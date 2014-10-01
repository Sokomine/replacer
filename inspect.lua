
minetest.register_tool( "replacer:inspect",
{
    description = "Node inspection tool",
    groups = {}, 
    inventory_image = "replacer_inspect.png",
    wield_image = "",
    wield_scale = {x=1,y=1,z=1},
    liquids_pointable = true, -- it is ok to request information about liquids
    -- the tool_capabilities are of no intrest here; it is not for digging
    tool_capabilities = {
        full_punch_interval = 1.0,
        max_drop_level=0,
        groupcaps={
            fleshy={times={[2]=0.80, [3]=0.40}, maxwear=0.05, maxlevel=1},
            snappy={times={[2]=0.80, [3]=0.40}, maxwear=0.05, maxlevel=1},
            choppy={times={[3]=0.90}, maxwear=0.05, maxlevel=0}
        }
    },
    node_placement_prediction = nil,

    on_use = function(itemstack, user, pointed_thing)

       return replacer.inspect( itemstack, user, pointed_thing, above, false );
    end,

    on_place = function(itemstack, placer, pointed_thing)

       return replacer.inspect( itemstack, placer, pointed_thing, above, true );
    end,
})


replacer.inspect = function( itemstack, user, pointed_thing, mode, show_receipe )

	if( user == nil or pointed_thing == nil) then
		return nil;
	end
	local name = user:get_player_name();
 
	if(     pointed_thing.type == 'object' ) then
		local text = 'This is ';
		local ref = pointed_thing.ref;
		if( not( ref )) then
			text = text..'a borken object. We have no further information about it. It is located';
		elseif( ref:is_player()) then
			text = text..'your fellow player \"'..tostring( ref:get_player_name() )..'\"';
		else
			local luaob = ref:get_luaentity();
			if( luaob ) then
				text = text..'entity \"'..tostring( luaob.name )..'\"';
				local sdata = luaob:get_staticdata();
				if( sdata ) then
					sdata = minetest.deserialize( sdata );
					if( sdata.itemstring ) then
						text = text..' ['..tostring( sdata.itemstring )..']';
					end
					if( sdata.age ) then
						text = text..', dropped '..tostring( math.floor( sdata.age/60 ))..' minutes ago';
					end
				end
			else
				text = text..'object \"'..tostring( ref:get_entity_name() )..'\"';
			end

		end
		text = text..' at '..minetest.pos_to_string( ref:getpos() );
		minetest.chat_send_player( name, text );
		return nil;
	elseif( pointed_thing.type ~= 'node' ) then
		minetest.chat_send_player( name, 'Sorry. This is an unkown something of type \"'..tostring( pointed_thing.type )..'\". No information available.');
		return nil;
	end
	
	local pos  = minetest.get_pointed_thing_position( pointed_thing, mode );
	local node = minetest.env:get_node_or_nil( pos );
       
	if( node == nil ) then
		minetest.chat_send_player( name, "Error: Target node not yet loaded. Please wait a moment for the server to catch up.");
		return nil;
	end

	local text = ' ['..tostring( node.name )..'] with param2='..tostring( node.param2 )..' at '..minetest.pos_to_string( pos )..'.';	
	if( not( minetest.registered_nodes[ node.name ] )) then
		text = 'This node is an UNKOWN block'..text;
	else
		text = 'This is a \"'..tostring( minetest.registered_nodes[ node.name ].description or ' - no description provided -')..'\" block'..text;
	end
	if( minetest.is_protected(     pos, name )) then
		text = text..' You can\'t dig this node. It is protected.';
	elseif( minetest.is_protected( pos, '_THIS_NAME_DOES_NOT_EXIST_' )) then
		text = text..' You can dig this node, but others can\'t.';
	end
	minetest.chat_send_player( name, text );
	
	if( show_receipe ) then
		local res = minetest.get_all_craft_recipes( node.name );
		-- TODO: show a nice formspec
minetest.chat_send_player( name, 'RECEIPES: '..minetest.serialize( res ));
	end
	return nil; -- no item shall be removed from inventory
    end


minetest.register_craft({
        output = 'replacer:inspect',
        recipe = {
                { '', 'default:mese_crystal', '' },
                { '', 'default:sign_wall',    '' },
                { '', '',                     '' },
        }
})

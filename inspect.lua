
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
	local keys = user:get_player_control();
	if( keys["sneak"] ) then
		show_receipe = true;
	end
 
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
						if( show_receipe ) then
							replacer.inspect_show_crafting( name, sdata.itemstring, nil );
						end
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
	local node = minetest.get_node_or_nil( pos );
       
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
		replacer.inspect_show_crafting( name, node.name, nil );
	end
	return nil; -- no item shall be removed from inventory
end

-- some common groups
replacer.group_placeholder = {};
replacer.group_placeholder[ 'group:wood'  ] = 'default:wood';
replacer.group_placeholder[ 'group:tree'  ] = 'default:tree';
replacer.group_placeholder[ 'group:stick' ] = 'default:stick';
replacer.group_placeholder[ 'group:stone' ] = 'default:stone';
replacer.group_placeholder[ 'group:sand'  ] = 'default:sand';
replacer.group_placeholder[ 'group:leaves'] = 'default:leaves';
replacer.group_placeholder[ 'group:wood_slab'] = 'stairs:slab_wood';
replacer.group_placeholder[ 'group:wool'  ] = 'wool:white';

replacer.image_button_link = function( stack_string )
	local group = '';
	if( replacer.group_placeholder[ stack_string ] ) then
		stack_string = replacer.group_placeholder[ stack_string ];
		group = 'G';
	end		
-- TODO: show information about other groups not handled above
	local stack = ItemStack( stack_string );
	local new_node_name = stack_string;
	if( stack and stack:get_name()) then
		new_node_name = stack:get_name();
	end
	return tostring( stack_string )..';'..tostring( new_node_name )..';'..group;
end

replacer.add_circular_saw_receipe = function( node_name, receipes )
	if( not( node_name ) or not( circular_saw ) or not( circular_saw.names) or (node_name=='moreblocks:circular_saw')) then
		return;
	end
	local help = node_name:split( ':' );
	if( not( help ) or #help ~= 2 or help[1]=='stairs') then
		return;
	end
	help2 = help[2]:split('_');
	if( not( help2 ) or #help2 < 2 or (help2[1]~='micro' and help2[1]~='panel' and help2[1]~='stair' and help2[1]~='slab')) then
		return;
	end
--	for i,v in ipairs( circular_saw.names ) do
--		modname..":"..v[1].."_"..material..v[2]

-- TODO: write better and more correct method of getting the names of the materials
-- TODO: make sure only nodes produced by the saw are listed here
help[1]='default';
	local basic_node_name = help[1]..':'..help2[2];
	-- node found that fits into the saw
	receipes[ #receipes+1 ] = { method = 'saw',          type = 'saw',          items = { basic_node_name }, output = node_name};
	return receipes;
end

replacer.add_colormachine_receipe = function( node_name, receipes )
	if( not( colormachine )) then
		return;
	end
	local res = colormachine.get_node_name_painted( node_name, "" );

	if( not( res) or not( res.possible  ) or #res.possible < 1 ) then
		return;
	end
	-- paintable node found
	receipes[ #receipes+1 ] = { method = 'colormachine', type = 'colormachine', items = { res.possible[1] }, output = node_name};
	return receipes;
end


replacer.inspect_show_crafting = function( name, node_name, fields )
	if( not( name )) then
		return;
	end
	local receipe_nr = 1;
	if( not( node_name )) then
		node_name  = fields.node_name;
		receipe_nr = tonumber(fields.receipe_nr);
	end

	-- the player may ask for receipes of indigrents to the current receipe
	if( fields ) then
		for k,v in pairs( fields ) do
			if( v and v=="" and (minetest.registered_items[ k ]
			                 or  minetest.registered_nodes[ k ]
			                 or  minetest.registered_craftitems[ k ]
			                 or  minetest.registered_tools[ k ] )) then
				node_name = k;
				receipe_nr = 1;
			end
		end
	end

	local res = minetest.get_all_craft_recipes( node_name );
	if( not( res )) then
		res = {};
	end
	-- add special receipes for nodes created by machines
	replacer.add_circular_saw_receipe( node_name, res );
	replacer.add_colormachine_receipe( node_name, res );

	-- offer all alternate creafting receipes thrugh prev/next buttons
	if(     fields and fields.prev_receipe and receipe_nr > 1 ) then
		receipe_nr = receipe_nr - 1;
	elseif( fields and fields.next_receipe and receipe_nr < #res ) then
		receipe_nr = receipe_nr + 1;
	end

	local formspec = "size[6,6]"..
		"field[20,20;0.1,0.1;node_name;node_name;"..node_name.."]".. -- invisible field for passing on information
		"field[21,21;0.1,0.1;receipe_nr;receipe_nr;"..tostring( receipe_nr ).."]".. -- another invisible field
		"label[1,0;"..tostring( node_name ).."]"..
		"item_image_button[5,2;1.0,1.0;"..tostring( node_name )..";normal;]";
	if( not( res ) or receipe_nr > #res or receipe_nr < 1 ) then
		receipe_nr = 1;
	end
	if( res and receipe_nr > 1 ) then
		formspec = formspec.."button[3.8,5;1,0.5;prev_receipe;prev]";
	end
	if( res and receipe_nr < #res ) then
		formspec = formspec.."button[5.0,5;1,0.5;next_receipe;next]";
	end
	if( not( res ) or #res<1) then
		formspec = formspec..'label[3,1;No receipes.]';
		if(   minetest.registered_nodes[ node_name ]
		  and minetest.registered_nodes[ node_name ].drop ) then
			local drop = minetest.registered_nodes[ node_name ].drop;
			if( drop and type( drop )=='string' and drop ~= node_name ) then
				formspec = formspec.."label[2,1.6;Drops on dig:]"..
					"item_image_button[2,2;1.0,1.0;"..replacer.image_button_link( drop ).."]";
			end
		end
	else
		formspec = formspec.."label[1,5;Alternate "..tostring( receipe_nr ).."/"..tostring( #res ).."]";
		-- reverse order; default receipes (and thus the most intresting ones) are usually the oldest
		local receipe = res[ #res+1-receipe_nr ];
		if(     receipe.type=='normal'  and receipe.items) then
			for i=1,9 do
				if( receipe.items[i] ) then
					formspec = formspec.."item_image_button["..(((i-1)%3)+1)..','..(math.floor((i-1)/3)+1)..";1.0,1.0;"..
							replacer.image_button_link( receipe.items[i] ).."]";
				end
			end
		elseif( receipe.type=='cooking' and receipe.items and #receipe.items==1 ) then
			formspec = formspec.."item_image_button[1,1;3.4,3.4;"..replacer.image_button_link( 'default:furnace' ).."]".. --default_furnace_front.png]"..
					"item_image_button[2.9,2.7;1.0,1.0;"..replacer.image_button_link( receipe.items[1] ).."]";
		elseif( receipe.type=='colormachine' and receipe.items and #receipe.items==1 ) then
			formspec = formspec.."item_image_button[1,1;3.4,3.4;"..replacer.image_button_link( 'colormachine:colormachine' ).."]".. --colormachine_front.png]"..
					"item_image_button[2,2;1.0,1.0;"..replacer.image_button_link( receipe.items[1] ).."]";
		elseif( receipe.type=='saw'          and receipe.items and #receipe.items==1 ) then
			--formspec = formspec.."item_image[1,1;3.4,3.4;moreblocks:circular_saw]"..
			formspec = formspec.."item_image_button[1,1;3.4,3.4;"..replacer.image_button_link( 'moreblocks:circular_saw' ).."]"..
					"item_image_button[2,0.6;1.0,1.0;"..replacer.image_button_link( receipe.items[1] ).."]";
		else
			formspec = formspec..'label[3,1;Error: Unkown receipe.]';
		end
		-- show how many of the items the receipe will yield
		local outstack = ItemStack( receipe.output );
		if( outstack and outstack:get_count() and outstack:get_count()>1 ) then
			formspec = formspec..'label[5.5,2.5;'..tostring( outstack:get_count() )..']';
		end
	end
	minetest.show_formspec( name, "replacer:crafting", formspec );
end

-- translate general formspec calls back to specific calls
replacer.form_input_handler = function( player, formname, fields)
        if( formname and formname == "replacer:crafting" and player and not( fields.quit )) then
		replacer.inspect_show_crafting( player:get_player_name(), nil, fields );
                return;
        end
end

-- establish a callback so that input from the player-specific formspec gets handled
minetest.register_on_player_receive_fields( replacer.form_input_handler );


minetest.register_craft({
        output = 'replacer:inspect',
        recipe = {
                { '', 'default:mese_crystal', '' },
                { '', 'default:sign_wall',    '' },
                { '', '',                     '' },
        }
})

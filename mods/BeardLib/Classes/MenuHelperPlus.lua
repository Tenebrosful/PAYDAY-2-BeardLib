_G.MenuHelperPlus = _G.MenuHelperPlus or {}

function MenuHelperPlus:NewMenu(params)
	self.Menus = self.Menus or {}
	local callback_handler = CoreSerialize.string_to_classtable(params.callback_handler or "MenuCallbackHandler")
	self.Menus[params.id] = {
		menu_data = {
			_meta = "menues",
			[1] = {
				_meta = "menu",
				id = params.id,
				[1] = {
					_meta = "default_node",
					name = params.init_node.name
				},
				[2] = {
					_meta = "node",
					align_line = params.init_node.align_line or 0.75,
					back_callback = params.init_node.back_callback,
					gui_class = params.init_node.gui_class or "MenuNodeMainGui",
					menu_components = params.init_node.menu_components or "",
					modifier = params.init_node.modifier,
					name = params.init_node.name,
					refresh = params.init_node.refresh,
					topic_id = params.init_node.topic_id
				}
			}
		},
		register_data = {
			name = params.name,
			id = params.id,
			content_file = params.fake_path,
			callback_handler = callback_handler,
			input = params.input or "MenuInput",
			renderer = params.renderer or "MenuRenderer"
		},
		fake_path = params.fake_path
	}
	BeardLib.ScriptExceptions[Idstring(params.fake_path):key()] = BeardLib.ScriptExceptions[Idstring(params.fake_path):key()] or {}
	BeardLib.ScriptExceptions[Idstring(params.fake_path):key()][Idstring("menu"):key()] = true
	
	if params.init_node.legends then
		for i, legend in pairs(params.init_node.legends) do
			self:CreateAndInsertLegendData(self.Menus[params.id].menu_data[1][2], legend)
		end
	end
	
	if params.init_node.merge_data then
		table.merge(self.Menus[params.id].menu_data[1][2], params.init_node.merge_data)
	end
	
	if params.merge_data then
		table.merge(self.Menus[params.id].menu_data, params.merge_data)
	end
end

function MenuHelperPlus:NewNode(Menuname, params)
	local RegisteredMenu = managers.menu._registered_menus[Menuname or managers.menu._is_start_menu and "menu_main" or "menu_pause"]
	if not RegisteredMenu then
		return
	end
	local nodes = RegisteredMenu.logic._data._nodes
	
	local paramaters = {
		_meta = "node",
		align_line = params.align_line or 0.75,
		back_callback = params.back_callback,
		gui_class = params.gui_class or "MenuNodeGui",
		menu_components = params.menu_components or "",
		modifier = params.modifier,
		name = params.name,
		refresh = params.refresh,
		stencil_align = params.stencil_align or "right",
		stencil_image = params.stencil_image or "bg_creategame",
		topic_id = params.topic_id,
		type = params.type or "CoreMenuNode.MenuNode",
		update = params.update,
		scene_state = params.scene_state
	}
	if params.merge_data then
		table.merge(paramaters, params.merge_data)
	end
	
	if params.legends then
		for i, legend in pairs(params.legends) do
			self:CreateAndInsertLegendData(paramaters, legend)
		end
	end
	
	local node_class = CoreMenuNode.MenuNode
    if paramaters.type then
        node_class = CoreSerialize.string_to_classtable(paramaters.type)
    end
	local new_node = node_class:new(paramaters)
		
	local callback_handler = CoreSerialize.string_to_classtable(params.callback_overwrite or "MenuCallbackHandler")
	new_node:set_callback_handler(params.callback_overwrite and callback_handler or RegisteredMenu.callback_handler)
	
	nodes[params.name] = new_node
    
    return new_node
end

function MenuHelperPlus:AddLegend(Menuid, nodename, params)
	local menu = self.Menus[Menuid]
	
	if not menu then
		return
	end
	
	menu.nodes[nodename] = menu.nodes[nodename] or {}
	local max_val = table.maxn(menu.nodes[nodename])
	menu.nodes[nodename][max_val + 1] = params
end

function MenuHelperPlus:CreateAndInsertLegendData(nodeData, params)
	local max_val = table.maxn(nodeData)
	nodeData[max_val + 1] = {
		_meta = "legend",
		name = params.name,
		pc = params.pc or false,
		visible_callback = params.visible_callback or nil
	}
end

function MenuHelperPlus:GetNode(menu_name, node_name)
    return managers.menu._registered_menus[menu_name or managers.menu._is_start_menu and "menu_main" or "menu_pause"] and managers.menu._registered_menus[menu_name or managers.menu._is_start_menu and "menu_main" or "menu_pause"].logic._data._nodes[node_name] or nil
end

function MenuHelperPlus:AddButton(params)
	local node = params.node or self:GetNode(params.menu, params.node_name)
	if not node then
        --error
        return
    end
	
	local data = {
		type = "CoreMenuItem.Item",
	}

	local item_params = {
		name = params.id,
		text_id = params.title,
		help_id = params.desc,
		callback = params.callback,
		back_callback = params.back_callback,
		disabled_color = params.disabled_colour or Color(0.25, 1, 1, 1),
		next_node = params.next_node,
		localize = params.localized,
		localize_help = params.localized_help,
	}

	if params.merge_data then
		table.merge(item_params, params.merge_data)
	end
    
	local item = node:create_item(data, item_params)

	if params.enabled ~= nil then
		item:set_enabled( params.enabled )
	end
    
    if params.position then
        node:insert_item(item, params.position)
    else
        node:add_item(item)
    end
end

function MenuHelperPlus:AddDivider(params)
    local node = params.node or self:GetNode(params.menu, params.node_name)
	if not node then
        --error
        return
    end
    
	local data = {
		type = "MenuItemDivider",
		size = params.size or 8,
		no_text = params.no_text or true,
	}

	local item_params = {
		name = params.id,
	}
	
	if params.merge_data then
		table.merge(item_params, params.merge_data)
	end
	
	local item = node:create_item( data, item_params )
	if params.position then
        node:insert_item(item, params.position)
    else
        node:add_item(item)
    end

end

function MenuHelperPlus:AddToggle(params)
	local node = params.node or self:GetNode(params.menu, params.node_name)
	if not node then
        --error
        return
    end
	
	local data = {
		type = "CoreMenuItemToggle.ItemToggle",
		{
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			value = "on",
			x = 24,
			y = 0,
			w = 24,
			h = 24,
			s_icon = "guis/textures/menu_tickbox",
			s_x = 24,
			s_y = 24,
			s_w = 24,
			s_h = 24
		},
		{
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			value = "off",
			x = 0,
			y = 0,
			w = 24,
			h = 24,
			s_icon = "guis/textures/menu_tickbox",
			s_x = 0,
			s_y = 24,
			s_w = 24,
			s_h = 24
		}
	}

	local item_params = {
		name = params.id,
		text_id = params.title,
		help_id = params.desc,
		callback = params.callback,
		disabled_color = params.disabled_colour or Color( 0.25, 1, 1, 1 ),
		icon_by_text = params.icon_by_text or false,
		localize = params.localized,
	}
	
	if params.merge_data then
		table.merge(item_params, params.merge_data)
	end
	
	local item = node:create_item(data, item_params)
	item:set_value(params.value and "on" or "off")

	if params.enabled ~= nil then
		item:set_enabled(params.enabled)
	end
	
	if params.position then
        node:insert_item(item, params.position)
    else
        node:add_item(item)
    end
end

function MenuHelperPlus:AddSlider(params)
	local node = params.node or self:GetNode(params.menu, params.node_name)
	if not node then
        --error
        return
    end
	
	local data = {
		type = "CoreMenuItemSlider.ItemSlider",
		min = params.min or 0,
		max = params.max or 10,
		step = params.step or 1,
		show_value = params.show_value or false
	}

	local item_params = {
		name = params.id,
		text_id = params.title,
		help_id = params.desc,
		callback = params.callback,
		disabled_color = params.disabled_colour or Color( 0.25, 1, 1, 1 ),
		localize = params.localized,
	}

	if params.merge_data then
		table.merge(item_params, params.merge_data)
	end
	
	local item = node:create_item(data, item_params)
	item:set_value( math.clamp(params.value, data.min, data.max) or data.min )
	
	if params.enabled ~= nil then
		item:set_enabled( params.enabled )
	end

	if params.position then
        node:insert_item(item, params.position)
    else
        node:add_item(item)
    end
end

function MenuHelperPlus:AddMultipleChoice(params)
	local node = params.node or self:GetNode(params.menu, params.node_name)
	if not node then
        --error
        return
    end
	
	local data = {
		type = "MenuItemMultiChoice"
	}
	for k, v in ipairs( params.items or {} ) do
		table.insert( data, { _meta = "option", text_id = v, value = k, localize = params.localized_items } )
	end
	
	local item_params = {
		name = params.id,
		text_id = params.title,
		help_id = params.desc,
		callback = params.callback,
		filter = true,
		localize = params.localized,
	}
	
	if params.merge_data then
		table.merge(item_params, params.merge_data)
	end
	
	local item = node:create_item(data, item_params)
	item:set_value( params.value or 1 )

	if params.enabled ~= nil then
		item:set_enabled(params.enabled)
	end

	if params.position then
        node:insert_item(item, params.position)
    else
        node:add_item(item)
    end
end

function MenuHelperPlus:AddKeybinding(params)
	local node = params.node or self:GetNode(params.menu, params.node_name)
	if not node then
        --error
        return
    end
	
	local data = {
		type = "MenuItemCustomizeController",
	}

	local item_params = {
		name = params.id,
		text_id = params.title,
		help_id = params.desc,
		connection_name = params.connection_name,
		binding = params.binding,
		button = params.button,
		callback = params.callback,
		localize = params.localized,
		localize_help = params.help_localized,
		is_custom_keybind = true,
	}

	if params.merge_data then
		table.merge(item_params, params.merge_data)
	end
	
	local item = node:create_item(data, item_params)

	if params.position then
        node:insert_item(item, params.position)
    else
        node:add_item(item)
    end
end

function MenuHelperPlus:GetMenus()
	return self.Menus
end

function MenuHelperPlus:GetMenuDataFromFilepath(FilePath)
	for id, Data in pairs(self.Menus) do
		if Data.fake_path == FilePath then
			return Data.menu_data
		end
	end
	return nil
end

function MenuHelperPlus:GetMenuDataFromHashedFilepath(HashedFilePath)
	if self.Menus then
		for id, Data in pairs(self.Menus) do
			if Idstring(Data.fake_path):key() == HashedFilePath then
				return Data.menu_data
			end
		end
	end
	return nil
end

Hooks:Register("BeardLibMenuHelperPlusInitMenus")

Hooks:Add( "BeardLibMenuHelperPlusInitMenus", "MenuHelperPlusCreateMenus", function(menu_manager) 
	for id, Menu in pairs(MenuHelperPlus:GetMenus()) do
		menu_manager:register_menu(Menu.register_data)
	end
end)
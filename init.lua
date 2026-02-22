local FORMNAME = "trashbin:trash_gui"

local function inv_name(player_name)
    return "trashbin:trash_" .. player_name
end

local function clear_inv(player_name)
    local inv = minetest.get_inventory({type = "detached", name = inv_name(player_name)})
    if inv then
        inv:set_list("main", {})
    end
end

local function ensure_inv(player_name)
    local name = inv_name(player_name)
    local inv = minetest.get_inventory({type = "detached", name = name})
    if inv then
        return name
    end

    inv = minetest.create_detached_inventory(name, {
        allow_move = function()
            return 0
        end,
        allow_put = function(_, _, _, stack)
            return stack:get_count()
        end,
        allow_take = function()
            return 0
        end,
        on_put = function(invref, listname, index)
            invref:set_stack(listname, index, "")
        end,
    })
    inv:set_size("main", 1)
    return name
end

local function show_gui(player)
    local pname = player:get_player_name()
    local detached = ensure_inv(pname)
    local fs = table.concat({
        "formspec_version[4]",
        "size[12.0,9.2]",
        "bgcolor[#0f0f15dd;true]",
        "box[0.2,0.2;11.6,8.8;#1a1a24cc]",
        "label[0.5,0.5;Trash]",
        "label[0.5,0.9;Drop items here to delete them permanently.]",
        "list[detached:" .. detached .. ";main;5.5,2.0;1,1;]",
        "label[5.25,1.55;Bin]",
        "list[current_player;main;1.6,3.2;8,4;]",
        "listring[]",
        "button_exit[10.4,0.4;1.0,0.7;close;Close]",
    })
    minetest.show_formspec(pname, FORMNAME, fs)
end

local function register_open_command(cmd, description)
    minetest.register_chatcommand(cmd, {
        description = description,
        func = function(name)
            local player = minetest.get_player_by_name(name)
            if not player then
                return false, "Player not found."
            end
            show_gui(player)
            return true
        end,
    })
end

register_open_command("bin", "Open trash bin (deletes items)")
register_open_command("trash", "Alias for /bin")

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= FORMNAME then
        return false
    end
    if fields.quit or fields.close then
        clear_inv(player:get_player_name())
    end
    return true
end)

minetest.register_on_leaveplayer(function(player)
    clear_inv(player:get_player_name())
end)

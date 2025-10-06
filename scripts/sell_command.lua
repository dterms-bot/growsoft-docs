--[[
  Item Exchange Script (/sell) - v4
  Allows players to exchange a specific item for another.
  Rewritten by Jules using best practices from a working example.
]]

-- ==============================================================================
--[[ CONFIGURATION ]]
-- ==============================================================================
local config = {
    SOURCE_ITEM_NAME = "Lava Seed",
    SOURCE_ITEM_ID_FALLBACK = 5,
    SOURCE_ITEM_AMOUNT = 200,

    TARGET_ITEM_NAME = "Chandelier",
    TARGET_ITEM_ID_FALLBACK = 340,
    TARGET_ITEM_AMOUNT = 1,

    DIALOG_NAME = "jules_exchange_v4",
    COMMAND_NAME = "sell"
}

-- ==============================================================================
--[[ SCRIPT LOGIC ]]
-- ==============================================================================

local SOURCE_ITEM_ID = getEnumItem(config.SOURCE_ITEM_NAME) and getEnumItem(config.SOURCE_ITEM_NAME):getID() or config.SOURCE_ITEM_ID_FALLBACK
local TARGET_ITEM_ID = getEnumItem(config.TARGET_ITEM_NAME) and getEnumItem(config.TARGET_ITEM_NAME):getID() or config.TARGET_ITEM_ID_FALLBACK

function showExchangeDialog(player, message)
    local playerSourceItemCount = player:getItemAmount(SOURCE_ITEM_ID)

    -- Build the dialog string using a table, as seen in the market script example
    local dlg = {}
    table.insert(dlg, "set_default_color|`o\n")
    table.insert(dlg, "add_label_with_icon|big|`wItem Exchange|left|2|\n")
    table.insert(dlg, "add_spacer|small|\n")

    -- Cleaner UI layout
    table.insert(dlg, "add_label_with_icon|big|`w" .. config.SOURCE_ITEM_AMOUNT .. " " .. config.SOURCE_ITEM_NAME .. "|left|" .. SOURCE_ITEM_ID .. "|\n")
    table.insert(dlg, "add_label_with_icon|big|`w        ->|left|18|\n")
    table.insert(dlg, "add_label_with_icon|big|`9" .. config.TARGET_ITEM_AMOUNT .. " " .. config.TARGET_ITEM_NAME .. "|left|" .. TARGET_ITEM_ID .. "|\n")
    table.insert(dlg, "add_spacer|small|\n")
    table.insert(dlg, "add_textbox|`wYour " .. config.SOURCE_ITEM_NAME .. "s: `2" .. playerSourceItemCount .. "|left|\n")
    table.insert(dlg, "add_spacer|big|\n")

    -- Display feedback message if provided
    if message and message ~= "" then
        table.insert(dlg, "add_textbox|" .. message .. "|left|\n")
        table.insert(dlg, "add_spacer|small|\n")
    end

    table.insert(dlg, "add_button|exchange|`2Confirm Exchange|noflags|0|0|\n")
    table.insert(dlg, "add_quick_exit|\n")

    -- Use end_dialog, which is the correct method as seen in the market script
    table.insert(dlg, "end_dialog|" .. config.DIALOG_NAME .. "|||\n")

    player:onDialogRequest(table.concat(dlg))
end

-- 1. Register the command
registerLuaCommand({
    command = config.COMMAND_NAME,
    roleRequired = Roles.ROLE_NONE,
    description = "Opens the item exchange dialog."
})

-- 2. Handle the command usage
onPlayerCommandCallback(function(world, player, fullCommand)
    local command = fullCommand:match("^(%S+)")
    if command == config.COMMAND_NAME then
        showExchangeDialog(player)
        return true
    end
    return false
end)

-- 3. Handle the dialog interaction
onPlayerDialogCallback(function(world, player, data)
    -- Safe check for dialog name, as seen in the market script
    local dialog_name = (type(data) == "table" and data.dialog_name) or ""
    if dialog_name ~= config.DIALOG_NAME then
        return
    end

    local button_clicked = (type(data) == "table" and data.buttonClicked) or ""
    if button_clicked == "exchange" then
        local playerSourceItemCount = player:getItemAmount(SOURCE_ITEM_ID)
        local message = ""

        if playerSourceItemCount >= config.SOURCE_ITEM_AMOUNT then
            if player:changeItem(SOURCE_ITEM_ID, -config.SOURCE_ITEM_AMOUNT) then
                player:changeItem(TARGET_ITEM_ID, config.TARGET_ITEM_AMOUNT)
                message = "`2Success! `wThe exchange was completed."
                player:playAudio("audio/change_item.wav")
            else
                message = "`4Error: `wCould not remove items from your inventory."
                player:playAudio("audio/error.wav")
            end
        else
            message = "`4Error: `wYou do not have enough " .. config.SOURCE_ITEM_NAME .. "."
            player:playAudio("audio/error.wav")
        end

        -- Refresh the dialog to show the result
        showExchangeDialog(player, message)
    end
end)

print("'".. config.COMMAND_NAME .."' command script (v4) loaded successfully.")
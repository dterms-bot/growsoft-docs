--[[
  Item Exchange Script (/sell) - v3
  Allows players to exchange a specific item for another.
  Rewritten by Jules with debugging and a new UI.
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

    DIALOG_NAME = "jules_exchange_v3",
    COMMAND_NAME = "sell"
}

-- ==============================================================================
--[[ SCRIPT LOGIC ]]
-- ==============================================================================

local SOURCE_ITEM_ID = getEnumItem(config.SOURCE_ITEM_NAME) and getEnumItem(config.SOURCE_ITEM_NAME):getID() or config.SOURCE_ITEM_ID_FALLBACK
local TARGET_ITEM_ID = getEnumItem(config.TARGET_ITEM_NAME) and getEnumItem(config.TARGET_ITEM_NAME):getID() or config.TARGET_ITEM_ID_FALLBACK

-- Function to generate and display the exchange dialog
function showExchangeDialog(player, message)
    local playerSourceItemCount = player:getItemAmount(SOURCE_ITEM_ID)

    local dialog = "set_default_color|`o\n"
    dialog = dialog .. "add_label_with_icon|big|`wItem Exchange|left|2|\n"
    dialog = dialog .. "add_spacer|small|\n"

    -- New, cleaner UI layout
    dialog = dialog .. "add_label_with_icon|big|`w" .. config.SOURCE_ITEM_AMOUNT .. " " .. config.SOURCE_ITEM_NAME .. "|left|" .. SOURCE_ITEM_ID .. "|\n"
    dialog = dialog .. "add_label_with_icon|big|`w        ->|left|18|\n"
    dialog = dialog .. "add_label_with_icon|big|`9" .. config.TARGET_ITEM_AMOUNT .. " " .. config.TARGET_ITEM_NAME .. "|left|" .. TARGET_ITEM_ID .. "|\n"
    dialog = dialog .. "add_spacer|small|\n"
    dialog = dialog .. "add_textbox|`wYour " .. config.SOURCE_ITEM_NAME .. "s: `2" .. playerSourceItemCount .. "|left|\n"
    dialog = dialog .. "add_spacer|big|\n"

    -- Display feedback message if provided
    if message and message ~= "" then
        dialog = dialog .. "add_textbox|" .. message .. "|left|\n"
        dialog = dialog .. "add_spacer|small|\n"
    end

    dialog = dialog .. "embed_data|dialog_name|" .. config.DIALOG_NAME .. "\n"
    dialog = dialog .. "add_button|exchange|`2Confirm Exchange|noflags|0|0|\n"
    dialog = dialog .. "add_quick_exit|\n"

    player:onDialogRequest(dialog)
end

-- 1. Register the command
local exchangeCommand = {
    command = config.COMMAND_NAME,
    roleRequired = Roles.ROLE_NONE,
    description = "Opens the item exchange dialog."
}
registerLuaCommand(exchangeCommand)

-- 2. Handle the command usage
onPlayerCommandCallback(function(world, player, fullCommand)
    local command = fullCommand:match("^(%S+)")
    if command == exchangeCommand.command then
        showExchangeDialog(player)
        return true
    end
    return false
end)

-- 3. Handle the dialog interaction with debugging
onPlayerDialogCallback(function(world, player, data)
    -- =========== DEBUGGING BLOCK ===========
    -- This will print the received dialog data to the server console.
    -- It helps diagnose issues with button presses.
    print("--- [DEBUG] Dialog Callback Received ---")
    if data then
        for key, value in pairs(data) do
            print("DEBUG: data['" .. tostring(key) .. "'] = '" .. tostring(value) .. "'")
        end
    else
        print("DEBUG: data table is nil or empty")
    end
    print("--- [DEBUG] End of Report ---")
    -- =======================================

    -- Robust check for the dialog name to prevent errors from extra characters
    if data and data["dialog_name"] and string.match(data["dialog_name"], config.DIALOG_NAME) then
        if data["buttonClicked"] == "exchange" then
            local playerSourceItemCount = player:getItemAmount(SOURCE_ITEM_ID)
            local message = ""

            if playerSourceItemCount >= config.SOURCE_ITEM_AMOUNT then
                player:changeItem(SOURCE_ITEM_ID, -config.SOURCE_ITEM_AMOUNT)
                player:changeItem(TARGET_ITEM_ID, config.TARGET_ITEM_AMOUNT)
                message = "`2Success! `wThe exchange was completed."
                player:playAudio("audio/change_item.wav")
            else
                message = "`4Error: `wYou do not have enough " .. config.SOURCE_ITEM_NAME .. "."
                player:playAudio("audio/error.wav")
            end

            -- Refresh the dialog to show the result
            showExchangeDialog(player, message)
        end
    end
end)

print("'".. config.COMMAND_NAME .."' command script (v3) loaded successfully.")
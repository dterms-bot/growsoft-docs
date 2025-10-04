--[[
  Item Exchange Script (/sell)
  Allows players to exchange a specific item for another.
  Redesigned and fixed by Jules.
]]

-- ==============================================================================
--[[ CONFIGURATION ]]
-- ==============================================================================
-- You can easily change the items and their amounts here.

local config = {
    -- Item to be given by the player
    SOURCE_ITEM_NAME = "Lava Seed",
    SOURCE_ITEM_ID_FALLBACK = 5,
    SOURCE_ITEM_AMOUNT = 200,

    -- Item to be received by the player
    TARGET_ITEM_NAME = "Chandelier",
    TARGET_ITEM_ID_FALLBACK = 340,
    TARGET_ITEM_AMOUNT = 1,

    -- Dialog Settings
    DIALOG_NAME = "jules_item_exchange_v2",
    COMMAND_NAME = "sell"
}

-- ==============================================================================
--[[ SCRIPT LOGIC (Do not edit below unless you know what you are doing) ]]
-- ==============================================================================

-- Get Item IDs from their names, using fallbacks if not found.
local SOURCE_ITEM_ID = getEnumItem(config.SOURCE_ITEM_NAME) and getEnumItem(config.SOURCE_ITEM_NAME):getID() or config.SOURCE_ITEM_ID_FALLBACK
local TARGET_ITEM_ID = getEnumItem(config.TARGET_ITEM_NAME) and getEnumItem(config.TARGET_ITEM_NAME):getID() or config.TARGET_ITEM_ID_FALLBACK

-- This function generates and shows the exchange dialog to the player.
-- It can optionally display a message (e.g., for success or error feedback).
function showExchangeDialog(player, message)
    local playerSourceItemCount = player:getItemAmount(SOURCE_ITEM_ID)

    local dialog = "set_default_color|`o\n"
    dialog = dialog .. "add_label_with_icon|big|`wITEM EXCHANGE|left|2|\n" -- Using a gear icon for the title
    dialog = dialog .. "add_spacer|small|\n"
    dialog = dialog .. "add_textbox|`wTrade `4" .. config.SOURCE_ITEM_AMOUNT .. " `w" .. config.SOURCE_ITEM_NAME .. " for `9" .. config.TARGET_ITEM_AMOUNT .. "`w " .. config.TARGET_ITEM_NAME .. ".|left|\n"
    dialog = dialog .. "add_spacer|big|\n"

    -- Display the items with icons
    dialog = dialog .. "add_button_with_icon|from_item|" .. config.SOURCE_ITEM_AMOUNT .. " " .. config.SOURCE_ITEM_NAME .. "|staticBlueFrame| ".. SOURCE_ITEM_ID .."|left|\n"
    dialog = dialog .. "add_label_with_icon|small|`w(You have: `2" .. playerSourceItemCount .. "`w)|left|18|\n" -- Info icon
    dialog = dialog .. "add_label_with_icon|big|`w V |left|18|\n" -- Down arrow icon
    dialog = dialog .. "add_button_with_icon|to_item|" .. config.TARGET_ITEM_AMOUNT .. " " .. config.TARGET_ITEM_NAME .. "|staticBlueFrame| ".. TARGET_ITEM_ID .."|left|\n"
    dialog = dialog .. "add_spacer|big|\n"

    -- Display the feedback message if one was provided
    if message and message ~= "" then
        dialog = dialog .. "add_textbox|" .. message .. "|left|\n"
        dialog = dialog .. "add_spacer|small|\n"
    end

    dialog = dialog .. "embed_data|dialog_name|" .. config.DIALOG_NAME .. "\n"
    dialog = dialog .. "add_button|exchange|`2Exchange|noflags|0|0|\n"
    dialog = dialog .. "add_quick_exit|\n"

    player:onDialogRequest(dialog)
end

-- 1. Define and register the command
local exchangeCommand = {
    command = config.COMMAND_NAME,
    roleRequired = Roles.ROLE_NONE,
    description = "Opens the item exchange dialog."
}
registerLuaCommand(exchangeCommand)

-- 2. Handle the command when a player uses it
onPlayerCommandCallback(function(world, player, fullCommand)
    local command = fullCommand:match("^(%S+)")
    if command == exchangeCommand.command then
        showExchangeDialog(player) -- Show the dialog without any initial message
        return true
    end
    return false
end)

-- 3. Handle the dialog interaction
onPlayerDialogCallback(function(world, player, data)
    if data["dialog_name"] == config.DIALOG_NAME then
        if data["buttonClicked"] == "exchange" then
            local playerSourceItemCount = player:getItemAmount(SOURCE_ITEM_ID)
            local message = ""

            -- Check if the player has enough items
            if playerSourceItemCount >= config.SOURCE_ITEM_AMOUNT then
                -- Perform the exchange
                player:changeItem(SOURCE_ITEM_ID, -config.SOURCE_ITEM_AMOUNT)
                player:changeItem(TARGET_ITEM_ID, config.TARGET_ITEM_AMOUNT)

                -- Set success message
                message = "`2Success! `wThe exchange was completed."
                player:playAudio("audio/change_item.wav")
            else
                -- Set error message
                message = "`4Error: `wYou do not have enough " .. config.SOURCE_ITEM_NAME .. "."
                player:playAudio("audio/error.wav")
            end

            -- Refresh the dialog to show the message and updated item count
            showExchangeDialog(player, message)
        end
    end
end)

print("'".. config.COMMAND_NAME .."' command script (v2) loaded successfully.")
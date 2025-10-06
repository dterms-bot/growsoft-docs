--[[
  Advanced Exchange Center Script
  Rewritten by Jules based on the user-provided /exchange example.
  This script provides a flexible, config-driven item exchange system.
]]

-- ================================
-- CONFIGURATION
-- ================================

local CONFIG = {
    COMMAND = {
        NAME = "exchange",
        DESCRIPTION = "Opens the Exchange Center",
        AUDIO = "spell1.wav"
    },
    DIALOG = {
        TITLE = "`wExchange Center",
        TITLE_ICON = 12592,
        WELCOME_TEXT = "`oWelcome! Trade your items for something more useful. Choose from a variety of fair trades to upgrade your inventory.",
        INSTRUCTION_TEXT = "`2(Click the yellow-framed button to select a trade)",
        ITEMS_PER_ROW = 1,
        SPACER_SIZE = "small",
        CUSTOM_BREAK = true
    },
    STYLE = {
        REQUIRED_FRAME = "noflags",
        EXCHANGE_FRAME = "staticYellowFrame",
        ARROW_ICON = 11162,
        CONFIRM_ICON = 6292
    },
    SYSTEM = {
        MAX_ITEM_STACK = 200,
        SUCCESS_AUDIO = "keypad_hit.wav",
        FAIL_AUDIO = "bleep_fail.wav"
    }
}

-- Define all your item trades here.
-- You can add as many as you want.
local ITEM_STORAGE = {
    -- {itemID = ID_ITEM_YANG_DIBUTUHKAN, amountRequired = JUMLAH, itemToGiveID = ID_ITEM_YANG_DIBERI, amount = JUMLAH}
    {itemID = 5, amountRequired = 200, itemToGiveID = 340, amount = 1}, -- 200 Lava Seed for 1 Chandelier
    -- Tambahkan pertukaran lain di sini
    -- {itemID = 2, amountRequired = 100, itemToGiveID = 18, amount = 1}, -- Contoh: 100 Dirt for 1 Door
}

-- ================================
-- SCRIPT LOGIC
-- ================================

-- Helper function to safely get an item's name
local function getItemName(id)
    local item = getItem(id)
    return (item and item:getName()) or "Unknown Item"
end

-- Main dialog function to show all available trades
local function showExchangeDialog(player)
    local dlg = {}
    table.insert(dlg, "add_spacer|" .. CONFIG.DIALOG.SPACER_SIZE .. "|\n")
    table.insert(dlg, "add_label_with_icon|big|" .. CONFIG.DIALOG.TITLE .. "|left|" .. CONFIG.DIALOG.TITLE_ICON .. "||\n")
    if CONFIG.DIALOG.CUSTOM_BREAK then table.insert(dlg, "add_custom_break|\n") end
    table.insert(dlg, "add_spacer|" .. CONFIG.DIALOG.SPACER_SIZE .. "|\n")
    table.insert(dlg, "add_textbox|" .. CONFIG.DIALOG.WELCOME_TEXT .. "|\n")
    if CONFIG.DIALOG.CUSTOM_BREAK then table.insert(dlg, "add_custom_break|\n") end
    table.insert(dlg, "add_spacer|" .. CONFIG.DIALOG.SPACER_SIZE .. "|\n")
    table.insert(dlg, "add_smalltext|" .. CONFIG.DIALOG.INSTRUCTION_TEXT .. "|\n")
    if CONFIG.DIALOG.CUSTOM_BREAK then table.insert(dlg, "add_custom_break|\n") end
    table.insert(dlg, "add_spacer|" .. CONFIG.DIALOG.SPACER_SIZE .. "|\n")
    table.insert(dlg, "text_scaling_string|aaaaaaaaaaaaaa|\n")

    for i = 1, #ITEM_STORAGE, CONFIG.DIALOG.ITEMS_PER_ROW do
        for j = 0, CONFIG.DIALOG.ITEMS_PER_ROW - 1 do
            local itemIndex = i + j
            local item = ITEM_STORAGE[itemIndex]
            if item then
                local reqName = getItemName(item.itemID)
                local giveName = getItemName(item.itemToGiveID)

                table.insert(dlg, string.format("add_button_with_icon|req_%d|`w%d `o%s|%s|%d|left|\n", itemIndex, item.amountRequired, reqName, CONFIG.STYLE.REQUIRED_FRAME, item.itemID))
                table.insert(dlg, string.format("add_button_with_icon|click_none||%s|%d||\n", CONFIG.STYLE.REQUIRED_FRAME, CONFIG.STYLE.ARROW_ICON))
                table.insert(dlg, string.format("add_button_with_icon|give_%d|`w%d `9%s|%s|%d|left|\n", itemIndex, item.amount, giveName, CONFIG.STYLE.EXCHANGE_FRAME, item.itemToGiveID))
            end
        end
        if CONFIG.DIALOG.CUSTOM_BREAK then table.insert(dlg, "add_custom_break|\n") end
        table.insert(dlg, "add_spacer|" .. CONFIG.DIALOG.SPACER_SIZE .. "|\n")
    end

    table.insert(dlg, "add_quick_exit|\n")
    table.insert(dlg, "end_dialog|exchange_dialog|Close||\n")
    player:onDialogRequest(table.concat(dlg))
end

-- Quantity selection dialog
local function showQuantityDialog(player, index)
    local data = ITEM_STORAGE[index]
    if not data then return end

    local itemAmt = player:getItemAmount(data.itemID)
    local itemName = getItemName(data.itemID)
    local itemReward = getItemName(data.itemToGiveID)

    local dlg = {}
    table.insert(dlg, "add_spacer|" .. CONFIG.DIALOG.SPACER_SIZE .. "|\n")
    table.insert(dlg, "add_label_with_icon|big|`wConfirm Exchange|left|" .. CONFIG.STYLE.CONFIRM_ICON .. "|\n")
    if CONFIG.DIALOG.CUSTOM_BREAK then table.insert(dlg, "add_custom_break|\n") end
    table.insert(dlg, "add_spacer|" .. CONFIG.DIALOG.SPACER_SIZE .. "|\n")
    table.insert(dlg, "add_smalltext|`2You'll give:|left|\n")
    table.insert(dlg, "add_label_with_icon|small|(" .. data.amountRequired .. ") " .. itemName .. "|left|" .. data.itemID .. "|\n")
    table.insert(dlg, "add_smalltext|`4You'll get:|left|\n")
    table.insert(dlg, "add_label_with_icon|small|(" .. data.amount .. ") " .. itemReward .. "|left|" .. data.itemToGiveID .. "|\n")
    if CONFIG.DIALOG.CUSTOM_BREAK then table.insert(dlg, "add_custom_break|\n") end
    table.insert(dlg, "add_spacer|" .. CONFIG.DIALOG.SPACER_SIZE .. "|\n")
    table.insert(dlg, "add_smalltext|`2(You have " .. itemAmt .. " " .. itemName .. ")|left|\n")
    if CONFIG.DIALOG.CUSTOM_BREAK then table.insert(dlg, "add_custom_break|\n") end
    table.insert(dlg, "add_spacer|" .. CONFIG.DIALOG.SPACER_SIZE .. "|\n")
    table.insert(dlg, "add_textbox|`wHow many times do you want to perform this exchange?|\n")
    table.insert(dlg, "add_text_input|qty_input|`w:|1|3|\n")
    if CONFIG.DIALOG.CUSTOM_BREAK then table.insert(dlg, "add_custom_break|\n") end
    table.insert(dlg, "add_spacer|" .. CONFIG.DIALOG.SPACER_SIZE .. "|\n")
    table.insert(dlg, "end_dialog|confirm_qty_" .. index .. "|Cancel|Confirm|\n")
    player:onDialogRequest(table.concat(dlg))
end

-- ================================
-- EVENT HANDLERS
-- ================================

registerLuaCommand({
    command = CONFIG.COMMAND.NAME,
    roleRequired = 0,
    description = CONFIG.COMMAND.DESCRIPTION
})

onPlayerCommandCallback(function(world, player, fullCommand)
    local command = fullCommand:match("^(%S+)")
    if command == CONFIG.COMMAND.NAME then
        showExchangeDialog(player)
        player:playAudio(CONFIG.COMMAND.AUDIO)
        return true
    end
    return false
end)

onPlayerDialogCallback(function(world, player, data)
    local dialogName = data["dialog_name"] or ""
    local buttonClicked = data["buttonClicked"] or ""

    if dialogName == "exchange_dialog" and buttonClicked:match("^give_%d+") then
        local index = tonumber(buttonClicked:match("^give_(%d+)"))
        if index then showQuantityDialog(player, index) end
        return
    end

    local match = {dialogName:match("^confirm_qty_(%d+)$")}
    local index = tonumber(match[1])
    if index then
        local exchange = ITEM_STORAGE[index]
        if not exchange then return end

        local qty = tonumber(data["qty_input"] or "1") or 1
        if qty < 1 or qty > CONFIG.SYSTEM.MAX_ITEM_STACK then
            player:onTalkBubble(player:getNetID(), "`4Invalid Quantity", 0)
            player:playAudio(CONFIG.SYSTEM.FAIL_AUDIO)
            return
        end

        local totalCost = exchange.amountRequired * qty
        local totalReward = exchange.amount * qty
        local playerHas = player:getItemAmount(exchange.itemID)

        if playerHas < totalCost then
            player:onTalkBubble(player:getNetID(), "`4Not enough items", 0)
            player:playAudio(CONFIG.SYSTEM.FAIL_AUDIO)
            return
        end

        if player:changeItem(exchange.itemID, -totalCost) then
            player:changeItem(exchange.itemToGiveID, totalReward)
            player:onTalkBubble(player:getNetID(), "`2Exchange Complete!", 0)
            player:playAudio(CONFIG.SYSTEM.SUCCESS_AUDIO)
        else
            player:onTalkBubble(player:getNetID(), "`4Transaction Failed", 0)
            player:playAudio(CONFIG.SYSTEM.FAIL_AUDIO)
        end

        -- Return to the main menu after a transaction
        showExchangeDialog(player)
    end
end)

print("(Loaded) Advanced Exchange Center Script")
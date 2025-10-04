--[[
  Sell Command Script
  Memungkinkan pemain untuk menukar Lava Seed dengan Chandelier.
  Dibuat oleh Jules.
]]

-- ==============================================================================
--[[ KONFIGURASI ]]
-- ==============================================================================
-- Anda dapat dengan mudah mengubah item dan jumlahnya di sini.

-- Nama Item (harus sama persis dengan nama di database item server Anda)
local SEED_ITEM_NAME = "Lava Seed"
local TARGET_ITEM_NAME = "Chandelier"

-- Rasio Pertukaran
local SEEDS_REQUIRED = 200
local TARGET_ITEM_AMOUNT = 1

-- Nama Dialog (harus unik untuk menghindari konflik dengan skrip lain)
local DIALOG_NAME = "jules_seed_exchange"

-- ==============================================================================
--[[ LOGIKA SKRIP (Jangan diubah kecuali Anda tahu apa yang Anda lakukan) ]]
-- ==============================================================================

-- Dapatkan ID Item dari namanya.
-- Skrip akan berhenti jika nama item salah atau item tidak ditemukan.
-- ID Fallback (5 untuk Lava Seed, 340 untuk Chandelier) digunakan jika getEnumItem gagal.
local SEED_ITEM_ID = getEnumItem(SEED_ITEM_NAME) and getEnumItem(SEED_ITEM_NAME):getID() or 5
local TARGET_ITEM_ID = getEnumItem(TARGET_ITEM_NAME) and getEnumItem(TARGET_ITEM_NAME):getID() or 340

if not getEnumItem(SEED_ITEM_NAME) or not getEnumItem(TARGET_ITEM_NAME) then
    print("PERINGATAN: Fungsi getEnumItem tidak dapat menemukan '" .. SEED_ITEM_NAME .. "' atau '" .. TARGET_ITEM_NAME .. "'. Menggunakan ID fallback yang dikonfigurasi.")
end

-- 1. Definisi Perintah
local sellCommand = {
    command = "sell",
    roleRequired = Roles.ROLE_NONE,
    description = "Membuka dialog untuk menukar seed dengan item."
}

-- 2. Daftarkan perintah ke server
registerLuaCommand(sellCommand)

-- 3. Tangani perintah saat pemain menggunakannya
onPlayerCommandCallback(function(world, player, fullCommand)
    local command = fullCommand:match("^(%S+)")

    if command == sellCommand.command then
        -- Dapatkan jumlah seed yang dimiliki pemain saat ini
        local playerSeedCount = player:getItemAmount(SEED_ITEM_ID)

        -- Buat string dialog menggunakan sintaks dari dokumentasi
        local dialog = "set_default_color|`o\n"
        dialog = dialog .. "add_label|big|`wTukar Seed|left|\n"
        dialog = dialog .. "add_spacer|small|\n"
        dialog = dialog .. "add_textbox|`wTukar `4" .. SEEDS_REQUIRED .. " `o" .. SEED_ITEM_NAME .. " `wuntuk `9" .. TARGET_ITEM_AMOUNT .. " " .. TARGET_ITEM_NAME .. ".|left|\n"
        dialog = dialog .. "add_spacer|small|\n"
        dialog = dialog .. "add_textbox|`wAnda memiliki: `2" .. playerSeedCount .. " `o" .. SEED_ITEM_NAME .. ".|left|\n"
        dialog = dialog .. "add_spacer|big|\n"
        dialog = dialog .. "embed_data|dialog_name|" .. DIALOG_NAME .. "\n"
        dialog = dialog .. "add_button|exchange|`2Tukar Sekarang|noflags|0|0|\n"
        dialog = dialog .. "add_quick_exit|\n"

        -- Tampilkan dialog ke pemain
        player:onDialogRequest(dialog)

        return true -- Perintah berhasil ditangani
    end

    return false -- Bukan perintah ini, biarkan sistem lain yang menangani
end)

-- 4. Tangani interaksi dialog
onPlayerDialogCallback(function(world, player, data)
    -- Pastikan ini adalah dialog yang benar
    if data["dialog_name"] == DIALOG_NAME then
        -- Cek jika tombol "exchange" yang ditekan
        if data["buttonClicked"] == "exchange" then
            local playerSeedCount = player:getItemAmount(SEED_ITEM_ID)

            -- Cek apakah pemain memiliki cukup seed
            if playerSeedCount >= SEEDS_REQUIRED then
                -- Lakukan pertukaran
                player:changeItem(SEED_ITEM_ID, -SEEDS_REQUIRED)
                player:changeItem(TARGET_ITEM_ID, TARGET_ITEM_AMOUNT)

                -- Beri tahu pemain bahwa transaksi berhasil
                player:onConsoleMessage("`2Berhasil! `oAnda menukar `4" .. SEEDS_REQUIRED .. " " .. SEED_ITEM_NAME .. " `ountuk `9" .. TARGET_ITEM_AMOUNT .. " " .. TARGET_ITEM_NAME .. ".")
                player:playAudio("audio/change_item.wav") -- Memainkan suara jika ada
            else
                -- Beri tahu pemain jika seed tidak cukup
                player:onConsoleMessage("`4Gagal! `oAnda tidak punya cukup " .. SEED_ITEM_NAME .. ". Anda butuh `4" .. SEEDS_REQUIRED .. ".")
                player:playAudio("audio/error.wav") -- Memainkan suara error jika ada
            end
        end
    end
end)

print("Skrip perintah '/sell' berhasil dimuat.")
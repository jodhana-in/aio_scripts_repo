-- name = "AlQuran"
-- description = "AlQuran"
-- data_source = "https://quran.com/"
-- type = "widget"
-- author = "Nuhu Rule (ncalyx@gmail.com)"
-- version = "2.3"
-- foldable = "false"

local json = require "json"
local verse_data = nil  -- Store the verse translation data

function on_alarm()
    -- Fetch random verse with English translation
    http:get("https://vedicscriptures.github.io/slok/1/1")
end

function on_network_result(result, code)
    if code >= 200 and code < 300 then
        local response = json.decode(result)

        if response then
            -- Store verse data including Surah name, verse number, and English translation
            verse_data = response

            display_verse()
        else
            ui:show_text("Error loading verse data.")
        end
    else
        -- Show error if the HTTP request fails
        ui:show_text("Error fetching verse. Please try again later.")
    end
end

function display_verse()
    if verse_data then
        -- Prepare display lines with English translation
        local display_lines = {
            "Verse " .. verse_data.verse .. ": " .. verse_data.slok
        }
        local display_titles = {
            "Slok: " .. verse_data.slok
        }

        ui:show_lines(display_lines, display_titles)
    end
end

function on_click()
    if verse_data then
        -- Prepare text to copy to clipboard with English translation only
        local clipboard_text = "Verse " .. verse_data.verse .. ": " .. verse_data.slok ..
            " - Slok: " .. verse_data.slok

        system:to_clipboard(clipboard_text)
        ui:show_text("Verse copied to clipboard!")
    else
        ui:show_text("No verse available to copy.")
    end
end

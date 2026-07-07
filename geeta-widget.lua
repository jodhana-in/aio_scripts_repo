-- name = "Geeta"
-- description = "Geeta"
-- data_source = ""
-- type = "widget"
-- author = "Ravindra Bharadwaj (rvrajj@gmail.com)"
-- version = "1.0"
-- foldable = "true"

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

-- see https://github.com/mpv-player/mpv/issues/10303

-- by default, when the audio device becomes unavailable (e.g. HDMI audio
-- and the display turns off), then unless --audio-fallback-to-null is enabled,
-- mpv drops the audio track - which is quite undesirable.
-- But even with --audio-fallback-to-null, when the device becomes available
-- again - e.g. HDMI audio and the display turns on, then mpv doesn't switch
-- to it if it previously fell-back to null.

-- this script addresses both issues:
--   1. it enables --audio-fallback-to-null
--   2. if the audio device list changes while ao is null - reload the ao
--      (e.g. find the HDMI audio after the display was turned on)

mp.set_property("audio-fallback-to-null", "yes")

mp.observe_property("audio-device-list", "native", function()
    -- let the AO settle (500 ms) after device change, then reload if null
    mp.add_timeout(0.5, function()
        if mp.get_property("current-ao") == "null" then
            print("reloading AO...")
            mp.command("ao-reload")
        end
    end)
end)
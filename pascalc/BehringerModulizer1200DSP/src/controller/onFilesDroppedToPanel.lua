---
-- Callback to indicate that the user has dropped the files onto this panel
--
-- @files   - StringArray object that has the file paths
-- @x       - x coordinate where the event occured
-- @y       - y coordinate where the event occured
function onFilesDroppedToPanel(files, x, y)
  if files:size() > 0 then
    local f = File(files:get(0))
    behringerModulizerController:loadVoiceFromFile(f)
  end
end

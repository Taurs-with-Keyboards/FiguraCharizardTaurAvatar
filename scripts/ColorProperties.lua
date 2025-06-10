-- Avatar color
avatar:color(vectors.hexToRGB("D8741E"))

-- Glowing outline
renderer:outlineColor(vectors.hexToRGB("D8741E"))

-- Host only instructions
if not host:isHost() then return end

-- Table setup
local c = {}

-- Action variables
c.hover     = vectors.hexToRGB("D8741E")
c.active    = vectors.hexToRGB("1E7A73")
c.primary   = "#D8741E"
c.secondary = "#1E7A73"

-- Return variables
return c
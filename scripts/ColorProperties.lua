-- Avatar color
avatar:color(vectors.hexToRGB("D8741E"))

-- Glowing outline
renderer:outlineColor(vectors.hexToRGB("D8741E"))

-- Host only instructions
if not host:isHost() then return end

-- Table setup
local colors = {}

-- Action variables
colors.hover     = vectors.hexToRGB("D8741E")
colors.active    = vectors.hexToRGB("1E7A73")
colors.primary   = "#D8741E"
colors.secondary = "#1E7A73"

-- Return variables
return colors
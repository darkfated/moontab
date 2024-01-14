--[[
    * MoonTab *
    GitHub: https://github.com/darkfated/moontab
    Author's discord: darkfated
]]

local function run_scripts()
	Mantle.run_cl('menu.lua')
end

local function init()
	if SERVER then
		resource.AddFile('materials/moontab/style_list.png')
		resource.AddFile('materials/moontab/style_grid.png')
	end

	run_scripts()
end

init()
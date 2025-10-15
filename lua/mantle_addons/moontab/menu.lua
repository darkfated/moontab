-- Menu

local function CreateMenu()
    local tabW, tabH = Mantle.func.sw * 0.6, Mantle.func.sh * 0.65
    MoonTab.menu = vgui.Create('MantleFrame')
    MoonTab.menu:SetSize(tabW, tabH)
    MoonTab.menu:Center()
    MoonTab.menu:MakePopup()
    MoonTab.menu:ShowAnimation()

    local textPlayers = 'Количество игроков: ' .. #player.GetAll() .. ' из ' .. game.MaxPlayers()
    MoonTab.menu:SetTitle(textPlayers)
    MoonTab.menu:SetCenterTitle(MoonTab.cfg.title)

    local playerSP = vgui.Create('MantleScrollPanel', MoonTab.menu)
    playerSP:Dock(FILL)

    local sortedTeams = {}

    for _, pl in player.Iterator() do
        if !sortedTeams[pl:Team()] then
            sortedTeams[pl:Team()] = {}
        end

        table.insert(sortedTeams[pl:Team()], pl)
    end

    for i, teamTable in pairs(sortedTeams) do
        for _, pl in pairs(teamTable) do
            local plyPanel = vgui.Create('MoonTab.Player', playerSP)
            plyPanel:Dock(TOP)
            plyPanel:DockMargin(0, 0, 0, 6)
            plyPanel:SetTall(50)
            plyPanel:SetPlayer(pl)
        end
    end
end

hook.Add('ScoreboardShow', 'MoonTab', function()
    if IsValid(MoonTab.menu) then
        MoonTab.menu:SetVisible(true)
    else
        CreateMenu()
    end

    return false
end)

hook.Add('ScoreboardHide', 'MoonTab', function()
    if IsValid(MoonTab.menu) then
        -- MoonTab.menu:SetVisible(false)
        MoonTab.menu:Remove()
    end

    return false
end)

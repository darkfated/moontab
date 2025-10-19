-- Menu

local function CreateMenu()
    local tabW, tabH = Mantle.func.sw * 0.6, Mantle.func.sh * 0.65
    MoonTab.menu = vgui.Create('MantleFrame')
    MoonTab.menu:SetSize(tabW, tabH)
    MoonTab.menu:Center()
    MoonTab.menu:MakePopup()
    MoonTab.menu:ShowAnimation()
    MoonTab.menu:DisableCloseBtn()
    MoonTab.menu.canClose = true
    MoonTab.menu.OnKeyCodePressed = function(s, key)
        if key == KEY_TAB then
            s:SetVisible(false)
        end
    end

    local textPlayers = 'Количество игроков: ' .. #player.GetAll() .. ' из ' .. game.MaxPlayers()
    MoonTab.menu:SetTitle(textPlayers)
    MoonTab.menu:SetCenterTitle(MoonTab.cfg.title)

    local actionPanel = vgui.Create('Panel', MoonTab.menu)
    actionPanel:Dock(TOP)
    actionPanel:DockMargin(0, 0, 0, 6)
    actionPanel:SetTall(32)
    actionPanel.Paint = function(_, w, h)
        draw.SimpleText('Данные', 'Fated.16', 8, h * 0.5, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText('Профессия', 'Fated.16', w * 0.5, h * 0.5, Mantle.color.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText('Привилегия', 'Fated.16', w * 0.7 - 32, h * 0.5, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local searchBox = vgui.Create('MantleEntry', actionPanel)
    searchBox:Dock(RIGHT)
    searchBox:SetWide(200)
    searchBox:SetPlaceholder('Поиск по имени / команде')
    searchBox.textEntry.OnValueChange = function(_, newFilter)
        MoonTab.menu:RebuildList(newFilter)
    end

    local playerSP = vgui.Create('MantleScrollPanel', MoonTab.menu)
    playerSP:Dock(FILL)

    local sortedTeams = {}

    function MoonTab.menu:RebuildList(filter)
        playerSP:Clear()
        sortedTeams = {}

        print(filter)
        filter = string.Trim(string.lower(filter))
        local hasFilter = filter != ''

        for _, pl in player.Iterator() do
            local teamName = team.GetName(pl:Team())
            local plyName = pl:Name()

            if not hasFilter
                or string.find(string.lower(plyName), filter, 1, true)
                or string.find(string.lower(teamName), filter, 1, true)
            then
                if !sortedTeams[pl:Team()] then
                    sortedTeams[pl:Team()] = {}
                end

                table.insert(sortedTeams[pl:Team()], pl)
            end
        end

        for _, teamTable in pairs(sortedTeams) do
            for _, pl in ipairs(teamTable) do
                local plyPanel = vgui.Create('MoonTab.Player', playerSP)
                plyPanel:Dock(TOP)
                plyPanel:DockMargin(0, 0, 0, 6)
                plyPanel:SetTall(50)
                plyPanel:SetPlayer(pl)
            end
        end
    end

    MoonTab.menu:RebuildList('')
end

hook.Add('ScoreboardShow', 'MoonTab', function()
        if IsValid(MoonTab.menu) then
        MoonTab.menu:Remove()
    end
    if IsValid(MoonTab.menu) then
        MoonTab.menu:SetVisible(true)
        local m = MoonTab.menu
        Mantle.func.animate_appearance(m, m:GetWide(), m:GetTall(), 0.3, 0.2)
    else
        CreateMenu()
    end

    return false
end)

hook.Add('ScoreboardHide', 'MoonTab', function()
    return false
end)

hook.Add('PlayerConnect', 'MoonTab', function()
    if IsValid(MoonTab.menu) then
        MoonTab.menu:RebuildList('')
    end
end)

hook.Add('PlayerDisconnected', 'MoonTab', function()
    if IsValid(MoonTab.menu) then
        MoonTab.menu:RebuildList('')
    end
end)

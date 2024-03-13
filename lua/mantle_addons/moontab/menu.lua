--[[
    * MoonTab *
    GitHub: https://github.com/darkfated/moontab
    Author's discord: darkfated
]]

local convar_mantle_moontab_style_list = CreateClientConVar('mantle_moontab_style_list', 1, true, false)

local table_ranks = {
    ['superadmin'] = {'Создатель', 'icon16/tux.png'},
    ['vip'] = {'VIP', 'icon16/user_green.png'},
    ['user'] = {'Игрок', 'icon16/user.png'},
}

local table_hours = {
    {0, 'icon16/status_offline.png', 'Старт с нуля, финиш на вершине'},
    {100, 'icon16/scratchnumber.png', 'Усердно работаю над собой'},
    {500, 'icon16/world.png', 'Вертуоз в своём деле'},
    {1000, 'icon16/rosette.png', 'Финальный босс побеждён'}
}

local function time_to_hours(time)
    return math.floor(time / 3600)
end

local color_shadow = Color(0, 0, 0, 100)
local color_banner_shadow = Color(0, 0, 0, 150)

local function Close()
    if IsValid(MoonTab) then
        MoonTabScrollPos = MoonTab.sp:GetVBar():GetScroll()

        MoonTab:Remove()
    end

    if IsValid(Mantle.ui.menu_derma_menu) then
        Mantle.ui.menu_derma_menu:Remove()
    end
end

local menu_width, menu_tall = 1200, 676
local scrw, scrh = ScrW(), ScrH()

local function Create()
    MoonTab = vgui.Create('DFrame')
    Mantle.ui.frame(MoonTab, 'Количество игроков: ' .. #player.GetAll() .. ' из ' .. game.MaxPlayers(), math.Clamp(menu_width, 0, scrw), math.Clamp(menu_tall, 0, scrh), false)
    MoonTab:Center()
    MoonTab:MakePopup()
    MoonTab:SetKeyBoardInputEnabled(false)
    MoonTab.OnKeyCodePressed = function(self, key)
        if key == KEY_TAB and MoonTab.dont_remove then
            Close()
        end
    end
    MoonTab.player_filter = ''

    MoonTabScrollPos = MoonTabScrollPos or 0

    MoonTab.title = vgui.Create('DButton', MoonTab)
    MoonTab.title:SetSize(menu_width * 0.5, 24)
    MoonTab.title:SetPos(menu_width * 0.25, 0)
    MoonTab.title:SetText('')

    surface.SetFont('Fated.24')

    local title_text = 'Mantle MoonTab'
    local title_text_wide = surface.GetTextSize(title_text)
    local mat_title = Material('icon16/page_white_copy.png')

    MoonTab.title.Paint = function(_, w, h)
        draw.SimpleText(title_text, 'Fated.24', w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(color_white)
        surface.SetMaterial(mat_title)
        surface.DrawTexturedRect(w * 0.5 + title_text_wide * 0.5 + 4, 4, 16, 16)
    end
    MoonTab.title.DoClick = function()
        chat.AddText(color_white, 'Айпи сервера скопирован!')
        chat.PlaySound()

        SetClipboardText(game.GetIPAddress())
    end

    local function string_in_string(subString, fullString)
        local lowerSubString = string.lower(subString)
        local lowerFullString = string.lower(fullString)

        return string.find(lowerFullString, lowerSubString, 1, true) != nil
    end

    local function check_search_visible(pl)
        local filter = string.lower(MoonTab.player_filter)

        if string_in_string(filter, string.lower(pl:Name())) then
            return false
        end

        if string_in_string(filter, string.lower(pl:getDarkRPVar('job', ''))) then
            return false
        end
    
        return true
    end

    local sorted_categories = {}

    for k, category in SortedPairsByMemberValue(DarkRP.getCategories().jobs, 'sortOrder') do
        sorted_categories[k] = {
            name = category.name,
            jobs = {}
        }

        for j, job in pairs(category.members) do
            sorted_categories[k].jobs[j] = {
                name = job.name,
                color = job.color,
                members = {}
            }

            for _, pl in ipairs(player.GetAll()) do
                if pl:getDarkRPVar('job', '') == job.name then
                    table.insert(sorted_categories[k].jobs[j].members, pl)
                end
            end
        end
    end

    MoonTab.sp = vgui.Create('DScrollPanel', MoonTab)
    Mantle.ui.sp(MoonTab.sp)
    MoonTab.sp:Dock(FILL)
    MoonTab.sp:DockMargin(4, 4, 4, 4)

    local function get_time_table(pl)
        local time = time_to_hours(10) -- Здесь написать meta-функцию измерения часов у игрока. Пример: time_to_hours(pl:GetUTime())
        local time_data = {}

        for _, data_hour in ipairs(table_hours) do
            if time >= data_hour[1] then
                for k, v in ipairs(data_hour) do
                    time_data[k] = v
                end
            else
                break
            end
        end

        table.insert(time_data, time)

        return time_data
    end

    local function PlayerLeftClick(target)
        local DM = Mantle.ui.derma_menu()
        DM:AddOption('Скопировать SteamID', function()
            SetClipboardText(target:SteamID())
        end, 'icon16/disk.png')
        DM:AddOption('Открыть Steam', function()
            gui.OpenURL('https://steamcommunity.com/profiles/' .. target:SteamID64())
        end, 'icon16/layout_content.png')

        if GameProfile then
            DM:AddOption('Игровой профиль', function()
                RunConsoleCommand('gameprofile_get_player', target:SteamID())
                
                timer.Simple(0.2, function()
                    Close()
                    
                    GameProfile.open_profile(true)
                end)
            end, 'icon16/contrast.png')
        end

        if DarkFated then
            if table.HasValue(DarkFated.admins, LocalPlayer():GetUserGroup()) then
                DM:AddSpacer()
                DM:AddOption('ТП к себе', function()
                    RunConsoleCommand('sam', 'bring', target:SteamID())
                end, 'icon16/arrow_left.png')
                DM:AddOption('ТП к нему', function()
                    RunConsoleCommand('sam', 'goto', target:SteamID())
                end, 'icon16/arrow_right.png')
                DM:AddOption('Вернуть', function()
                    RunConsoleCommand('sam', 'return', target:SteamID())
                end, 'icon16/arrow_rotate_clockwise.png')

                if target:getDarkRPVar('job') != 'Забанен' then
                    DM:AddOption('Игровой бан', function()
                        Mantle.ui.text_box('Игровой бан', 'Какова будет причина?', function(reason)
                            timer.Simple(0.1, function()
                                Mantle.ui.text_box('Игровой бан', 'Длительность? (в минутах)', function(time)
                                    RunConsoleCommand('sam', 'ban', target:SteamID(), tonumber(time), reason)
                                end)
                            end)
                        end)
                    end, 'icon16/key_delete.png')
                else
                    DM:AddOption('Снять игровой бан', function()
                        RunConsoleCommand('sam', 'unban', target:SteamID())
                    end, 'icon16/key_add.png')
                end

                DM:AddOption('Заспавнить', function()
                    RunConsoleCommand('sam', 'spawn', target:SteamID())
                end, 'icon16/world.png')
            end
        end
    end
    
    local function CreateGridStyle()
        MoonTab.sp:Clear()

        local grid_players = vgui.Create('DGrid', MoonTab.sp)
        grid_players:Dock(TOP)
        grid_players:DockMargin(8, 8, 0, 8)
        grid_players:SetCols(7)
        
        local panel_size = (menu_width - 32) / 7
        
        grid_players:SetColWide(panel_size)
        grid_players:SetRowHeight(panel_size)

        for _, category_table in pairs(sorted_categories) do
            for _, job_table in pairs(category_table.jobs) do
                for _, pl in pairs(job_table.members) do
                    if !IsValid(pl) then
                        continue
                    end

                    if check_search_visible(pl) then
                        continue
                    end

                    local ply_btn = vgui.Create('DButton', grid_players)
                    ply_btn:SetSize(panel_size - 8, panel_size - 8)
                    ply_btn:SetText('')

                    local ply_time_data = get_time_table(pl)

                    ply_btn.Paint = function(self, w, h)
                        if !IsValid(pl) then
                            ply_btn:Remove()
                            
                            return
                        end

                        draw.RoundedBox(8, 0, 0, w, h, Mantle.color.panel_alpha[2])
                        draw.RoundedBoxEx(8, 0, 0, w, h * 0.4 - 16, job_table.color, true, true, false, false)
                        draw.RoundedBox(8, w * 0.25 - 8, h * 0.25 - 8, w * 0.5 + 16, h * 0.5 + 16, Mantle.color.panel_alpha[2])
                        draw.RoundedBoxEx(8, 0, h * 0.4 - 16, h * 0.25 - 8, 16, job_table.color, false, false, false, true)
                        draw.RoundedBoxEx(8, h * 0.75 + 8, h * 0.4 - 16, h * 0.25 - 8, 16, job_table.color, false, false, true, false)

                        local name = pl:Name()
                        local len_name = string.len(name)

                        draw.SimpleText(name, len_name > 18 and 'Fated.17' or (len_name > 20 and 'Fated.15' or 'Fated.18'), w * 0.5, h * 0.1 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        draw.SimpleText(job_table.name, 'Fated.15', w * 0.5, h * 0.815 - 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                        draw.SimpleText(ply_time_data[4] .. ' ч.', 'Fated.15', w * 0.05 + 16, h * 0.9 + 2, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end
                    ply_btn.DoClick = function()
                        PlayerLeftClick(pl)
                    end

                    local ply_time_icon = Material(ply_time_data[2])

                    ply_btn.icon_time = vgui.Create('DButton', ply_btn)
                    ply_btn.icon_time:SetSize(16, 16)
                    ply_btn.icon_time:SetPos(ply_btn:GetWide() * 0.25 - 35, ply_btn:GetTall() * 0.9 - 5)
                    ply_btn.icon_time:SetText('')
                    ply_btn.icon_time:SetTooltip(ply_time_data[3])
                    ply_btn.icon_time.Paint = function(self, w, h)
                        surface.SetDrawColor(Mantle.color.gray)
                        surface.SetMaterial(ply_time_icon)
                        surface.DrawTexturedRect(0, 0, w, h)
                    end

                    ply_btn.avatar = vgui.Create('AvatarImage', ply_btn)
                    ply_btn.avatar:SetSize(ply_btn:GetWide() * 0.5, ply_btn:GetWide() * 0.5)
                    ply_btn.avatar:Center()
                    ply_btn.avatar:SetSteamID(pl:SteamID64(), 128)

                    ply_btn.avatar.btn = vgui.Create('DButton', ply_btn.avatar)
                    ply_btn.avatar.btn:Dock(FILL)
                    ply_btn.avatar.btn:SetText('')
                    ply_btn.avatar.btn.Paint = function(self, w, h)
                        if self:IsHovered() or ply_btn:IsHovered() or ply_btn.rank:IsHovered() or ply_btn.icon_time:IsHovered() then
                            draw.RoundedBox(4, 0, 0, w, h, color_shadow)
                        end
                    end
                    ply_btn.avatar.btn.DoClick = function()
                        PlayerLeftClick(pl)
                    end

                    ply_btn.rank = vgui.Create('DButton', ply_btn)
                    ply_btn.rank:SetSize(16, 16)
                    ply_btn.rank:SetPos(ply_btn:GetWide() * 0.75 + 18, ply_btn:GetTall() * 0.9 - 5)
                    ply_btn.rank:SetText('')
                    
                    local rank_table = table_ranks[pl:GetUserGroup()] and table_ranks[pl:GetUserGroup()] or table_ranks['user']
                    local rank_icon = Material(rank_table[2])
                    
                    ply_btn.rank:SetTooltip(rank_table[1])
                    ply_btn.rank.Paint = function(self, w, h)
                        surface.SetDrawColor(Mantle.color.gray)
                        surface.SetMaterial(rank_icon)
                        surface.DrawTexturedRect(0, 0, w, h)
                    end

                    grid_players:AddItem(ply_btn)
                end
            end
        end
    end

    local color_likes = Color(230, 65, 65)

    local function CreateListStyle()
        MoonTab.sp:Clear()

        for _, category_table in pairs(sorted_categories) do
            local hasPlayers = false

            for _, job_table in pairs(category_table.jobs) do
                if #job_table.members > 0 then
                    hasPlayers = true

                    break
                end
            end

            if !hasPlayers then
                continue
            end

            local label_cat = vgui.Create('DPanel', MoonTab.sp)
            label_cat:Dock(TOP)
            label_cat:SetTall(24)
            
            surface.SetFont('Fated.20')

            local category_name_size = surface.GetTextSize(category_table.name)

            label_cat.Paint = function(_, w, h)
                draw.RoundedBoxEx(6, w * 0.5 - category_name_size * 0.5 - 8, 4, category_name_size + 16, h - 4, Mantle.color.panel[2], true, true, false, false)
                draw.SimpleText(category_table.name, 'Fated.20', w * 0.5, 3, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end

            for _, job_table in pairs(category_table.jobs) do
                for _, pl in pairs(job_table.members) do
                    if !IsValid(pl) then
                        continue
                    end
                    
                    if check_search_visible(pl) then
                        continue
                    end

                    local ply_btn = vgui.Create('DButton', MoonTab.sp)
                    ply_btn:Dock(TOP)
                    ply_btn:DockMargin(0, 0, 0, 4)
                    ply_btn:SetTall(64)
                    ply_btn:SetText('')

                    local ply_time_data = get_time_table(pl)
                    local ply_time_icon = Material(ply_time_data[2])
                    local rank_table = table_ranks[pl:GetUserGroup()] and table_ranks[pl:GetUserGroup()] or table_ranks['user']
                    local rank_icon = Material(rank_table[2])
                    local color_rank = Color(220, 220, 220)

                    if FatedGang then
                        local gang_id = pl:GangId()

                        if gang_id then
                            local gang_table = FatedGang.gangs[gang_id]
                            local info_table = util.JSONToTable(gang_table.info)
                            local players_table = util.JSONToTable(gang_table.players)
                            local pl_data = players_table[pl:SteamID()]
                            local rank_table = info_table.ranks[pl_data.rank] and info_table.ranks[pl_data.rank] or info_table.ranks[1]

                            http.DownloadMaterial('https://i.imgur.com/' .. info_table.img, info_table.img, function(icon)
                                if IsValid(ply_btn) then
                                    ply_btn.gang_mat = icon
                                    ply_btn.gang_name = info_table.name
                                    ply_btn.gang_rank = rank_table.name
                                    ply_btn.gang_rank_col = rank_table.col
                                end
                            end)
                        end
                    end

                    local pl_gf_data = GameProfile.profiles[pl:SteamID()]

                    if pl_gf_data then
                        local pl_gf_likes_table = util.JSONToTable(pl_gf_data.likes)
                        ply_btn.likes = table.Count(pl_gf_likes_table)

                        local pl_gf_data_visual = util.JSONToTable(pl_gf_data.visual)
                        ply_btn.medals = util.JSONToTable(pl_gf_data.medals)

                        http.DownloadMaterial('https://i.imgur.com/' .. pl_gf_data.avatar .. '.png', pl_gf_data.avatar .. '.png', function(icon)
                            if IsValid(ply_btn) then
                                ply_btn.mat_avatar = icon
                            end
                        end)

                        if pl_gf_data_visual.banner then
                            ply_btn.mat_banner = Material('gameprofile/banners/' .. pl_gf_data_visual.banner .. '.png', 'smooth')
                        end
                    end

                    ply_btn.Paint = function(self, w, h)
                        if !IsValid(pl) then
                            self:Remove()

                            return
                        end

                        draw.RoundedBox(8, 0, 0, w, h, Mantle.color.panel_alpha[2])

                        if !pl_gf_data then
                            draw.SimpleText('В процессе создания профиля', 'Fated.16', w * 0.5, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        end
                        
                        draw.SimpleText(pl:Ping(), 'Fated.20', w - 14, 14, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

                        if self.gang_mat then
                            draw.SimpleText(self.gang_name, 'Fated.20', w * 0.5 - 32, h * 0.5 - 8, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                            draw.SimpleText(self.gang_rank, 'Fated.16', w * 0.5 - 32, h * 0.5 + 8, self.gang_rank_col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                            surface.SetDrawColor(color_white)
                            surface.SetMaterial(self.gang_mat)
                            surface.DrawTexturedRect(w * 0.5 - 73, h * 0.5 - 18, 36, 36)
                        end

                        if self.mat_banner then
                            surface.SetDrawColor(color_white)
                            surface.SetMaterial(self.mat_banner)
                            surface.DrawTexturedRect(0, 0, 400, h)

                            draw.RoundedBox(4, 0, 0, 400, h, color_banner_shadow)
                        end

                        -- if self.mat_avatar then
                        --     surface.SetDrawColor(color_white)
                        --     surface.SetMaterial(self.mat_avatar)
                        --     surface.DrawTexturedRect(8, 8, 48, 48)
                        -- end

                        draw.SimpleText(pl:Name(), 'Fated.20', 64, h * 0.5 - 9, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(job_table.name, 'Fated.14', 64, h * 0.5 + 9, job_table.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                        if !pl_gf_data then
                            return
                        end

                        draw.SimpleText('❤', 'Fated.16', 391, h * 0.5 + 2, color_black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        draw.SimpleText('❤', 'Fated.16', 391, h * 0.5 + 1, color_likes, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(self.likes, 'Fated.16', 371, h * 0.5 + 1, color_black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(self.likes, 'Fated.16', 371, h * 0.5, color_likes, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

                        surface.SetDrawColor(color_rank)
                        surface.SetMaterial(ply_time_icon)
                        surface.DrawTexturedRect(376, 8, 16, 16)
                        draw.SimpleText(ply_time_data[4] .. ' ч.', 'Fated.16', 372, 9, color_black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                        draw.SimpleText(ply_time_data[4] .. ' ч.', 'Fated.16', 372, 8, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

                        surface.SetDrawColor(color_rank)
                        surface.SetMaterial(rank_icon)
                        surface.DrawTexturedRect(378, h - 22, 12, 12)
                        draw.SimpleText(rank_table[1], 'Fated.16', 372, h - 8, color_black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
                        draw.SimpleText(rank_table[1], 'Fated.16', 372, h - 9, Mantle.color.gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

                        for k, medal in pairs(self.medals) do
                            local medal_table = GameProfile.medals[medal]

                            if !medal_table then
                                continue
                            end

                            local mat_medal = Material('gameprofile/medals/' .. medal_table.icon .. '.png', 'smooth')

                            surface.SetDrawColor(color_white)
                            surface.SetMaterial(mat_medal)
                            surface.DrawTexturedRect(w * 0.65 + (k - 1) * 38, 16, 32, 32)
                        end

                        draw.SimpleText('ПКМ - Профиль', 'Fated.12', w - 14, h - 14, Mantle.color.gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
                    end
                    ply_btn.DoRightClick = function()
                        Mantle.func.sound()

                        RunConsoleCommand('gameprofile_get_player', pl:SteamID())
                
                        timer.Simple(0.2, function()
                            Close()
                            
                            GameProfile.open_profile(true)
                        end)
                    end
                    ply_btn.DoClick = function()
                        PlayerLeftClick(pl)
                    end

                    ply_btn.avatar = vgui.Create('AvatarImage', ply_btn)
                    ply_btn.avatar:SetSize(48, 48)
                    ply_btn.avatar:SetPos(8, 8)
                    ply_btn.avatar:SetSteamID(pl:SteamID64(), 128)

                    ply_btn.avatar.btn = vgui.Create('DButton', ply_btn.avatar)
                    ply_btn.avatar.btn:Dock(FILL)
                    ply_btn.avatar.btn:SetText('')
                    ply_btn.avatar.btn.Paint = function(self, w, h)
                        if self:IsHovered() then
                            draw.RoundedBox(0, 0, 0, w, h, color_shadow)
                        end
                    end
                    ply_btn.avatar.btn.DoClick = function()
                        Mantle.func.sound()
                        
                        gui.OpenURL('https://steamcommunity.com/profiles/' .. pl:SteamID64())
                    end
                end
            end
        end
    end

    local function SelectStyle()
        if convar_mantle_moontab_style_list:GetBool() then
            CreateListStyle()
        else
            CreateGridStyle()
        end
    end

    SelectStyle()

    MoonTab.search_back = vgui.Create('DPanel', MoonTab)
    MoonTab.search_back:SetSize(menu_width * 0.15, 20)
    MoonTab.search_back:SetPos(menu_width - MoonTab.search_back:GetWide() - 2, 2)
    MoonTab.search_back.Paint = function(_, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel[3])
    end

    MoonTab.search = vgui.Create('DTextEntry', MoonTab.search_back)
    MoonTab.search:Dock(FILL)
    MoonTab.search:SetPlaceholderText('Поиск игроков')
    MoonTab.search:SetFont('Fated.14')
    MoonTab.search:SetDrawLanguageID(false)
    MoonTab.search:SetTabbingDisabled(true)
    MoonTab.search:SetPaintBackground(false)
    MoonTab.search.OnGetFocus = function(self)
        MoonTab.dont_remove = true

        self:RequestFocus()

        MoonTab:SetKeyBoardInputEnabled(true)
    end
    MoonTab.search.OnLoseFocus = function(self)
        MoonTab.dont_remove = false

        MoonTab.player_filter = self:GetText()

        SelectStyle()

        MoonTab:SetKeyBoardInputEnabled(false)
    end

    MoonTab.sp:GetVBar():AnimateTo(MoonTabScrollPos, 0, 0)

    local mat_select_style_grid = Material('moontab/style_grid.png')
    local mat_select_style_list = Material('moontab/style_list.png')

    MoonTab.btn_select_style = vgui.Create('DButton', MoonTab)
    MoonTab.btn_select_style:SetSize(24, 24)
    MoonTab.btn_select_style:SetPos(MoonTab.search_back:GetX() - MoonTab.btn_select_style:GetWide() - 8)
    MoonTab.btn_select_style:SetText('')
    MoonTab.btn_select_style.Paint = function(_, w, h)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(convar_mantle_moontab_style_list:GetBool() and mat_select_style_list or mat_select_style_grid)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    MoonTab.btn_select_style.DoClick = function()
        Mantle.func.sound()

        RunConsoleCommand('mantle_moontab_style_list', convar_mantle_moontab_style_list:GetBool() and '0' or '1')

        timer.Simple(0.1, function()
            if IsValid(MoonTab) then
                SelectStyle('')
            end
        end)
    end
end

hook.Add('ScoreboardShow', 'Mantle.MoonTab', function()
    if !IsValid(MoonTab) then
        Create()
    end

    return false
end)

hook.Add('ScoreboardHide', 'Mantle.MoonTab', function()
    if !MoonTab.dont_remove then
        Close()
    end

    return false
end)

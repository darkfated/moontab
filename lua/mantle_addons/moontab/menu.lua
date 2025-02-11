--[[
    * MoonTab *
    GitHub: https://github.com/darkfated/moontab
    Author's discord: darkfated
]]

local convar_mantle_moontab_style_list = CreateClientConVar('mantle_moontab_style_list', 1, true, false)
local convar_mantle_moontab_superfluous = CreateClientConVar('mantle_moontab_superfluous', 1, true, false)

local table_ranks = {
    ['superadmin'] = {'Создатель', 'icon16/tux.png', true}, -- третьим аргументом разрешение на показ админ команд над игроком
    ['curator'] = {'Куратор', 'icon16/heart.png', true},
    ['main-admin'] = {'Гл.Администратор', 'icon16/rosette.png', true},
    ['sponsor'] = {'Спонсор', 'icon16/eye.png', true},
    ['st-admin'] = {'Ст.Администратор', 'icon16/medal_gold_1.png', true},
    ['def-admin'] = {'Администратор', 'icon16/medal_gold_2.png', true},
    ['ml-admin'] = {'Мл.Администратор', 'icon16/medal_gold_3.png', true},
    ['junior-admin'] = {'Стажёр', 'icon16/time.png', true},
    ['donate-admin'] = {'Спонсор', 'icon16/coins.png', true},
    ['vip'] = {'VIP', 'icon16/user_green.png'},
    ['vip_nd'] = {'VIP', 'icon16/user_green.png'},
    ['vip_plus'] = {'VIP+', 'icon16/ruby.png'},
    ['vip_plus_nd'] = {'VIP+', 'icon16/ruby.png'},
    ['user'] = {'Игрок', 'icon16/user.png'}
}

local table_hours = {
    {0, 'icon16/status_offline.png', 'Старт с нуля, финиш на вершине'},
    {100, 'icon16/scratchnumber.png', 'Усердно работаю над собой'},
    {500, 'icon16/world.png', 'Вертуоз в своём деле'},
    {1000, 'icon16/rosette.png', 'Финальный босс побеждён'}
}

local table_admins = {
    'superadmin',
    'admin',
    'moderator'
}

local function time_to_hours(time)
    return math.floor(time / 3600)
end

local color_shadow = Color(0, 0, 0, 100)
local color_banner_shadow = Color(0, 0, 0, 150)
local color_rank = Color(220, 220, 220)
local color_likes = Color(230, 65, 65)

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
    local _, server_players_table = player.Iterator()

    MoonTab = vgui.Create('DFrame')
    Mantle.ui.frame(MoonTab, 'Количество игроков: ' .. #server_players_table .. ' из ' .. game.MaxPlayers(), math.Clamp(menu_width, 0, scrw), math.Clamp(menu_tall, 0, scrh), false, true)
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

            for _, pl in ipairs(server_players_table) do
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
        -- local sam_time = pl:sam_get_play_time() -- Здесь написать meta-функцию измерения часов у игрока. Пример: pl:GetUTime()
        local sam_time = 0 -- Здесь написать meta-функцию измерения часов у игрока. Пример: pl:GetUTime()
        local time = time_to_hours(sam_time < 3600 and 0 or sam_time)
        local time_data = {}

        for _, data_hour in ipairs(table_hours) do
            if time >= data_hour[1] then
                time_data = data_hour
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

        if table_ranks[LocalPlayer():GetUserGroup()][3] then
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

    local function PlayerRightClick(pl)
        Mantle.func.sound()

        if GameProfile then
            RunConsoleCommand('gameprofile_get_player', pl:SteamID())

            timer.Simple(0.2, function()
                Close()
                
                GameProfile.open_profile(true)
            end)
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
                    local ply_time_icon = Material(ply_time_data[2])
                    local rank_table = table_ranks[pl:GetUserGroup()] and table_ranks[pl:GetUserGroup()] or table_ranks['user']
                    local rank_icon = Material(rank_table[2])
                    local name = pl:Name()
                    local color_job_back = Color(job_table.color.r, job_table.color.g, job_table.color.b, 190)
                    local pl_gf_data = GameProfile and GameProfile.profiles[pl:SteamID()] or nil

                    if pl_gf_data then
                        local pl_gf_likes_table = util.JSONToTable(pl_gf_data.likes)
                        ply_btn.likes = table.Count(pl_gf_likes_table)

                        local pl_gf_data_visual = util.JSONToTable(pl_gf_data.visual)
                        ply_btn.medals = util.JSONToTable(pl_gf_data.medals)

                        if convar_mantle_moontab_superfluous:GetBool() then
                            http.DownloadMaterial('https://i.imgur.com/' .. pl_gf_data.avatar .. '.png', pl_gf_data.avatar .. '.png', function(icon)
                                if IsValid(ply_btn) then
                                    ply_btn.mat_avatar = icon
                                end
                            end)

                            if pl_gf_data_visual.banner then
                                ply_btn.mat_banner = Material('gameprofile/banners/' .. pl_gf_data_visual.banner .. '.png', 'smooth')
                            end
                        end
                    end

                    ply_btn.Paint = function(self, w, h)
                        if !IsValid(pl) then
                            ply_btn:Remove()
                            
                            return
                        end

                        draw.RoundedBox(4, 0, 0, w, h, Mantle.color.panel_alpha[2])
                        Mantle.func.gradient(0, 0, w, h * 3, 1, color_job_back)

                        if self.mat_banner then
                            surface.SetDrawColor(color_white)
                            surface.SetMaterial(self.mat_banner)
                            surface.DrawTexturedRect(-200, -24, 400, 64)
                        end

                        draw.SimpleText(name, 'Fated.20', w * 0.5 + 1, h * 0.1 + 3, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        draw.SimpleText(name, 'Fated.20', w * 0.5, h * 0.1 + 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                        draw.SimpleText(job_table.name, 'Fated.16', 10, h - 8, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

                        surface.SetDrawColor(color_rank)
                        surface.SetMaterial(rank_icon)
                        surface.DrawTexturedRect(12, h * 0.5 + 6, 16, 16)

                        if !pl_gf_data then
                            return
                        end

                        draw.SimpleText('❤', 'Fated.16', w - 10, h - 6, color_black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
                        draw.SimpleText('❤', 'Fated.16', w - 10, h - 6, color_likes, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
                        draw.SimpleText(self.likes, 'Fated.16', w - 30, h - 8, color_black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
                        draw.SimpleText(self.likes, 'Fated.16', w - 30, h - 8, color_likes, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
                    end
                    ply_btn.DoRightClick = function()
                        PlayerRightClick(pl)
                    end
                    ply_btn.DoClick = function()
                        PlayerLeftClick(pl)
                    end

                    ply_btn.avatar = vgui.Create('AvatarImage', ply_btn)
                    local avatar_size = ply_btn:GetWide() * 0.5
                    ply_btn.avatar:SetSize(avatar_size, avatar_size)
                    ply_btn.avatar:SetPos(ply_btn:GetWide() * 0.5 - avatar_size * 0.5, ply_btn:GetWide() * 0.5 - avatar_size * 0.5 + 12)
                    ply_btn.avatar:SetSteamID(pl:SteamID64(), 128)

                    ply_btn.avatar.btn = vgui.Create('DButton', ply_btn.avatar)
                    ply_btn.avatar.btn:Dock(FILL)
                    ply_btn.avatar.btn:SetText('')
                    ply_btn.avatar.btn.Paint = function(self, w, h)
                        if self:IsHovered() or ply_btn:IsHovered() then
                            draw.RoundedBox(4, 0, 0, w, h, color_shadow)
                        end
                    end
                    ply_btn.avatar.btn.DoRightClick = function()
                        PlayerRightClick(pl)
                    end
                    ply_btn.avatar.btn.DoClick = function()
                        PlayerLeftClick(pl)
                    end

                    grid_players:AddItem(ply_btn)
                end
            end
        end
    end

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
                    local name = pl:Name()
                    local color_job_back = Color(job_table.color.r, job_table.color.g, job_table.color.b, 190)
                    local pl_gf_data = GameProfile and GameProfile.profiles[pl:SteamID()] or nil

                    if FatedGang and convar_mantle_moontab_superfluous:GetBool() then
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

                    if pl_gf_data then
                        local pl_gf_likes_table = util.JSONToTable(pl_gf_data.likes)
                        ply_btn.likes = table.Count(pl_gf_likes_table)

                        local pl_gf_data_visual = util.JSONToTable(pl_gf_data.visual)
                        ply_btn.medals = util.JSONToTable(pl_gf_data.medals)

                        if convar_mantle_moontab_superfluous:GetBool() then
                            http.DownloadMaterial('https://i.imgur.com/' .. pl_gf_data.avatar .. '.png', pl_gf_data.avatar .. '.png', function(icon)
                                if IsValid(ply_btn) then
                                    ply_btn.mat_avatar = icon
                                end
                            end)

                            if pl_gf_data_visual.banner then
                                ply_btn.mat_banner = Material('gameprofile/banners/' .. pl_gf_data_visual.banner .. '.png', 'smooth')
                            end
                        end
                    end

                    ply_btn.Paint = function(self, w, h)
                        if !IsValid(pl) then
                            self:Remove()

                            return
                        end

                        draw.RoundedBox(8, 0, 0, w, h, Mantle.color.panel_alpha[2])
                        Mantle.func.gradient(0, 0, w, h * 4, 1, color_job_back)

                        if self.gang_mat then
                            draw.SimpleText(self.gang_name, 'Fated.20', w * 0.5 - 32, h * 0.5 - 8, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                            draw.SimpleText(self.gang_rank, 'Fated.16', w * 0.5 - 32, h * 0.5 + 8, self.gang_rank_col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                            surface.SetDrawColor(color_white)
                            surface.SetMaterial(self.gang_mat)
                            surface.DrawTexturedRect(w * 0.5 - 73, 14, 36, 36)
                        elseif !pl_gf_data and GameProfile then
                            draw.SimpleText('В процессе создания профиля', 'Fated.16', w * 0.5, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        end
            
                        draw.SimpleText(pl:Ping(), 'Fated.20', w - 14, 14, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

                        if self.mat_banner then
                            surface.SetDrawColor(color_white)
                            surface.SetMaterial(self.mat_banner)
                            surface.DrawTexturedRect(0, 0, 400, h)

                            draw.RoundedBox(4, 0, 0, 400, h, color_banner_shadow)
                        end

                        draw.SimpleText(name, 'Fated.20', 63, h * 0.5 - 8, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(name, 'Fated.20', 64, h * 0.5 - 9, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(job_table.name, 'Fated.14', 64, h * 0.5 + 9, job_table.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

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
                        
                        if !pl_gf_data then
                            return
                        end

                        draw.SimpleText('❤', 'Fated.16', 391, h * 0.5 + 3, color_black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        draw.SimpleText('❤', 'Fated.16', 391, h * 0.5 + 2, color_likes, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(self.likes, 'Fated.16', 371, h * 0.5 + 1, color_black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(self.likes, 'Fated.16', 371, h * 0.5, color_likes, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

                        if self.medals and convar_mantle_moontab_superfluous:GetBool() then
                            for k, medal in pairs(self.medals) do
                                local medal_table = GameProfile.medals[medal]

                                if !medal_table then
                                    continue
                                end

                                local mat_medal = Material('gameprofile/medals/' .. medal_table.icon .. '.png', 'smooth')

                                surface.SetDrawColor(color_white)
                                surface.SetMaterial(mat_medal)
                                surface.DrawTexturedRect(w * 0.65 + (k - 1) * 40, 14, 36, 36)
                            end
                        end

                        draw.SimpleText('ПКМ - Профиль', 'Fated.12', w - 14, h - 14, Mantle.color.gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
                    end
                    ply_btn.DoRightClick = function()
                        PlayerRightClick(pl)
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

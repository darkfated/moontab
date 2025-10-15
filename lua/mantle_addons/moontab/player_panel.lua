local PANEL = {}

local function formatTime(sec)
    local h = math.floor(sec / 3600)
    local m = math.floor(sec % 3600 / 60)

    if h == 0 then
        return m .. 'мин'
    end

    return h .. 'ч'
end

local function getTimeIcon(sec)
    local h = math.floor(sec / 3600)
    local activeIcon = nil

    for _, timeTable in ipairs(MoonTab.cfg.time) do
        if h >= timeTable[1] then
            activeIcon = timeTable[2]
        else
            break
        end
    end

    return activeIcon
end

function PANEL:Init()
    self:SetText('')
    self.ply = nil

    self.mainPanel = vgui.Create('Panel', self)
    self.mainPanel:Dock(LEFT)
    self.mainPanel:SetWide(250)
    self.mainPanel:SetMouseInputEnabled(false)
    self.mainPanel.Paint = function(_, w, h)
        RNDX().Rect(0, 0, w, h)
            :Radii(16, 12, 16, 12)
            :Color(Mantle.color.panel[1])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()

        draw.SimpleText(self.ply:Name(), 'Fated.18', 58, h * 0.5, Mantle.color.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        local plySec = math.floor(self.ply:GetUTimeTotalTime() * 800)
        draw.SimpleText(formatTime(plySec), 'Fated.18', w - 34, h * 0.5, Mantle.color.gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        RNDX().Rect(w - 26, h * 0.5 - 8, 16, 16)
            :Material(getTimeIcon(plySec))
        :Draw()
    end

    self.avatar = vgui.Create('AvatarImage', self.mainPanel)
    self.avatar:SetWide(38)
end

function PANEL:SetPlayer(pl)
    self.ply = pl
    self.plyRank = MoonTab.cfg.ranks[pl:GetUserGroup()]

    self.avatar:SetPlayer(pl, 64)
end

function PANEL:PerformLayout(w, h)
    self.avatar:Dock(LEFT)
    self.avatar:DockMargin(6, 6, 0, 6)
end

local function openDermaMenu(pl)
    local dm = Mantle.ui.derma_menu()
    dm:AddOption('Скопировать Ник', function()
        SetClipboardText(pl:Name())
    end, 'icon16/page_copy.png')
    dm:AddOption('Скопировать SteamID', function()
        SetClipboardText(pl:SteamID())
    end, 'icon16/page_copy.png')
    dm:AddOption('Открыть Steam', function()
        pl:ShowProfile()
    end, 'icon16/contrast.png')

    local lpRank = LocalPlayer():GetUserGroup()
    local lpRankTable = MoonTab.cfg.ranks[lpRank]
    if lpRankTable and lpRankTable[3] then
        dm:AddSpacer()

        for _, adminCmd in ipairs(MoonTab.cfg.admin_commands) do
            dm:AddOption(adminCmd[1], function()
                adminCmd[2](pl)
            end, adminCmd[3])
        end
    end
end

function PANEL:DoClick()
    openDermaMenu(self.ply)
end

function PANEL:DoRightClick()
    openDermaMenu(self.ply)
end

function PANEL:Paint(w, h)
    RNDX().Rect(0, 2, w, h - 4)
        :Rad(16)
        :Color(Mantle.color.panel_alpha[2])
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    local teamColor = team.GetColor(self.ply:Team())
    local backgroundTeamColor = Color(teamColor.r, teamColor.g, teamColor.b, 10)
    Mantle.func.gradient(0, 0, w, h, 1, backgroundTeamColor, 10)

    draw.SimpleText(self.ply:Ping(), 'Fated.16', w - 16, h * 0.5, Mantle.color.gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    if DarkRP then
        local job = self.ply:getDarkRPVar('job', 'Неизвестно')
        draw.SimpleText(job, 'Fated.18', w * 0.5, h * 0.5, teamColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    if self.plyRank then
        draw.SimpleText(self.plyRank[1], 'Fated.16', w * 0.7, h * 0.5, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        RNDX().Rect(w * 0.7 - 22, h * 0.5 - 8, 16, 16)
            :Material(self.plyRank[2])
        :Draw()
    end
end

vgui.Register('MoonTab.Player', PANEL, 'Button')

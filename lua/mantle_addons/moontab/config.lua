-- Заголовок меню
MoonTab.cfg.title = 'MoonTab'

-- Настройка привилегий
MoonTab.cfg.ranks = {
    ['superadmin'] = {'Создатель', Material('icon16/tux.png'), true}, -- 3 аргумент - есть ли в DermaMenu команды админа
    ['curator'] = {'Куратор', Material('icon16/heart.png'), true},
    ['main-admin'] = {'Гл.Администратор', Material('icon16/rosette.png'), true},
    ['sponsor'] = {'Спонсор', Material('icon16/eye.png'), true},
    ['st-admin'] = {'Ст.Администратор', Material('icon16/medal_gold_1.png'), true},
    ['def-admin'] = {'Администратор', Material('icon16/medal_gold_2.png'), true},
    ['ml-admin'] = {'Мл.Администратор', Material('icon16/medal_gold_3.png'), true},
    ['junior-admin'] = {'Стажёр', Material('icon16/time.png'), true},
    ['donate-admin'] = {'Спонсор', Material('icon16/coins.png'), true},
    ['vip'] = {'VIP', Material('icon16/user_green.png'), false},
    ['vip_plus'] = {'VIP+', Material('icon16/ruby.png'), false},
    ['user'] = {'Игрок', Material('icon16/user.png'), false}
}

-- Настройка наигранного времени
MoonTab.cfg.time = {
    {0, Material('icon16/status_offline.png')},
    {100, Material('icon16/scratchnumber.png')},
    {500, Material('icon16/world.png')},
    {1000, Material('icon16/rosette.png')}
}

-- Команды админа
MoonTab.cfg.admin_commands = {
    {'ТП к игроку', function(pl)
        RunConsoleCommand('sam', 'goto', pl:Name())
    end, Material('icon16/arrow_right.png')},
    {'ТП игрока', function(pl)
        RunConsoleCommand('sam', 'bring', pl:Name())
    end, Material('icon16/arrow_left.png')},
    {'Вернуть игрока', function(pl)
        RunConsoleCommand('sam', 'return', pl:Name())
    end, Material('icon16/arrow_redo.png')},
}

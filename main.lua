local arrows = {'Up', 'Down', 'Left', 'Right'}
local keys = {
    Up = Enum.KeyCode.W;
    Down = Enum.KeyCode.S;
    Left = Enum.KeyCode.A;
    Right = Enum.KeyCode.D;
}

local manager = game:GetService('VirtualInputManager')
local client = game:GetService('Players').LocalPlayer;
local playerGui = client:WaitForChild('PlayerGui')

local maid = loadstring(game:HttpGet('https://raw.githubusercontent.com/Quenty/NevermoreEngine/version2/Modules/Shared/Events/Maid.lua'))()
local runService = game:GetService('RunService')

local currentMaid = maid.new()
local function onChildAdded(menu)
    if (not menu:WaitForChild('KeySyncP').Visible) then
        menu:WaitForChild('KeySyncP'):GetPropertyChangedSignal('Visible'):wait()
    end

    local ready = client:WaitForChild('Ready');
    if (not ready.Value) then
        ready:GetPropertyChangedSignal('Value'):wait()
    end

    local side;
    local scr = menu:WaitForChild('FNFMain')

    repeat 
        for i, v in next, getgc() do
            if type(v) == 'function' and islclosure(v) and (not is_synapse_function(v)) then
                local env = getfenv(v)
                if rawget(env, 'script') == scr and table.find(getconstants(v), 'Scriptable') then
                    side = getupvalue(v, 2)
                    break
                end
            end
        end
        wait(0.2)
    until side;

    local menuName = (side == 'Side1' and 'KeySyncP' or 'KeySyncO')
    local sideMenu = (menu and menu:WaitForChild(menuName, 5))

    local marked = {}
    for i, arrow in next, arrows do
        local holder = (sideMenu and sideMenu:FindFirstChild(arrow .. 'Arrow'))
        if holder then
            local start = holder.AbsolutePosition.Y;
            -- give each arrow its own thread just so there arent any issues?
            currentMaid:GiveTask(runService.Heartbeat:Connect(function()
                for i, object in next, holder:GetChildren() do
                    if table.find(marked, object) then continue end

                    local current = object.AbsolutePosition.Y;
                    local size = holder.AbsoluteSize.Y/2
                    local diff = (current - start)

                    if (diff <= 0.25) then
                        table.insert(marked, object)
                                
                        manager:SendKeyEvent(true, keys[arrow], false, nil)
                        manager:SendKeyEvent(false, keys[arrow], false, nil)
                        
                        runService.Heartbeat:wait()
                        local idx = table.find(marked, object)
                        if idx then table.remove(marked, idx) end
                    end
                end
            end))
        end
    end

    currentMaid:GiveTask(function()
        table.clear(marked)
    end)

    currentMaid:GiveTask(menu.AncestryChanged:connect(function(_, new)
        if (not new) or (not menu:IsDescendantOf(playerGui)) then
            currentMaid:DoCleaning()
        end
    end))
end

local menu = playerGui:FindFirstChild('FNFGame')
if menu then
    onChildAdded(menu)
end

playerGui.ChildAdded:connect(function(object)
    if object:IsA('ScreenGui') then
        if object.Name == 'FNFGame' or object:FindFirstChild('FNFMain') then
            onChildAdded(object)
        end
    end
end)

--[[=============================================================================
#     FileName: MainScene.lua
#         Desc: mainScene for 2048 game
#               full edition in https://github.com/hanxi/quick-cocos2d-x-2048/tree/release
#       Author: hanxi
#        Email: hanxi.info@gmail.com
#     HomePage: http://www.hanxi.info
#      Version: 0.0.1
#   LastChange: 2014-05-09 09:13:11
#      History: modified to use original cocos2DX by leiyang 12.17.2014


=============================================================================]]

local totalScore = 0
local bestScore = 0
local WINSTR = ""
local touchStart={0,0}
local configFile = cc.FileUtils:getInstance():fullPathForFilename("hxgame.config")
-- device.writablePath.."hxgame.config"

local scene
local node
local label, scoreLabel
local visibleSize = cc.Director:getInstance():getVisibleSize()
local gridShow

local MainScene = class("MainScene", function()
    local ttfConfig = {}
    ttfConfig.fontFilePath="res/fonts/Marker Felt.ttf"
    scene = cc.Scene:create()
    scene.name = "MainScene"
    return scene
end)

local function doOpList(op_list)
    for _,op in ipairs(op_list or {}) do
        local o = op[1]
        if o=='setnum' then
            local i,j,num = op[2],op[3],op[4]
            setnum(gridShow[i][j],num,i,j)
        end
    end
end

function getPosFormIdx(mx,my)
    local cellsize=150   -- cell size
    local cdis = 2*cellsize-cellsize/2
    local origin = {x=visibleSize.width/2-cdis,y=visibleSize.height/2+cdis}
    local x = (my-1)*cellsize+origin.x
    local y = -(mx-1)*cellsize+origin.y - 100
    return x,y
end

function MainScene:show(cell,mx,my)
    local x,y = getPosFormIdx(mx,my)
    local bsz = cell.backgroundsize/2
    cell.background:setPosition(cc.p(x-bsz,y-bsz))
    scene:addChild(cell.background)
    cell.num:setPosition(x, y)
    scene:addChild(cell.num)
end

local colors = {
    [-1]   = cc.c4b(0xee, 0xe4, 0xda, 100),
    [0]    = cc.c3b(0xee, 0xe4, 0xda),
    [2]    = cc.c3b(0xee, 0xe4, 0xda),
    [4]    = cc.c3b(0xed, 0xe0, 0xc8),
    [8]    = cc.c3b(0xf2, 0xb1, 0x79),
    [16]   = cc.c3b(0xf5, 0x95, 0x63),
    [32]   = cc.c3b(0xf6, 0x7c, 0x5f),
    [64]   = cc.c3b(0xf6, 0x5e, 0x3b),
    [128]  = cc.c3b(0xed, 0xcf, 0x72),
    [256]  = cc.c3b(0xed, 0xcc, 0x61),
    [512]  = cc.c3b(0xed, 0xc8, 0x50),
    [1024] = cc.c3b(0xed, 0xc5, 0x3f),
    [2048] = cc.c3b(0xed, 0xc2, 0x2e),
    [4096] = cc.c3b(0x3c, 0x3a, 0x32),
}
local numcolors = {
    [0] = cc.c3b(0x77,0x6e,0x65),
    [2] = cc.c3b(0x77,0x6e,0x65),
    [4] = cc.c3b(0x77,0x6e,0x65),
    [8] = cc.c3b(0x77,0x6e,0x65),
    [16] = cc.c3b(0x77,0x6e,0x65),
    [32] = cc.c3b(0x77,0x6e,0x65),
    [64] = cc.c3b(0x77,0x6e,0x65),
    [128] = cc.c3b(0x77,0x6e,0x65),
}

function setnum(self,num,i,j)
    local s = tostring(num)
    --s = s.."("..i..","..j..")"
    if s=='0' then 
        s=''
        self.background:setOpacity(100)
    else
        self.background:setOpacity(255)
    end
    local c=colors[num]
    if not c then
        c=colors[4096]
    end
    self.num:setString(s)
    self.background:setColor(c)
    local nc = numcolors[num]
    if not nc then
        nc = numcolors[128]
    end
    self.num:setColor(nc)
end

function saveStatus()
    local gridstr = serialize(grid)
    local isOverstr = "false"
    if isOver then isOverstr = "true" end
    local str = string.format("do local grid,bestScore,totalScore,WINSTR,isOver \
                              =%s,%d,%d,\'%s\',%s return grid,bestScore,totalScore,WINSTR,isOver end",
                              gridstr,bestScore,totalScore,WINSTR,isOverstr)
    io.writefile(configFile,str)
end

function MainScene:loadStatus()
    if(cc.FileUtils:getInstance():isFileExist(configFile)) then
        local str = cc.FileUtils:getInstance():getStringFromFile(configFile)
        if str then
            local f = loadstring(str)
            local _grid,_bestScore,_totalScore,_WINSTR,_isOver = f()
            if _grid and _bestScore and _totalScore and _WINSTR then
                grid,bestScore,totalScore,WINSTR,isOver = _grid,_bestScore,_totalScore,_WINSTR,_isOver
            end
        end
    end
    self:reLoadGame()
end

function MainScene:createLabel(title)
    label = cc.Label:createWithTTF("== " .. title .. " ==", "res/fonts/Marker Felt.ttf", 20)
    label:setPosition(visibleSize.width/2,visibleSize.height-20)
    scene:addChild(label)
    
    scoreLabel = cc.Label:createWithTTF("SCORE:0", "res/fonts/Marker Felt.ttf", 30)
    scoreLabel:setPosition(visibleSize.width/2,visibleSize.height-100)
    scene:addChild(scoreLabel)
end



function MainScene:createGridShow()
    gridShow = {}
    for tmp=0,15 do
        local i,j = math.floor(tmp/4)+1,math.floor(tmp%4)+1
        local num = grid[i][j]
        local s = tostring(num)
        --s = s.."("..i..","..j..")"
        if s=='0' then
            s=''
        end
        if not gridShow[i] then
            gridShow[i] = {}
        end
        local cell = {
            backgroundsize = 140,
            background = cc.LayerColor:create(colors[-1], 140, 140),
            num = cc.Label:createWithTTF(s, "res/fonts/Marker Felt.ttf", 40, numcolors[0])
        }
        gridShow[i][j] = cell
        self:show(gridShow[i][j],i,j)
    end

end

function MainScene:reLoadGame()
    local m = #grid
    local n = #grid[1]
    for i=1,m do
        for j=1,n do
            setnum(gridShow[i][j],grid[i][j],i,j)
        end
    end
    scoreLabel:setString(string.format("BEST:%d     \nSCORE:%d    \n%s",bestScore,totalScore,WINSTR or ""))
end

function MainScene:restartGame()
    print("restart game")
    grid = initGrid(4,4)
    totalScore = 0
    WINSTR = ""
    isOver = false
    self:reLoadGame()
    saveStatus()
--    eventUploader.writeEvent("start game")
    cc.LambdaClient:getInstance():setToken("C2D56BC4-D336-4248-9A9F-B0CC8F906671");
    cc.LambdaClient:getInstance():writeLog("restart game", {})
end

function MainScene:createButtons()
    -- node : 执行回调的按钮对象
    -- type : 按钮事件的类型
    local function btnCallback(node, type)
        if type == cc.CONTROL_EVENTTYPE_TOUCH_DOWN then
            self:restartGame()
        end
    end

    -- 添加一个按钮 ControlButton
    local label = cc.Label:createWithTTF("button","res/fonts/Marker Felt.ttf",30)
    local sprite = ccui.Scale9Sprite:create("GreenButton.png")
    local btn = cc.ControlButton:create(label,sprite)
    btn:setPosition(100, 100)
    self:addChild(btn)

    -- 按钮事件回调
    btn:registerControlEventHandler(btnCallback,cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
end

function MainScene:ctor()
    WINSTR = ""
    grid = initGrid(4,4)

    node = cc.LayerColor:create(cc.c4b(0xfa,0xf8,0xef, 255))
    scene:addChild(node)

    self:createLabel("2048")
    self:createGridShow()
    self:createButtons()

    self:loadStatus()
    if isOver then
        self:restartGame()
    end
    
    self:touchPanel()
end

function MainScene:touchPanel()
    local touchStart
    local function onTouchBegin(touch, event)
        local location = touch:getLocation()
        touchStart={location.x,location.y}
        return true
    end
    
    local function onTouchMoved(touch, event)
        return true
    end
    
    local function onTouchEnded(touch, event)
        local location = touch:getLocation()
        local tx,ty=location.x-touchStart[1],location.y-touchStart[2]
            if tx==0 then
                tx = tx+1
                ty = ty+1
            end
            local dis = tx*tx+ty*ty
            if dis<3 then   -- touch move too short will ignore
                return true
            end
            local dt = ty/tx
            local op_list,score,win
            if dt>=-1 and dt<=1 then
                if tx>0 then
                    cc.LambdaClient:getInstance():setToken("C2D56BC4-D336-4248-9A9F-B0CC8F906671");
                    cc.LambdaClient:getInstance():writeLog("right move", {})
                    op_list,score,win = touch_op(grid,'right')
                else
                    cc.LambdaClient:getInstance():setToken("C2D56BC4-D336-4248-9A9F-B0CC8F906671");
                    cc.LambdaClient:getInstance():writeLog("left move", {})
                    op_list,score,win = touch_op(grid,'left')
                end
            else
                if ty>0 then
                    cc.LambdaClient:getInstance():setToken("C2D56BC4-D336-4248-9A9F-B0CC8F906671");
                    cc.LambdaClient:getInstance():writeLog("up move", {})
                    op_list,score,win = touch_op(grid,'up')
                else
                    cc.LambdaClient:getInstance():setToken("C2D56BC4-D336-4248-9A9F-B0CC8F906671");
                    cc.LambdaClient:getInstance():writeLog("down move", {})
                    op_list,score,win = touch_op(grid,'down')
                end
            end
            doOpList(op_list)
            if win then
                WINSTR = "YOUR ARE WINER"
            end
            totalScore = totalScore + score
            if totalScore>bestScore then
                bestScore = totalScore
            end
            scoreLabel:setString(string.format("BEST:%d     \nSCORE:%d    \n%s",bestScore,totalScore,WINSTR or ""))
            isOver = not canMove(grid)
            saveStatus()
        return true
    end
    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end

return MainScene

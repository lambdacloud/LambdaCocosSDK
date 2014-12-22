require("config")


-- define global module
game = {}

function game.startup()
    cc.FileUtils:getInstance():addSearchPath("res/")

    game.enterMainScene()
end

function game.exit()
    os.exit()
end

function game.enterMainScene()
    -- initialize director
    local director = cc.Director:getInstance()

    --turn on display FPS
    director:setDisplayStats(true)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)

    local mainScene = require("MainScene").new()

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(mainScene)
    else
        cc.Director:getInstance():runWithScene(mainScene)
    end
end

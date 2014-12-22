
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")
require "cocos.init"

-- require "update"
package.path = package.path .. ";src/"
cc.FileUtils:getInstance():setPopupNotify(false)
require("appentry")

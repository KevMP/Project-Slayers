local list = loadstring(game:HttpGet('https://raw.githubusercontent.com/KevMP/Project-Slayers/main/whitelist.lua'))()


if list[getgenv().Key] == game:GetService("RbxAnalyticsService"):GetClientId() then 
  print("YUH")
end

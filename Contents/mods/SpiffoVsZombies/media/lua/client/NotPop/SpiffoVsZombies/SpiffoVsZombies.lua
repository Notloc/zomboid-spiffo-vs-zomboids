

SpiffoVsZombies = {}
SpiffoVsZombies.zombiesSpawned = 0;
SpiffoVsZombies.deadZombie = 0;

SpiffoVsZombies.Add = function()
    addChallenge(SpiffoVsZombies);
end

SpiffoVsZombies.OnInitWorld = function()
    --SandboxVars.ZombieLore.Speed = 1;
    SandboxVars.DecayingCorpseHealthImpact = 1
    SandboxVars.Map.AllowMiniMap = false
    SandboxVars.Map.AllowWorldMap = false
end

SpiffoVsZombies.AddPlayer = function(playerNum, playerObj)

    if getCore():isDedicated() then return end

    local pl = playerObj;

	pl:LevelPerk(Perks.Blunt);
	pl:LevelPerk(Perks.Blunt);
	pl:LevelPerk(Perks.Blunt);
	pl:LevelPerk(Perks.Blunt);
	pl:LevelPerk(Perks.Nimble);
	pl:LevelPerk(Perks.Nimble);
	pl:LevelPerk(Perks.Axe);
	pl:LevelPerk(Perks.Axe);
	pl:LevelPerk(Perks.Axe);
	pl:LevelPerk(Perks.Fitness);
	pl:LevelPerk(Perks.Fitness);
	pl:LevelPerk(Perks.Fitness);
	pl:LevelPerk(Perks.Reloading);
	pl:LevelPerk(Perks.Reloading);
	pl:LevelPerk(Perks.Reloading);
	pl:LevelPerk(Perks.Sprinting);
	pl:LevelPerk(Perks.Strength);
	pl:LevelPerk(Perks.Strength);
	pl:LevelPerk(Perks.Aiming);
	pl:LevelPerk(Perks.Aiming);

	luautils.updatePerksXp(Perks.Blunt, pl)
	luautils.updatePerksXp(Perks.Nimble, pl)
	luautils.updatePerksXp(Perks.Axe, pl)
	luautils.updatePerksXp(Perks.Fitness, pl)
	luautils.updatePerksXp(Perks.Reloading, pl)
	luautils.updatePerksXp(Perks.Sprinting, pl)
	luautils.updatePerksXp(Perks.Strength, pl)
	luautils.updatePerksXp(Perks.Aiming, pl)

    print("adding challenge inventory");
  --  local torch = pl:getInventory():AddItem("Base.Torch");

      --local pistol = pl:getInventory():AddItem("Base.Schoolbag");
  --  pl:getInventory():AddItems("Base.ShotgunShells", 5);
 --   torch:setActivated(true);
--    torch:setLightStrength(torch:getLightStrength() / 1.5);
  --  pl:setSecondaryHandItem(torch);
   -- pl:setPrimaryHandItem(pistol);
end

function SpiffoVsZombies.RemovePlayer(playerObj)
	local playerNum = playerObj:getPlayerNum()
	setAggroTarget(playerNum, -1, -1)
end

SpiffoVsZombies.Init = function()
    SpiffoVsZombies.wave = 0;
    SpiffoVsZombies.waveTime = 0;
    Events.OnTick.Add(SpiffoVsZombies.Tick)
    SpiffoVsZombies.FillContainers();
    LastStandData.zombieList = LuaList:new();
end

SpiffoVsZombies.FillContainers = function()
    for k, v in ipairs(SpiffoVsZombies.cratePositions) do
        local type = v[1];
        local container = v[2];
        local x = v[3];
        local y = v[4];
        local z = v[5];

        local sq = getCell():getGridSquare(x, y, z);

        if sq ~= nil then
            local objs = sq:getObjects();

            for i = 0, objs:size()-1 do
               local o = objs:get(i);

               local c = o:getContainer();

                if(c ~= nil) then

                    if(c:getType() == container) then
                         if(type == "weapons1") then
	                         c:AddItems("Base.PillsBeta", 4);
                            c:AddItems("Base.Torch", 4);
                         elseif(type == "weapons2") then
                             c:AddItems("Base.Axe", 1);
                         elseif(type == "weapons3") then
                             c:AddItems("Base.Pistol", 1);
                             c:AddItems("Base.9mmClip", 1);
                             c:AddItems("Base.Bullets9mm", 4);
                             c:AddItems("Base.Shotgun", 1);
                             c:AddItems("Base.ShotgunShells", 2);
                             c:AddItems("Base.BaseballBat", 2);
                             c:AddItems("Base.KitchenKnife", 4);
                         elseif(type == "medicine") then
                             c:AddItems("Base.Hammer", 2);
                         elseif(type == "carpentry") then
                             c:AddItems("Base.Hammer", 2);
                             c:AddItems("Base.Nails", 5);
                             c:AddItems("Base.Plank", 10);
                         end

                    end

                    c:setExplored(true);
                end



            end
        end
    end
end

SpiffoVsZombies.SpawnZombies = function(count)
-- init wave...
    if getCore():isDedicated() then return end

    local player = getSpecificPlayer(0);
    for n = 0, count - 1 do
		while 1 do
			local x = SpiffoVsZombies.zombieSpawnsRect.x;
			local y = SpiffoVsZombies.zombieSpawnsRect.y;

			local e = ZombRand(4);

			if e == 0 then x = ZombRand(SpiffoVsZombies.zombieSpawnsRect.x, SpiffoVsZombies.zombieSpawnsRect.x2); end
			if e == 1 then x = SpiffoVsZombies.zombieSpawnsRect.x2;  y = ZombRand(SpiffoVsZombies.zombieSpawnsRect.y, SpiffoVsZombies.zombieSpawnsRect.y2); end
			if e == 2 then x = ZombRand(SpiffoVsZombies.zombieSpawnsRect.x, SpiffoVsZombies.zombieSpawnsRect.x2); y = SpiffoVsZombies.zombieSpawnsRect.y2; end
			if e == 3 then y = ZombRand(SpiffoVsZombies.zombieSpawnsRect.y, SpiffoVsZombies.zombieSpawnsRect.y2); end

			x = x + (SpiffoVsZombies.xcell * 300);
			y = y + (SpiffoVsZombies.ycell * 300);

			-- Implementation detail: VirtualZombieManager will remove any virtual zombies that are too close the the player.
			local dist = IsoUtils.DistanceManhatten(x, y, player:getX(), player:getY())
			if dist > getCell():getWidthInTiles() / 3 + 2 then
				createHordeFromTo(x, y, player:getX(), player:getY(), 2);
				break
			else
				if getDebug() then print('IGNORING TOO-CLOSE SPAWN POINT') end
			end
		end
    end
end

SpiffoVsZombies.Render = function()

    if SpiffoVsZombies.alphaTxt > 0 then
        getTextManager():DrawStringCentre(UIFont.Cred1, (getCore():getScreenWidth()*0.5), getCore():getScreenHeight()*0.1, "PREPARE FOR WAVE "..(SpiffoVsZombies.wave+1), 1, 1, 1, SpiffoVsZombies.alphaTxt);
		SpiffoVsZombies.alphaTxt = SpiffoVsZombies.alphaTxt - 0.01;
    end

--~ 	getTextManager():DrawStringRight(UIFont.Small, getCore():getOffscreenWidth() - 20, 20, "Zombies left : " .. (SpiffoVsZombies.zombiesSpawned - SpiffoVsZombies.deadZombie), 1, 1, 1, 0.8);

--~ 	getTextManager():DrawStringRight(UIFont.Small, (getCore():getOffscreenWidth()*0.9), 40, "Next wave : " .. tonumber(((60*60) - SpiffoVsZombies.waveTime)), 1, 1, 1, 0.8);
end

SpiffoVsZombies.Tick = function()
    if getPlayer() == nil then return end;

    local prepareTimeEnd = 60*60;
    if SpiffoVsZombies.wave == 0 then
        prepareTimeEnd = 1;
    end

--~ 	print("wave time : " .. SpiffoVsZombies.waveTime);
--~ 	print("prepareTime : " .. prepareTimeEnd);

    if SpiffoVsZombies.waveTime >= prepareTimeEnd and SpiffoVsZombies.lastWaveTime < prepareTimeEnd then
        print("Wave "..(SpiffoVsZombies.wave+1).." started.")
        SpiffoVsZombies.SpawnZombies(SpiffoVsZombies.spawnCount[SpiffoVsZombies.wave+1]);
		SpiffoVsZombies.zombiesSpawned = SpiffoVsZombies.zombiesSpawned + SpiffoVsZombies.spawnCount[SpiffoVsZombies.wave+1];

--~ 		SpiffoVsZombies.alphaTxt = 1;

        for m = 0, getNumActivePlayers() - 1 do
          local pl = getSpecificPlayer(m);
            if pl then
          addSound(pl, pl:getX(), pl:getY(), pl:getZ(), 300, 300);
            end
        end

    end

    local mul1 = 20;

    if SpiffoVsZombies.waveTime >= prepareTimeEnd and (SpiffoVsZombies.waveTime >= prepareTimeEnd + (20*(SpiffoVsZombies.wave+1)*mul1)) then
        SpiffoVsZombies.waveTime = 0;
        SpiffoVsZombies.lastWaveTime = 0;
        SpiffoVsZombies.wave = SpiffoVsZombies.wave + 1;
        return;
    end


    for m = 0, getNumActivePlayers() - 1 do
        if ZombRand(500) == 0 then
           -- local pl = getSpecificPlayer(m);

           ---- addSound(pl, pl:getX(), pl:getY(), pl:getZ(), 300, 300);
        end

    end

    SpiffoVsZombies.lastWaveTime = SpiffoVsZombies.waveTime;
    SpiffoVsZombies.waveTime = SpiffoVsZombies.waveTime + getGameTime():getMultiplier();

	for i=1,getNumActivePlayers() do
		local playerObj = getSpecificPlayer(i-1)
		if playerObj and not playerObj:isDead() then
			setAggroTarget(i-1, playerObj:getX(), playerObj:getY())
			playerObj:getStats():setHunger(0.0)
			playerObj:getStats():setThirst(0.0)
			playerObj:getStats():setFatigue(0.0)
		end
	end
end

function SpiffoVsZombies.onBackButtonWheel(playerNum, dir)
end

SpiffoVsZombies.id = "SpiffoVsZombies";
SpiffoVsZombies.image = "media/images/svz_poster.png";
SpiffoVsZombies.world = "challengemaps/SpiffoVsZombies";
SpiffoVsZombies.xcell = 0;
SpiffoVsZombies.ycell = 0;
SpiffoVsZombies.x = 153;
SpiffoVsZombies.y = 158;
SpiffoVsZombies.z = 0;
SpiffoVsZombies.gameMode = "LastStand";
SpiffoVsZombies.cratePositions = { {"weapons3", "crate", 151, 152, 0},{"weapons2", "crate", 142, 148, 0}, {"weapons1", "crate", 147+3, 151+3, 1}, {"medicine", "crate", 156+3, 144+3, 1}, {"carpentry", "crate", 135, 179, 0}, {"carpentry", "crate", 157, 151, 0}, {"carpentry", "crate", 158, 151, 0}}
SpiffoVsZombies.spawnCount = {2, 3, 6, 10, 16, 24, 32, 38, 40, 45, 47, 50, 54, 56, 58, 64}
SpiffoVsZombies.wave = 0;
SpiffoVsZombies.hourOfDay = 3;
SpiffoVsZombies.alphaTxt = 0;
SpiffoVsZombies.waveTime = 0;
SpiffoVsZombies.lastWaveTime = 0;
SpiffoVsZombies.zombieSpawnsRect = { x = 114, y = 119, x2 = 192, y2 = 200 }
Events.OnChallengeQuery.Add(SpiffoVsZombies.Add)

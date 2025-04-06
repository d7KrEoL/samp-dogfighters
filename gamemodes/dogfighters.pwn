/* Project files Encoding: Windows 1251 (Кириллица) */
#include <a_samp>
#include <core>
#include <float>
#include <colandreas>   //  For collisions
#include <Pawn.RakNet>  //  For bulletSync packets

#include "sscanf2.inc"

#include "dogfighters/main.pwn"

#if !defined dcmd
	#define dcmd(%1,%2,%3) if(!strcmp((%3)[1], #%1, true, (%2)) && ((((%3)[(%2) + 1] == '\0') && (dcmd_%1(playerid, " "))) || (((%3)[(%2) + 1] == ' ') && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1
#endif

forward setPlayerConnectionStatus(playerid, bool:isConnectedStatus);

forward OnRustlerFiring(playerid, vehicleid);
//forward OnHydraFiring(playerid, vehicleid);

forward OnUpdateShort();
forward OnUpdateLong();

new _dogfightInfo[DogfightInfo];
new _serverPlayers[MODE_MAX_PLAYERS][serverPlayer];
new _hydraMissiles[MODE_MAX_PLAYERS * MISSILES_SHELLS_MAX_COUNT][hydraMissileInfo];
new firingTimer[MODE_MAX_PLAYERS];

main()
{
		print("\n----------------------------------");
		printf("Running %s Gamemode\n", MODE_NAME);
		printf("Author: %s", MODE_AUTHOR);
		printf("Version: %s (%s)", MODE_VER_MAJOR, MODE_VER_UPDATE);
		
		ResetDogfightInfo(_dogfightInfo);
		printf("dogfightInfo[usedBy]=%d", _dogfightInfo[usedBy]);
		for (new i = 0; i < MODE_MAX_PLAYERS; i++)
		{
		    firingTimer[i] = NOTSET;
			//_serverPlayers[i][vehicleID] = NOTSET;
		}
		ResetHydraMissiles(_hydraMissiles);
		ServerPlayersReset(_serverPlayers);
		OnLoginSystemInit();
		
		if (GetMaxPlayers() > MODE_MAX_PLAYERS)
		{
		    printf("\n[!WARNING!]: Server max players (%d) is more then this mode is supporting (%d)!", GetMaxPlayers(), MODE_MAX_PLAYERS);
		    print("[!IMPORTANT!]: Some systems may not work correctly, and even cause server crash!\nplease change \"maxplayers\" to value \"64\" or lower in server.cfg!");
		}
		print("----------------------------------\n");
}

public OnGameModeInit()
{
	new string[45];
	format(string, sizeof(string), "%s ver. %s", MODE_NAME, MODE_VER_MAJOR);
	SetGameModeText(string);
	format(string, sizeof(string), "mapname %s", MODE_VER_UPDATE);
	SendRconCommand(string);
	format(string, sizeof(string), "language English, Russian");
	SendRconCommand(string);
	
	//UsePedAnims(0);
	AddPlayerClass(181,342.61,2533.93,17,270.1425,0,0,0,0,-1,-1);// Punk
	AddPlayerClass(179,293.7,2031.31,18,270.1425,0,0,0,0,-1,-1);//  Army SF
	AddPlayerClass(287,-1409.96,496.92,19,270.1425,0,0,0,0,-1,-1);//    Army LV
	AddPlayerClass(227,1687.82,1449.2,11,270,0,0,0,0,-1,-1);//    Dispatch
    AddPlayerClass(61,1889.45,-2289,13,270,0,0,0,0,-1,-1);//    Civil Pilot
    
    new helptext[39];
    format(helptext, sizeof(helptext), "Use /help to see all player's commands");
    Create3DTextLabel(helptext, COLOR_SYSTEM_MAIN, 342.61,2533.93,16.4, 10, 0, 0);
    Create3DTextLabel(helptext, COLOR_SYSTEM_MAIN, 293.7,2031.31,17.3, 10, 0, 0);
    Create3DTextLabel(helptext, COLOR_SYSTEM_MAIN, -1409.96,496.92,18.3, 10, 0, 0);
    Create3DTextLabel(helptext, COLOR_SYSTEM_MAIN, 1687.82,1449.2,10.4, 10, 0, 0);
    Create3DTextLabel(helptext, COLOR_SYSTEM_MAIN, 1889.45,-2289,13, 10, 0, 0);

	if (!CA_Init())
	    printf("[planesFireFix]: cannot create raycast world. Script may not work well.");
    
    //RegisterServerPlayers(_serverPlayers);
    SetTimer("OnUpdateShort", 100, true);
    SetTimer("OnUpdateLong", 1000, true);
	return 1;
}

public OnUpdateShort()
{
    OnHydraUpdateMissiles(_hydraMissiles, _serverPlayers);
}

public OnUpdateLong()
{
    //RegisterServerPlayers(_serverPlayers);
    CheckAllPlayersActivity(_serverPlayers);
    OnUpdateAllPlayers(_serverPlayers);
}

public OnGameModeExit()
{
	print("Unloading Dogfighters Gamemode (exit)");
	OnLoginSystemExit();
	ResetHydraMissiles(_hydraMissiles);
	ServerPlayersReset(_serverPlayers);
	return 1;
}

public OnPlayerConnect(playerid)
{
	GameTextForPlayer(playerid,"~w~SA-MP: ~r~Dogfighters ~g~Server",5000,5);
	setPlayerConnectionStatus(playerid, true);
	showSelectLanguageDialog(playerid, _serverPlayers);
	/*new FuncName[28] = "LoginSystem_OnPlayerConnect";
	ServerPlayerSetPersonalTimer(playerid, SetTimerEx(FuncName, 1000, true, "i", playerid), _serverPlayers);*/
	return 1;
}

public OnPlayerDisconnect(playerid)
{
	if (_dogfightInfo[usedBy] == playerid)
	    _dogfightInfo[usedBy] = NOTSET;
	LoginSystem_OnPlayerDisconnect(playerid, _serverPlayers);
	setPlayerConnectionStatus(playerid, false);
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if (!ServerPlayerIsFireFix(playerid, _serverPlayers))
	    return 0;
    if ((newkeys & KEY_ACTION) && !(oldkeys & KEY_ACTION) && IsPlayerInAnyVehicle(playerid))
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        /*if (GetVehicleModel(vehicleid) != RUSTLER_MODEL_ID)
            return 0;*/
		switch(GetVehicleModel(vehicleid))
		{
		    case RUSTLER_MODEL_ID:
		    {
		        AddPlayerFiringTimerRustler(playerid, vehicleid);
		    }
		    case HYDRA_MODEL_ID:
		    {
		        AddPlayerFiringTimerHydra(playerid, vehicleid);
		    }
		}
		
	}
	if ((oldkeys & KEY_ACTION) && !(newkeys & KEY_ACTION))
	{
	    if (playerid > MODE_MAX_PLAYERS)
	        return 0;
	    new vehicleid = GetPlayerVehicleID(playerid);
        if (GetVehicleModel(vehicleid) != RUSTLER_MODEL_ID)
            return 0;
	    if (firingTimer[playerid] != NOTSET)
	        KillFiringTimer(playerid);
	}
    return 0;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	#if DEBUG_MODE == true
    printf("OnDialogResponse %d %d %d %d %s", playerid, dialogid, response, listitem, inputtext);
    #endif
    LoginSystem_OnDialogResponse(playerid, dialogid, response, listitem, inputtext, _serverPlayers);
	switch(dialogid)
	{
	    case 0:
	    {
		}
	    case DIALOG_SELECT_LANGUAGE:
	    {
			_serverPlayers[playerid][language] = !response;
			if (_serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
			    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "You will now receive english language messages from server");
			else
			    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "Сообщения от сервера теперь будут приходить на Русском языке");
			LoginSystem_OnPlayerConnect(playerid, _serverPlayers);
	    }
	    case DIALOG_SELECT_VEHICLE:
	    {
			if (!response)
			    return 1;
			switch(listitem)
			{
			    case 0:
			        showSelectMilitaryDialog(playerid, _serverPlayers);
				case 1:
				    showSelectPlaneDialog(playerid, _serverPlayers);
				case 2:
				    showSelectHeliDialog(playerid, _serverPlayers);
				case 3:
				    showSelectCarDialog(playerid, _serverPlayers);
				case 4:
				    showSelectBikeDialog(playerid, _serverPlayers);
				case 5:
				    showSelectBoatDialog(playerid, _serverPlayers);
			}
	    }
	    case DIALOG_SELECT_MILITARY:
	    {
			if (response == 0)
			{
			    showSelectVehicleDialog(playerid, _serverPlayers);
			    return 1;
			}
			new params[4];
			format(params, sizeof(params), "%d", processSelectMilitaryDialog(playerid, listitem));
			dcmd_vehicle(playerid, params);
			return 1;
	    }
	    case DIALOG_SELECT_PLANE:
	    {
			if (!response)
			{
			    showSelectVehicleDialog(playerid, _serverPlayers);
			    return 1;
			}
			new params[4];
			format(params, sizeof(params), "%d", processSelectPlaneDialog(playerid, listitem));
			dcmd_vehicle(playerid, params);
			return 1;
	    }
	    case DIALOG_SELECT_HELI:
	    {
			if (!response)
			{
			    showSelectVehicleDialog(playerid, _serverPlayers);
			    return 1;
			}
			new params[4];
			format(params, sizeof(params), "%d", processSelectHeliDialog(playerid, listitem));
			dcmd_vehicle(playerid, params);
			return 1;
	    }
	    case DIALOG_SELECT_CAR:
	    {
			if (!response)
			{
			    showSelectVehicleDialog(playerid, _serverPlayers);
			    return 1;
			}
			new params[4];
			format(params, sizeof(params), "%d", processSelectCarDialog(playerid, listitem));
			dcmd_vehicle(playerid, params);
			return 1;
	    }
	    case DIALOG_SELECT_BIKE:
	    {
			if (!response)
			{
			    showSelectVehicleDialog(playerid, _serverPlayers);
			    return 1;
			}
			new params[4];
			format(params, sizeof(params), "%d", processSelectBikeDialog(playerid, listitem));
			dcmd_vehicle(playerid, params);
			return 1;
	    }
	    case DIALOG_SELECT_BOAT:
	    {
			if (!response)
			{
			    showSelectVehicleDialog(playerid, _serverPlayers);
			    return 1;
			}
			new params[4];
			format(params, sizeof(params), "%d", processSelectBoatDialog(playerid, listitem));
			dcmd_vehicle(playerid, params);
			return 1;
	    }
		case DIALOG_ADD_DF_PL1:
		    return processPlayer1Dialog(playerid, response, inputtext, _serverPlayers, _dogfightInfo);
		case DIALOG_ADD_DF_PL2:
		    return processPlayer2Dialog(playerid, response, inputtext, _serverPlayers, _dogfightInfo);
		case DIALOG_ADD_DF_SC1:
		    return processScore1Dialog(playerid, response, inputtext, _serverPlayers, _dogfightInfo);
		case DIALOG_ADD_DF_SC2:
		    return processScore2Dialog(playerid, response, inputtext, _serverPlayers, _dogfightInfo);
		case DIALOG_ADD_DF_YT1:
		    return processYouTube1Dialog(playerid, response, inputtext, _serverPlayers, _dogfightInfo);
		case DIALOG_ADD_DF_YT2:
		    return processYouTube2Dialog(playerid, response, inputtext, _serverPlayers, _dogfightInfo);
		case DIALOG_ADD_DF_TNAME:
		    return processTourNameDialog(playerid, response, inputtext, _serverPlayers, _dogfightInfo);
		case DIALOG_ADD_DF_TSTAGE:
		    return processTourStageDialog(playerid, response, inputtext, _serverPlayers, _dogfightInfo);
		case DIALOG_ADD_DF_REF:
		    return processRefereeDialog(playerid, response, inputtext, _serverPlayers, _dogfightInfo);
		case DIALOG_ADD_DF_APPROVE:
		    return processSummaryDialog(playerid, response, listitem, _serverPlayers, _dogfightInfo);
   }
   return 0;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	//printf("OnPlayerDeath: %s (%d) -> %s (%d) [%d];", _serverPlayers[killerid][name], killerid, _serverPlayers[playerid][name], playerid, reason);
	return ProcessPlayerDeath(playerid,	killerid, reason, _serverPlayers);
}

public OnPlayerSpawn(playerid)
{
	if (ServerPlayerIsInPvp(playerid, _serverPlayers))
	{
		PlayerSpawnDuel(playerid, _serverPlayers);
		return 1;
	}
	return ProcessPlayerSpawn(playerid, _serverPlayers[playerid][money], _serverPlayers);
}

public OnVehicleDeath(vehicleid, killerid)
{
	return ProcessVehicleDeath(vehicleid, killerid, _serverPlayers);
}

public OnPlayerRequestClass(playerid, classid)
{
	PlayerSelectClass(playerid, classid);
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    dcmd(login, 5, cmdtext);
	if (!_serverPlayers[playerid][isLoggedIn])
	{
	    if (_serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            SendClientMessage(playerid, COLOR_SYSTEM_DISCORD, "You should login first");
        else
            SendClientMessage(playerid, COLOR_SYSTEM_DISCORD, "Сначала необходимо залогиниться");
		return 1;
	}
	dcmd(spec, 4, cmdtext);
	dcmd(specoff, 7, cmdtext);
	dcmd(unspec, 7, cmdtext);
	dcmd(uspec, 7, cmdtext);
	dcmd(givecash, 8, cmdtext);
	dcmd(givemoney, 9, cmdtext);
	dcmd(pay, 3, cmdtext);
	
	new playerState = GetPlayerState(playerid);
	if (playerState < PLAYER_STATE_ONFOOT || playerState > PLAYER_STATE_PASSENGER)
	{
	    if (_serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            SendClientMessage(playerid, COLOR_SYSTEM_DISCORD, "You should spawn");
        else
            SendClientMessage(playerid, COLOR_SYSTEM_DISCORD, "Сначала необходимо заспавниться");
		return 1;
	}
	dcmd(setlevel, 8, cmdtext);
	
    dcmd(kill, 4, cmdtext);
    
    dcmd(language,8,cmdtext);
	dcmd(lang,4,cmdtext);
	dcmd(setlang,7,cmdtext);
	
	dcmd(pm, 2, cmdtext);
	dcmd(sms, 3, cmdtext);
	
	dcmd(vehicle,7,cmdtext);
	dcmd(veh,3,cmdtext);
	dcmd(car,3,cmdtext);
	
	dcmd(firefix, 7, cmdtext);
	
	dcmd(password, 8, cmdtext);
	dcmd(pass, 4, cmdtext);
	
	dcmd(savedf, 6, cmdtext);

	dcmd(cancelpvp, 9, cmdtext);
	if (ServerPlayerIsInPvp(playerid, _serverPlayers))
	{
	    if (_serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
            SendClientMessage(playerid, COLOR_SYSTEM_DISCORD, "This commands is unavaliable in pvp mode");
        else
            SendClientMessage(playerid, COLOR_SYSTEM_DISCORD, "Эти команды недоступны в дуэли");
		return 1;
	}
	
	dcmd(heal,4,cmdtext);
	dcmd(hp,2,cmdtext);
	dcmd(armour,6,cmdtext);
	dcmd(arm,3,cmdtext);
	
	dcmd(repair,6,cmdtext);
	dcmd(rep,3,cmdtext);
	dcmd(r,1,cmdtext);
	
	dcmd(teleport,8,cmdtext);
	dcmd(tp,2,cmdtext);
	
	dcmd(reclass, 7, cmdtext);
	
	dcmd(s, 1, cmdtext);
	dcmd(t, 1, cmdtext);
	
	dcmd(pvp, 3, cmdtext);
	dcmd(duel, 4, cmdtext);
	dcmd(y, 1, cmdtext);
	dcmd(n, 1, cmdtext);
	
	dcmd(vt, 2, cmdtext);
	
	dcmd(kick, 4, cmdtext);
	dcmd(ban, 3, cmdtext);
	
	dcmd(changecert, 10, cmdtext);
	
	dcmd(help, 4, cmdtext);
	return 0;
}

dcmd_vehicle(playerid, const params[])
{
    #if DEBUG_MODE == true
	    printf("cmd: vehicle[pre](playerid=%d params[0]=%s, params[1]=%s, params[2]=%s, params[3]=%s)", playerid, params[0], params[2], params[2]);
	#endif
    return CommandGivePlayerVehicle(playerid, params, _serverPlayers);
}

dcmd_veh(playerid, const params[])
{
	return dcmd_vehicle(playerid, params);
}

dcmd_car(playerid, const params[])
{
	return dcmd_vehicle(playerid, params);
}

dcmd_firefix(playerid, const params[])
{
	return CommandFireFix(playerid, params, _serverPlayers);
}

dcmd_password(playerid, const params[])
{
	return CommandChangePassword(playerid, params, _serverPlayers);
}

dcmd_pass(playerid, const params[])
{
	return dcmd_password(playerid, params);
}

dcmd_savedf(playerid, const params[])
{
	return CommandSaveDogfight(playerid, params, _serverPlayers, _dogfightInfo);
}

dcmd_cancelpvp(playerid, const params[])
{
	return CommandCancelPvp(playerid, params, _serverPlayers);
}

dcmd_heal(playerid, const params[])
{
	return CommandHeal(playerid, params, _serverPlayers);
}

dcmd_hp(playerid, const params[])
{
	return dcmd_heal(playerid, params);
}

dcmd_armour(playerid, const params[])
{
	return dcmd_heal(playerid, params);
}

dcmd_arm(playerid, const params[])
{
	return dcmd_heal(playerid, params);
}

dcmd_repair(playerid, const params[])
{
	return CommandRepair(playerid, params, _serverPlayers);
}

dcmd_rep(playerid, const params[])
{
	return dcmd_repair(playerid, params);
}

dcmd_r(playerid, const params[])
{
	return dcmd_repair(playerid, params);
}

dcmd_teleport(playerid, const params[])
{
    return CommandTeleport(playerid, params, _serverPlayers);
}

dcmd_tp(playerid, const params[])
{
	return dcmd_teleport(playerid, params);
}

dcmd_language(playerid, const params[])
{
    return CommandLanguage(playerid, params, _serverPlayers);
}

dcmd_lang(playerid, const params[])
{
	return dcmd_language(playerid, params);
}

dcmd_setlang(playerid, const params[])
{
	return dcmd_language(playerid, params);
}

dcmd_setlevel(playerid, const params[])
{
	return CommandSetLevelAdm(playerid, params, _serverPlayers);
}

dcmd_kill(playerid, const params[])
{
	return CommandKill(playerid, params, _serverPlayers);
}

dcmd_login(playerid, const params[])
{
    ServerPlayerSetLoggedIn(playerid, false, _serverPlayers);
	return LoginSystem_OnPlayerConnect(playerid, _serverPlayers);
}

dcmd_reclass(playerid, const params[])
{
	return CommandReclass(playerid, params, _serverPlayers);
}

dcmd_pm(playerid, const params[])
{
	return CommandPrivateMessage(playerid, params, _serverPlayers);
}

dcmd_sms(playerid, const params[])
{
	return dcmd_pm(playerid, params);
}

dcmd_s(playerid, const params[])
{
	return CommandSavePosition(playerid, params, _serverPlayers);
}

dcmd_t(playerid, const params[])
{
	return CommandTeleportPosition(playerid, params, _serverPlayers);
}

dcmd_pvp(playerid, const params[])
{
	return CommandPvp(playerid, params, _serverPlayers);
}

dcmd_duel(playerid, const params[])
{
	return dcmd_pvp(playerid, params);
}

dcmd_y(playerid, const params[])
{
	return CommandAccept(playerid, params, _serverPlayers);
}

dcmd_n(playerid, const params[])
{
	return CommandDecline(playerid, params, _serverPlayers);
}

dcmd_spec(playerid, const params[])
{
    return CommandSpec(playerid, params, _serverPlayers);
}

dcmd_specoff(playerid, const params[])
{
	return CommandSpecOff(playerid, params, _serverPlayers);
}

dcmd_unspec(playerid, const params[])
{
	return dcmd_specoff(playerid, params);
}

dcmd_uspec(playerid, const params[])
{
	return dcmd_specoff(playerid, params);
}

dcmd_givecash(playerid, const params[])
{
	return CommandGiveCash(playerid, params, _serverPlayers);
}

dcmd_givemoney(playerid, const params[])
{
	return dcmd_givecash(playerid, params);
}

dcmd_pay(playerid, const params[])
{
	return dcmd_givecash(playerid, params);
}

dcmd_kick(playerid, const params[])
{
	return CommandKickAdm(playerid, params, _serverPlayers);
}

dcmd_ban(playerid, const params[])
{
    return CommandBanAdm(playerid, params, _serverPlayers);
}

dcmd_changecert(playerid, const params[])
{
	return CommandSetCertificate(playerid, params, _serverPlayers);
}

dcmd_help(playerid, const params[])
{
	return CommandHelp(playerid, params, _serverPlayers);
}

dcmd_vt(playerid, const params[])
{
	if (LoginSystem_GetAccessLevel(playerid, _serverPlayers) < 4)
	    return 0;
	AddPlayerMoney(playerid, 10000, _serverPlayers);
	return 1;
}

public setPlayerConnectionStatus(playerid, bool:isConnectedStatus)
{
	//_serverPlayers[playerid][isConnected] = isConnectedStatus;
	if (isConnectedStatus)
	{
	    PlayerConnect(playerid, _serverPlayers);
	}
	else
	{
 		PlayerDisconnect(playerid, _serverPlayers);
	}
}

public OnRustlerFiring(playerid, vehicleid)
{
	if (!IsPlayerConnected(playerid) || !IsPlayerSpawned(playerid) || !IsPlayerInAnyVehicle(playerid))
	{
	    KillFiringTimer(playerid);
	    return;
	}
	#if DEBUG_MODE_FIREFIX == true
    printf("\n------------\n\n\nRustler fire from id: %d", playerid);
    #endif
    if (!IsPlayerInAnyVehicle(playerid))
		KillFiringTimer(playerid);
	new Float:vehPositionX, Float:vehPositionY, Float:vehPositionZ;
	GetVehiclePos(vehicleid, vehPositionX, vehPositionY, vehPositionZ);
	new Float:offsetX, Float:offsetY, Float:offsetZ;
	new Float:castX, Float:castY, Float:castZ;
	new targetid = NOTSET;
	new searchRadius = COLLISION_SEARCH_MIN_RADIUS;

	for (new i = COLLISION_MINIMAL_DISTANCE; i < COLLISION_MAXIMAL_DISTANCE; i += COLLISION_DISTANCE_STEP)
	{
    	GetVehicleRelativePos(vehicleid, 0, i, 0, offsetX, offsetY, offsetZ);
		targetid = GetNearestPlayer(offsetX, offsetY, offsetZ, searchRadius, playerid);

		if (searchRadius < COLLISION_SEARCH_MAX_RADIUS)
    	    searchRadius += COLLISION_SEARCH_RADIUS_STEP;
		if (targetid == NOTSET)
		    continue;

		new Float:targetX, Float:targetY, Float:targetZ;
		if (!GetPlayerPos(targetid, targetX, targetY, targetZ))
		{
		    #if DEBUG_MODE_FIREFIX == true
		    printf("bad target %d", targetid);
		    #endif

		    break;
		}

		if (CA_RayCastLine(vehPositionX, vehPositionY, vehPositionZ, targetX, targetY, targetZ, castX, castY, castZ) != 0)
        {
            #if DEBUG_MODE_FIREFIX == true
			printf("!!![COLLISION FOUND: %.2f %.2f %.2f] (Player %d is behind the object)", castX, castY, castZ, targetid);
			#endif

			break;
		}
		#if BULLET_SYNC_ENABLE == true
		new bulletData[PR_BulletSync];  //To send bulletData
		bulletData[PR_hitId] = targetid;
		bulletData[PR_origin][0] = vehPositionX;
		bulletData[PR_origin][1] = vehPositionY;
		bulletData[PR_origin][2] = vehPositionZ;
		bulletData[PR_hitPos][0] = targetX;
        bulletData[PR_hitPos][1] = targetY;
        bulletData[PR_hitPos][2] = targetZ;
        bulletData[PR_offsets][0] = 0;
        bulletData[PR_offsets][1] = 0;
        bulletData[PR_offsets][2] = 0;
        bulletData[PR_weaponId] = RUSTLER_WEAPON_ID;
        #endif

		if (IsPlayerInAnyVehicle(targetid))
		{
			new targetvehicleid = GetPlayerVehicleID(targetid);
			#if DEBUG_MODE_FIREFIX == true
		    printf("%d damaged vehicle: %d(player: %d)", playerid, targetvehicleid, targetid);
		    #endif

			if (!GiveVehicleDamage(targetvehicleid, targetid, playerid, RUSTLER_DAMAGE_VEHICLES, RUSTLER_WEAPON_ID, _serverPlayers))
			    continue;
		    // SetVehicleHealth(targetvehicleid, vehiclehealth - RUSTLER_DAMAGE_VEHICLES);  //  Can rewrite with you GiveVehicleDamage logic here
		    #if BULLET_SYNC_ENABLE == true
		    bulletData[PR_hitType] = BULLET_HIT_TYPE_VEHICLE;
		    SendBulletSync(playerid, targetvehicleid, bulletData);
		    #endif

		    break;
		}
		else
		{
		    #if DEBUG_MODE_FIREFIX == true
		    printf("%d damaged player: %d", playerid, targetid);
		    #endif
		    new Float:playerhealth = 100;
            if (!GetPlayerHealth(targetid, playerhealth))
		        continue;
            GivePlayerDamage(targetid, playerid, RUSTLER_DAMAGE_PLAYERS, RUSTLER_WEAPON_ID, _serverPlayers);
            #if BULLET_SYNC_ENABLE == true
            bulletData[PR_hitType] = BULLET_HIT_TYPE_PLAYER;
            SendBulletSync(playerid, targetid, bulletData);
            #endif

            break;
		}
	}
	//	KillFiringTimer(playerid, 0);
	#if DEBUG_MODE_FIREFIX == true
    printf("---------");
    #endif
}

stock AddPlayerFiringTimerRustler(playerid, vehicleid)
{
	if (firingTimer[playerid] != NOTSET)
	    KillFiringTimer(playerid);
	//RegisterServerPlayers(serverPlayers);
    new FuncName[16] = "OnRustlerFiring";
	firingTimer[playerid] = SetTimerEx(FuncName, 100, true, "ii", playerid, vehicleid);
	//SetTimerEx(FuncName, 100, false, "ii", playerid, vehicleid);
}

stock AddPlayerFiringTimerHydra(playerid, vehicleid)
{
	printf("AddPlayerFiringTimerHydra %s (%d) - (%d)", _serverPlayers[playerid][name], playerid, vehicleid);
    //new FuncName[16] = "OnHydraFiring";
    new Float:vehiclePosX, Float:vehiclePosY, Float:vehiclePosZ, Float:finishPosX, Float:finishPosY, Float:finishPosZ;
    new Float:castX, Float:castY, Float:castZ;
    //GetVehiclePos(vehicleid, vehiclePosX, vehiclePosY, vehiclePosZ);
    GetVehicleRelativePos(vehicleid, 0, HYDRA_MINIMAL_DISTANCE, 0, vehiclePosX, vehiclePosY, vehiclePosZ);
    GetVehicleRelativePos(vehicleid, 0, HYDRA_MAXIMAL_DISTANCE, 0, finishPosX, finishPosY, finishPosZ);
    if (CA_RayCastLine(vehiclePosX, vehiclePosY, vehiclePosZ, finishPosX, finishPosY, finishPosZ, castX, castY, castZ) != 0)
    {
        #if DEBUG_MODE == true
		printf("!!![COLLISION FOUND: %.2f %.2f %.2f] ", castX, castY, castZ);
		#endif
        finishPosX = castX;
        finishPosY = castY;
        finishPosZ = castZ;
		//return;
	}
	new missile = AddHydraMissile(
	                            playerid,
								vehiclePosX,
								vehiclePosY,
								vehiclePosZ,
								finishPosX,
								finishPosY,
								finishPosZ,
								_hydraMissiles);
	if (missile == NOTSET)
	    printf("Cannot create a missile for %d", playerid);
	//new missileTimerID = SetTimerEx(FuncName, 100, true, "iii", playerid, vehicleid, missile);
	AddHydraMyssileTimer(playerid, _hydraMissiles, HYDRA_MISSILE_TIMER_ID);//missileTimerID);
	print("AddPlayerFiringTimerHydra end");
	//AddFiringTimer(playerid, timerID);
}

stock KillFiringTimer(playerid)
{
    KillTimer(firingTimer[playerid]);
	firingTimer[playerid] = NOTSET;
}

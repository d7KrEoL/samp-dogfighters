#if !defined SVR_COMMAND_SPEC
#define SVR_COMMAND_SPEC

#include "dogfighters\server\serverInfo\serverMain.pwn"
#include "dogfighters\player\playerMain.pwn"

forward CommandSpec(playerid, const params[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);

public CommandSpec(playerid, const params[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
    if (isnull(params))
    {
        if(serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
	    	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/spec] Syntax: /spec [ID]");
		else
		    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/spec] ���������: /spec [ID]");
	    return 1;
    }
	new targetid = strval(params);
    if (targetid == playerid)
    {
        if(serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
	    	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/spec] You can't spectate yourself");
		else
		    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/spec] �� �� ������ ������� �� ����� �����");
	    return 1;
    }
    if (PlayerSpectate(playerid, targetid, serverPlayers))
    {
        if(serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
	    	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/spec] Spectate mode activated (to stop spectating enter /specoff)");
		else
		    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/spec] �� ������� � ����� �������� (����� ��������� ������� ������� /specoff)");
    }
    else
    {
        if(serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
	    	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/spec] Cannot spectate this player ID");
		else
		    SendClientMessage(playerid, COLOR_SYSTEM_MAIN, "[/spec] �� ��������� ������� �� ���� ID");
    }
    return 1;
}

#endif
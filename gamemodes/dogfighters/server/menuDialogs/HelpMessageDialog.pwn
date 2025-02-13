#if !defined HELP_MESSAGE_DIALOG
#define HELP_MESSAGE_DIALOG

#define DIALOG_MESSAGE_HELP

#include "dogfighters\server\serverInfo\serverMain.pwn"
#include "dogfighters\server\menuDialogs\DialogStyles.pwn"
#include "dogfighters\server\menuDialogs\DialogID.pwn"
#include "dogfighters\player\localization\PlayerLanguage.pwn"

forward showHelpMessageDialog(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);

public showHelpMessageDialog(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{  
    if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
        ShowPlayerDialog(playerid, DIALOG_HELP_MESSAGE, DIALOG_STYLE_MSGBOX, 
                        "Server information and commands", 
                        "/vehicle /veh /car [model ID] [Color1] [Color2] - Take a new personal vehicle\n\
                        /repair /r - Fix a personal vehicle\n\
                        /heal /hp - Heal a player\n\
                        /reclass - Re-select player class\n\
                        /kill - Spawn a player\n\
                        /pvp [player ID] - Request player to start duel\n\
                        /y - Accept duel with player (/pvp)\n\
                        /n - Decline to start duel (/pvp)\n\
                        /s - Save current position for teleport\n\
                        /t - Teleport to saved position\n\
                        /tp [LocationName] - Teleport to location\n\
                        Locations:\n\
                        /tp ls - teleport to Los Santos International Airport\n\
                        /tp lv - teleport to Las Venturas International Airport\n\
                        /tp sf - teleport to San Fierro International Airport\n\
                        /tp desert - teleport to Desert airspace\n\
                        /tp gate - teleport to Golden Gate Bridge airspace\n\
                        /tp beach - teleport to Los Santos Beach airspace\n\
                        /tp chill - teleport to chiliad mountain",
                        "Ok", "");
    else
        ShowPlayerDialog(playerid, DIALOG_HELP_MESSAGE, DIALOG_STYLE_MSGBOX, 
                        "������� � ���������� � �������", 
                        "/vehicle /veh /car [ID ������] [����1] [����2] - �������� ������ ���������\n\
                        /repair /r - �������� ������ ���������\n\
                        /heal /hp - �������� ������\n\
                        /reclass - ����������� ���� �����\n\
                        /kill - ������������\n\
                        /pvp [ID ������] - ������� ������ �� �����\n\
                        /y - ����������� ��� ������� � ����� (/pvp)\n\
                        /n - ���������� �� ������� � ����� (/pvp)\n\
                        /s - ��������� ������� ������� ��� ���������\n\
                        /t - �������� �� ���������� �������\n\
                        /tp [�������� �������] - ����������������� �� �������\n\
                        ������ �������:\n\
                        /tp ls - �������� � ������������� �������� ��� ������\n\
                        /tp lv - �������� � ������������� �������� ��� ��������\n\
                        /tp sf - �������� � ������������� �������� ��� ������\n\
                        /tp desert - �������� � ������� ���� \"�������\"\n\
                        /tp gate - �������� � ������� ���� \"���� ������� ������\"\n\
                        /tp beach - �������� � ������� ���� \"���� ��\"\n\
                        /tp chill - �������� � ������� ���� \"���� ������\"",
                        "Ok", "");
    return 1;
}
#endif
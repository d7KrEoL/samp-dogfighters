#if !defined DIALOG_DUEL_INFO
#define DIALOG_DUEL_INFO
#include "dogfighters\server\serverInfo\serverMain.pwn"
#include "dogfighters\server\menuDialogs\DialogStyles.pwn"
#include "dogfighters\server\menuDialogs\DialogID.pwn"
#include "dogfighters\player\localization\PlayerLanguage.pwn"
#include "dogfighters\server\menuDialogs\DialogDuelInfo.pwn"

forward showDuelHelpDialog(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);

public showDuelHelpDialog(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{  
    if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
        ShowPlayerDialog(playerid, DIALOG_HELP_DUEL, DIALOG_STYLE_MSGBOX, 
                        "Dogfight PvP information", 
                        "In duel there is only you and your enemy. Duel starts if both of players agree to participate in it.\n\
                        First player who wins 5 rounds wins\n\n\
                        After you request player to join duel (/pvp), he should accept (/y) or decline (/n) your request\n\
                        If 2nd player accepting request you and your enemy will teleport to another game world and \n\
                        stay there untill one of you achive 5 score points.\n\
                        When you or your enemy dies. No metter what was reason of death, player who still alive\n\
                        achives 1 score point.\n\
                        When one of players achive 5 score points, he wins and duel ends, all players returns to\n\
                        the public game world.\n\n\
                        If one of players leaves server before duel ends, he auto-looses.\n\
                        If 2nd player declines to participate duel (/n) - it's not starting, without loose.",
                        "Ok", "");
    else
        ShowPlayerDialog(playerid, DIALOG_HELP_DUEL, DIALOG_STYLE_MSGBOX, 
                        "���������� � ��� ������", 
                        "� �������� ����� �� ����� ���������� ������ �� � ��� ���������. ����� ��������, ���� ��� ������\n\
                        ����������� � ��� �����������. ��������� �����, ������ ��������� 5 �����.\n\n\
                        ����� ������ ������� �� ����� (/pvp), ������ ����� ������ ������� ����������� (/y), ���� ���������� (/n)\n\
                        ���� ������ ����� ����������� �� �������, �� ��� ������������� � ��������� ������� ��� � ������ ����������\n\
                        � ��� �� ����� �����.\n\
                        ��� ������ ������ �� �������, ���� ��� ���������� ������������� �� �������. ��� ���������� 5 �������� �����\n\
                        ����� �� �������, �� ��������� � ����� �����������. �� ������������� ������������� � ����� ������� ���.\n\n\
                        ���� ���� �� ������� ������� � ������� �� ���������� �����, �� ������������� �����������\n\
                        ���� 2� ����� ������������ �� ������� � ����� (/n) - ��� �� ����������, ��� ��������� ������������� ������",
                        "Ok", "");
    return 1;
}
#endif
#include <yoursql>
#include "dogfighters\database\loginRegisterSensitiveData.pwn"
#include "dogfighters\server\serverInfo\Gamemode\ModeInfo.pwn"
#include "dogfighters\server\serverInfo\Players\ServerPlayers.pwn"
#include "dogfighters\server\menuDialogs\DialogID.pwn"

//simple login and register system using YourSQL.
//Original github repo: https://github.com/Gammix/SAMP-YourSQL/


forward OnLoginSystemInit();
forward OnLoginSystemExit();
forward LoginSystem_OnPlayerConnect(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);
forward LoginSystem_OnPlayerDisconnect(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);
forward LoginSystem_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);
forward LoginSystem_OnPlayerDeath(playerid, killerid, reason, serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);
forward LoginSystem_OnChangePassword(playerid, password[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);
forward LoginSystem_OnChangeName(playerid, newPlayerName[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);
forward LoginSystem_GetAccessLevel(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);
forward LoginSystem_SetAccessLevel(playerid, level, serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);
forward LoginSystem_RefereeGetCert(playerid, accessCertificate[257], serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);
forward LoginSystem_RefereeSetCert(playerid, accessCertificate[257], serverPlayers[MODE_MAX_PLAYERS][serverPlayer]);

public OnLoginSystemInit()
{
	//open the database file
	//since i am only using one database file, i won't be creating any variable with tag "SQL:" to store the db id
	//the returning values with "yoursql_open" are whole numbers so the first one would be "SQL:0"
	yoursql_open(LOGIN_PASS_DBUSR);

    //create/verify a table named LOGIN_PASS_TBL_USR where we will store all the user data
    yoursql_verify_table(SQL:0, LOGIN_PASS_TBL_USR);

    //verify column in table LOGIN_PASS_TBL_USR names "Name" to store user names
    yoursql_verify_column(SQL:0, LOGIN_PASS_TBL_USRNAME, SQL_STRING);
    //verify column "Password" to store user account password (SHA256 hashed)
    yoursql_verify_column(SQL:0, LOGIN_PASS_TBL_USRPASS, SQL_STRING);
    //verify column "Kills" to store user kills count
    yoursql_verify_column(SQL:0, LOGIN_PASS_TBL_USRKILLS, SQL_NUMBER);
    //verify column "Deaths" to store user deaths count
    yoursql_verify_column(SQL:0, LOGIN_PASS_TBL_USRDEATHS, SQL_NUMBER);
    //verify column "Score" to store user score count
    yoursql_verify_column(SQL:0, LOGIN_PASS_TBL_USRSCORE, SQL_NUMBER);
	//verify column "Score" to store user score count
    yoursql_verify_column(SQL:0, LOGIN_PASS_TBL_USRACCESS, SQL_NUMBER);
	//verify column "nextNameChange" to store user score count
    yoursql_verify_column(SQL:0, LOGIN_PASS_TBL_NAMECHANGE, SQL_NUMBER);
	//verify column "Certificate" to store user's referee certificate
    yoursql_verify_column(SQL:0, LOGIN_PASS_TBL_USRCERT, SQL_STRING);

    return 1;
}

public OnLoginSystemExit()
{
	//close the database, stored in index 0
    yoursql_close(SQL:0);

	return 1;
}

public LoginSystem_OnPlayerConnect(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
	//ServerPlayerResetPersonalTimer(playerid, serverPlayers);
	new namePlayer[MAX_PLAYER_NAME + 1];
	GetPlayerName(playerid, namePlayer, MAX_PLAYER_NAME + 1);

	//check if the player is registered or not
	new
	    SQLRow:rowid = yoursql_get_row(SQL:0, LOGIN_PASS_TBL_USR, "Name = %s", namePlayer)
	;
	if (rowid != SQL_INVALID_ROW)//if registered
	{
		if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
			ShowPlayerDialog(playerid, DIALOG_ID_LOGIN, DIALOG_STYLE_PASSWORD, "User Accounts:", "\t\t\t     You are registered\t\t\n.\t\tplease insert your password to continue:\t\t", "Login", "Exit");
		else
			ShowPlayerDialog(playerid, DIALOG_ID_LOGIN, DIALOG_STYLE_PASSWORD, "Аккаунт:", "\t\t     Ваш ник зарегистрирован!\t\t\n.\t\tВведите пароль для продолжения:\t\t    .", "Ввод", "Выход");
	    
	}
	else//if new user
	{
		if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
			ShowPlayerDialog(playerid, DIALOG_ID_REGISTER, DIALOG_STYLE_PASSWORD, "User Accounts:", "\t\t        You are not recognized on the database\t\t\n.\t\tplease insert a password to sing-in and continue:\t\t.", "Register", "Exit");
		else
			ShowPlayerDialog(playerid, DIALOG_ID_REGISTER, DIALOG_STYLE_PASSWORD, "Аккаунт:", "\t\tВаш ник ещё не зарегистрирован!\n.\t\t\tпридумайте пароль для аккаунта и введите его в поле ниже:\t\t\tпїЅ", "Ввод", "Выход");
	}

	return 1;
}

public LoginSystem_OnPlayerDisconnect(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
	printf("[LoginSystem] LoginRegister %d", playerid);
	//save player's score
	new SQLRow:rowid = yoursql_get_row(SQL:0, LOGIN_PASS_TBL_USR, "Name = %s", serverPlayers[playerid][name]);
	if (rowid < SQLRow:1)
		printf("[LoginSystem] Error: OnPlayerDisconnect - cannot fight player in database: %s (%d) [rowid: %d]", serverPlayers[playerid][name], playerid, int:rowid);
	else
		printf("[LoginSystem]: Saving player's score: %s (%d) score: %d, rowid: %d", serverPlayers[playerid][name], playerid, serverPlayers[playerid][money], int:rowid);
	//save player score
	yoursql_set_field_int(SQL:0, LOGIN_PASS_TBL_USRSCORE, rowid, serverPlayers[playerid][money]);

	return 1;
}

public LoginSystem_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
	switch (dialogid)
	{
		case DIALOG_ID_REGISTER://if response for register dialog
		{
		    if (! response)//if the player presses 'ESC' button
		    {
		        return Kick(playerid);
		    }
		    else
		    {
		        if (! inputtext[0] || strlen(inputtext) < 4 || strlen(inputtext) > 50)//if the player's password is empty or not between 4 - 50 in length
		        {
					if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
						SendClientMessage(playerid, 0xFF0000FF, "ERROR: Your password must be between 4 - 50 characters.");//give warning message and reshow the dialog
					else
						SendClientMessage(playerid, 0xFF0000FF, "Ошибка: Пароль должен быть длиной 4 - 50 символов.");//give warning message and reshow the dialog
		            
					if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
						return ShowPlayerDialog(playerid, 
												DIALOG_ID_REGISTER, 
												DIALOG_STYLE_PASSWORD, 
												"User Accounts:", "\t\t        You are not recognized on the database\t\t\nпїЅ\t\tplease insert a password to sing-in and continue:\t\tпїЅ", 
												"Register", 
												"Exit");
					else
						return ShowPlayerDialog(playerid, 
												DIALOG_ID_REGISTER, 
												DIALOG_STYLE_PASSWORD, 
												"Аккаунт:", 
												"\tВы ещё не зарегистрированы на сервере\t\t\nпїЅ\t\t   придумайте пароль и введите его в поле ниже:\t\t\t.", 
												"Ввод", 
												"Выход");
		        }

		        //we create the new row the same way we verufy it using "yoursql_get_row"
		        new
				    namePlayer[MAX_PLAYER_NAME + 1]
				;
				GetPlayerName(playerid, namePlayer, MAX_PLAYER_NAME + 1);
		        yoursql_set_row(SQL:0, LOGIN_PASS_TBL_USR, "Name = %s", namePlayer);//create new row with the specific "name"

		        //hash player inputtext with SHA256
		        new
		            password[128]
				;
				SHA256_PassHash(inputtext, LOGIN_PASS_SALT, password, sizeof(password));
				yoursql_set_field(SQL:0, LOGIN_PASS_TBL_USRPASS_SML, yoursql_get_row(SQL:0, LOGIN_PASS_TBL_USR, "Name = %s", namePlayer), password);//set the password


				if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
					SendClientMessage(playerid, 0x00FF00FF, "SUCCESS: You have successfully registered your account in the server.");
				else
					SendClientMessage(playerid, 0x00FF00FF, "Вы успешно зарегистрировали свой аккаунт.");
				ServerPlayerSetLoggedIn(playerid, true, serverPlayers);  
		    }
		}
		case DIALOG_ID_LOGIN://if response for login dialog
		{
		    if (! response)//if the player presses 'ESC' button
		    {
		        return Kick(playerid);
		    }
		    else
			{
			    //read player row and retrieve password
		        new
				    namePlayer[MAX_PLAYER_NAME + 1]
				;
				GetPlayerName(playerid, namePlayer, MAX_PLAYER_NAME + 1);

				//read the hashed password
				new
				    acc_password[128]
				;
				new SQLRow:rowid = yoursql_get_row(SQL:0, LOGIN_PASS_TBL_USR, "Name = %s", namePlayer);
				yoursql_get_field(SQL:0, LOGIN_PASS_TBL_USRPASS_SML, rowid, acc_password);

				//read the current input password and hash it
				new
		            password[128]
				;
				SHA256_PassHash(inputtext, LOGIN_PASS_SALT, password, sizeof(password));

		        if (! inputtext[0] || strcmp(password, acc_password))//if the player's password idoesn't match with the account password
		        {
					if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
						SendClientMessage(playerid, 0xFF0000FF, "ERROR: Incorrect password.");//give warning message and reshow the dialog
					else
						SendClientMessage(playerid, 0xFF0000FF, "Ошибка: Неверный пароль.");//give warning message and reshow the dialog
		            
					if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
						return ShowPlayerDialog(playerid, 
												DIALOG_ID_LOGIN, DIALOG_STYLE_PASSWORD, 
												"User Accounts:", 
												"\t\t\t     You entered wrong password\t\t\n\t\t          please insert your password to continue\n.\t\tor create a new account by changing your nickname:\t\t.", 
												"Login", 
												"Exit");
					else
						return ShowPlayerDialog(playerid, 
												DIALOG_ID_LOGIN, DIALOG_STYLE_PASSWORD, 
												"Аккаунт:", 
												"\t\t\t\t   Вы ввели неверный пароль.\t\t\n.\t\t.введите свой пароль, или смените ник и создайте новый аккаунт.:\t\t   .", 
												"Login", 
												"Exit");
		            
		        }

		        if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
					SendClientMessage(playerid, 0x00FF00FF, "SUCCESS: You have successfully logged in your account, enjoy playing!");
				else
					SendClientMessage(playerid, 0x00FF00FF, "Вы успешно авторизовались на сервере!");
				new accessLevel = LoginSystem_GetAccessLevel(playerid, serverPlayers);
				if (accessLevel > 0)
				{
					if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
						format(password, sizeof(password), "You have admin rights level: %d", accessLevel);
					else
						format(password, sizeof(password), "У вас есть права администратора %d уровня", accessLevel);
					SendClientMessage(playerid, COLOR_SYSTEM_MAIN, password);
				}
				new bankCash = yoursql_get_field_int(SQL:0, LOGIN_PASS_TBL_USRSCORE_SML, rowid);
				if (bankCash > 0 && bankCash < 90000000)
					AddPlayerMoney(playerid, bankCash, serverPlayers);
				ServerPlayerSetLoggedIn(playerid, true, serverPlayers);
		    }
		}
		case DIALOG_ID_CHANGEPWD:
		{
			if (response)
				LoginSystem_OnChangePassword(playerid, inputtext, serverPlayers);
		}
		case DIALOG_ID_CHANGENAME:
		{
			if (!response)
				return 1;
			new oldName[MAX_PLAYER_NAME + 1];
			new message[256];
			GetPlayerName(playerid, oldName, sizeof(oldName));
			if (LoginSystem_OnChangeName(playerid, inputtext, serverPlayers))
			{
				print("Changing player name in df system was approved");
				ChangeDogfighterName(oldName, inputtext);
				if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
					format(message, sizeof(message), "[/changename]: Your nickname has been changed to %s in df system", inputtext);
				else
					format(message, sizeof(message), "[/changename]: Ваш ник изменён на %s в системе", inputtext);
				SendClientMessage(playerid, COLOR_SYSTEM_MAIN, message);
				printf("Name of player %s (%d) was changed to %s", oldName, playerid, inputtext);
			}
			else
			{
				SetPlayerName(playerid, oldName);
				if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
					format(message, sizeof(message), "[/changename]: You cannot change nickname that quick (once per 3 days)");
				else
					format(message, sizeof(message), "[/changename]: Нельзя так часто менять ник (не чаще чем раз в 3 дня)");
				SendClientMessage(playerid, COLOR_SYSTEM_MAIN, message);
				printf("Player %s (%d) is trying to change name too quick", oldName, playerid);
			}
		}
	}

	return 1;
}

public LoginSystem_OnPlayerDeath(playerid, killerid, reason, serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
	new namePlayer[MAX_PLAYER_NAME + 1], SQLRow: rowid;
	
	if (killerid != INVALID_PLAYER_ID && killerid >= 0)
	{
	    //save killerid's kills
		GetPlayerName(killerid, namePlayer, MAX_PLAYER_NAME + 1);
		rowid = yoursql_get_row(SQL:0, LOGIN_PASS_TBL_USR, "Name = %s", namePlayer);
		if (!rowid)
		{
			printf("Cannot add kill to player %s (%d) - not found in database (%d)", namePlayer, killerid, int:rowid);
			return 1;
		}
		yoursql_set_field_int(SQL:0, LOGIN_PASS_TBL_USRKILLS_SML, rowid, yoursql_get_field_int(SQL:0, LOGIN_PASS_TBL_USRKILLS_SML, rowid) + 1);//add 1 to killer kills
	}
	if (playerid < 0)
		return 1;
	//save playerid's deaths
	GetPlayerName(playerid, namePlayer, MAX_PLAYER_NAME + 1);
	rowid = yoursql_get_row(SQL:0, LOGIN_PASS_TBL_USR, "Name = %s", namePlayer);
	if (!rowid)
	{
		printf("Cannot add death to player %s (%d) - not found in database (%d)", namePlayer, playerid, int:rowid);
		return 1;
	}
	yoursql_set_field_int(SQL:0, LOGIN_PASS_TBL_USRDEATHS_SML, rowid, yoursql_get_field_int(SQL:0, LOGIN_PASS_TBL_USRDEATHS_SML, rowid) + 1);//add 1 to player deaths
	return 1;
}

public LoginSystem_OnChangePassword(playerid, password[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
	if (!password[0], strlen(password) < 4 || strlen(password) > 50)
	{
		if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
			SendClientMessage(playerid, 0xFF0000FF, "ERROR: Your password must be between 4 - 50 characters.");//give warning message and reshow the dialog
		else
			SendClientMessage(playerid, 0xFF0000FF, "Ошибка: Пароль должен быть 4 - 50 символов в длину.");//give warning message and reshow the dialog
		return;
	}
	new namePlayer[MAX_PLAYER_NAME + 1], SQLRow: rowid;
	GetPlayerName(playerid, namePlayer, MAX_PLAYER_NAME + 1);
	rowid = yoursql_get_row(SQL:0, LOGIN_PASS_TBL_USR, "Name = %s", namePlayer);
	if (!rowid)
	{
		printf("Cannot change password for player %s (%d) - not found in database (%d)", namePlayer, playerid, int:rowid);
		return;
	}

	new passwordHashed[128];
	SHA256_PassHash(password, LOGIN_PASS_SALT, passwordHashed, sizeof(passwordHashed));
	yoursql_set_field(SQL:0, LOGIN_PASS_TBL_USRPASS_SML, yoursql_get_row(SQL:0, LOGIN_PASS_TBL_USR, "Name = %s", namePlayer), passwordHashed);//set the password

	if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
		format(passwordHashed, sizeof(passwordHashed), "[/password]: Password was successfully changed!");
	else
		format(passwordHashed, sizeof(passwordHashed), "[/password]: Пароль был успешно изменён!");
	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, passwordHashed);
	return;
}

public LoginSystem_OnChangeName(playerid, newPlayerName[], serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
	if (!newPlayerName[0], strlen(newPlayerName) < 4 || strlen(newPlayerName) > 20)
	{
		if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
			SendClientMessage(playerid, 0xFF0000FF, "ERROR: Your nickname must be between 3 - 20 characters.");//give warning message and reshow the dialog
		else
			SendClientMessage(playerid, 0xFF0000FF, "Ошибка: Ник должен быть 3 - 20 символов в длину.");//give warning message and reshow the dialog
		return false;
	}
	new SQLRow: nickRow = yoursql_get_row(SQL:0, LOGIN_PASS_TBL_USR, "Name = %s", newPlayerName);
	new resultMessage[256];
	if (nickRow)
	{
		printf("Cannot change name for player %s (%d) - user with name %s is already exists in database (%d)", 
			serverPlayers[playerid][name], 
			playerid, 
			newPlayerName, 
			int:nickRow);
		if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
			format(resultMessage, sizeof(resultMessage), "[/changename]: Cannot change name - player with that nickname is already exist!");
		else
			format(resultMessage, sizeof(resultMessage), "[/changename]: Невозможно сменить ник - игрок с таким ником уже существует!");
		SendClientMessage(playerid, COLOR_SYSTEM_MAIN, resultMessage);
		return false;
	}
	new namePlayer[MAX_PLAYER_NAME + 1], SQLRow: rowid;
	GetPlayerName(playerid, namePlayer, MAX_PLAYER_NAME + 1);
	rowid = yoursql_get_row(SQL:0, LOGIN_PASS_TBL_USR, "Name = %s", namePlayer);
	if (!rowid)
	{
		printf("Cannot change name for player %s (%d) - not found in database (%d)", namePlayer, playerid, int:rowid);
		return false;
	}
	new allowNameChangeDate = yoursql_get_field_int(SQL:0, LOGIN_PASS_TBL_NAMECHANGE_SML, rowid);
	new currentDate = gettime();
	if (currentDate < allowNameChangeDate)
	{
		printf("Cannot change name for player %s (%d) - player has already changed his nickname (last change: %d, current datetime: %d)", 
			serverPlayers[playerid][name], 
			playerid, 
			allowNameChangeDate, 
			currentDate);
		return false;
	}
	yoursql_set_field(SQL:0, LOGIN_PASS_TBL_USRNAME_SML, rowid, newPlayerName);//set the nickname
	yoursql_set_field_int(SQL:0, LOGIN_PASS_TBL_NAMECHANGE_SML, rowid, (currentDate + 259200));//create new name change time

	if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
		format(resultMessage, sizeof(resultMessage), "[/changename]: Nickname was successfully changed on this server!");
	else
		format(resultMessage, sizeof(resultMessage), "[/changename]: Ник был успешно изменён на этом сервере!");
	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, resultMessage);
	printf("Changing name is approved for player %s (%d) [Time: %d] [Next change: %d]", 
		serverPlayers[playerid][name], 
		playerid, 
		currentDate,
		currentDate + 259200);
	return true;
}

public LoginSystem_GetAccessLevel(playerid, serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
	if (!IsPlayerConnected(playerid))
		return 0;
	if (IsPlayerAdmin(playerid))
		return 10;
	new playerLevel = yoursql_get_field_int(SQL:0, LOGIN_PASS_TBL_USRACCESS_SML, yoursql_get_row(SQL:0, LOGIN_PASS_TBL_USR, "Name = %s", serverPlayers[playerid][name]));
	return playerLevel >= 0 ? playerLevel : 0;
}

public LoginSystem_SetAccessLevel(playerid, level, serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
	if (!IsPlayerConnected(playerid) || !serverPlayers[playerid][isLoggedIn])
		return false;
	if (level < 0 || level > 10)
	{
		printf("![ADM]> Cannot set access level [%d] for %s (%d). Wrong level!", level, serverPlayers[playerid][name], playerid);
		return false;
	}
	printf("![ADM]> Set access level [%d] for player %s (%d)!", level, serverPlayers[playerid][name], playerid);
	new SQLRow: rowid;
	rowid = yoursql_get_row(SQL:0, LOGIN_PASS_TBL_USR, "Name = %s", serverPlayers[playerid][name]);
	if (!rowid)
	{
		printf("Cannot change acces level for player %s (%d) - not found in database (%d)", serverPlayers[playerid][name], playerid, int:rowid);
		return false;
	}
	yoursql_set_field_int(SQL:0, LOGIN_PASS_TBL_USRACCESS_SML, rowid, level);
	new message[64];
	if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
		format(message, sizeof(message), "Your access (admin) level is now set to %d", level);
	else
		format(message, sizeof(message), "Уровень ваших админ прав изменён на: %d", level);
	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, message);
	return true;
}

public LoginSystem_RefereeGetCert(playerid, accessCertificate[257], serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
	format(accessCertificate, sizeof(accessCertificate), "");
	if (!IsPlayerConnected(playerid) || !serverPlayers[playerid][isLoggedIn])
		return false;
	new SQLRow: rowid;
	rowid = yoursql_get_row(SQL:0, LOGIN_PASS_TBL_USR, "Name = %s", serverPlayers[playerid][name]);
	if (!rowid)
	{
		printf("Cannot change acces level for player %s (%d) - not found in database (%d)", serverPlayers[playerid][name], playerid, int:rowid);
		return false;
	}
	yoursql_get_field(SQL:0, LOGIN_PASS_TBL_USRCERT_SML, rowid, accessCertificate);
	return true;
}
public LoginSystem_RefereeSetCert(playerid, accessCertificate[257], serverPlayers[MODE_MAX_PLAYERS][serverPlayer])
{
	if (!IsPlayerConnected(playerid) || !serverPlayers[playerid][isLoggedIn])
		return false;
	yoursql_set_field(SQL:0, LOGIN_PASS_TBL_USRCERT_SML, yoursql_get_row(SQL:0, LOGIN_PASS_TBL_USR, "Name = %s", serverPlayers[playerid][name]), accessCertificate);
	new message[64];
	if (serverPlayers[playerid][language] == PLAYER_LANGUAGE_ENGLISH)
		format(message, sizeof(message), "Your referee certificate was successfully changed");
	else
		format(message, sizeof(message), "Ваш судейский сертификат был успешно изменён");
	SendClientMessage(playerid, COLOR_SYSTEM_MAIN, message);
	return true;
}

#if !defined DOGFIGHTERS_SERVER
	#define DOGFIGHTERS_SERVER
	//	Functions for all players/objects/vehicles on server
	#include "dogfighters/server/menuDialogs/AddDogfightMenu.pwn"
	#include "dogfighters/server/menuDialogs/SelectVehicleMenu.pwn"
	#include "dogfighters/server/menuDialogs/SelectLanguageMenu.pwn"
	#include "dogfighters/server/menuDialogs/HelpMessageDialog.pwn"
	#include "dogfighters/server/menuDialogs/ChangePasswordDialog.pwn"
	#include "dogfighters/server/menuDialogs/DialogInput.pwn"
	#include "dogfighters/server/menuDialogs/ChangeNameDialog.pwn"
	#include "dogfighters/server/menuDialogs/DialogInput.pwn"
	#include "dogfighters/server/serverInfo/serverMain.pwn"
	#include "dogfighters/server/events/UpdatePlayers.pwn"
	#include "dogfighters/server/events/UpdateMissiles.pwn"
	#include "dogfighters/server/events/SaveDogfightGlobal.pwn"
	#include "dogfighters/server/events/ChangePlayerName.pwn"
	#include "dogfighters/server/commands/commandsMain.pwn"
	//#include "dogfighters/server/globals/ServerGlobalVariables.pwn"
#endif
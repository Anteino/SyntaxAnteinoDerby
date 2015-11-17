/*		
	By Syntax and Anteino (anteino@gmail.com) 15-11-2015
	
	This work is licensed under the
	Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.
	Go to http://creativecommons.org/licenses/by-nc-sa/4.0/ to read a copy
	of the license. Nothing may be copied and used in a commercial
	environment without special permission of the owners, Anteino & Syntax.
	
	Future aspirations for this project:
		-	Anti cheat module
		-	moving objects
		-	periodic powerups on the track
		-	roulating worlds/derbies
		-	language modules
*/

#define FILTERSCRIPT

#include <a_samp>		//	The SA-MP team with their awesome GTA SA mod
#include <zcmd>			//	The ZMCD module by Zeex
#include <sscanf2>		//	The scan module by Y_Less
#include <streamer>		//	Incognito's streamer
#include <AntiCheat>	//	GamerZ's anticheat module
#include "derby_defines.inc"

forward initializeDerby();
forward addDerbyPlayer(playerid);
forward findDerbyPlayer(playerid);
forward derbyUpdate();
forward derbyCountDown();
forward setUpVehicles();
forward removeDerbyPlayer(derbyId);
forward playerEndDerby(derbyId);
forward setDeathPos(derbyId);
forward resetDerbyPlayer(derbyId);
forward enableSpectatingMode(derbyId);
forward startDerby();
forward updatePlayers();
forward checkForDiedPlayers();
forward setOldAmmo(derbyId);
forward setOldHealth(derbyId);
forward setOldPosition(derbyId);
forward	releaseVehicles();
forward createArenaMap();
forward getOldAmmo(playerid);
forward Float:getOldHealth(playerid);
forward endDerby();
forward restartDerby();
forward sendLongClientMessage(color, const msg[], length);
forward setStartingPosition(i, Float:X, Float:Y, Float:Z, Float:Zr);
forward IsPlayerPaused(playerid);
forward changeSpectatedPlayer(derbyId, step);
forward sendClientMessageToAllPlayers(msg[]);
forward kickPlayer(derbyId, reason[]);
forward banPlayer(derbyId, reason[]);

enum derbyPlayerData
{
	oldAmmo,					//	When leaving the derby, the player will have their old ammo
	Float:oldHealth,			//	To remember the players old health
	oldWorld,					//	To remember which world the player came from
	Float:oldPosition[3],		//	To remember the players old position
	id,							//	Map the playerid to the array of derbyplayers
	status,						//	DERBY_PLAYER_DEAD when the player is eliminated and DERBY_PLAYER_ALIVE when not
	spectator,					//	The potential id of the player being spectated, in case of joining after a derby has started
	vehicleId,					//	The vehicleid of the vehicle assigned to the player
	kickVote[DERBY_KICKVOTES]	//	Array of playerids which voted to kick the player
}

new derbyPlayer[DERBY_MAX_PLAYERS][derbyPlayerData],

	derbyVehicleId				= 0,					//	id of the vehicle driven by the players, set in createArenaMap
	playerAmount				= 0,					//	+1 when a player joins and -1 when a player leaves the derby
	T1							= 0,					//	A time value used for several purposes
	dt							= 0,					//	A variable to measure elapsed time since specified event
	derbyWorld					= 0,					//	The virtual world of the derby, set in createArenaMap
	alivePlayers				= 0,					//	= playerAmount on start of derby, -1 when a player is eliminated
	countDownTime				= DERBY_COUNTDOWN_TIME,	//	The value X for the X..3..2..1..GO! to start from
	
	Float:minZHeight,									//	Below this height the player is considered eliminated, set in createArenaMap
	Float:minDeathZHeight,								//	Below this height, the position of an eliminated player is reset, set in createArenaMap
	
	Float:playerDeathPos[3],							//	The position which will be set for a player if they're eliminated, set in createArenaMap
	Float:spectatorPosition[3],							//	The position which will be set for a player if they're spectating, set in createArenaMap
	
	Float:startingPositions[DERBY_MAX_PLAYERS][4],		//	The positions and Z angle of the vehicles at the start of the derby, set in createArenaMap
	
	bool:derbyStarted 			= false,				//	To indicate if the derby has started
	bool:derbyCountDownStarted	= false,				//	To indicate if the countdown has started
	bool:vehiclesSetUp			= false,				//	To indicate if the vehicles are setup yet
	
	bool:startingPositionFree[DERBY_MAX_PLAYERS],		//	The starting positions will be assigned randomly to the players, this array is used to check for free positions
	
	Text:spectatingTextDraw;							//	The text draw shown to spectators

//	This functions loads the filterscript and starts the thread for the derby, the frequency at which the game is updated is 1 / ERBY_UPDATE_DELAY
public OnFilterScriptInit()
{
	print("Derby script loaded.\n");
	SetTimer("derbyUpdate", DERBY_UPDATE_DELAY, true);
	initializeDerby();
	return 1;
}

//	This function creates the objects for the playing fields and the textdraw for spectators
public OnGameModeInit()
{
	createArenaMap();
	spectatingTextDraw = TextDrawCreate(10.0, 415.0, "Press ~b~~k~~GO_LEFT~ ~w~or ~b~~k~~GO_RIGHT~ ~w~to switch players.");
	return 1;
}

//	Should the derby player die, this function takes care of their elimination, there is a slight delay because the player has to respawn before their location can be set
// public OnPlayerDeath(playerid, killerid, reason)
public OnPlayerSpawn(playerid)
{
	new derbyId = findDerbyPlayer(playerid);	//	Conversion from playerid to derbyId
	if(derbyId >= 0)
	{
		playerEndDerby(derbyId);
		// SetTimerEx("playerEndDerby", DERBY_DEATH_INTERVAL, false, "i", derbyId);
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	SetPVarInt(playerid, "lastUpdate", GetTickCount());
	return 1;
}

//	The key states are kept record of for players who are spectating, the left and right keys are used to switch between players being spectated by the playerid
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if (newkeys & KEY_FIRE)
	{
		SetPVarInt(playerid, "pressedKey", KEY_FIRE);
		return 1;
	}
	if ((oldkeys & KEY_LEFT) && !(newkeys & KEY_LEFT))
	{
		SetPVarInt(playerid, "releasedKey", KEY_LEFT);
		return 1;
	}
	if ((oldkeys & KEY_RIGHT) && !(newkeys & KEY_RIGHT))
	{
		SetPVarInt(playerid, "releasedKey", KEY_RIGHT);
		return 1;
	}
	return 1;
}

//	This module was causing problems, so it is disabled for now, the function of it may be clear, to kick/ban cheaters
public AC_OnCheatDetected(playerid, type, extraint, Float:extrafloat, extraint2)
{
	// new derbyId = findDerbyPlayer(playerid);
	// if(derbyId == -1  || IsPlayerPaused(derbyPlayer[derbyId][id]))
	// {
		// return 1;
	// }
	// switch(type)
	// {
		// case CHEAT_JETPACK:
		// {
			// kickPlayer(derbyId, "jetpack hack");
		// }
		// case CHEAT_WEAPON:
		// {
			// kickPlayer(derbyId, "weapon hack");
		// }
		// case CHEAT_SPEED:
		// {
			// if(extraint == derbyPlayer[derbyId][vehicleId])
			// {
				// banPlayer(derbyId, "speed hack");
			// }
		// }
		// case CHEAT_HEALTHARMOUR:
		// {
			// kickPlayer(derbyId, "health hack");
		// }
		// case CHEAT_PING:
		// {
			// kickPlayer(derbyId, "too high ping");
		// }
		// case CHEAT_TELEPORT:
		// {
			// banPlayer(derbyId, "teleport hack");
		// }
		// case CHEAT_AIRBREAK:
		// {
			// if(extraint == 100)
			// {
				// banPlayer(derbyId, "airbreak hack");
			// }
		// }
		// case CHEAT_SPECTATE:
		// {
			// kickPlayer(derbyId, "anti-spectate hack");
		// }
		// case CHEAT_REMOTECONTROL:
		// {
			// banPlayer(derbyId, "remote control hack")
		// }
		// case CHEAT_MASSCARTELEPORT:
		// {
			// banPlayer(derbyId, "mass car teleport hack");
		// }
		// case CHEAT_CARJACKHACK:
		// {
			// banPlayer(derbyId, "car jack hack");
		// }
	// }
	// return 1;
}

//	Kicks a player, showing them and every derby player the reason
public kickPlayer(derbyId, reason[])
{
	new msg[MAX_CLIENT_MESSAGE], name[MAX_PLAYER_NAME], playerId;
	
	playerId = derbyPlayer[derbyId][id];	//	To prevent confusion with the playerid obtained from callbacks, playerId is used here
	GetPlayerName(derbyPlayer[derbyId][id], name, MAX_PLAYER_NAME);
	format(msg, MAX_CLIENT_MESSAGE, "You were removed from the derby with reason: %s.", reason);
	SendClientMessage(derbyPlayer[derbyId][id], DERBY_MESSAGE_COLOR, msg);
	
	removeDerbyPlayer(derbyId);				//	The player is first eliminated from the derby before they're kicked
	format(msg, MAX_CLIENT_MESSAGE, "Derby: Player %s was removed from the derby and kicked from the server with reason: %s.", name, reason);
	sendClientMessageToAllPlayers(msg);		//	All derby players receive a message notifying them of the kick and reason
	Kick(playerId);							//	The actual kicking of the player
	print(msg);								//	A debug message introduced for the problems the anti cheat module is causing
}

//	Bans a player, showing them and every player on the server the reason, further documentation analogue to kickPlayer
public banPlayer(derbyId, reason[])
{
	new msg[MAX_CLIENT_MESSAGE], name[MAX_PLAYER_NAME], playerId;
	
	playerId = derbyPlayer[derbyId][id];
	GetPlayerName(derbyPlayer[derbyId][id], name, MAX_PLAYER_NAME);
	format(msg, MAX_CLIENT_MESSAGE, "You were removed from the derby with reason: %s.", reason);
	SendClientMessage(derbyPlayer[derbyId][id], DERBY_MESSAGE_COLOR, msg);
	
	removeDerbyPlayer(derbyId);
	format(msg, MAX_CLIENT_MESSAGE, "Derby: Player %s was removed from the derby and banned from the server with reason: %s.", name, reason);
	SendClientMessageToAll(DERBY_MESSAGE_COLOR, msg);
	Ban(playerId);
	print(msg);
}

//	This functions adds a new player to the derby
public addDerbyPlayer(playerid)
{
	for(new i = 0; i < DERBY_MAX_PLAYERS; i++){
		if(derbyPlayer[i][id] == -1)							//	If there is room in the derby, the playerid will be given the free spot in the derby, ie the derbyId
		{
			//	Save the old conditions of the player, which are reset on exiting the derby
			new Float:X = 0.0, Float:Y = 0.0, Float:Z = 0.0;
			derbyPlayer[i][oldAmmo] = getOldAmmo(playerid);
			derbyPlayer[i][oldWorld] = GetPlayerVirtualWorld(playerid);
			derbyPlayer[i][oldHealth] = getOldHealth(playerid);
			GetPlayerPos(playerid, X, Y, Z);
			derbyPlayer[i][oldPosition][0] = X;
			derbyPlayer[i][oldPosition][1] = Y;
			derbyPlayer[i][oldPosition][2] = Z;
			//	End of saving old conditions
			derbyPlayer[i][id] = playerid;						//	Map playerid to derbyId, now every function can use derbyId, because with this, the playerid is also know
			derbyPlayer[i][status] = DERBY_PLAYER_DEAD;			//	The player is eliminated until the (next) derby starts
			SetPVarInt(playerid, "lastUpdate", GetTickCount());	//	A player dependent variable is set to check for paused (pressed escape) players during the derby
			playerAmount++;										//	There is now one player more in the derby	
			if(playerAmount == DERBY_MIN_PLAYERS)				//	If there are enough players to start a derby (so at least 2), a timer will start for other players to join
																//	before the derby starts
			{
				T1 = GetTickCount();							//	This value will be used for if(GetTickCount - T1 > DERBY_START_DELAY) startDerby
			}
			for(new j = 0; j < DERBY_KICKVOTES; j++)
			{
				derbyPlayer[i][kickVote][j] = -1;				// The player starts with a clean slate of course
			}
			//	Teleport the player to eliminated players position until they can join a new round
			SetPlayerVirtualWorld(playerid, derbyWorld);
			SetPlayerPos(playerid, playerDeathPos[0], playerDeathPos[1], playerDeathPos[2]);
			//	End of teleport
			TogglePlayerControllable(playerid, 0);				//	Player can't move until new round starts
			TogglePlayerSpectating(derbyPlayer[i][id], 0);
			derbyPlayer[i][spectator] = -1;
			if(derbyStarted || derbyCountDownStarted)			//	This is most likely the case on a busy server
			{
				SendClientMessage(playerid, DERBY_MESSAGE_COLOR, "Derby: The derby has already started, you can spectate the current derby and are automatically joined in the next.");
				enableSpectatingMode(i);
			}
			SendClientMessage(playerid, DERBY_MESSAGE_COLOR, "Derby: Welcome to the derby! If you spot a cheater, use /kickvote [id].");
			return 1;
		}
	}
	SendClientMessage(playerid, DERBY_MESSAGE_COLOR, "Derby: this derby is full");	//	Here something could be implemented to suggest another derby
	return 0;
}

//	This function allows the players who joined during a match to watch the other players, the first joined player which is not eliminated is the default spectated player
public enableSpectatingMode(derbyId)
{
	SetPlayerPos(derbyPlayer[derbyId][id], spectatorPosition[0], spectatorPosition[1], spectatorPosition[2]);
	TogglePlayerControllable(derbyPlayer[derbyId][id], 1);
	TogglePlayerSpectating(derbyPlayer[derbyId][id], 1);
	TextDrawShowForPlayer(derbyPlayer[derbyId][id], spectatingTextDraw);	//	Instructions on how to switch spectated player are shown
	for(new i = 0; i < playerAmount; i++)
	{
		//	Only players who are not eliminated and are not spectators themselves can be spectated, the latter could be removed from the constraints though
		if(derbyPlayer[i][status] == DERBY_PLAYER_ALIVE && derbyPlayer[i][spectator] == -1)
		{
			new name1[MAX_PLAYER_NAME], name2[MAX_PLAYER_NAME], msg[MAX_CLIENT_MESSAGE];
			GetPlayerName(derbyPlayer[derbyId][id], name1, MAX_PLAYER_NAME);
			GetPlayerName(derbyPlayer[i][id], name2, MAX_PLAYER_NAME);
			format(msg, MAX_CLIENT_MESSAGE, "Player %s has started spectating player %s.", name1, name2);
			print(msg);
			derbyPlayer[derbyId][spectator] = i;
			PlayerSpectateVehicle(derbyPlayer[derbyId][id], derbyPlayer[i][vehicleId], SPECTATE_MODE_NORMAL);
		}
	}
	return 1;
}

//	Remove a player from the derby, either because they used the /exit command or after they've been caught cheating
public removeDerbyPlayer(derbyId)
{
	playerAmount--;		//	The amount of player is decreased
	playerEndDerby(derbyId);
	if(IsPlayerConnected(derbyPlayer[derbyId][id]))		//	Set old conditions back if player is still on the server
	{
		setOldAmmo(derbyId);
		setOldHealth(derbyId);
		setOldPosition(derbyId);
		TogglePlayerControllable(derbyPlayer[derbyId][id], 1);
	}
	/*	Prevent having to move every entry in the array, just change the derbyId of the last player, so take [p1, p2, p3, p4, p5, ... empty spaces ..., pMAX],
		if p3 leaves, this array will become[p1, p2, p5, p4, ... empty spaces ..., pMAX]. This way it's ensured that playerAmount - 1 is always the id of the last player.
	*/
	derbyPlayer[derbyId] = derbyPlayer[playerAmount];
	resetDerbyPlayer(playerAmount);
	return 1;
}

//	Set of functions to reset to old conditions of player
public setOldPosition(derbyId)
{
	SetPlayerVirtualWorld(derbyPlayer[derbyId][id], derbyPlayer[derbyId][oldWorld]);
	SetPlayerPos(derbyPlayer[derbyId][id], derbyPlayer[derbyId][oldPosition][0], derbyPlayer[derbyId][oldPosition][1], derbyPlayer[derbyId][oldPosition][2]);
	return 1;
}

public setOldHealth(derbyId)
{
	SetPlayerHealth(derbyPlayer[derbyId][id], derbyPlayer[derbyId][oldHealth]);
	return 1;
}

public setOldAmmo(derbyId)
{
	new weapon, ammo;
	for(new i = 0; i < WEAPON_SLOTS; i++)
	{
		GetPlayerWeaponData(derbyPlayer[derbyId][id], i, weapon, ammo);
		if(weapon == DERBY_WEAPON_ID)
		{
			SetPlayerAmmo(derbyPlayer[derbyId][id], weapon, derbyPlayer[derbyId][oldAmmo]);
			return 1;
		}
	}
	return 1;
}
//	End of set of functions to reset old conditions

//	This function is called when a player is eliminated
public playerEndDerby(derbyId)
{
	derbyPlayer[derbyId][status] = DERBY_PLAYER_DEAD;									//	Direct indication of player being dead
	setDeathPos(derbyId);
	GivePlayerWeapon(derbyPlayer[derbyId][id], DERBY_WEAPON_ID, DERBY_WEAPON_AMMO);		//	Give player the weapon to eliminate other players from above
	DestroyVehicle(derbyPlayer[derbyId][vehicleId]);									//	Get rid of the players vehicle
	alivePlayers--;																		//	Pretty straightforward
	return 1;
}

//	This function sets the position of the eliminated player to the position specified in createArenaMap
public setDeathPos(derbyId)
{
	SetPlayerPos(derbyPlayer[derbyId][id], playerDeathPos[0], playerDeathPos[1], playerDeathPos[2]);
	return 1;
}

//	Checks if the player had a rocket launcher before joining the game, if this is normally an illegal weapon just set it to return 0
public getOldAmmo(playerid)
{
	new weapon = 0, ammo = 0;
	for(new i = 0; i < WEAPON_SLOTS; i++)
	{
		GetPlayerWeaponData(playerid, i, weapon, ammo);
		if(weapon == DERBY_WEAPON_ID)
		{
			return ammo;
		}
	}
	return 0;
}

//	This function gets the current health of the player and is called when they join to save their conditions before joining the game
public Float:getOldHealth(playerid)
{
	new Float:tmp = 0.0;
	GetPlayerHealth(playerid, tmp);
	return tmp;
}

/*	These two functions initialize all the derbyPlayer values to make comparisons like 
	derbyPlayer[derbyId][status] == DERBY_PLAYER_ALIVE make sense before the derby is started the first time
*/
public initializeDerby()
{
	for(new i = 0; i < DERBY_MAX_PLAYERS; i++)
	{
		resetDerbyPlayer(i);
	}
}

public resetDerbyPlayer(derbyId)
{
	derbyPlayer[derbyId][oldAmmo] = 0;
	derbyPlayer[derbyId][oldHealth] = 0.0;
	derbyPlayer[derbyId][oldWorld] = 0;
	derbyPlayer[derbyId][oldPosition][0] = 0.0;
	derbyPlayer[derbyId][oldPosition][1] = 0.0;
	derbyPlayer[derbyId][oldPosition][2] = 0.0;
	derbyPlayer[derbyId][id] = -1;
	derbyPlayer[derbyId][status] = DERBY_PLAYER_DEAD;
	derbyPlayer[derbyId][spectator] = -1;
	derbyPlayer[derbyId][vehicleId] = -1;
	for(new i = 0; i < DERBY_KICKVOTES; i++)
	{
		derbyPlayer[derbyId][kickVote][i] = 0;
	}
}
//	End of derby intialization

//	This function lets the player join the derby
CMD:derby(playerid, params[]){
	if(findDerbyPlayer(playerid) >= 0)	//	Check if player is not already in the derby
	{
		SendClientMessage(playerid, DERBY_MESSAGE_COLOR, "Derby: You're already in the derby!\n");
		return 1;
	}
	addDerbyPlayer(playerid);			//	Can still return negative outcome if the derby is full
	return 1;
}

//	This functions checks if the player is in the derby, and if so, allows it to leave
CMD:exit(playerid, params[])
{
	new derbyId = findDerbyPlayer(playerid);
	if(derbyId >= 0)
	{
		removeDerbyPlayer(derbyId);
	}
	return 1;
}

//	Allows the players to democratically remove a player from the derby when they are cheating, should probably be disabled because of possible misuse
CMD:kickvote(playerid, params[])
{
	new kickId, derbyId;
	if(sscanf(params, "d", kickId))
	{
		SendClientMessage(playerid, DERBY_MESSAGE_COLOR, "USAGE: /kickvote <playerid>");
		return 1;
	}
	else
	{
		if(findDerbyPlayer(playerid) == -1)
		{
			SendClientMessage(playerid, DERBY_MESSAGE_COLOR, "Derby: you can only /kickvote when you're part of the derby.");
			return 1;
		}
		derbyId = findDerbyPlayer(kickId);
		for(new i = 0; i < DERBY_KICKVOTES; i++)
		{
			if(derbyPlayer[derbyId][kickVote][i] != -1)
			{
				if(derbyPlayer[derbyId][kickVote][i] == playerid)
				{
					SendClientMessage(playerid, DERBY_MESSAGE_COLOR, "Derby: You can only /kickvote the player once.");
					return 1;		//	Every player can only vote once to keep things fair
				}
				continue;
			}
			else
			{
				derbyPlayer[derbyId][kickVote][i] = playerid;		//	The playerid of the reporter is logged to keep track of who has voted yet
				if(i == DERBY_KICKVOTES)							//	The maximum amount of votes have been achieved
				{
					new msg[MAX_CLIENT_MESSAGE], name[MAX_PLAYER_NAME];
					GetPlayerName(derbyPlayer[derbyId][id], name, MAX_PLAYER_NAME);
					SendClientMessage(derbyPlayer[derbyId][id], DERBY_MESSAGE_COLOR, "You were removed from the derby.");
					removeDerbyPlayer(derbyId);
					format(msg, MAX_CLIENT_MESSAGE, "Derby: Player %s was removed from the derby.", name);
					sendClientMessageToAllPlayers(msg);
				}
				return 1;
			}
		}
	}
	return 1;
}

//	That is, to all DERBY players
public sendClientMessageToAllPlayers(msg[])
{
	for(new i = 0; i < playerAmount; i++)
	{
		SendClientMessage(derbyPlayer[i][id], DERBY_MESSAGE_COLOR, msg);
	}
	return 1;
}

//	Finds out if a playerid is in the derby. To save computing time, one could introduce an array playerInDerby[MAX_PLAYERS] to keep track of this
public findDerbyPlayer(playerid)
{
	for(new i = 0; i < DERBY_MAX_PLAYERS; i++)
	{
		if(derbyPlayer[i][id] == playerid)
		{
			return i;
		}
	}
	return -1;
}

/*	The idea of this function is that there can be more of these in the future,
	so that the script can select the correct function belonging to a specific map.
*/
public createArenaMap()
{
	derbyWorld = 97;		//	Virtual world for this specific derby
	// derbyVehicleId = 415;	//	Cheetah
	// derbyVehicleId = 409;	//	Stretch
	derbyVehicleId = 571;		//	Kart
	
	//	Start of creating objects in playing field
	CreateDynamicObject(1337, 2520.6001, -1672.7, 14.5, 0, 0, 334, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(1337, 2488.2, -1662, 13, 0, 0, 324, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(1337, 2673.8999, -1774.5, 37, 0, 0, 14, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(1337, 2681.8999, -1771.5, 38.8, 0, 0, 0, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(1337, 2688.3, -1769.8, 40.3, 0, 0, 0, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(1337, 2694.8, -1768, 41.1, 0, 0, 0, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(1337, 2703.3, -1766, 41.8, 0, 0, 0, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(1660, 2793.8999, -1743.9, 37, 0, 0, 160, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(1660, 2785.5, -1756.1, 39, 0, 0, 27.999, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(1660, 2777.8999, -1740.1, 37.9, 0, 0, 256, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(1660, 2785.8, -1755.8, 38.8, 0, 0, 0, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(2935, 2728.5, -1760.8, 44.4, 0, 0, 0, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(2935, 2746.3999, -1761.2, 44.4, 0, 0, 0, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(2935, 2737.8999, -1770.6, 44.3, 0, 0, 268, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(2935, 2738.5, -1749.6, 44.4, 0, 0, 268, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(2935, 2730.8999, -1768, 44.4, 0, 0, 44, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(2935, 2731.8, -1753.3, 44.3, 0, 0, 320, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(2935, 2744.3, -1753.8, 44.3, 0, 0, 34, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(2935, 2744.2, -1767.9, 44.3, 0, 0, 324, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(1395, 2737.8999, -1760.9, 75.7, 0, 0, 0, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(2934, 2740.8, -1729.5, 43, 0, 0, 26, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(2934, 2735.1001, -1730.1, 43, 0, 0, 344, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(2934, 2737.7, -1722.4, 42.4, 0, 0, 0, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(2934, 2729.3, -1706.8, 40.2, 0, 0, 334, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(2934, 2735.8, -1706.1, 40.5, 0, 0, 36, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	CreateDynamicObject(2934, 2731.6001, -1700.3, 38.9, 0, 0, 0, derbyWorld, -1, -1, DERBY_DRAW_DISTANCE, DERBY_DRAW_DISTANCE);
	//	End of object creation
	
	//	When the player is eliminated from the playing field, they will be placed on this position with a rocket launcher
	playerDeathPos[0] = 2738.1929;
	playerDeathPos[1] = -1760.6576;
	playerDeathPos[2] = 130.2522;
	
	//	When the player is spectating, this is their position
	spectatorPosition[0] = 2660.5981;
	spectatorPosition[1] = -1458.6235;
	spectatorPosition[2] = 80.3805;
	
	minZHeight = 40.2138 - DERBY_DEATH_DZ;			//	If the player gets below this height, they will be considered off playing field
	minDeathZHeight = 130.2522 - DERBY_DEATH_DZ;	//	Should the player get below this height after being eliminated, the position is reset	
	
	//	Creates starting positions for derby players in a circle around the middle
	new Float:R = 24.4;
	for(new i = 0; i < DERBY_MAX_PLAYERS; i++)
	{
		setStartingPosition(	i,
								2737.5989 + R * floatsin(float(i) / float(DERBY_MAX_PLAYERS) * 360.0, degrees),
								-1760.1744 + R * floatcos(float(i) / float(DERBY_MAX_PLAYERS) * 360.0, degrees),
								42.8689,
								180.0 - float(i) / float(DERBY_MAX_PLAYERS) * 360.0
							);
	}
	//	End of positioning
	return 1;
}

//	Helps initialize the startingPositions array and keep createArenaMap clean and organized
public setStartingPosition(i, Float:X, Float:Y, Float:Z, Float:Zr)
{
	startingPositions[i][0] = X;
	startingPositions[i][1] = Y;
	startingPositions[i][2] = Z + DERBY_EXTRA_STARTING_HEIGHT;
	startingPositions[i][3] = Zr;
	startingPositionFree[i] = true;
	return 1;
}

//	When derbyCountDownStarted == true this function will be called every time the thread updates
public derbyCountDown()
{
	new msg[4] = "";
	dt = GetTickCount() - T1;
	if(dt >= DERBY_COUNTDOWN_DT){				//	Has a second passed since the last message (3, 2, 1, GO!) on the screen?
		T1 += DERBY_COUNTDOWN_DT;				//	Tell the timer a second has passed
		if(countDownTime <= 0)					//	Should the countDownTime == 0, the derby is started
		{
			startDerby();
			msg = "Go!";
			derbyCountDownStarted = false;		//	Countdown can of course be stopped and resetted now
			derbyStarted = true;				//	The next time the derby updates it starts the derby
		}
		else {
			valstr(msg, countDownTime / DERBY_COUNTDOWN_DT);	//	Only show whole seconds in the countdown
		}
		print(msg);
		for(new i = 0; i < playerAmount; i++)
		{
			GameTextForPlayer(derbyPlayer[i][id], msg, DERBY_COUNTDOWN_DT, DERBY_COUNTDOWN_TEXT_STYLE);
		}
		countDownTime -= DERBY_COUNTDOWN_DT;	//	Decrease the counter with the passed time
	}
	return 1;
}

//	Resets some values which should be reset before every derby
public startDerby()
{
	alivePlayers = playerAmount;			//	Every player is NOT eliminated (yet)
	for(new i = 0; i < playerAmount; i++)
	{
		derbyPlayer[i][status] = DERBY_PLAYER_ALIVE;		//	Setting the individual states of the non eliminated players
		TogglePlayerControllable(derbyPlayer[i][id], 1);	//	Make sure the players can move
	}
	return 1;
}

//	Toggles the engines of the vehicles the players where already placed in during countdown
public releaseVehicles()
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	vehiclesSetUp = false;
	for(new i = 0; playerAmount; i++)
	{
		GetVehicleParamsEx(derbyPlayer[i][vehicleId], engine, lights, alarm, doors, bonnet, boot, objective);
		engine = 1;
		SetVehicleParamsEx(derbyPlayer[i][vehicleId], engine, lights, alarm, doors, bonnet, boot, objective);
	}
	return 1;
}

//	Sends a message only to ALL DEBY players, when the message is too long, it's chopped into pieces and send. Note that sentences are NOT broken down nicely with - and serried syllables
public sendLongClientMessage(color, const msg[], length)
{
	new tmp[MAX_CLIENT_MESSAGE];
	new amountOfLoops = 0;
	
	//	Determine how many messages are needed 
	if(length % MAX_CLIENT_MESSAGE == 0)
	{
		amountOfLoops = length / MAX_CLIENT_MESSAGE;
	}
	else
	{
		amountOfLoops = length / MAX_CLIENT_MESSAGE + 1;
	}
	//	End
	
	//	Send the actual message in parts of length MAX_CLIENT_MESSAGE
	for(new i = 0; i < amountOfLoops; i++)
	{
		strmid(tmp, msg, i * MAX_CLIENT_MESSAGE, (i + 1) * MAX_CLIENT_MESSAGE - 1, MAX_CLIENT_MESSAGE);
		for(new j = 0; j < playerAmount; j++)
		{
			SendClientMessage(derbyPlayer[j][id], color, tmp);
		}
	}
	
}

/*	There's either only one survivor or time has run out. Either way this function will eventually be called.
	The function finds the winner(s) of the derby round and sends the outcome to all the DERBY players, it 
	also resets the game, so a new game can be started.
*/
public endDerby()
{
	new winners[DERBY_MAX_PLAYERS];							//	To save the ids of the non eliminated players
	new amountWinners = 0;									//	Increase when a non eliminated player is found
	new msg[DERBY_MAX_PLAYERS * MAX_PLAYER_NAME] = "init";	//	This is initialized to test if it's correctly reset in the code, and it is
	new name[MAX_PLAYER_NAME];								//	Variable to temporarily save the name of the winning player
	
	for(new i = 0; i < playerAmount; i++)
	{
		TogglePlayerControllable(derbyPlayer[i][id], 0);	//	They can't move untill the next derby starts there's by the way no need to reset ammo,
															//	as players which get out of their vehicles, are eliminated
		if(derbyPlayer[i][status] == DERBY_PLAYER_ALIVE)	//	To win, a player must not be eliminated
		{
			winners[amountWinners] = derbyPlayer[i][id];
			amountWinners++;
			playerEndDerby(i);								//	Still has to be called, as it takes care of things like destroying the player's vehicle
		}
	}
	if(amountWinners == 0)									//	In the rare case the last two players are both eliminated between two updates
	{
		msg = "Derby: There were no winners.\n";
	}
	else if(amountWinners == 1)								//	If the game ended because there was only one player left
	{
		GetPlayerName(winners[0], name, MAX_PLAYER_NAME);
		msg = "Derby: The winner of this derby is: ";
		strcat(msg, name);
	}
	else													//	If the game ended because the timer ran out
	{
		msg = "Derby: The winners of this derby are: ";
		GetPlayerName(winners[0], name, MAX_PLAYER_NAME);
		strcat(msg, name);
		for(new j = 1; j < amountWinners - 1; j++)
		{
			GetPlayerName(winners[j], name, MAX_PLAYER_NAME);
			strcat(msg, ", ");								//	Insert "spacer"
			strcat(msg, name);
		}
		GetPlayerName(winners[amountWinners - 1], name, MAX_PLAYER_NAME);
		strcat(msg, " and ");								//	Spacer is different for the last player in the sentence
		strcat(msg, name);
		strcat(msg, ".");
	}
	
	print(msg);
	
	sendLongClientMessage(DERBY_MESSAGE_COLOR, msg, strlen(msg));	//	Send the outcome of the game to every DERBY player
	
	for(new i = 0; i < DERBY_MAX_PLAYERS; i++)						//	Reset all the variables to start a new game
	{
		startingPositionFree[i] = true;								//	There are of course as many starting positions as there can be players
		TogglePlayerSpectating(derbyPlayer[i][id], 0);
		derbyPlayer[i][spectator] = -1;								//	No one is spectating any more of course
		TogglePlayerSpectating(derbyPlayer[i][id], 0);				//	Stop the actual spectating
	}
	derbyStarted = false;											//	The derby is ended
	derbyCountDownStarted = false;									//	The countdown is not (yet) active because there is an amount of time between two sequential games			
	countDownTime = DERBY_COUNTDOWN_TIME;							//	The countdown timer is already reset however
	vehiclesSetUp = false;											//	Vehicles are deleted so they can't be set up (dohh)
	
	SetTimer("restartDerby", DERBY_RESTART_DELAY, false);			//	A countdown before the countdown starts, there are probably neater ways to implement this
	return 1;
}

//	Sets the (last) needed condition to start the derby
public restartDerby()
{
	print("Derby was restarted.");
	alivePlayers = playerAmount;	//	In the next derby update, statement 2 will be true, starting the countdown after DERBY_RESTART_DELAY milliseconds have passed
	T1 = GetTickCount();
	return 1;
}

//	Puts the vehicles in place, because this might take a lot of time, it is done during the countdown, a second is always enough time
public setUpVehicles()
{
	new pos = -1, engine, lights, alarm, doors, bonnet, boot, objective;
	new bool:foundFreeSlot = false;
	for(new i = 0; i < playerAmount; i++)
	{
		//	Take a good patient look at this, it's very logic, not efficient, but logic
		pos = -1;
		foundFreeSlot = false;
		while(!foundFreeSlot)
		{
			pos = random(DERBY_MAX_PLAYERS - 1);
			foundFreeSlot = startingPositionFree[pos];
		}
		startingPositionFree[pos] = false;
		derbyPlayer[i][vehicleId] = CreateVehicle(derbyVehicleId, startingPositions[pos][0], startingPositions[pos][1], startingPositions[pos][2], random(255), random(255), 0, 0);
		SetVehicleVirtualWorld(derbyPlayer[i][vehicleId], derbyWorld);
		PutPlayerInVehicle(derbyPlayer[i][id], derbyPlayer[i][vehicleId], 0);
		SetVehicleZAngle(derbyPlayer[i][vehicleId], startingPositions[pos][3]);
		GetVehicleParamsEx(derbyPlayer[i][vehicleId], engine, lights, alarm, doors, bonnet, boot, objective);
		engine = 0;		//	Will be set to 1, in other words true, when the countdown has finished
		SetVehicleParamsEx(derbyPlayer[i][vehicleId], engine, lights, alarm, doors, bonnet, boot, objective);
	}
	vehiclesSetUp = true;
	return 1;
}

//	Check for changes in the players states: eliminated or not, switched spectated id, is paused
public updatePlayers()
{
	new Float:X = 0.0, Float:Y = 0.0, Float:Z = 0.0;
	for(new i = 0; i < playerAmount; i++)
	{
		new msg[32];
		valstr(msg, derbyPlayer[i][spectator]);
		print(msg);
		GetPlayerPos(derbyPlayer[i][id], X, Y, Z);
		if(derbyPlayer[i][status] == DERBY_PLAYER_DEAD)
		{
			if (derbyPlayer[i][spectator] >= 0)
			{
				if(GetPVarInt(derbyPlayer[i][id], "releasedKey") == KEY_RIGHT)
				{
					changeSpectatedPlayer(i, 1);
					SetPVarInt(derbyPlayer[i][id], "releasedKey", -1);	//	In the next update the code won't reach this part so it won't be repeated infinitely
				}
				if(GetPVarInt(derbyPlayer[i][id], "releasedKey") == KEY_LEFT)
				{
					changeSpectatedPlayer(i, -1);
					SetPVarInt(derbyPlayer[i][id], "releasedKey", -1);
				}
			}
			SetPlayerHealth(derbyPlayer[i][id], 100.0);	//	This sounds contradictory but is actually meant to keep player from murdering each other after they've been eliminated
			if (Z < minDeathZHeight && derbyPlayer[i][spectator] == -1) 	//	Should the eliminated player jump of the platform, they are put back
			{
				setDeathPos(i);
			}
		}
		/*	Make sure to understand the difference between minDeathZHeight and minZHeight, see createArenaMap to this end.
			If a player is alive and falls of the platform, this is the part where that is detected. If a player pressed ESC
			to prevent from being pushed of, they automatically are eliminated, the same goes for when they get out of their
			vehicle
		*/
		else if(Z <= minZHeight || IsPlayerPaused(derbyPlayer[i][id]) || !IsPlayerInAnyVehicle(derbyPlayer[i][id]))
		{
			if(derbyPlayer[i][spectator] == -1)
			{
				playerEndDerby(i);
				derbyPlayer[i][status] = DERBY_PLAYER_DEAD;
			}
		}
		else
		{
			if(GetPVarInt(derbyPlayer[i][id], "pressedKey") == KEY_FIRE)
			{
				AddVehicleComponent(derbyPlayer[i][vehicleId], 1010);
			}
			else
			{
				RemoveVehicleComponent(derbyPlayer[i][vehicleId], 1010);
			}
		}
	}
}

//	This function changes the player being spectated by derbyId, step can only be 1 or -1
public changeSpectatedPlayer(derbyId, step)
{
	new targetId = 0;
	for(new i = derbyPlayer[derbyId][spectator] + step; i < derbyPlayer[derbyId][spectator] + step * DERBY_MAX_PLAYERS; i += step)
	{
		targetId = i % DERBY_MAX_PLAYERS;	//	Together with the second statement in the for loop this will loop through all the derby players in the direction of step
		if(targetId == derbyId)				//	Player can't spectate themselves
		{
			continue;
		}
		else if(derbyPlayer[targetId][spectator] == -1)	//	The player being spectated can't be a spectator themselve. This allows the spectators to be moved to any position.
		{
			PlayerSpectateVehicle(derbyPlayer[derbyId][id], derbyPlayer[targetId][id], SPECTATE_MODE_NORMAL);
			return 1;
		}
	}
	return 0;
}

//	This function checks if the last update from the player is so long ago, it must be ALT + TABBED or used ESC to pause, this is of course a way of cheating
public IsPlayerPaused(playerid)
{
	return GetTickCount() - GetPVarInt(playerid, "lastUpdate") > 1000;
}

public derbyUpdate()
{
	//	Statement 1:	If the countdown is started, it's updated here. When the countdown is through, derbyStarted is set to true and timer T1 = GetTickCount()
	if(derbyCountDownStarted)
	{
		derbyCountDown();
		if(!vehiclesSetUp)
		{
			setUpVehicles();	//	Should the vehicles not be set up yet, they will be. In setUpVehicles vehiclesSetUp will be set to true
		}
	}
	/*	Statement 2:	To start the countdown there should be at least two players, every player is alive (not eliminated), the countdown is
						not YET started, the game definately can't be started and the start delay between two games or after the first two 
						players have joined is over.
	*/
	else if(playerAmount >= DERBY_MIN_PLAYERS && !derbyStarted && !derbyCountDownStarted && GetTickCount() - T1 > DERBY_START_DELAY)
	{
		T1 = GetTickCount();
		derbyCountDownStarted = true;
	}
	/*	Statement 3:	At the end of the countdown derbyStarted is set to true and at the beginning of the countdown the vehiclesSetUp was set
		to true after the vehicles were set up. The derby can now really start!
	*/
	else if((derbyStarted) && (vehiclesSetUp))
	{
		/*	vehiclesSetUp is set to false in this function, because the vehicles will move and thus differ from their original set up, but more
			importantly, this function isn't called anymore, which would take a lot of otherwise useful computing time every update.
		*/
		releaseVehicles();
	}
	//	Statement 4:	Only if the countdown is over, the vehicles were set up and released and the derby was started, this code can be reached
	else if(derbyStarted)
	{
		updatePlayers();			//	Check if anything changed in the players states
		dt = GetTickCount() - T1;	//	Update the change in time since the game was started, so the maximum duration of the game can be compared to this value
		if (alivePlayers <= 1 || dt >= DERBY_TOTAL_TIME)
		{
			endDerby();				//	End the derby if this is the case or if every player but one is eliminated
		}
	}
}
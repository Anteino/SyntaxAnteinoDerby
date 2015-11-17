//----------------------------------------------------------
//
//  GRAND LARCENY  1.0
//  A freeroam gamemode for SA-MP 0.3
//
//----------------------------------------------------------

#include <a_samp>
#include <a_npc>
#include <core>
#include <float>
#include <AntiCheat>
#include "../include/gl_common.inc"
#include "../include/gl_spawns.inc"

#pragma tabsize 0

#define COLOR_WHITE 		0xFFFFFFFF
#define COLOR_NORMAL_PLAYER 0xFFBB7777

new total_vehicles_from_files=0, randSpawn = 1;

main()
{
	print("\n---------------------------------------");
	print("Anteino + Syntax derby.\n");
	print("---------------------------------------\n");
}

public AC_OnCheatDetected(playerid, type, extraint, Float:extrafloat, extraint2)
{
	switch(type)
	{
		case CHEAT_JETPACK:
		{
			//	Do something
		}
		case CHEAT_WEAPON:
		{
		
		}
		case CHEAT_SPEED:
		{
		
		}
		case CHEAT_HEALTHARMOUR:
		{
		
		}
		case CHEAT_IPFLOOD:
		{
		
		}
		case CHEAT_PING:
		{
		
		}
		case CHEAT_SPOOFKILL:
		{
		
		}
		case CHEAT_SPAWNKILL:
		{
		
		}
		case CHEAT_INACTIVITY:
		{
		
		}
		case CHEAT_TELEPORT:
		{
		
		}
		case CHEAT_AIRBREAK:
		{
		
		}
		case CHEAT_BACK_FROM_INACTIVITY:
		{
		
		}
		case CHEAT_SPECTATE:
		{
		
		}
		case CHEAT_FASTCONNECT:
		{
		
		}
		case CHEAT_REMOTECONTROL:
		{
		
		}
		case CHEAT_MASSCARTELEPORT:
		{
		
		}
		case CHEAT_CARJACKHACK:
		{
		
		}
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	GameTextForPlayer(playerid,"~w~Anteino + Syntax derby",3000,4);
  	SendClientMessage(playerid,COLOR_WHITE,"Welcome to Anteino + Syntax derby!");
 	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	
	randSpawn = random(sizeof(gRandomSpawns_LosSantos));
	SetPlayerPos(playerid,
		gRandomSpawns_LosSantos[randSpawn][0],
		gRandomSpawns_LosSantos[randSpawn][1],
		gRandomSpawns_LosSantos[randSpawn][2]);
	SetPlayerFacingAngle(playerid,gRandomSpawns_LosSantos[randSpawn][3]);
	
	SetPlayerInterior(playerid,0);
	TogglePlayerClock(playerid,0);
 	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, 30000);
    
    GivePlayerWeapon(playerid,WEAPON_COLT45,100);
	TogglePlayerClock(playerid, 0);

	return 1;
}

//----------------------------------------------------------

public OnPlayerDeath(playerid, killerid, reason)
{
	if(IsPlayerNPC(playerid)) return 1;
    new playercash;
    
	if(killerid == INVALID_PLAYER_ID) {
        ResetPlayerMoney(playerid);
	} else {
		playercash = GetPlayerMoney(playerid);
		if(playercash > 0)  {
			GivePlayerMoney(killerid, playercash);
			ResetPlayerMoney(playerid);
		}
	}
   	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid)) return 1;
	return 1;
}

//----------------------------------------------------------

public OnGameModeInit()
{
	if(IsPlayerNPC(playerid)) return 1;
	SetGameModeText("Anteino + Syntax derby.");
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
	ShowNameTags(1);
	SetNameTagDrawDistance(40.0);
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	SetWeather(2);
	SetWorldTime(11);
	
	//SetObjectsDefaultCameraCol(true);
	//UsePlayerPedAnims();
	//ManualVehicleEngineAndLights();
	//LimitGlobalChatRadius(300.0);

	// Player Class
	AddPlayerClass(298,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(299,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(300,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(301,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(302,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(303,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(304,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(305,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(280,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(281,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(282,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(283,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(284,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(285,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(286,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(287,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(288,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(289,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(265,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(266,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(267,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(268,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(269,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(270,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(1,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(2,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(3,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(4,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(5,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(6,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(8,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(42,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(65,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	//AddPlayerClass(74,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(86,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(119,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
 	AddPlayerClass(149,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(208,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(273,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(289,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	
	AddPlayerClass(47,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(48,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(49,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(50,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(51,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(52,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(53,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(54,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(55,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(56,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(57,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(58,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
   	AddPlayerClass(68,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(69,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(70,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(71,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(72,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(73,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(75,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(76,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(78,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(79,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(80,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(81,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(82,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(83,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(84,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(85,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(87,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(88,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(89,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(91,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(92,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(93,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(95,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(96,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(97,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(98,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(99,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);

	// SPECIAL
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/trains.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/pilots.txt");

   	// LAS VENTURAS
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_gen.txt");
    
    // SAN FIERRO
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_gen.txt");
    
    // LOS SANTOS
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_gen_inner.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_gen_outer.txt");
    
    // OTHER AREAS
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/whetstone.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/bone.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/flint.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/tierra.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/red_county.txt");

    printf("Total vehicles from files: %d",total_vehicles_from_files);

	return 1;
}

//----------------------------------------------------------

public OnPlayerUpdate(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	return 1;
}
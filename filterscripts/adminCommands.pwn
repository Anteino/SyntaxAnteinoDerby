#define FILTERSCRIPT

#include <a_samp>		//	The SA-MP team with their awesome GTA SA mod
#include <zcmd>			//	The ZMCD module by Zeex
#include <sscanf2>		//	The scan module by Y_Less

#define MESSAGE_COLOR	0xFFFFFFFF

CMD:kill(playerid, params[])
{
	// if(IsPlayerAdmin(playerid))
	// {
		new killId;
		if(!sscanf(params, "d", killId) && killId >= 0)
		{
			SetPlayerHealth(params[0], 0.0);
		}
		else
		{
			SetPlayerHealth(playerid, 0.0);
		}
		return 1;
	// }
	// return 0;
}

CMD:jetpack(playerid, params[])
{
	// if(IsPlayerAdmin(playerid))
	// {
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
		return 1;
	// }
	// return 0;
}

CMD:spectate(playerid, params[])
{
	new target;
	if(sscanf(params, "d", target))
	{
		TogglePlayerSpectating(playerid, 0);
		SendClientMessage(playerid, MESSAGE_COLOR, "USAGE: /spectate <playerid>");
	}
	else
	{
		TogglePlayerSpectating(playerid, 1);
		PlayerSpectatePlayer(playerid, target, SPECTATE_MODE_NORMAL);
	}
	return 1;
}

CMD:goto(playerid, params[])
{
	new target, Float:X, Float:Y, Float:Z;
	if(sscanf(params, "d", target))
	{
		SendClientMessage(playerid, MESSAGE_COLOR, "USAGE: /get <playerid>");
	}
	else
	{
		if(IsPlayerInAnyVehicle(target))
		{
			PutPlayerInVehicle(playerid, GetPlayerVehicleID(target), 1);
		}
		else
		{
			GetPlayerPos(target, X, Y, Z);
			SetPlayerPos(playerid, X, Y, Z);
		}
	}
	return 1;
}

CMD:get(playerid, params[])
{
	new target, vehicleid, Float:X, Float:Y, Float:Z;
	if(sscanf(params, "d", target))
	{
		SendClientMessage(playerid, MESSAGE_COLOR, "USAGE: /get <playerid>");
	}
	else
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
			vehicleid = GetPlayerVehicleID(playerid);
			PutPlayerInVehicle(target, vehicleid, 1);
		}
		else
		{
			GetPlayerPos(playerid, X, Y, Z);
			SetPlayerPos(target, X, Y, Z);
		}
	}
	return 1;
}

CMD:uzi(playerid, params[])
{
	GivePlayerWeapon(playerid, WEAPON_UZI, 9999999);
	return 1;
}

CMD:takecontrol(playerid, params[])
{
	new vehicleid, seatid;
	vehicleid = GetPlayerVehicleID(playerid);
	if(vehicleid == 0)
	{
		SendClientMessage(playerid, MESSAGE_COLOR, "SERVER: You're not in a vehicle!");
		return 1;
	}
	else
	{
		seatid = GetPlayerVehicleSeat(playerid);
		if(seatid == 0)
		{
			SendClientMessage(playerid, MESSAGE_COLOR, "SERVER: You're already in control of this vehicle.");
			return 1;
		}
		else
		{
			for(new i = 0; i < MAX_PLAYERS; i++)
			{
				if(GetPlayerVehicleSeat(i) == 0 && GetPlayerVehicleID(i) == vehicleid)
				{
					PutPlayerInVehicle(i, vehicleid, seatid);
					PutPlayerInVehicle(playerid, vehicleid, 0);
					return 1;
				}
			}
		}
	}
	return 1;
}

CMD:repair(playerid, params[])
{
	new vehicleid = GetPlayerVehicleID(playerid);
	if(vehicleid == 0)
	{
		SendClientMessage(playerid, MESSAGE_COLOR, "SERVER: You're not in a vehicle!");
	}
	else
	{
		RepairVehicle(vehicleid);
	}
	return 1;
}

CMD:sniper(playerid, params[])
{
	GivePlayerWeapon(playerid, WEAPON_SNIPER, 9999999);
	return 1;
}

CMD:v(playerid, params[])
{
	// if(IsPlayerAdmin(playerid))
	// {
		new vehicle, type, Float:position[4];
		if(sscanf(params, "d", type))
		{
			SendClientMessage(playerid, MESSAGE_COLOR, "USAGE: /v <vehicle type>");
		}
		else
		{
			GetPlayerPos(playerid, position[0], position[1], position[2]);
			GetPlayerFacingAngle(playerid, position[3]);
			vehicle = CreateVehicle(type, position[0], position[1], position[2], position[3], random(255), random(255), 0);
			PutPlayerInVehicle(playerid, vehicle, 0);
			SetVehicleZAngle(vehicle, position[3]);
		}
		return 1;
	// }
	// return 0;
}
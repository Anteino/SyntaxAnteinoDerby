//
//

#include <a_npc>

//------------------------------------------

main(){}

//------------------------------------------

public OnNPCEnterVehicle()
{
   StartRecordingPlayback(PLAYER_RECORDING_TYPE_ONFOOT,"mynpc");
   print("NPC has entered vehicle.");
   return 1;
}

//------------------------------------------

public OnNPCSpawn()
{
	SendCommand("/derby");
}

//------------------------------------------

public OnNPCExitVehicle()
{
    StopRecordingPlayback();
}

//------------------------------------------

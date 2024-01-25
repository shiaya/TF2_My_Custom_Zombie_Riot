#pragma semicolon 1
#pragma newdecls required

enum
{
	NOTHING	= 0,

	// Add entries above this line
	MAX_NPC_TYPES
}

public const char NPC_Names[MAX_NPC_TYPES][] =
{
	"nothing"
};

public const char NPC_Plugin_Names_Converted[MAX_NPC_TYPES][] =
{
	"npc_nothing"
};

void NPC_MapStart()
{
}

any Npc_Create(int index, int client, const float vecPos[3], const float vecAng[3], const char[] data = "")
{
	any entity = -1;
	switch(index)
	{
		default:
			PrintToChatAll("Please Spawn the NPC via plugin or select which npcs you want! ID:[%d] Is not a valid npc!", index);
	}

	return entity;
}

void NPCDeath(int entity)
{
	Function func = func_NPCDeath[entity];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(entity);
		Call_Finish();
	}
}

void NpcSpecificOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Function func = func_NPCOnTakeDamage[victim];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(victim);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, sizeof(damageForce), SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, sizeof(damagePosition), SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish();
	}
}

#include "fortress_wars/npc/npc_base.sp"

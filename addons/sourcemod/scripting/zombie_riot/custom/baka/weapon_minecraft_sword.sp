#pragma semicolon 1
#pragma newdecls required

static int Ms_HitEntities[MAXENTITIES];
static float Ms_Weapon_Energy[MAXPLAYERS];
static float Ms_Weapon_Energy_Max[MAXPLAYERS];
static Handle MSwordTimer[MAXPLAYERS];
static float MSwordHUDDelay[MAXPLAYERS];

/*public void Market_Gardener_Attack(int client, int weapon, bool crit)
{
	return;
}*/

public void MSword_OnMapStart()
{
	Zero(Ms_Weapon_Energy);
	Zero(Ms_Weapon_Energy_Max);
	Zero(Ms_HitEntities);
	Zero(MSwordHUDDelay);
	PrecacheSound("ambient/explosions/explode_9.wav", true);
}

public void MSword_Enable(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if(MSwordTimer[client] != null)
	{
		if(i_CustomWeaponEquipLogic[weapon]==WEAPON_MINECRAFT_SWORD)
		{
			delete MSwordTimer[client];
			MSwordTimer[client] = null;
			DataPack pack;
			MSwordTimer[client] = CreateDataTimer(0.2, Timer_MSword, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
	}
	else if(i_CustomWeaponEquipLogic[weapon]==WEAPON_MINECRAFT_SWORD)
	{
		DataPack pack;
		MSwordTimer[client] = CreateDataTimer(0.2, Timer_MSword, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_MSword(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon) || i_CustomWeaponEquipLogic[weapon]!=WEAPON_MINECRAFT_SWORD)
	{
		MSwordTimer[client] = null;
		return Plugin_Stop;
	}
	if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == weapon)
	{
		Ms_Weapon_Energy_Max[client]=Attributes_Get(weapon, 41);
		if(Ms_Weapon_Energy[client] < Ms_Weapon_Energy_Max[client])Ms_Weapon_Energy[client] += 0.25;
		if(Ms_Weapon_Energy[client] > Ms_Weapon_Energy_Max[client])Ms_Weapon_Energy[client] = Ms_Weapon_Energy_Max[client];
		if(MSwordHUDDelay[client] < GetGameTime())
		{
			PrintHintText(client, "Sweeping Edge [%i％]", RoundToFloor(Ms_Weapon_Energy[client]/Ms_Weapon_Energy_Max[client]*100.0));
			StopSound(client, SNDCHAN_STATIC, "ui/hint.wav");
			MSwordHUDDelay[client] = GetGameTime() + 0.5;
		}
	}
	return Plugin_Continue;
}

public void MSword_Attack(int client, int weapon, bool &result, int slot)
{
	if(Ms_Weapon_Energy[client] >= Ms_Weapon_Energy_Max[client])
	{
		DataPack pack;
		CreateDataTimer(0.25, Timer_MSword_Attack, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_MSword_Attack(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon) || i_CustomWeaponEquipLogic[weapon]!=WEAPON_MINECRAFT_SWORD)
		return Plugin_Stop;
	float damage=65.0;
	
	damage *= Attributes_Get(weapon, 1, 1.0);
	damage *= Attributes_Get(weapon, 2, 1.0);
	damage *= Attributes_Get(weapon, 1000, 1.0);
	damage *= Attributes_Get(weapon, 425, 0.5);
	
	DataPack pack2 = new DataPack();
	pack2.WriteCell(GetClientUserId(client));
	pack2.WriteCell(EntIndexToEntRef(weapon));
	pack2.WriteFloat(damage);
	RequestFrames(Weapon_Sweeping_Edge, 12, pack2);
	Ms_Weapon_Energy[client]=0.0;
	return Plugin_Stop;
}

public void MSword_NPCTakeDamage(int victim, int attacker, float &damage, int weapon)
{
	if(!IsValidEntity(victim) || GetTeam(victim) == TFTeam_Red)
		return;
	if(!IsValidClient(attacker))
		return;
	if(Ms_Weapon_Energy[attacker] >= Ms_Weapon_Energy_Max[attacker])
		damage*=1.0-Attributes_Get(weapon, 425, 0.5);
}

public void Weapon_Sweeping_Edge(DataPack pack)
{
	pack.Reset();
	int client = 	GetClientOfUserId(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	float damage = pack.ReadFloat();
	if(IsValidClient(client) && IsValidCurrentWeapon(client, weapon))
	{
		//This melee is too unique, we have to code it in a different way.
		static float pos2[3], ang2[3];
		GetClientEyePosition(client, pos2);
		GetClientEyeAngles(client, ang2);
		/*
			Extra effects on bare swing
		*/
		static float AngEffect[3];
		AngEffect = ang2;

		AngEffect[1] -= 90.0;
		int MaxRepeats = 4;
		float Speed = 1500.0;
		int PreviousProjectile;

		for(int repeat; repeat <= MaxRepeats; repeat ++)
		{
			int projectile = Wand_Projectile_Spawn(client, Speed, 99999.9, 0.0, -1, weapon, "", AngEffect);
			DataPack pack2 = new DataPack();
			int laser = projectile;
			if(IsValidEntity(PreviousProjectile))
			{
				laser = ConnectWithBeam(projectile, PreviousProjectile, 200, 200, 200, 10.0, 10.0, 1.0);
			}
			SetEntityMoveType(projectile, MOVETYPE_NOCLIP);
			PreviousProjectile = projectile;
			pack2.WriteCell(EntIndexToEntRef(projectile));
			pack2.WriteCell(EntIndexToEntRef(laser));
			RequestFrames(Sweeping_Edge_DeleteLaserAndParticle, 18, pack2);
			AngEffect[1] += (180.0 / float(MaxRepeats));
		}

		float vecSwingForward[3];
		GetAngleVectors(ang2, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
		ang2[0] = fixAngle(ang2[0]);
		ang2[1] = fixAngle(ang2[1]);

		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
			
		for(int i=0; i < MAXENTITIES; i++)
		{
			Ms_HitEntities[i] = false;
		}
		TR_EnumerateEntitiesSphere(pos2, Attributes_Get(weapon, 101), PARTITION_NON_STATIC_EDICTS, TraceSweeping_Edge, client);

	//	bool Hit = false;
		for (int entity_traced = 0; entity_traced < 8; entity_traced++)
		{
			if(Ms_HitEntities[entity_traced] > 0)
			{
				static float ang3[3];

				float pos1[3];
				WorldSpaceCenter(Ms_HitEntities[entity_traced], pos1);
				GetVectorAnglesTwoPoints(pos2, pos1, ang3);

				// fix all angles
				ang3[0] = fixAngle(ang3[0]);
				ang3[1] = fixAngle(ang3[1]);

				// verify angle validity
				if(!(fabs(ang2[0] - ang3[0]) <= 90.0 ||
				(fabs(ang2[0] - ang3[0]) >= (360.0-90.0))))
					continue;

				if(!(fabs(ang2[1] - ang3[1]) <= 90.0 ||
				(fabs(ang2[1] - ang3[1]) >= (360.0-90.0))))
					continue;

				// ensure no wall is obstructing
				if(Can_I_See_Enemy_Only(client, Ms_HitEntities[entity_traced]))
				{
					// success
			//		Hit = true;
					float damage_force[3]; CalculateDamageForce(vecSwingForward, 100000.0, damage_force);
					SDKHooks_TakeDamage(Ms_HitEntities[entity_traced], client, client, damage, DMG_CLUB, weapon, damage_force, pos1);
				}
			}
			else
			{
				break;
			}
		}
		FinishLagCompensation_Base_boss();
	}
	delete pack;
}

public void Sweeping_Edge_DeleteLaserAndParticle(DataPack pack)
{
	pack.Reset();
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	int Laser = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(Projectile))
	{
		int particle = EntRefToEntIndex(i_WandParticle[Projectile]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		
		RemoveEntity(Projectile);
	}
	if(Projectile != Laser)
	{
		if(IsValidEntity(Laser))
			RemoveEntity(Laser);
	}
	delete pack;
}

public bool TraceSweeping_Edge(int entity, int filterentity)
{
	if(IsValidEnemy(filterentity, entity, true, true)) //Must detect camo.
	{
		//This will automatically take care of all the checks, very handy. force it to also target invul enemies.
		for(int i=0; i < MAXENTITIES; i++)
		{
			if(!Ms_HitEntities[i])
			{
				Ms_HitEntities[i] = entity;
				break;
			}
		}
	}
	//always keep going!
	return true;
}
untyped

global function GiftCommand
global function Gift
global function ForceGift
global function CreateGiftLoadout

global struct GiftLoadout
{
	entity player
	string weaponId
	array<string> mods
	bool isOffhand
	int mainWeaponSlot = -1 // default
	int offhandSlot
}

struct StoredWeaponStruct
{
	string weaponName
	array<string> weaponMods
	int skinIndex
	int camoIndex
}

global array<GiftLoadout> GiftSaver

// a lot of this is from Icepick's code so big props to them

void function GiftCommand()
{
	AddClientCommandCallback("gift", Gift);
	AddClientCommandCallback("fgift", ForceGift);
	AddClientCommandCallback("forcegift", ForceGift);
	AddCallback_OnPlayerGetsNewPilotLoadout( OnPilotGetLoadout )
}

bool function ForceGift(entity player, array<string> args)
{
	Kprint( player, "已关闭fgift.");
	
	return true;
}

bool function Gift(entity player, array<string> args)
{
	array<entity> players = GetPlayerArray();
	hadGift_Admin = false;
	CheckAdmin(player);
	if (hadGift_Admin != true)
	{
		Kprint( player, "未检测到管理员权限.");
		return true;
	}

	// if player only typed "gift"
	if (args.len() == 0)
	{
		Kprint( player, "至少输入一个有效的参数.");
		Kprint( player, "格式: gift <weaponId> <slot> <playerId>");
		Kprint( player, "若不知道武器ID, 你可以通过控制台输入give, 按下tab键来滚动显示武器ID.");
		// print every single player's name and their id
		int i = 0;
		foreach (entity p in GetPlayerArray())
		{
			string playername = p.GetPlayerName();
			Kprint( player, "[" + i.tostring() + "] " + playername);
			i++
		}
		return true;
	}

	// if player typed "gift somethinghere"
	string weaponId = args[0];
	// if player typed "gift correctId" with no further arguments
	bool clearLoadouts = false
	if( args[0] == "clear" ) // gift clear <player>
		clearLoadouts = true
	if (args.len() == 1 && !clearLoadouts)
	{
		Kprint( player, "格式: gift <weaponId> <slot> <playerId> <mod>");
		Kprint( player, "如果想给自己武器, 也可输入自己的玩家序号.");
		return true;
	}

	array<entity> playerstogift
	// if player typed "gift correctId somethinghere"
	switch (args[1])
	{
		case ("all"):
			foreach (entity p in GetPlayerArray())
			{
				if (p != null)
					playerstogift.append(p)
			}
		break;

		case ("imc"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_IMC ))
			{
				if (p != null)
					playerstogift.append(p)
			}
		break;

		case ("militia"):
			foreach (entity p in GetPlayerArrayOfTeam( TEAM_MILITIA ))
			{
				if (p != null)
					playerstogift.append(p)
			}
		break;

		default:
            CheckPlayerName(args[1])
			 	foreach (entity p in successfulnames)
                	playerstogift.append(p)
		break;
	}

	// we got playerstogift, try clear loadout
	if ( clearLoadouts )
	{
		foreach(entity p in playerstogift)
		{
			//foreach(GiftLoadout loadout in GiftSaver)
			for( int i = 0;  i < GiftSaver.len(); i++ )
			{
				if (GiftSaver[i].player == p)
				{
					Kprint( CMDsender, "[GiftLoadout] 移除 " + p.GetPlayerName() + " 已保存的 " + GiftSaver[i].weaponId)
					GiftSaver.remove( i )
					i--
				}
			}
		}
		return true // try to clean it up, no need to do givings
	}

	//print( "clearLoadouts: " + string( clearLoadouts ) )
	if (args.len() == 2) // no enough arguments. if not clearing this time, we return
	{
		Kprint( player, "缺少参数! 格式: gift <weaponId> <slot> <playerId> <mod>");
		return true
	}

	int mainWeaponSlot = -1
	int offhandSlot = -1
	if(args.len() > 2)
	{
		switch(args[2]) 
		{
			case ("active"): // replace active weapon
				break
			case ("main1"):
				mainWeaponSlot = 0
				break
			case ("main2"):
				mainWeaponSlot = 1
				break
			case ("main3"):
				mainWeaponSlot = 2
				break
			case ("ordnance"):
				offhandSlot = OFFHAND_ORDNANCE
				break
			case ("tactical"):
				offhandSlot = OFFHAND_SPECIAL
				break
			case ("antirodeo"):
				offhandSlot = OFFHAND_ANTIRODEO
				break
			case ("inventory"):
				offhandSlot = OFFHAND_INVENTORY
				break
			case ("melee"):
				offhandSlot = OFFHAND_MELEE
				break
			case ("core"):
				offhandSlot = OFFHAND_EQUIPMENT
				break
			default: // cannot find any slot!
				Kprint( player, "参数类型错误！请填入武器槽位" )
				return true
		}
	}

	array<string> mods
	if (args.len() > 3)
	{
		mods = args.slice(3);
	}

	CMDsender = player
	bool saveLoadout = false
	if (!clearLoadouts) // if not clearing, try to do save
	{
		int saveIndex = mods.find( "save" )
		if ( saveIndex != -1 )
		{	
			mods.remove( saveIndex )
			saveLoadout = true
		}
	}

	if( offhandSlot >= 0 ) // not the -1 number
	{
		Kprint( player, "尝试给予offhand" )
		foreach(entity p in playerstogift)
		{
			KGiveOffhandWeapon(p, weaponId, offhandSlot, mods, saveLoadout)
		}
	}
	else
	{
		Kprint( player, "尝试给予mainhand" )
		foreach(entity p in playerstogift)
			KGiveWeapon( p, weaponId, mods, mainWeaponSlot, saveLoadout )
	}

	return true;
}

void function KGiveWeapon( entity player, string weaponId, array<string> mods = [], int mainWeaponSlot = -1, bool saveLoadout = false, bool forceSwitch = true )
{
	string playername = player.GetPlayerName()
	StoredWeaponStruct storedWeapon = StoreActiveWeaponForPlayer( player ) // store first weapon
	//try
	//{
		entity weaponToReplace = player.GetActiveWeapon()
		array<entity> mainWeapons = player.GetMainWeapons()
		if ( mainWeaponSlot > -1 ) // handle modified weapon slot!
		{
			if ( mainWeapons.len() >= mainWeaponSlot + 1 )
				weaponToReplace = mainWeapons[mainWeaponSlot]
		}
		if( mainWeapons.len() >= 3 ) // no room for new given weapon!
		{
			if( IsValid( weaponToReplace ) )
			{
				//player.TakeWeaponNow( weaponToReplace.GetWeaponClassName() )
				weaponToReplace.Destroy() // so we directly handle weapon replace
			}
			else // player's weapon has been disabled
				player.TakeWeaponNow( mainWeapons[0].GetWeaponClassName() ) // take first weapon
		}
		entity weaponToGive
		try { weaponToGive = player.GiveWeapon( weaponId, mods ) } // player might pass an offhand weapon, or passed wrong mods...
		catch(ex1)
		{ 
			Kprint( CMDsender, string( ex1 ) ) 
			if( !IsValid( player.GetActiveWeapon() ) )
			{
				if( !TryRestoreWeaponFromStruct( player, storedWeapon ) ) // cannot restore weapon, notify CMDSender
					Kprint( CMDsender, "给予 " + playername + ", 武器 " + weaponId + "失败! 主武器可能丢失" )
			}
		}
		if ( !IsValid( weaponToGive ) )
			return
		try { weaponToGive.SetWeaponPrimaryClipCount( weaponToGive.GetWeaponPrimaryClipCountMax() ) } // update clip size
		catch(ex2){}
		try { weaponToGive.SetWeaponPrimaryAmmoCount( weaponToGive.GetWeaponSettingInt( eWeaponVar.ammo_default_total ) ) } // update stockpile
		catch(ex3){}
		if( forceSwitch ) // make savedWeapons less annoying
			thread DelayedForceSwitchWeapon( weaponId, player, mainWeaponSlot ) // delay it, for AddMod() to apply
		// loadout saving should be done after sucessfully gave weapons
		if( saveLoadout )
			CreateGiftLoadout( player, weaponId, mods, mainWeaponSlot, -1 ) // -1 will turn "isOffhand" to false
		Kprint( CMDsender, "给予 " + playername + ", 武器: " + weaponId )
	//} 
	//catch(exception)
	//{
	//	print( exception )
	//	Kprint( CMDsender, "给予 " + playername + ", 武器 " + weaponId + " 失败! 已给予的武器可能丢失配件" )
	//}
}

void function DelayedForceSwitchWeapon( string weaponId, entity player, int mainWeaponSlot = -1 )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	WaitFrame() // wait for weapon mods set up
	if ( mainWeaponSlot > -1 )
		player.SetActiveWeaponBySlot( mainWeaponSlot )
	else
		player.SetActiveWeaponByName( weaponId )
}

void function KGiveOffhandWeapon( entity player, string weaponId, int offhandSlot, array<string> mods = [], bool saveLoadout = false )
{
	string playername = player.GetPlayerName()
	StoredWeaponStruct storedWeapon = StoreActiveWeaponForPlayer( player ) // store first weapon
	try
	{
		entity curWeapon = player.GetOffhandWeapon( offhandSlot )
		if( IsValid( curWeapon ) )
			player.TakeWeaponNow( curWeapon.GetWeaponClassName() )
		if( PlayerHasWeapon( player, weaponId ) )
			player.TakeWeaponNow( weaponId )
		// GiveOffhandWeapon() won't return anything
		//entity weaponToGive = player.GiveOffhandWeapon( weaponId, offhandSlot )
		//foreach( string mod in mods )
		//	weaponToGive.AddMod( mod ) // so the weapon will only have succeed mods
		player.GiveOffhandWeapon( weaponId, offhandSlot, mods )
		// loadout saving should be done after sucessfully gave weapons
		if( saveLoadout )
			CreateGiftLoadout( player, weaponId, mods, -1, offhandSlot ) // -1 will mark as it's not a main weapon
		Kprint( CMDsender, "给予 " + playername + ", 武器: " + weaponId )
	}
	catch ( exception )
	{
		Kprint( CMDsender, string( exception ) )
		if( !IsValid( player.GetActiveWeapon() ) )
		{
			if( !TryRestoreWeaponFromStruct( player, storedWeapon ) ) // cannot restore weapon, notify CMDSender
				Kprint( CMDsender, "给予 " + playername + ", 武器 " + weaponId + "失败! 主武器可能丢失" )
		}
	}
}

GiftLoadout function CreateGiftLoadout( entity player, string weaponId, array<string> mods, int mainWeaponSlot, int offhandSlot = -1 )
{
	GiftLoadout newloadout
	newloadout.player = player
	newloadout.weaponId = weaponId
	newloadout.mainWeaponSlot = mainWeaponSlot
	newloadout.isOffhand = offhandSlot == -1? false : true // if no offhandSlot it must be a mainhand
	newloadout.offhandSlot = offhandSlot
	newloadout.mods = mods
	GiftSaver.append( newloadout )
	print( "正在为 " + player.GetPlayerName() + " 保存武器: " + weaponId )
	return newloadout
}

void function OnPilotGetLoadout( entity player, PilotLoadoutDef p )
{
	thread DelayedGiveSavedLoadout( player ) 
}

void function DelayedGiveSavedLoadout( entity player )
{
	wait 0.5 // wait for other functions ends
	if( IsAlive( player ) )
	{
		foreach (GiftLoadout loadout in GiftSaver)
		{
			if (loadout.player != player)
				continue

			if( loadout.isOffhand )
				KGiveOffhandWeapon( player, loadout.weaponId, loadout.offhandSlot, loadout.mods )
			else
				KGiveWeapon( player, loadout.weaponId, loadout.mods, loadout.mainWeaponSlot, false, false )
		}
	}
}

StoredWeaponStruct function StoreActiveWeaponForPlayer( entity player )
{
	StoredWeaponStruct tempStruct // empty struct
	player.ClearOffhand()
	entity weapon = player.GetActiveWeapon()
	if( IsValid( weapon ) && !weapon.IsWeaponOffhand() )
	{
		tempStruct.weaponName = weapon.GetWeaponClassName()
		tempStruct.weaponMods = weapon.GetMods()
		tempStruct.skinIndex = weapon.GetSkin()
		tempStruct.camoIndex = weapon.GetCamo()
	}
	return tempStruct
}

StoredWeaponStruct function StoreWeaponForPlayerBySlot( entity player, int slot )
{
	StoredWeaponStruct tempStruct // empty struct
	array<entity> mainWeapons = player.GetMainWeapons()
	if( mainWeapons.len() - 1 >= slot ) // have enough weapons!
	{
		entity weaponToStore = mainWeapons[slot]
		tempStruct.weaponName = weaponToStore.GetWeaponClassName()
		tempStruct.weaponMods = weaponToStore.GetMods()
		tempStruct.skinIndex = weaponToStore.GetSkin()
		tempStruct.camoIndex = weaponToStore.GetCamo()
	}
	return tempStruct
}

bool function TryRestoreWeaponFromStruct( entity player, StoredWeaponStruct storedWeapon )
{
	if( player.GetMainWeapons().len() >= 3 ) // weapon full!
		return false // failed to restore
	if( storedWeapon.weaponName == "" ) //  this weapon wasn't stored!
		return false
	entity weapon = player.GiveWeapon( storedWeapon.weaponName, storedWeapon.weaponMods )
	weapon.SetSkin( storedWeapon.skinIndex )
	weapon.SetCamo( storedWeapon.camoIndex )
	return true
}
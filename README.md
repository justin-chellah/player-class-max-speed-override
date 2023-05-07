# [TF2] Player Class Default Max Speed Override
This is a SourceMod Plugin that lets developers dynamically override specific player or class base max speeds. This is a way more efficient approach because it hooks onto the `CTFPlayer::TeamFortress_CalculateMaxSpeed` method and allows to apply the speed change before the game does its own class and state-specific calculations so that speed attributes won't become useless.

# API
- Global Forward
  - `Action TF2_OnCalculatePlayerMaxSpeed( int iClient, TFClassType eClass, float& flDefaultMaxSpeed )`
  
Example code:
```
public Action TF2_OnCalculatePlayerMaxSpeed( int iClient, TFClassType eClass, float& flDefaultMaxSpeed )
{
	if ( eClass == TFClass_Scout )
	{
		const float flMaxSpeed = 200.0;
		
		flDefaultMaxSpeed = flMaxSpeed;
		
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}
```

# Requirements
- [SourceMod 1.11+](https://www.sourcemod.net/downloads.php?branch=stable)

# Supported Platforms
- Windows
- Linux

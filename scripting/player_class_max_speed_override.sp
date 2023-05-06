#include <sourcemod>
#include <tf2_stocks>

#define REQUIRE_EXTENSIONS
#include <dhooks>

#define GAMEDATA_FILE "player_class_max_speed_override"

Handle g_hSDKCall_GetPlayerClassData = null;

GlobalForward g_hForward_OnCalculatePlayerMaxSpeed = null;

int g_nOffset_TFPlayerClassData_t_m_flMaxSpeed = -1;

float g_flOldDefaultMaxSpeed;

Address GetPlayerClassData( int iClass )
{
	return SDKCall( g_hSDKCall_GetPlayerClassData, iClass );
}

public MRESReturn DDetour_CTFPlayer_TeamFortress_CalculateMaxSpeed_Pre( int iClient, DHookReturn hReturn, DHookParam hParams )
{
	if ( !IsClientConnected( iClient ) )
	{
		return MRES_Ignored;
	}

	Address addrTFPlayerClassData = GetPlayerClassData( view_as< int >( TF2_GetPlayerClass( iClient ) ) );
	Address addrMaxSpeedOffset = addrTFPlayerClassData + view_as< Address >( g_nOffset_TFPlayerClassData_t_m_flMaxSpeed );

	Action eResult = Plugin_Continue;

	float flDefaultMaxSpeed = view_as< float >( LoadFromAddress( addrMaxSpeedOffset, NumberType_Int32 ) );

	g_flOldDefaultMaxSpeed = flDefaultMaxSpeed;

	Call_StartForward( g_hForward_OnCalculatePlayerMaxSpeed );
	Call_PushCell( iClient );
	Call_PushCell( TF2_GetPlayerClass( iClient ) );
	Call_PushFloatRef( flDefaultMaxSpeed );
	Call_Finish( eResult );

	if ( eResult == Plugin_Changed )
	{
		StoreToAddress( addrMaxSpeedOffset, flDefaultMaxSpeed, NumberType_Int32 );
	}

	return MRES_Ignored;
}

public MRESReturn DDetour_CTFPlayer_TeamFortress_CalculateMaxSpeed_Post( int iClient, DHookReturn hReturn, DHookParam hParams )
{
	if ( !IsClientConnected( iClient ) )
	{
		return MRES_Ignored;
	}

	Address addrTFPlayerClassData = GetPlayerClassData( view_as< int >( TF2_GetPlayerClass( iClient ) ) );
	Address addrMaxSpeedOffset = addrTFPlayerClassData + view_as< Address >( g_nOffset_TFPlayerClassData_t_m_flMaxSpeed );

	StoreToAddress( addrMaxSpeedOffset, g_flOldDefaultMaxSpeed, NumberType_Int32 );

	return MRES_Ignored;
}

public void OnPluginStart()
{
	GameData hGameData = new GameData( GAMEDATA_FILE );

	if ( hGameData == null )
	{
		SetFailState( "Unable to load gamedata file \"" ... GAMEDATA_FILE ... "\"" );
	}

	g_nOffset_TFPlayerClassData_t_m_flMaxSpeed = hGameData.GetOffset( "TFPlayerClassData_t::m_flMaxSpeed" );

	if ( g_nOffset_TFPlayerClassData_t_m_flMaxSpeed == -1 )
	{
		delete hGameData;
		
		SetFailState( "Unable to find gamedata offset entry for \"TFPlayerClassData_t::m_flMaxSpeed\"" );
	}

	StartPrepSDKCall( SDKCall_Static );
	if ( !PrepSDKCall_SetFromConf( hGameData, SDKConf_Signature, "GetPlayerClassData" ) )
	{
		delete hGameData;
		
		SetFailState( "Unable to find gamedata offset entry for \"GetPlayerClassData\"" );
	}

	PrepSDKCall_SetReturnInfo( SDKType_PlainOldData, SDKPass_Plain );
	PrepSDKCall_AddParameter( SDKType_PlainOldData, SDKPass_Plain );	// unsigned int iClass
	g_hSDKCall_GetPlayerClassData = EndPrepSDKCall();

	DynamicDetour hDDetour_CTFPlayer_TeamFortress_CalculateMaxSpeed = new DynamicDetour( Address_Null, CallConv_THISCALL, ReturnType_Float, ThisPointer_CBaseEntity );

	if ( !hDDetour_CTFPlayer_TeamFortress_CalculateMaxSpeed.SetFromConf( hGameData, SDKConf_Signature, "CTFPlayer::TeamFortress_CalculateMaxSpeed" ) )
	{
		delete hGameData;

		SetFailState( "Unable to find gamedata signature entry for \"CTFPlayer::TeamFortress_CalculateMaxSpeed\"" );
	}

	delete hGameData;

	hDDetour_CTFPlayer_TeamFortress_CalculateMaxSpeed.AddParam( HookParamType_Bool );		// bool bIgnoreSpecialAbility
	hDDetour_CTFPlayer_TeamFortress_CalculateMaxSpeed.Enable( Hook_Pre, DDetour_CTFPlayer_TeamFortress_CalculateMaxSpeed_Pre );
	hDDetour_CTFPlayer_TeamFortress_CalculateMaxSpeed.Enable( Hook_Post, DDetour_CTFPlayer_TeamFortress_CalculateMaxSpeed_Post );

	g_hForward_OnCalculatePlayerMaxSpeed = new GlobalForward( "TF2_OnCalculatePlayerMaxSpeed", ET_Event, Param_Cell, Param_Cell, Param_FloatByRef );
}

public APLRes AskPluginLoad2( Handle hMyself, bool bLate, char[] szError, int nErrMax )
{
	RegPluginLibrary( "player_class_max_speed_override" );

	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "[TF2] Player Class Default Max Speed Override",
	author = "Justin \"Sir Jay\" Chellah",
	description = "Allows developers to dynamically override default max speed for specific players or classes",
	version = "1.0.0",
	url = "https://justin-chellah.com"
};
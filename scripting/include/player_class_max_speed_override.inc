#if defined _player_class_max_speed_override_included
 #endinput
#endif
#define _player_class_max_speed_override_included

#include <tf2>

/**
 * Called whenever game calculates the player max speed.
 *
 * @return	Plugin_Changed to override default max speed,
 *			Plugin_Continue otherwise.
 */
forward Action TF2_OnCalculatePlayerMaxSpeed( int iClient, TFClassType eClass, float& flDefaultMaxSpeed );

public SharedPlugin __pl_player_class_max_speed_override =
{
    name = "player_class_max_speed_override",
    file = "player_class_max_speed_override.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};
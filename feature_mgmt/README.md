# Feature Management
Feature Management is a script that provides feature management functionality to your LSL projects. Features can be configured via LSL link messages or, when enabled, debug commands in local chat.

The library uses Linden Lab's new Linkset Data functions that were introduced in October 2022 to store the feature configurations in the linkset, rather than script memory, to make them more persistent and memory efficient.

## Usage
To use this script library, make a call to `llMessageLinked` in the following format:

```lsl
llMessageLinked( LINK_THIS, feature_management_message, feature_id, config_data );
```

`feature_management_message` must be a constant defined in `lib_inc.lsl` from the following list:

|Constant|Description|
|--|--|
|`FEATURE_GET_CONFIG`|Get the feature configuration for a specified feature ID.|
|`FEATURE_SET_CONFIG`|Set the feature configuration for a specified feature ID.|
|`FEATURE_RESET_CONFIG`|Delete all feature configurations.|
|`FEATURE_DEBUG`|Send a debug command to the library. See the **Examples** section.|

## Feature States
Features can have the following states:

|Constant|Description|
|--|--|
|`FEATURE_STATE_DEFAULT (0)`|The feature is in a default state. This may be enabled or disabled depending on how the feature is being used.|
|`FEATURE_STATE_DISABLED (1)`|The feature is disabled.|
|`FEATURE_STATE_ENABLED (2)`|The feature is enabled.|

## Variants
Variants are entirely custom defined by the scripter using this library. A feature can have whatever variant IDs it can accept, or none (leaving the value at `0`).

For example, you might have variant `0` the default behaviour for the feature, and `1` being an alternative version that the user sees or uses differently (e.g. a button's text being different).

It is recommended, though not at all mandatory, that you only use the variant ID when the feature is **enabled**.

## Examples
The following examples show how you can use this library to have test features in your Second Life projects.

#### Check if a feature is enabled

```lsl
#include "lib\lib_inc.lsl"

key feature_req;

default
{
    state_entry()
    {
        //
        // Get feature configuration for feature ID "testFeature"
        //
        feature_req = llGenerateKey();
        llMessageLinked( LINK_THIS, FEATURE_GET_CONFIG, "testFeature", feature_req );
    }

    link_message( integer sender, integer value, string message, key id )
    {
        if( value == FEATURE_GET_CONFIG_RESPONSE )
        {
            key req_key = (key)llJsonGetValue( (string)id, [ "req_id" ] );
            
            if( req_key == feature_req && message == "testFeature" )
            {
                if( llJsonGetValue( (string)id, [ "error" ] ) == "ERR_FEATURE_INVALID" )
                {
                    llOwnerSay( "Feature not configured!" );
                    return;
                }

                //
                // "id" contains JSON data with the feature's state and variant ID
                //
                integer feature_state = (integer)llJsonGetValue( (string)id, [ "state" ] );
                integer feature_variant = (integer)llJsonGetValue( (string)id, [ "variant" ] );
                
                if( feature_state == FEATURE_STATE_ENABLED )
                    llOwnerSay( "Feature is enabled with variant ID " + (string)feature_variant + "." );
                else
                    llOwnerSay( "Feature is disabled." );
            }
        }
    }
}
```
#### Set a feature's configuration

```lsl
#include "lib\lib_inc.lsl"

default
{
    state_entry()
    {
        //
        // Set feature configuration for feature ID "testFeature"
        //
        llMessageLinked(
            LINK_THIS,
            FEATURE_SET_CONFIG,
            "testFeature",
            llList2Json(
                JSON_OBJECT,
                [
                    "state", FEATURE_STATE_ENABLED, // Enabled
                    "variant", 0 // No variant
                ]
            )
        );
    }
}
```

#### Delete (reset) all feature configurations
```lsl
#include "lib\lib_inc.lsl"

default
{
    state_entry()
    {
        //
        // Delete all feature configurations
        //
        llMessageLinked( LINK_THIS, FEATURE_RESET_CONFIG, "", "" );
    }
}
```

#### Enable or disable CLI (local chat debug) commands
```lsl
#include "lib\lib_inc.lsl"

default
{
    state_entry()
    {
        //
        // Enable debug commands
        //
        llMessageLinked( LINK_THIS, FEATURE_DEBUG, "EnableCLI", "" );

        //
        // Disable debug commands
        //
        llMessageLinked( LINK_THIS, FEATURE_DEBUG, "DisableCLI", "" );
    }
}
```

# Debug Commands
The local chat debug commands you can send (when CLI is enabled via the `EnableCLI` command for the `FEATURE_DEBUG` link message) are:

|Command|Description|
|--|--|
|`/features_reset`|Delete all feature configurations.|
|`/features_list`|List feature configurations currently set.|
|`/features_set <feature> <state> <variant>`|Set a feature's configuration.<br/><br/>**Example:** `/features_set testFeature 2 0` would enable the `testFeature` feature with a variant ID of `0`.|
|`/features_get <feature>`|Get a feature's configuration and output it to local chat.<br/><br/>**Example:** `/features_get testFeature` would output `testFeature`'s state and variant ID.|
|`/features_delete <feature>`|Delete a feature's configuration.<br/><br/>**Example:** `/features_delete testFeature` would delete the feature `testFeature`.|
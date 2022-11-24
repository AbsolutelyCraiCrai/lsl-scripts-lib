/**
 * Feature Management by John Parker
 * Version 1.0
 *
 * This script allows you to read and manage feature flags for a product.
 * The flags are persistent across script resets by using Linkset Data.
 *
 * See readme file for usage instructions.
 *
 * Change history:
 *
 *    None.
 *
 * Licence:
 *
 *   MIT License
 *
 *   Copyright (c) 2022 John Parker
 *
 *   Permission is hereby granted, free of charge, to any person obtaining a copy
 *   of this software and associated documentation files (the "Software"), to deal
 *   in the Software without restriction, including without limitation the rights
 *   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *   copies of the Software, and to permit persons to whom the Software is
 *   furnished to do so, subject to the following conditions:
 *   
 *   The above copyright notice and this permission notice shall be included in all
 *   copies or substantial portions of the Software.
 *   
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *   SOFTWARE.
**/
#include "lib\lib_inc.lsl"

integer cli_listener;

default
{
    state_entry()
    {
        cli_listener = llListen( PUBLIC_CHANNEL, "", "", "" );
        llListenControl( cli_listener, FALSE );
    }

    link_message( integer sender, integer value, string text, key id )
    {
        if( value == FEATURE_GET_CONFIG )
        {
            key req_id = id;

            //
            // Get feature configuration data
            //
            string config_data = llLinksetDataRead( "FeatureConfiguration\\" + text );
            if( config_data == "" )
            {
                //
                // Doesn't exist
                //
                llMessageLinked(
                    sender,
                    FEATURE_GET_CONFIG_RESPONSE,
                    text,
                    llList2Json(
                        JSON_OBJECT,
                        [
                            "req_id", req_id,
                            "error", "ERR_FEATURE_INVALID"
                        ]
                    )
                );
                return;
            }

            llMessageLinked(
                sender,
                FEATURE_GET_CONFIG_RESPONSE,
                text,
                llList2Json(
                    JSON_OBJECT,
                    [
                        "req_id", req_id,
                        "state", ( (integer)config_data & 0xF ),
                        "variant", ( (integer)config_data >> 4 )
                    ]
                )
            );
        }
        else if( value == FEATURE_SET_CONFIG )
        {
            //
            // Set feature configuration data
            //
            string state_val = llJsonGetValue( (string)id, [ "state" ] );
            string variant_val = llJsonGetValue( (string)id, [ "variant" ] );

            if( state_val == JSON_INVALID || variant_val == JSON_INVALID )
                return;

            integer state_val_i = (integer)state_val;
            integer variant_val_i = (integer)variant_val;
            if( state_val_i < FEATURE_STATE_DEFAULT ||
                state_val_i > FEATURE_STATE_ENABLED ||
                variant_val_i < 0 )
            {
                llRegionSay( DEBUG_CHANNEL, "Error: State or variant parameters for FEATURE_SET_CONFIG were set to invalid values." );
                return;
            }

            llLinksetDataWrite(
                "FeatureConfiguration\\" + text,
                (string)( variant_val_i << 4 | state_val_i )
            );
        }
        else if( value == FEATURE_RESET_CONFIG )
        {
            //
            // Delete all feature configuration data
            //
            list features = llLinksetDataFindKeys( "^FeatureConfiguration\\\\", 0, 0 );

            integer i;
            for( i = 0; i < llGetListLength( features ); i++ )
                llLinksetDataDelete(
                    (string)features[ 0 ]                    
                );
        }
        else if( value == FEATURE_DEBUG )
        {
            //
            // Debug commands
            //
            if( text == "EnableCLI" )
            {
                llListenControl( cli_listener, TRUE );
            }
            else if( text == "DisableCLI" )
            {
                llListenControl( cli_listener, FALSE );
            }
        }
        else if( value == FEATURE_GET_CONFIG_RESPONSE )
        {
            //
            // Get request from CLI?
            //
            string json = (string)id;

            if( llJsonGetValue( json, [ "req_id" ] ) == "cli" )
            {
                if( llJsonGetValue( json, [ "error" ] ) == "ERR_FEATURE_INVALID" )
                {
                    llOwnerSay( "The requested feature is not configured." );
                    return;
                }

                string state_str = "Default";
                if( llJsonGetValue( json, [ "state" ] ) == (string)FEATURE_STATE_ENABLED )
                    state_str = "Enabled";
                else if( llJsonGetValue( json, [ "state" ] ) == (string)FEATURE_STATE_DISABLED )
                    state_str = "Disabled";

                llOwnerSay( "Feature configuration for feature \"" + text + "\":" );
                llOwnerSay( "State: " + state_str );
                llOwnerSay( "Variant: " + (string)llJsonGetValue( json, [ "variant" ] ) );
            }
        }
    }

    listen( integer channel, string name, key id, string message )
    {
        if( message == "/features_reset" )
        {
            llMessageLinked(
                LINK_THIS,
                FEATURE_RESET_CONFIG,
                "",
                ""
            );
        }
        else if( llSubStringIndex( message, "/features_set" ) == 0 )
        {
            list config = llParseString2List( message, [ " " ], [] );
            if( llGetListLength( config ) != 4 )
                return;
            
            string feature = (string)config[ 1 ];
            integer feature_state = (integer)config[ 2 ];
            integer feature_variant = (integer)config[ 3 ];

            if( feature_state < FEATURE_STATE_DEFAULT ||
                feature_state > FEATURE_STATE_ENABLED ||
                feature_variant < 0 )
            {
                llOwnerSay( "Error: Feature state or variant is an invalid value." );
                return;
            }

            llMessageLinked(
                LINK_THIS,
                FEATURE_SET_CONFIG,
                feature,
                llList2Json(
                    JSON_OBJECT,
                    [
                        "state", feature_state,
                        "variant", feature_variant
                    ]
                )
            );

            llOwnerSay( "Feature configuration for \"" + feature + "\" updated." );
        }
        else if( llSubStringIndex( message, "/features_get" ) == 0 )
        {
            list config = llParseString2List( message, [ " " ], [] );
            if( llGetListLength( config ) != 2 )
                return;
            
            string feature = (string)config[ 1 ];

            llMessageLinked(
                LINK_THIS,
                FEATURE_GET_CONFIG,
                feature,
                "cli"
            );
        }
        else if( llSubStringIndex( message, "/features_list" ) == 0 )
        {
            list features = llLinksetDataFindKeys( "^FeatureConfiguration\\\\", 0, 0 );

            if( !llGetListLength( features ) )
            {
                llOwnerSay( "No feature configurations available." );
                return;
            }
            
            integer i;
            for( i = 0; i < llGetListLength( features ); i++ )
                llMessageLinked(
                    LINK_THIS,
                    FEATURE_GET_CONFIG,
                    llGetSubString( (string)features[ 0 ], 21, -1 ),
                    "cli"
                );
        }
        else if( llSubStringIndex( message, "/features_delete" ) == 0 )
        {
            list config = llParseString2List( message, [ " " ], [] );
            if( llGetListLength( config ) != 2 )
                return;
            
            string feature = (string)config[ 1 ];

            llLinksetDataDelete(
                "FeatureConfiguration\\" + feature
            );

            llOwnerSay( "Feature \"" + feature + "\" deleted." );
        }
    }
}
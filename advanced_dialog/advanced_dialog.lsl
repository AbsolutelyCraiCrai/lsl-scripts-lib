/**
 * Advanced Dialog by John Parker
 * Version 1.0
 *
 * This script allows you to show "fancy" looking dialogs in LSL, including a title
 * icon and spaced-out button layouts.
 *
 * See readme file for usage instructions.
 *
 * Licence:
 *
 *   MIT License
 *
 *   Copyright (c) 2019 John Parker
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

/**
 * The link message value that we check for when reading link messages.
**/
#define ADVANCED_DIALOG_MESSAGE -39484225

/**
 * This script tries to have a maximum of 4 KB free at any one time. While this is
 * not needed with Mono, we do this periodically throughout the script to:
 *
 *    1. Ensure we do not run out of the 4 KB of memory, and
 *    2. Protect this script from script-memory checker devices that warn the user
 *       that they are using too much script memory.
 *
 * Top Scripts usually reports the maximum memory a script is using, not the
 * currently used memory, and so does the OBJECT_SCRIPT_MEMORY flag for
 * llGetObjectDetails, so this protects the script from being blamed by them.
**/
#define set_memory_limit() llSetMemoryLimit( llGetUsedMemory() + 4096 )

/**
 * This function re-orders the button list so that you always have three buttons
 * per line. The added buttons are a blank space (" ").
 *
 * @param buttons The list of buttons.
 * @return list The re-ordered list of buttons.
**/
list get_button_list( list buttons )
{
    set_memory_limit();

    integer len = llGetListLength( buttons );
    
    if( len == 0 )
        return [ " ", "OK", " " ];
    
    integer mod = len % 3;
    
    if( mod != 0 )
    {
        if( mod == 1 )
        {
            buttons = llListInsertList( buttons, [ " " ], len - 1 );
            buttons = llListInsertList( buttons, [ " " ], len + 1 );
        }
        else if( mod == 2 )
        {
            buttons = llListInsertList( buttons, [ " " ], len - 1 );
        }
    }
    
    return buttons;
}

/**
 * This function throws an invalid JSON error message to DEBUG_CHANNEL.
**/
invalid_json()
{
    llRegionSay(
        DEBUG_CHANNEL,
        "Error: You have a syntax error in your JSON for Advanced Dialog." +
        "Ensure that the parameters \"target\", \"title\", \"message\" and " +
        "\"buttons\" are set, and that the channel number is set to a value " +
        "other than 0."
    );
}

default
{
    state_entry()
    {
        set_memory_limit();
    }
    
    link_message( integer sender, integer value, string text, key id )
    {
        if( value != ADVANCED_DIALOG_MESSAGE )
            return;
        
        set_memory_limit();

        key target = (key)llJsonGetValue( text, [ "target" ] );
        if( (string)target == JSON_INVALID )
        {
            invalid_json();
            return;
        }
        
        string icon = llStringTrim( llJsonGetValue( text, [ "icon" ] ), STRING_TRIM );
        if( icon == JSON_INVALID || icon == "" )
        {
            //
            // The "icon" parameter is the only parameter that is not required.
            // Failing to specify an icon will make it use the info icon by
            // default.
            //
            icon = "icons/Info.png";
        }
        
        string title = llJsonGetValue( text, [ "title" ] );
        if( title == JSON_INVALID )
        {
            invalid_json();
            return;
        }
        
        string msg = llJsonGetValue( text, [ "message" ] );
        if( msg == JSON_INVALID )
        {
            invalid_json();
            return;
        }
        
        integer channel = (integer)((string)id);
        if( channel == 0 )
        {
            invalid_json();
            return;
        }
        
        string buttons = llJsonGetValue( text, [ "buttons" ] );
        if( buttons == JSON_INVALID )
        {
            invalid_json();
            return;
        }
        
        list btns = get_button_list( llJson2List( buttons ) );

        llDialog( target, "\n<icon>" + icon + "</icon> " + title + "\n\n" + msg, btns, channel );
    }
}
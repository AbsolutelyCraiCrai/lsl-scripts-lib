/**
 * Progress Status Text by John Parker
 * Version 1.0
 *
 * This script displays a progress bar above a prim, with support for a marquee
 * animation.
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

#define LM_SET_PROGRESS_LINK -800100
#define LM_SET_PROGRESS_TEXT -800101
#define LM_SET_PROGRESS_VALUE -800102
#define LM_SET_PROGRESS_MARQUEE -800103
#define LM_SET_PROGRESS_COLOR -800104
#define LM_SET_PROGRESS_AUTO_UPDATE -800105
#define LM_TRIGGER_PROGRESS_UPDATE -800106
#define LM_RESET_PROGRESS -800107

integer link_number = LINK_THIS;
string progress_text = "";
integer progress_value = 0;
integer progress_marquee = FALSE;
integer progress_marquee_state = 0;
vector progress_color = <1, 1, 1>;

integer auto_update = TRUE;

/**
 * This prevents Top Scripts and script-memory checkers from seeing this script
 * as a memory hog.
**/
#define set_memory_limit() llSetMemoryLimit( llGetUsedMemory() + 2048 )

update_progress()
{
    set_memory_limit();

    if( progress_marquee )
    {
        string progress_markers = "";
        integer i;

        for( i = 0; i < 20; i++ )
        {
            if( progress_marquee_state == i )
                progress_markers += "█";
            else
                progress_markers += "░";
        }
        
        llSetLinkPrimitiveParamsFast(
            link_number,
            [
                PRIM_TEXT, progress_text + "\n" + progress_markers, progress_color, 1.0
            ]
        );
    }
    else
    {
        integer progress_value_count = llRound( ( (float)progress_value / 100 ) * 20 );
        string progress_markers = "";

        integer i;
        for( i = 0; i < progress_value_count; i++ )
        {
            progress_markers += "█";
        }

        for( ; i < 20; i++ )
        {
            progress_markers += "░";
        }

        llSetLinkPrimitiveParamsFast(
            link_number,
            [
                PRIM_TEXT, progress_text + "\n" + progress_markers, progress_color, 1.0
            ]
        );
    }
}

default
{
    state_entry()
    {
        set_memory_limit();
    }

    on_rez( integer start_param )
    {
        llResetScript();
    }

    link_message( integer sender_num, integer num, string str, key id )
    {
        set_memory_limit();

        if( num == LM_SET_PROGRESS_LINK )
        {
            if( link_number == 0 )
                link_number = LINK_THIS;
            else
                link_number = (integer)str;
        }
        else if( num == LM_SET_PROGRESS_TEXT )
        {
            progress_text = str;

            if( auto_update )
                update_progress();
        }
        else if( num == LM_SET_PROGRESS_VALUE )
        {
            progress_value = (integer)str;

            if( auto_update )
                update_progress();
        }
        else if( num == LM_SET_PROGRESS_MARQUEE )
        {
            progress_marquee = (integer)str;

            if( progress_marquee )
            {
                progress_marquee_state = 0;
                llSetTimerEvent( 0.1 );
            }
            else
            {
                llSetTimerEvent( 0 );
            }

            if( auto_update )
                update_progress();
        }
        else if( num == LM_SET_PROGRESS_COLOR )
        {
            progress_color = (vector)str;

            if( auto_update )
                update_progress();
        }
        else if( num == LM_SET_PROGRESS_AUTO_UPDATE )
        {
            auto_update = (integer)str;

            if( auto_update )
                update_progress();
        }
        else if( num == LM_TRIGGER_PROGRESS_UPDATE )
        {
            update_progress();
        }
        else if( num == LM_RESET_PROGRESS )
        {
            llResetScript();
        }
    }

    timer()
    {
        progress_marquee_state++;

        if( progress_marquee_state == 20 )
            progress_marquee_state = 0;

        update_progress();
    }
}
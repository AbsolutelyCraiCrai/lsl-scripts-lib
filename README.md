# LSL Script Library
This repository is a library of LSL scripts written by me to be used to aid script development in Second Life.

All code in this repository is licenced under the MIT Licence unless otherwise stated in the header of the script.

Each script has a readme file associated with it for usage instructions.

## Compilation
The scripts in the LSL script library rely on the Firestorm preprocessor in order to compile successfully in Second Life. If you are using Firestorm, you can enable this in preferences under `Firestorm > Build 1 > Enable LSL Preprocessor`.

If you want a pre-compiled version of the scripts for use outside of the Firestorm viewer, use the code from the associated `.lslo` file.

## Using the include script
When using these libraries with the Firestorm preprocessor, you can include the `lib_inc.lsl` file. This will allow you to use the constants used by the library scripts, as well as in-line functions that help you send the link message for those libraries.

To include the include script, use the following line at the top of your LSL script:

    #include "path_to_lib_folder\lib_inc.lsl"

Then you can use the libraries with their respective constants and in-line functions. The following example shows use of the Advanced Dialog library with this include script. Note the use of the `advanced_dialog` in-line function defined in the include script:

    #include "lib\lib_inc.lsl"

    integer listener;

    default
    {
        touch_start( integer num_detected )
        {
            llListenRemove( listener );
            listener = llListen( -100, "", llDetectedKey( 0 ), "" );

            list dlg = [
                "target", llDetectedKey( 0 ),
                "title", "Example dialog",
                "message", "This is an example dialog using the include library.",
                "buttons", llList2Json( JSON_ARRAY, [ "Button 1", "Button 2", "Button 3", "Button 4" ] )
            ];
            advanced_dialog( LINK_THIS, dlg, -100 );
        }

        listen( integer channel, string name, key id, string message )
        {
            llListenRemove( listener );

            llRegionSayTo( id, 0 "You chose \"" + message + "\"." );
        }
    }

The descriptions of the available in-line functions are in the include script source code.
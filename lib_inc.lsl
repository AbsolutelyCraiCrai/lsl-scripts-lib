/**
 * This include file should be included via Firestorm's preprocessor. It
 * defines the constants that are used by the libraries in this repository,
 * and useful in-line functions that you can use to call the library
 * functionality.
 *
 * Include this file with the following line in an LSL editor at the top of
 * a script:
 *
 *    #include "path_to_lib_folder\lib_inc.lsl"
 *
 * Note: The Firestorm preprocessor will optimise out any of this code that
 *       you do not use in your script.
**/

/**
 * Advanced Dialog constants
**/
#define ADVANCED_DIALOG_MESSAGE -39484225

/**
 * Advanced Dialog in-line functions
**/

/**
 * Use this function to send a link message to Advanced Dialog.
 *
 * Parameters:
 *
 *     link - The link number to send the message to.
 *     json - The list containing the JSON data for the message.
 *     channel - The channel number the dialog should use.
**/
#define advanced_dialog( link, json, channel ) llMessageLinked( link, ADVANCED_DIALOG_MESSAGE, llList2Json( JSON_OBJECT, json ), (string)channel )

/**
 * Progress Status Text constants
**/
#define PROGRESS_STATUS_MESSAGE -800100

/**
 * Progress Status Text in-line functions
**/

/**
 * Use this function to send a link message to Progress Status Text.
 *
 * Parameters:
 *
 *     link - The link number to send the message to.
 *     json - The list containing the JSON data for the message.
**/
#define update_progress( link, json ) llMessageLinked( link, PROGRESS_STATUS_MESSAGE, llList2Json( JSON_OBJECT, json ), NULL_KEY )

/**
 * Feature Management constants
 */
#define FEATURE_MESSAGE_BASE         -11000
#define FEATURE_GET_CONFIG           FEATURE_MESSAGE_BASE + 1
#define FEATURE_GET_CONFIG_RESPONSE  FEATURE_MESSAGE_BASE + 2
#define FEATURE_SET_CONFIG           FEATURE_MESSAGE_BASE + 3
#define FEATURE_RESET_CONFIG         FEATURE_MESSAGE_BASE + 4
#define FEATURE_DEBUG                FEATURE_MESSAGE_BASE + 5

#define FEATURE_STATE_DEFAULT  0
#define FEATURE_STATE_DISABLED 1
#define FEATURE_STATE_ENABLED  2
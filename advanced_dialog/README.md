# Advanced Dialog
Advanced Dialog is a script that produces dialogs using `llDialog()` but formats them with an icon and title, and re-orders the button list you pass to it in such a way that forces three buttons per line. This way, your dialogs should look neat and tidy, and always feel consitent.

## Dialog icons
The Second Life viewer allows the user to use `<icon></icon>` tags to specify an icon for things like user profiles and dialogs. You can use any icon from the skins folder of the viewer.

For example, to show the information icon, you can put `<icon>icons/Info.png</icon>` in a dialog message and it will replace that with the icon.

This dialog does this by default, and allows you to change the icon path with one of the JSON parameters it accepts. See "Usage" below for more information.

## Usage
To use this script library, make a call to `llMessageLinked` in the following format:

    llMessageLinked( LINK_THIS, ADVANCED_DIALOG_MESSAGE, json, channel );

### Parameter Information
|Parameter|Description|
|--|--|
|`LINK_THIS`|The link to send the message to. This is usually the link number the Advanced Dialog script is in.|
|`ADVANCED_DIALOG_MESSAGE`|This is a constant value of -39484225. This is used by Advanced Dialog to distinguish what link message it needs to listen to.|
|`json`|The JSON data to send to Advanced Dialog. See below for information on this.|
|`channel`|The channel number the dialog is to send the response to, type-cast to a `string`. We can't type-cast to a key directly with integers, but key parameters can be substituted with strings.|

### JSON data
To create JSON, use `llList2Json` with `JSON_OBJECT` for the main JSON string, and `JSON_ARRAY` for the buttons list. See "Example usage" for an example.

The JSON parameters used are as follows:

|Parameter|Type|Description|
|--|--|--|
|`target`*|`key`|The UUID of the user to send the dialog to.|
|`type`|`integer`|The type of dialog to show. Supported options are `TYPE_DIALOG` (`0`) or `TYPE_TEXTBOX` (`1`). Default is `TYPE_DIALOG` (`0`).|
|`icon`|`string`|The file path of the icon to show instead of the information icon, relative to the viewer's active skin folder.|
|`title`*|`string`|The title of the dialog next to the icon.|
|`message`*|`string`|The message of the dialog.|
|`buttons`*|`string`|A list of buttons to show on the dialog, formatted in a JSON string itself using `llList2Json( JSON_ARRAY, list )`. **Note:** This parameter is not supported for `TYPE_TEXTBOX` dialogs, and will be ignored if provided.|

An asterisk (*) denotes a required parameter.

Specifying `JSON_NULL` as a button will result in that button becoming a blank space. This is useful for hiding a button, or enforcing a more spaced out layout of the dialog. Setting the `buttons` parameter to a blank string, `JSON_NULL`, or a JSON array with just one `JSON_NULL` item in it and no other buttons, will result in the default buttons to be used instead: `[ " ", "OK", " " ]`.

## Example usage
The following example shows a confirmation dialog to the user:

	string buttons = llList2Json( JSON_ARRAY, [ "Yes", "No" ] );

	list data = [];
	data += [ "target", llGetOwner() ];
	data += [ "icon", "icons/Inv_UnknownObject.png" ];
	data += [ "title", "Confirm Operation" ];
	data += [ "message", "Are you sure you wish to continue?" ];
	data += [ "buttons", buttons ];

	integer channel = -100;

	llMessageLinked(
		LINK_THIS,
		-39484225, // ADVANCED_DIALOG_MESSAGE
		llList2Json( JSON_OBJECT, data ),
		(string)channel
	);

![A screenshot of an example using Advanced Dialog.](https://raw.githubusercontent.com/JohnEMParker/lsl-scripts-lib/master/advanced_dialog/example.png "Advanced Dialog Example")
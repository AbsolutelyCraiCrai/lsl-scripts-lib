# Progress Status Text
This script displays a progress bar above a prim, with support for a marquee animation.

## Usage
To use Progress Status Text, send a link message with the following format:

    llMessageLinked( LINK_THIS, PROGRESS_STATUS_MESSAGE, json, NULL_KEY );

|Parameter|Description|
|--|--|
|`LINK_THIS`|The link to send the message to. This is usually the link number the Progress Status Text script is in.|
|`PROGRESS_STATUS_MESSAGE`|This is an integer value for Progress Status Text. It is a constant value of `-800100`.|
|`json`|The JSON data as a `string`.|
|`NULL_KEY`|This parameter is unused. Leave this as `NULL_KEY`.|

### JSON data
|Parameter|Type|Description|
|--|--|--|
|`link`|`integer`|The link number to show progress on. Value should be the link number, an LSL link constant, or `0` for `LINK_THIS` (default).|
|`text`|`string`|The progress text to display above the progress bar.|
|`value`|`integer`|The value of the progress bar. Value should be the value as an integer between 0 and 100. **Note:** Setting `marquee` to `TRUE` will force Progress Status Text to ignore this setting.|
|`marquee`|`integer`|Whether the progress bar should be animated or not. Value should be `TRUE` (`1`) or `FALSE` (`0`). Default is `FALSE`.|
|`color`|`vector`|The colour of the progress text and bar. Value should be a colour vector. Default is `<1, 1, 1>` (white).|
|`auto_update`|`integer`|Whether any change to the settings with the above parameters should force an update immediately. Value should be `TRUE` (`1`) or `FALSE` (`0`). Default is `TRUE`. **Note:** Setting `marquee` to `TRUE` forces this setting on during the animation.|
|`update`|`integer`|Triggers an update to the progress bar immediately, regardless of the auto-update setting. Value **must** be non-zero to have any effect.|
|`reset`|`integer`|Triggers a reset of the Progress Status Text script. Value **must** be non-zero to have any effect.|

**Note:** None of these parameters are required. Sending a blank JSON message to the script will result in no change occuring to the status displayed above the prim.

## Example usage
The following example shows a yellow progress bar climbing by 1% every 0.3 seconds:

    integer pgb_link = LINK_THIS;
    string pgb_text = "Loading...";
    vector pgb_color = <1, 1, 0>;

	list json = [
        "link", pgb_link,
        "text", pgb_text,
        "color", pgb_color
    ];
    llMessageLinked(
        LINK_THIS,
        PROGRESS_STATUS_MESSAGE,
        llList2Json( JSON_OBJECT, json ),
        NULL_KEY
    );

    integer percent = 0;
    while( percent <= 100 )
    {
        json = [
            "value", percent
        ];
        llMessageLinked(
            LINK_THIS,
            PROGRESS_STATUS_MESSAGE,
            llList2Json( JSON_OBJECT, json ),
            NULL_KEY
        );

        percent++;

        llSleep( 0.3 );
    }

**Note:** I recommend not sending update messages any faster than 0.3 second intervals due to possible race conditions with Second Life link messages.
# Progress Status Text
This script displays a progress bar above a prim, with support for a marquee animation.

## Usage
To use Progress Status Text, send a link message with the following format:

    llMessageLinked( LINK_THIS, command, data, NULL_KEY );

|Parameter|Description|
|--|--|
|`LINK_THIS`|The link to send the message to. This is usually the link number the Progress Status Text script is in.|
|`command`|This is an integer value that specifies what Progress Status Text should do. See "Command Constants" below.|
|`data`|The data for the command as a `string`.|
|`NULL_KEY`|This parameter is unused. Leave this as `NULL_KEY`.|

### Command Constants
|Constant|Value|Usage|
|--|--|--|
|`LM_SET_PROGRESS_LINK`|`-800100`|Sets the link number to show progress on. `data` should be the link number, an LSL link constant, or `0` for `LINK_THIS` (default).|
|`LM_SET_PROGRESS_TEXT`|`-800101`|Sets the progress text to display above the progress bar. `data` should be the text.|
|`LM_SET_PROGRESS_VALUE`|`-800102`|Sets the value of the progress bar. `data` should be the value as an integer between 0 and 100. **Note:** Setting `LM_SET_PROGRESS_MARQUEE` to `TRUE` will force Progress Status Text to ignore this setting.|
|`LM_SET_PROGRESS_MARQUEE`|`-800103`|Sets whether the progress bar should be animated or not. `data` should be `TRUE` (`1`) or `FALSE` (`0`). Default is `FALSE`.|
|`LM_SET_PROGRESS_COLOR`|`-800104`|Sets the colour of the progress text and bar. `data` should be a colour vector. Default is `<1, 1, 1>` (white).|
|`LM_SET_PROGRESS_AUTO_UPDATE`|`-800105`|Sets whether any change to the settings with the above constants should force an update immediately. `data` should be `TRUE` (`1`) or `FALSE` (`0`). Default is `TRUE`. **Note:** Setting `LM_SET_PROGRESS_MARQUEE` to `TRUE` forces this setting on during the animation.|
|`LM_TRIGGER_PROGRESS_UPDATE`|`-800106`|Triggers an update to the progress bar immediately. `data` is unused.|
|`LM_RESET_PROGRESS`|`-800107`|Triggers a reset of the Progress Status Text script. `data` is unused.|

## Example usage
The following example shows a yellow progress bar climbing by 1% every 0.3 seconds:

    integer pgb_link = LINK_THIS;
    string pgb_text = "Loading...";
    vector pgb_color = <1, 1, 0>;

	llMessageLinked(
        LINK_THIS,
        LM_SET_PROGRESS_LINK,
        (string)pgb_link,
        NULL_KEY
    );
    llMessageLinked(
        LINK_THIS,
        LM_SET_PROGRESS_TEXT,
        (string)pgb_text,
        NULL_KEY
    );
    llMessageLinked(
        LINK_THIS,
        LM_SET_PROGRESS_COLOR,
        (string)pgb_color,
        NULL_KEY
    );

    integer percent = 0;
    while( percent <= 100 )
    {
        llMessageLinked(
            LINK_THIS,
            LM_SET_PROGRESS_VALUE,
            (string)percent,
            NULL_KEY
        );

        percent++;

        llSleep( 0.3 );
    }

**Note:** We recommend not updating the progress bar's value any faster than 0.3 second intervals due to possible race conditions with Second Life link messages.
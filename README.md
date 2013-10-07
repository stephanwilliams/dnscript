# dnscript

dnscript is a Mac OS X user agent that allows for simple integration into Mac
OS X's [distributed notification system][dns] - for example, running shell scripts when
they are dispatched.

The specific use case this tool was developed for was
refreshing [GeekTool][gt] "geeklets"; I have a set of geeklets displaying the
currently playing artist/track/album in iTunes. As wonderful of a program as
GeekTool is, it only allows geeklets to be updated on a timer, which forces a
compromise between having song info update less immediately and having constant
small drain on the CPU. This program allows the distributed notifications sent
by iTunes (and other music players) to be set to run shell scripts that update
the geeklet display *immediately*.

## Configuration

dnscript reads its configuration from a `.dnscriptrc` file in the current user's
home directory. As an example, my `.dnscriptrc` file is as follows:

    # refresh geektool on music change
    ;com.apple.iTunes.playerInfo
    ;com.catpigstudios.Radium.stateChange
    ;VLCPlayerStateDidChange
    osascript ~/scripts/refreshall.scpt

Lines preceeded with `#`'s are, as you could've guessed, comments. Lines
beginning with `;` contain names of notifications to listen for; all other lines
are read as single-line shell commands. Notifications names are associated with
each other by alternating groups; so, ignoring comments and empty lines, a group
of consecutive notification names will be associated with the following
consecutive group of shell commands, and the next notification line found will
start a new group. To make this more concrete, if you wanted to rewrite my
`.dnscriptrc` to run a separate script for each of the music player notifications
instead of of one for all three, you could rewrite it as:

    ;com.apple.iTunes.playerInfo
    osascript ~/scripts/refreshitunes.scpt

    ;com.catpigstudios.Radium.stateChange
    osascript ~/scripts/refreshradium.scpt

    ;VLCPlayerStateDidChange
    osascript ~/scripts/refreshvlc.scpt

I'll be the first to admit that this format is somewhat bizaare - the semicolon
was chosen to denote notification names because I could see no reason for it
to need to be at the start of a shell command. The format is also inherently
broken, in that it eschews support for certain pathological examples of
notification names - for example, names containing newlines, though I have yet
to see anything of the sort.

As a bonus, because I was interested in how it would be implemented, dnscript
will listen for any changes to `.dnscriptrc` and process them automatically -
all configuration changes will be refelcted immediately.

## Installation

To install dnscript from the Xcode project, you need to run `xcodebuild install`
from the project directory, which will generate a `dnscript.pkg` installer that
you can run to install. Or, you can just download the installer from GitHub.
dnscript only needs two files: the `dnscript` binary itself, which is installed
to `/usr/local/bin`, and a configuration file `com.github.stephanwilliams.dnscript`,
installed to `/Library/LaunchAgents`, which will tell `launchd` how to manage
the `dnscript` process. After installation you should restart your computer.

## Other Files

Since the use case I've presented here for dnscript is using it in conjunction
with GeekTool, it seems appropriate to include the relevant GeekTool scripts -
these are located in the `scripts` directory. `refreshall.scpt` is a dead-simple
script that simply tells GeekTool to refresh all geeklets. `musicinfo.scpt` is
more complicated, being a one-stop-shop to get the name, artist, or album of the
currently playing song, from iTunes, Radium, or VLC (though, I couldn't figure
out how to get an album name from VLC). The latter script can be used in a shell
geeklet with the command `osascript path/to/musicinfo.scpt name`, for `name`,
`artist`, or `album`.

## Future Improvement

It's unlikely I'll ever get around to doing this, but dnscript would definitely
benefit from being able to pass the [`userInfo`][info] dictionary in the NSNotification
object to the scripts being executed. iTunes, for example, passes a large amount
track info as part of its notifications - if this could be passed in as some
sort of JSON or something, perhaps it could be parsed by some Perl/Python/Ruby/etc.
script to do some interesting stuff. Though, most of the same information should
also be obtainable through AppleScript, at least in iTunes' case. Also useful
would be a mode where dnscript would simply print out names of **all** distributed
notifications, which is about the only way to discover what notifications are
being dispatched by applications.

[dns]: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Notifications/Articles/NotificationCenters.html
[gt]: http://projects.tynsoe.org/en/geektool/
[info]: https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSNotification_Class/Reference/Reference.html#//apple_ref/occ/instm/NSNotification/userInfo
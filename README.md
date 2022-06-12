ekko
==============================================================================

Simple bash echo replacement with colour semantics.

I got tired of boring `echo`s from my bash scripts.  This is a small and simple drop-in replacement that uses the first argument to assign some colour to your terminal!

Add it to your `.bashrc` and start generating simple ANSI coloured output!

```
source ./bin/ekko.sh
ekko_help
```

![ekko_help terminal capture](./doc/ekko_help.svg)

![ekko_help_examples terminal capture](./doc/ekko_help_examples.svg)

Usage
==============================================================================

```
ekko [MARKER] This is my message!
```

The simple markers assign some colour and bold to the message.  The first argument is set to bold and attached back to the rest.

* __`msg`__ or __`msg1`__, __`msg2`__, __`msg3`__: Information (cyan, blue, magenta)
* __`error`__: Error (red)
* __`warn`__: Warning (yellow)
* __`ok`__: Success (green)
* __`bold`__ or __`b`__: Only sets bold with no colour change
* Adding __`banner_`__ prefix to a simple marker fills the rest of the line with `----`

```
ekko banner_msg "Step 1:" Reticulating splines
ekko warn "" A message with no bold.
ekko ok Success!
```

Comments are entirely in bold and prepended with a `#`.

* __`comment`__ or __`\#`__: Adds a `#`, and sets the entire line to bold grey.
* Adding __`comment_`__ prefix to a simple marker adds the last argument as a `# comment`
* A __`comment_`__ prefix and __`_<NN>`__ suffix aligns the comments at column `<NN>`

```
ekko comment_warn_35 Attention: possible data loss "Make sure you've specified the right"
ekko comment_b_35 sudo mkfs -t vfat /dev/sdX1 "partition using lsblk"
ekko comment Follow the prompts here
```

Some other markers generate different, preformatted output.

* __`kv`__ Key/Value: prints the first word of the message right-aligned to column 30 (violet) followed by the rest (default colour).
* __`kv_`<NN>__ As above, with the first argument right aligned to column <NN>.
* __`export`__ prints an export line with the first word of the message.  If there is more to the message text, the rest is used as the value.  Otherwise, the actual environment variable corresponding to the first work is printed. 
* __`env_not_null`__ verifies that the first word of the message is set as an environment variable and prints nothing if true.  If false, an error message is printed using the rest of the message text and the return code `$?` is set to `1` (error).

```
ekko kv host $HOSTNAME
ekko kv port 8080
ekko export HOSTNAME
ekko export PORT 80 # Does not set the environment variable!
ekko env_not_null PORT 8080
```

You can also use the __`exec`__ or __`no-exec`__ markers to execute other commands.

* __`exec`__ prints the message text (grey background) before trying to execute it as a command, and writes the time it took afterwards.  The `EKKO_LAST_EXEC_TIME` is set to this value in milliseconds.  The return code is the same as the command.
* __`no-exec`__ just prints the command in the same style without trying to execute it.
* Commands are executed with `eval $'bash -c "'$@'"'`.  Simple commands should work, but you'll probably be unhappy with aliases and non-exported functions!

```
ekko exec find /tmp
ekko no-exec find /tmp
```

If you are on a system with the `notify-send` command (like [gnome][notify-send]), you can execute two types of popups.

* __`popup`__ Sends the message to the notification center directly.
* __`remind`__ Starts a background process that sleeps for `N` seconds before displaying.  If the argument is non-numeric, try to parse it into seconds using the linux `date` command.

```
ekko popup Splines have been reticulated
ekko remind $((5 * 60)) Five minute break is finished
ekko remind 25min Pompodoro #1 is ended
ekko remind "1 day 1 hour" Water your plants
```

[notify-send]: https://developer.gnome.org/notification-spec/

"Building" and Testing
==============================================================================

There are some some [BATS](https://bats-core.readthedocs.io/en/stable/) unit tests included with the project.

```bash
# Clone including submodules to include the BATS framework and testing tools.
git clone --recurse-submodules git@github.com:RyanSkraba/ekko.git
# Alternatively, update the submodules in place.
git submodule update --init --recursive

# Run the tests
test/ekko.bats
```

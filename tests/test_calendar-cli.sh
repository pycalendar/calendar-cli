#!/usr/bin/env bash

[ "$PYTHON3" ] || PYTHON3='python3'

storage=$(mktemp -d)

## Radicale (like most real servers) requires authentication; set up an
## htpasswd file so the hard-coded testuser/password1 used below is accepted.
htpasswd_file="$storage/htpasswd"
printf 'testuser:password1\n' > "$htpasswd_file"

## Always tear the test servers down, even if the script is interrupted -
## otherwise an orphaned server keeps holding its port and breaks the next run.
radicale_pid=""
xandikos_pid=""
cleanup() {
    [ -n "$radicale_pid" ] && kill "$radicale_pid" 2>/dev/null
    [ -n "$xandikos_pid" ] && kill "$xandikos_pid" 2>/dev/null
    rm -rf "$storage"
}
trap cleanup EXIT

echo "This script will attempt to set up a Radicale server and a Xandikos server and run the test code towards those two servers"
echo "The test code itself is found in tests.sh"

export RUNTESTSNOPAUSE="foo"

echo "########################################################################"
echo "## RADICALE"
echo "########################################################################"
## Launch radicale directly in the background (not via "sh -c ... &") so that
## $! is radicale's own pid and the kill below actually stops it.
rad_out=/dev/stdout; rad_err=/dev/stderr
[ -n "$DAEMONS_OUTPUT_TO_FILES" ] && { rad_out="$storage/radicale.stdout"; rad_err="$storage/radicale.stderr"; }
"$PYTHON3" -m radicale --storage-filesystem-folder="$storage" \
    --auth-type htpasswd --auth-htpasswd-filename "$htpasswd_file" --auth-htpasswd-encryption plain \
    >"$rad_out" 2>"$rad_err" &
radicale_pid=$!
sleep 0.5
if [ -n "$radicale_pid" ]; then
    echo "## Radicale now running on pid $radicale_pid"
    calendar_cli="env PYTHONPATH=..:$PYTHONPATH $( printf "%s%s%s%s" '../bin/calendar-cli.py ' \
        '--caldav-url=http://localhost:5232/ --caldav-pass=password1 ' \
        '--caldav-user=testuser ' \
        '--calendar-url=/testuser/calendar-cli-test-calendar' )"
    echo "## Creating a calendar"
    $calendar_cli calendar create calendar-cli-test-calendar

    ## crazy, now I get a 403 forbidden on the calendar create, but
    ## the calendar is created.  Without the statement above, I'll
    ## just get 404 when running tests.
    if [ -n "$DEBUG" ]; then
        echo "press enter to run tests"
        read -r
    fi
    ./tests.sh "$calendar_cli"
    if [ -n "$DEBUG" ]; then
        echo "press enter to take down test server"
        read -r
    fi
    kill "$radicale_pid" 2>/dev/null
    radicale_pid=""
    sleep 0.3
else
    echo "## Could not start up radicale (is it installed?).  Will skip running tests towards radicale"
fi


echo "########################################################################"
echo "## XANDIKOS"
echo "########################################################################"
xandikos_bin=$(which xandikos 2> /dev/null)
if [ -n "$xandikos_bin" ]; then
    ## Launch directly in the background so $! is xandikos' own pid.
    xan_out=/dev/stdout; xan_err=/dev/stderr
    [ -n "$DAEMONS_OUTPUT_TO_FILES" ] && { xan_out="$storage/xandikos.stdout"; xan_err="$storage/xandikos.stderr"; }
    "$xandikos_bin" --defaults -d "$storage" >"$xan_out" 2>"$xan_err" &
    xandikos_pid=$!
    sleep 0.5
fi

if [ -n "$xandikos_pid" ]; then
    echo "## Xandikos now running on pid $xandikos_pid"
    calendar_cli="env PYTHONPATH=..:$PYTHONPATH ../bin/calendar-cli.py --caldav-url=http://localhost:8080/ --caldav-user=user"

    ./tests.sh "$calendar_cli"
    kill "$xandikos_pid" 2>/dev/null
    xandikos_pid=""
else
    echo "## Could not start up xandikos (is it installed?).  Will skip running tests towards xandikos"
fi


echo "########################################################################"
echo "## cleanup"
echo "########################################################################"
rm -rf "$storage"

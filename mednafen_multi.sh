#!/bin/bash

MEDNAFEN=$(command -v mednafen)
MEDNAFEN_SERVER=$(command -v mednafen-server)
MEDNAFEN_SERVER=${MEDNAFEN_SERVER:-~/src/mednafen-server/run.sh}


usage() {
    printf "Usage: mednafen_multi.sh game [-c|--count window_count] [-r|--record] [-d|--record-dir]\n"
}


if [[ $# -lt 1 ]]; then
    usage
    printf "No game specified\n"
    exit 1
else
    GAME=$1
    shift
fi

while [[ $# -gt 0 ]]; do
    case $1 in
    -c|--count)
        WINDOW_COUNT="$2"
        shift 2
        ;;
    -r|--record)
        RECORD=true;
        shift
        ;;
    -d|--record-dir)
        RECORD_DIR=$2
        shift 2
        ;;
    *)
        usage
        printf "Unknown argument: $1\n"
        exit 1
        ;;
    esac
done

WINDOW_COUNT=${WINDOW_COUNT:-0}
RECORD=${RECORD:-false}
if $RECORD; then
    BASE_NAME=$(basename "$GAME")
    RECORD_DIR=${RECORD_DIR:-"/tmp/mednafen/$BASE_NAME/"}
    RECORD_NAME="${BASE_NAME}_$(date -Iseconds).mp4"
    mkdir -p "$RECORD_DIR"
fi


on_exit() {
    # kill subprocesses in reverse order
    PGID=$(ps -o 'pgid=' $$ | tr -d ' ')
    pkill -TERM -g $PGID -f ffmpeg
    (while pgrep -g $PGID -f ffmpeg; do :; done) && sleep 1
    setsid kill -TERM -$PGID
}; trap "on_exit" EXIT


main() {
    $MEDNAFEN_SERVER & sleep 1
    if [[ WINDOW_COUNT -gt 0 ]]; then
        for window in $(seq 1 $WINDOW_COUNT); do
            (
                Xephyr :$window -ac -br -screen 1280x800 & sleep 1
                DISPLAY=:$window $MEDNAFEN -netplay.nick "subwindow-$window" -video.fs 1 -connect "$GAME" &
            ) &
        done
    fi
    sleep 5;

    if $RECORD && [[ WINDOW_COUNT -gt 0 ]] ; then
        input_str=""
        filter_str="[0:v]pad=iw*${WINDOW_COUNT}:ih[t0]"
        map_str=""
        for window in $(seq 1 $WINDOW_COUNT); do
            input_str="${input_str} -f x11grab -r 25 -video_size 1280x800 -i :${window}"
            if [[ window -lt WINDOW_COUNT ]]; then
                filter_str="${filter_str}; [t$(( $window-1 ))][$window:v]overlay=w:x=$(( 1280*(window) ))[t$window]"
                map_str="[t$window]"
            fi
        done
        ffmpeg  ${input_str} -filter_complex "${filter_str}" -map "$map_str"\
            -c:v libx264 -preset ultrafast -crf 22 \
            "$RECORD_DIR/$RECORD_NAME" &
    fi

    $MEDNAFEN -netplay.nick "master" -connect "$GAME" &
    printf "Press Enter to exit" && read
    on_exit
}

main

#!/bin/bash

MEDNAFEN=$(command -v mednafen)
MEDNAFEN_SERVER=$(command -v mednafen-server)
MEDNAFEN_SERVER=${MEDNAFEN_SERVER:-~/src/mednafen-server/run.sh}


usage() {
    printf "Usage: mednafen_multi.sh game [-c|--count window_count] [-r|--record] [-d|--record-dir] [-s|--record-single]\n"
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
    -s|--record-single)
        RECORD_SINGLE=true
        shift
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
if [[ WINDOW_COUNT -lt 1 ]]; then
    RECORD=false
fi
if $RECORD; then
    BASE_NAME=$(basename "$GAME")
    RECORD_DIR=${RECORD_DIR:-"/tmp/mednafen/$BASE_NAME/"}
    RECORD_NAME="${BASE_NAME}_$(date -Iseconds)_%s.mp4"
    RECORD_SINGLE=${RECORD_SINGLE:-false}
    if $RECORD_SINGLE; then
        RECORD_FUNC="record_single"
    else
        RECORD_FUNC="record"
    fi
    mkdir -p "$RECORD_DIR"
fi


on_exit() {
    # kill subprocesses in reverse order
    PGID=$(ps -o 'pgid=' $$ | tr -d ' ')
    pkill -TERM -g $PGID -f ffmpeg
    (while pgrep -g $PGID -f ffmpeg; do :; done) && sleep 1
    setsid kill -TERM -$PGID
}; trap "on_exit" EXIT


get_ffmpeg_input() {
    printf -- "-f x11grab -r 60 -video_size 1280x800 -i :$1"
}


get_ffmpeg_output() {
    printf -- "-c:v libx264 -preset ultrafast -crf 22"
}


record_single() {
    input_str=""
    filter_str="[0:v]pad=iw*${WINDOW_COUNT}:ih[t0]"
    map_str=""
    for window in $(seq 1 $WINDOW_COUNT); do
        input_str="${input_str} $(get_ffmpeg_input ${window})"
        if [[ window -lt WINDOW_COUNT ]]; then
            filter_str="${filter_str}; [t$(( $window-1 ))][$window:v]overlay=w:x=$(( 1280*(window) ))[t$window]"
            map_str="[t$window]"
        fi
    done
    ffmpeg ${input_str} -filter_complex "${filter_str}" -map "$map_str"\
        $(get_ffmpeg_output single)  "$(printf -- "$RECORD_DIR/$RECORD_NAME" single)" &
}


record() {
    for window in $(seq 1 $WINDOW_COUNT); do
        ffmpeg $(get_ffmpeg_input $window) $(get_ffmpeg_output $window) \
            "$(printf -- "$RECORD_DIR/$RECORD_NAME" $window)" &
    done
}


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
    sleep $(( 3*WINDOW_COUNT ))

    if $RECORD; then
        $RECORD_FUNC
    fi

    $MEDNAFEN -netplay.nick "master" -connect "$GAME" &
    printf "Press Enter to exit" && read
    on_exit
}

main

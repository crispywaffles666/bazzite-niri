#!/bin/sh
# The event stream reports both new and changed windows, so track known IDs.
open_ids=$(niri msg windows 2>/dev/null | grep -oP 'id: \K[0-9]+' | tr '\n' ' ')

niri msg event-stream | while read -r line; do
    case "$line" in
        "Window opened or changed:"*)
            window_id=$(echo "$line" | grep -oP 'id: \K[0-9]+' | head -1)
            case " $open_ids " in
                *" $window_id "*)  ;;
                *)
                    open_ids="$open_ids $window_id "
                    niri msg action close-overview 2>/dev/null
                    ;;
            esac
            ;;
        "Window closed:"*)
            window_id=$(echo "$line" | grep -oP 'id: \K[0-9]+' | head -1)
            open_ids=$(echo "$open_ids" | sed "s/ $window_id / /g")
            ;;
    esac
done

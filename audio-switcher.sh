#!/bin/bash

# get the list of available sinks and their indexes ## added the grep to remove something specific to my environment which is a mic loopback
# basically just changed all the commands to be compatible with pactl instead of pacmd
mapfile -t sinks < <(pactl list sinks | grep -v MV7 | awk '/index/ {print $NF}')

# get all sink input indexes
mapfile -t input_indexes < <(pactl list sink-inputs | awk '/index/ {print $NF}')

# find the active sink index
active_sink_index=$(pactl list sinks | awk '/\* index/ {print $NF}')

# find the index of the next sink in the list
next_sink_index=${sinks[0]}
for ((i = 0; i < ${#sinks[@]} - 1; i++)); do
    if [[ ${sinks[i]} == "$active_sink_index" ]]; then
        next_sink_index=${sinks[i + 1]}
        break
    fi
done

# switch to the next sink
pactl set-default-sink "$next_sink_index" &> /dev/null
for input_index in "${input_indexes[@]}"; do
    pactl move-sink-input "$input_index" "$next_sink_index" &> /dev/null
done

#i think this should wor

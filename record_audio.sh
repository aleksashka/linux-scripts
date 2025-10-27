#!/usr/bin/env bash
#
# Thanks to ChatGPT
# Checked on Ubuntu 24.04
# Requires `pulseaudio-utils`
# Simple script to record system audio (PipeWire/PulseAudio) to a file
# Usage:
#   ./record_audio.sh <output_file> [duration]
#
# Examples:
#   ./record_audio.sh music.mp3
#   ./record_audio.sh meeting.mp3 02:00:00  # record for 2 hours
#   ./record_audio.sh meeting.mp3 01:00     # record for 1 minute
#   ./record_audio.sh meeting.mp3 15        # record for 15 seconds

# --- Check arguments ---
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 <output_file> [duration]"
    echo "Example: $0 output.mp3 01:30:00"
    exit 1
fi

filename="$1"
duration="$2"  # optional

# --- Find 'monitor' source (system output audio) ---
monitor_source=$(pactl list short sources | awk '/\.monitor/ {print $2; exit}')

if [ -z "$monitor_source" ]; then
    echo "Could not find a '.monitor' source."
    echo "Check 'pactl list short sources' manually."
    exit 2
fi

echo "Using source: $monitor_source"
echo "Output file: $filename"

if [ -n "$duration" ]; then
    t_arg="-t $duration"
    echo "Duration limit: $duration"
else
    t_arg=""
    echo "Recording until you press Ctrl+C"
fi

# --- Run ffmpeg ---
# -f pulse     : use PulseAudio input
# -i <source>  : select the monitor source
# -ac 2        : stereo
# -ar 44100    : sample rate
# -acodec mp3  : encode as MP3
# -t <time>    : optional duration limit
# Press Ctrl+C to stop manually
ffmpeg -f pulse -i "$monitor_source" -ac 2 -ar 44100 -acodec mp3 $t_arg "$filename"

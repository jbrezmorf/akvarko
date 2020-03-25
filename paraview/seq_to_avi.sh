#/bin/bash
ffmpeg -framerate 2 -i first_spot...%04d.png -c:v libx264 -profile:v high -crf 20 -pix_fmt yuv420p first_spot.mp4

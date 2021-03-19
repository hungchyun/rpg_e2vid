#!/bin/bash

DIR_WS=/home/hcchou/Project/temp
BAG=2021-03-19-10-44-40

echo Run reconstruction.

# Move bag to workspace.
WS=${DIR_WS}/${BAG}
mkdir ${WS}
mv ${DIR_WS}/${BAG}.bag ${WS}

# Extract event from bag.
python scripts/extract_events_from_rosbag.py ${WS}/${BAG}.bag \
  --output_folder=${WS} \
  --event_topic=/dvs/events

# Reconstruction image.
source $CONDA_PREFIX/etc/profile.d/conda.sh
conda activate E2VID
python run_reconstruction.py -c pretrained/firenet_1000.pth.tar \
  -i ${WS}/${BAG}.zip \
  --auto_hdr \
  --display \
  --show_events \
  --output_folder ${WS}

# Insert reconstructed image to original bag.
source /opt/ros/melodic/setup.bash
mkdir -p ${WS}/reconstruction/${BAG}
mkdir ${WS}/output
mv -v ${WS}/reconstruction/* ${WS}/reconstruction/${BAG}
python2 scripts/embed_reconstructed_images_in_rosbag.py \
  --rosbag_folder ${WS} \
  --datasets ${BAG} \
  --image_folder ${WS}/reconstruction \
  --output_folder ${WS}/output \
  --image_topic /dvs/image_reconstructed

# Remove .txt file.
rm  ${WS}/${BAG}.txt

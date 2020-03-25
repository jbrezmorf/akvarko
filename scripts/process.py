import numpy as np
import cv2
import argparse
import yaml
import os

def parse_args():
    parser = argparse.ArgumentParser(
        description='Script for cropping a part of the video, rendering the frame number.')
    parser.add_argument('script', type=str,
                        help='Path to the main script file.')

    return parser.parse_args()

def load_script(script_path):
    with open(script_path, "r") as f:
        return yaml.load(f)

class ExcNoFrame(Exception):
    pass


class VideoSource:
    '''
    Wrapper for cv2.VideoCapture:
    - remove duplicate frames
    - keep track for correct frame numbers and time
    '''
    def __init__(self, file_name):
        if not os.path.exists(file_name):
            raise FileExistsError(file_name)
        self.vidcap = cv2.VideoCapture(file_name)
        # internal frame and time including skipped frames
        self._i_frame = 0
        self._time = 0
        # public i_frame and time of actual frame
        self.i_frame = 0
        self.time = 0

        self.last_frame = None
        self.curr_frame = None
        self.time_interval = (0, 0)
        self.frame_interval = (0, 1)
        self.frame_diff_limit = 0


    def update_time(self):
        p = (self._i_frame - self.frame_interval[0]) / (self.frame_interval[1] - self.frame_interval[0])
        self._time = (1-p) * self.time_interval[0] + p * self.time_interval[1]
        return self._time

    def set_time(self, end_frame, end_time):
        '''
        Set new interval for the time interpolation.
        '''
        self.time_interval = (self._time, end_time)
        self.frame_interval = (self._i_frame, end_frame)

    def frame_diff(self, frame):
        if self.last_frame is None:
            self.frame_diff_limit = frame.size * 0.0025
            return 2 * self.frame_diff_limit
        diff = np.subtract(frame, self.last_frame, dtype = 'float32')
        return np.linalg.norm(diff)

    def read(self):
        '''
        Get next frame, update the frame counter and the time interpolation.
        '''
        success, frame = self.vidcap.read()
        if not success:
            raise ExcNoFrame()
        self._i_frame += 1
        self.update_time()
        return frame
      
    def read_and_skip(self, frame_step):
        self.i_frame = self._i_frame
        self.time = self.update_time()

        image = self.read()
        # skip remaining frames from the step
        for i in range(frame_step - 1):
            self.read()
        return image


    def read_dedup(self):
        '''
        Read variant that skip duplicated frames. Unfortunately the frames that looks the same are not actually
        exactly the same and their difference can be even larger then difference of the non-duplicate frames (with different
        real time on the stopwatch.
        '''
        skip = 0
        while True:
            frame = self.read()
            skip += 1
            diff = self.frame_diff(frame)
            print(self._i_frame, diff)
            if diff > self.frame_diff_limit:
                self.last_frame = frame
                print("skipping: ", skip)
                return True, frame


def process_script(script):

    v_file = script['video_file']
    vidcap = VideoSource(v_file)

    attributes = {}
    attributes['output_shape'] = script.get('output_shape', [1940, 1080])

    script_list = script['script']
    script_list.append({'frame': 1e10 }) # to make last cycle proceed

    i_block = 0
    # next block
    while True:
        if vidcap.i_frame >= script_list[i_block]['frame']:
            # Read current block attributes
            attributes.update(script_list[i_block])
            # Set next time
            i_block += 1
            end_time = script_list[i_block].get('time', None)
            if end_time is not None:
                end_frame = script_list[i_block]['frame']
                vidcap.set_time(end_frame, end_time)
        try:
            process_frame(vidcap, attributes)
        except ExcNoFrame:
            return


def process_frame(video, attributes):
    # read the frame, index, time
    image = video.read_and_skip(attributes.get('frame_step', 1))
    annotate = "{:04d} : {:010}s".format(video.i_frame, int(video.time))

    # target dir is given by the scene name
    output_dirs = attributes.get('scene_name', [])    
    if type(output_dirs) is str:
        output_dirs = [output_dirs]
    for dir in output_dirs:
        os.makedirs(dir, exist_ok=True)
    scene_overview = '|'.join([d.rjust(20) for d in output_dirs])
    print(annotate, ' -> ', scene_overview)
    if len(output_dirs) == 0:
        return True

    operations = attributes.get('operations', [])


    if 'crop' in operations:
        # compute perspective transform
        dims = tuple(attributes.get('output_shape', [1940, 1080]))
        crop_corners = np.float32(attributes.get('crop_corners', None))
        if crop_corners is None:
            X, Y = image.shape
            crop_corners = [[0, 0], [X, 0], [0, Y], [X, Y]]
        output_corners = np.float32([[0, 0], [dims[0], 0], [0, dims[1]], [dims[0], dims[1]]])
        deform_matrix = cv2.getPerspectiveTransform(crop_corners, output_corners)

        image = cv2.warpPerspective(image, deform_matrix, dims)

    if 'background_diff' in operations:
        # extract difference frame
        diff_frame = attributes.get('diff_background_frame', None)
        diff_contrast_scale = attributes.get('diff_contrast_scale', 1.0)
        if diff_frame == video.i_frame:
            attributes['_diff_image'] = image.copy()
        diff_image = attributes.get('_diff_image', None)
        if diff_image is not None:
            image[:, :, 0] = 0
            image[:, :, 2] = 0
            #image[:, :, 1] = np.maximum(diff_image[:, :, 1] - image[:, :, 1], 0.0)
            overflow_limit = 32
            image[:, :, 1] =  np.maximum(diff_contrast_scale * (diff_image[:, :, 1] - image[:, :, 1]) + overflow_limit,
                                         overflow_limit) - overflow_limit
            image[:, :, 1] =  image[:, :, 1]
            # keep just the green component

    if 'render' in operations:
        image = cv2.putText(image, annotate, (dims[0] - 400, 30),
                       cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2, cv2.LINE_AA)

    for dir in output_dirs:
        out_path = os.path.join(dir, "frame_{:04d}.jpg".format(video.i_frame))
        cv2.imwrite(out_path, image, [int(cv2.IMWRITE_JPEG_QUALITY), 90])     # save frame as JPEG file
        # out_path = os.path.join(dir, "frame_{:04d}.png".format(i_frame))
        # cv2.imwrite(out_path, image)  # save frame as PNG file
    return True

def main():
    args = parse_args()
    script_dir, script_file = os.path.split(args.script)
    os.chdir(script_dir)
    script = load_script(script_file)
    process_script(script)

main()

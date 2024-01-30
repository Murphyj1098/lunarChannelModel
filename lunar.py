#!/usr/bin/env python3

import argparse
import sys

from emane.events import EventService, EventServiceException, PathlossEvent
from time import sleep

def init():
    # Parse input arguments
    parser = argparse.ArgumentParser()

    parser.add_argument('pathlossFile',
                        metavar='FILE',
                        help='Input file with precomputed path loss values') 

    parser.add_argument('pathlossDelta',
                        default=1,
                        type=int,
                        help='The number of pathloss events sent per second')

    args = parser.parse_args()

    delta = args.pathlossDelta
    inputFile = args.pathlossFile
    pathlossList = []
    with open(inputFile, 'r') as f:
        for line in f.readlines():
            line = line.strip("\n")
            pathlossList.append(float(line))

    # Check that EMANE is running and connect to EventChannel
    try:
        EMANEEventChannel = EventService(('224.1.2.8', 45703, 'control0')) # NOTE: 'Default' values
    except EventServiceException:
        print("ERROR: Can not find the event channel, is EMANE running?")
        sys.exit(-1)

    # init finished, call main functional loop
    main(EMANEEventChannel, pathlossList, delta)


def main(EMANEEventChannel: EventService, pathlossList: list[float], delta: int):

    iter = 0
    while(iter < len(pathlossList)):
        # pathloss = pathlossList.pop(0)

        pathloss = pathlossList[iter]
        plEvent = PathlossEvent()
        plEvent.append(1,forward=pathloss)
        plEvent.append(2,forward=pathloss)   # NOTE: Assuming a symmetric pathloss between links
        EMANEEventChannel.publish(1,plEvent)
        EMANEEventChannel.publish(2,plEvent)
        iter += 1

        sleep(1/delta)

    return 0


if __name__ == '__main__':
    init()
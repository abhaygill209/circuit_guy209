# It creates a rosnode, named listner, which subscibes data from a chatter rostopic.  


#!/usr/bin/env python

import rospy
from std_msgs.msg import String

def callback(data):
    rospy.loginfo("I heard %s", data.data)

def listener():
    rospy.init_node('listener', anonymous=True)
    rospy.Subscriber('chatter', String, callback)
    # Keep the node running until it is stopped
    rospy.spin()

if __name__ == '__main__':
    listener()

	

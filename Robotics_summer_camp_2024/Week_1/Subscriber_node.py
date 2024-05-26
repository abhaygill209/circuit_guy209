# It creates a rosnode, named listner, which subscibes data from a chatter rostopic.  


#!/usr/bin/env python

import rospy
from std_msgs.msg import String

def callback(data):
    rospy.loginfo("Communication is working smoothly! Ping no. %s", data.data)

def listener():
    rospy.init_node('listener', anonymous=True)
    rospy.Subscriber('chatter', String, callback)
    rospy.spin()

if __name__ == '__main__':
    listener()

	

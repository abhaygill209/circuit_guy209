# It creates a rosnode, named listner, which subscibes data from a chatter rostopic.  


#!/usr/bin/env python3

import rospy 
from std_msgs.msg import String
from std_msgs.msg import Int32 

def callback(data):
	rospy.loginfo("Communication is working smoothly! Ping no. %d", data.data)
	
def listener():
	rospy.init_node('listner', anonymous = True)
	rospy.Subscriber('chatter', Int32, callback)
	rospy.spin()
	
if __name__ == '__main__':
	listener()
	

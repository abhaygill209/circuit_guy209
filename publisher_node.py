#!/usr/bin/env python3

import rospy 
from std_msgs.msg import Int32 

def talker():
	pub = rospy.Publisher('chatter', Int32, queue_size=10)
	rospy.init_node('talker', anonymous=True)
	rate = rospy.Rate(10)
	i = 0
	while not rospy.is_shutdown():
		number = i
		i=i+1
		rospy.loginfo(number)
		pub.publish(number)
		rate.sleep()
if __name__ == '__main__':
	try:
		talker()
	except rospy.ROSInterruptException:
		pass

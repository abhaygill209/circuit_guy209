# code to move the robot in a square 
# tough it is not perfect square but still it tries to be in a square 


#!/usr/bin/env python3 

import rospy 
from geometry_msgs.msg import Twist 

def square():
	pub = rospy.Publisher('/cmd_vel', Twist, queue_size=10)
	rospy.init_node('Square', anonymous=True)
	rate = rospy.Rate(10)
	move_cmd = Twist()
	while not rospy.is_shutdown():
		move_cmd.linear.x = 0.2;
		move_cmd.angular.z = 0
		pub.publish(move_cmd)
		for i in range(4000):
			rospy.loginfo(i)
		rate.sleep()
		move_cmd.linear.x = 0
		move_cmd.angular.z = 0.5
		pub.publish(move_cmd)
		for j in range(4500):
			rospy.loginfo(j)
		rate.sleep()
		move_cmd.linear.x = 0
		move_cmd.angular.z = 0
		pub.publish(move_cmd)
		for k in range(1000):
			rospy.loginfo(k)
		rate.sleep()
	
if __name__ == '__main__':
	try:
		square()
	except rospy.ROSInterruptException:
		pass

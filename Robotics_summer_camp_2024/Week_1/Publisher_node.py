# This is the code for publishing node 
# It initiates a rosnode talker which Publishes integer data to a rostopic called Chatter 



#!/usr/bin/env python3
import rospy
from std_msgs.msg import String

def talker():
    rospy.init_node('talker', anonymous=True)
    pub = rospy.Publisher('chatter', String, queue_size=10)
    rate = rospy.Rate(1)

    while not rospy.is_shutdown():
        com_str = "Communication is working smoothly! Ping no. %s" % rospy.get_time()
        rospy.loginfo(com_str)
        pub.publish(com_str)
        rate.sleep()

if __name__ == '__main__':
    try:
        talker()
    except rospy.ROSInterruptException:
        pass


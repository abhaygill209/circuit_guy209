# This is the code for publishing node 
# It initiates a rosnode talker which Publishes integer data to a rostopic called Chatter 



#!/usr/bin/env python3
import rospy
from std_msgs.msg import String

def talker():
    # Initialize the node with the name 'talker'
    rospy.init_node('talker', anonymous=True)
    # Create a publisher object with the topic 'chatter' and message type 'String'
    pub = rospy.Publisher('chatter', String, queue_size=10)
    # Set the loop rate to 1 Hz
    rate = rospy.Rate(1) # 1 Hz

    while not rospy.is_shutdown():
        # Create a hello_str message
        hello_str = "hello world %s" % rospy.get_time()
        # Log the message to the console
        rospy.loginfo(hello_str)
        # Publish the message to the 'chatter' topic
        pub.publish(hello_str)
        # Sleep to maintain the loop rate
        rate.sleep()

if __name__ == '__main__':
    try:
        talker()
    except rospy.ROSInterruptException:
        pass


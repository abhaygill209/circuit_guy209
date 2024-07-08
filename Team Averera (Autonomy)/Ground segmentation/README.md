Hi foaks!!<br/>
Aim of this file : implement ground filteration algorithm from a point cloud data of 3d lidar<br/>

The git I got for this implementes ground filteration and non-ground filteration simultaneiously. 
<br/>
https://github.com/url-kaist/patchwork-plusplus-ros
<br/>
this is the github link. 
the package name is pathworkpp which which works with ros noetic and the codes in this repo are in c++. 

While on the demo run the running topics were:<br/>

/clicked_point<br/>
/ground_segmentation/cloud<br/>
/ground_segmentation/ground<br/>
/ground_segmentation/noise<br/>
/ground_segmentation/nonground<br/>
/ground_segmentation/normals<br/>
/ground_segmentation/plane<br/>
/ground_segmentation/reject_pc<br/>
/ground_segmentation/revert_pc<br/>
/ground_segmentation/vertical<br/>
/initialpose<br/>
/kitti/velo/pointcloud<br/>
/move_base_simple/goal<br/>
/ouster/points<br/>
/rosout<br/>
/rosout_agg<br/>
/tf<br/>
/tf_static<br/>

the lidar which we are using publishers the point cloud data to topic /ouster/points. 
in the demo run of the patchworkpp package I was not able to visualize any data in rviz point cloud visualizer. That is most probably because the nodes in the package are not subscribed to the correct topic i.e. /ouster/points. 
thus my task now is figure out the nodes and change their subscribed topics to /ouster/points.


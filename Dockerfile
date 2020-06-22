FROM ros:melodic-ros-core

MAINTAINER Yosuke Matsusaka <yosuke.matsusaka@gmail.com>

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y curl python-pip && \
    pip install -U supervisor supervisor_twiddler && \
    apt-get clean

# OSRF distribution is better for gazebo
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' && \
    curl -L http://packages.osrfoundation.org/gazebo.key | apt-key add -

RUN source /opt/ros/melodic/setup.bash && \
    mkdir -p ~/catkin_ws/src && cd ~/catkin_ws/src && \
    catkin_init_workspace && \
    git clone --depth 1 -b melodic-devel https://github.com/ROBOTIS-GIT/turtlebot3.git && \
    git clone --depth 1 -b melodic-devel https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git && \
    git clone --depth 1 -b melodic-devel https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git && \
    git clone --depth 1 https://github.com/ROBOTIS-GIT/turtlebot3_gazebo_plugin.git && \
    cd .. && \
    rosdep update && apt-get update && \
    apt-get install -y ros-melodic-gazebo-plugins && \
    rosdep install --from-paths src --ignore-src -r -y && \
    catkin_make -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/ros/melodic install && \
    apt-get clean && rm -r ~/catkin_ws

RUN git clone --depth 1 https://github.com/osrf/gazebo_models.git /tmp/gazebo_models && \
    cp -r /tmp/gazebo_models/cafe_table /usr/share/gazebo-9/models/ && \
    cp -r /tmp/gazebo_models/first_2015_trash_can /usr/share/gazebo-9/models/ && \
    cp -r /tmp/gazebo_models/mailbox /usr/share/gazebo-9/models/ && \
    cp -r /tmp/gazebo_models/table_marble /usr/share/gazebo-9/models/ && \
    rm -r /tmp/gazebo_models

ADD supervisord.conf /etc/supervisor/supervisord.conf

VOLUME /opt/ros/melodic/share/turtlebot3_description

CMD ["/usr/local/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

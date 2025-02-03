#include <ros/ros.h>
#include <hardware_interface/joint_state_interface.h>
#include <hardware_interface/joint_command_interface.h>
#include <hardware_interface/robot_hw.h>
#include <controller_manager/controller_manager.h>
#include <std_msgs/Float64.h>

class MyRobotHardware : public hardware_interface::RobotHW
{
public:
	MyRobotHardware(ros::NodeHandle& nh, ros::NodeHandle& nhp)
	{
		nhp.param<bool>("wheelLeftDirection", wheelLeftDirection, false);
		nhp.param<bool>("encoderLeftDirection", encoderLeftDirection, false);
		nhp.param<bool>("wheelRightDirection", wheelRightDirection, false);
		nhp.param<bool>("encoderRightDirection", encoderRightDirection, false);
		nhp.param<double>("timeout", timeout, 1.0);

		// Initialize joint names
		joint_names_ = {"drive_left_joint", "drive_right_joint"};

		// Resize vectors
		pos_.resize(joint_names_.size(), 0.0);
		vel_.resize(joint_names_.size(), 0.0);
		eff_.resize(joint_names_.size(), 0.0);
		cmd_.resize(joint_names_.size(), 0.0);

		// Connect and register the joint state and velocity interfaces
		for (size_t i = 0; i < joint_names_.size(); ++i)
		{
			hardware_interface::JointStateHandle state_handle(joint_names_[i], &pos_[i], &vel_[i], &eff_[i]);
			jnt_state_interface_.registerHandle(state_handle);

			hardware_interface::JointHandle vel_handle(jnt_state_interface_.getHandle(joint_names_[i]), &cmd_[i]);
			jnt_vel_interface_.registerHandle(vel_handle);
		}
		registerInterface(&jnt_state_interface_);
		registerInterface(&jnt_vel_interface_);

		// Initialize subscribers and publishers
		left_wheel_encoder_sub_ = nh.subscribe("leftWheelFeedback", 10, &MyRobotHardware::leftWheelEncoderCallback, this);
		right_wheel_encoder_sub_ = nh.subscribe("rightWheelFeedback", 10, &MyRobotHardware::rightWheelEncoderCallback, this);

		left_wheel_cmd_pub_ = nh.advertise<std_msgs::Float64>("leftWheelDesire", 10);
		right_wheel_cmd_pub_ = nh.advertise<std_msgs::Float64>("rightWheelDesire", 10);

		processTimer = nh.createTimer(ros::Duration(ros::Rate(50)), &MyRobotHardware::processCallback, this);
	}

	void read(const ros::Time& time, const ros::Duration& period)
	{
		// Read the robot's joint states from encoders, sensors, etc.
		// Update pos_, vel_, and eff_ based on your robot's readings
		vel_[0] = left_wheel_encoder_data_;
		vel_[1] = right_wheel_encoder_data_;
		pos_[0] = pos_[0] + vel_[0] * period.toSec();
		pos_[1] = pos_[1] + vel_[1] * period.toSec();
	}

	void write(const ros::Time& time, const ros::Duration& period)
	{
		// Send commands (in cmd_) to the robot's actuators
		std_msgs::Float64 left_cmd;
		std_msgs::Float64 right_cmd;


		if (!left_wheel_encoder_stop_ && !right_wheel_encoder_stop_)
		{
			left_cmd.data = wheelLeftDirection ? -cmd_[0] : cmd_[0];
			right_cmd.data = wheelRightDirection ? -cmd_[1] : cmd_[1];
			left_wheel_cmd_pub_.publish(left_cmd);
			right_wheel_cmd_pub_.publish(right_cmd);
		}
		else
		{
			left_cmd.data = 0.0;
			right_cmd.data = 0.0;
			left_wheel_cmd_pub_.publish(left_cmd);
			right_wheel_cmd_pub_.publish(right_cmd);
		}
	}

	void leftWheelEncoderCallback(const std_msgs::Float64::ConstPtr& msg)
	{
		left_wheel_encoder_data_ = encoderLeftDirection ? -msg->data : msg->data;
		left_wheel_encoder_stop_ = false;
		left_wheel_encoder_time_ = ros::Time::now();
	}

	void rightWheelEncoderCallback(const std_msgs::Float64::ConstPtr& msg)
	{
		right_wheel_encoder_data_ = encoderRightDirection ? -msg->data : msg->data;
		right_wheel_encoder_stop_ = false;
		right_wheel_encoder_time_ = ros::Time::now();
	}

	void processCallback(const ros::TimerEvent& _event)
	{
		if (!left_wheel_encoder_stop_)
		{
			if ((ros::Time::now()-left_wheel_encoder_time_).toSec()>timeout)
			{
				left_wheel_encoder_data_ = 0.0;
				left_wheel_encoder_stop_ = true;
			}
		}
		if (!right_wheel_encoder_stop_)
		{
			if ((ros::Time::now()-right_wheel_encoder_time_).toSec()>timeout)
			{
				right_wheel_encoder_data_ = 0.0;
				right_wheel_encoder_stop_ = true;
			}
		}
	}

private:
	std::vector<std::string> joint_names_;
	std::vector<double> pos_, vel_, eff_, cmd_;
	hardware_interface::JointStateInterface jnt_state_interface_;
	hardware_interface::VelocityJointInterface jnt_vel_interface_;
	ros::Subscriber left_wheel_encoder_sub_;
	ros::Subscriber right_wheel_encoder_sub_;
	ros::Publisher left_wheel_cmd_pub_;
	ros::Publisher right_wheel_cmd_pub_;
	ros::Timer processTimer;

	double left_wheel_encoder_data_ = 0.0;
	double right_wheel_encoder_data_ = 0.0;
	bool left_wheel_encoder_stop_ = true;
	bool right_wheel_encoder_stop_ = true;
	ros::Time left_wheel_encoder_time_ = ros::Time::now();
	ros::Time right_wheel_encoder_time_ = ros::Time::now();
	double timeout = 1;

	bool wheelLeftDirection = false;
	bool encoderLeftDirection = false;
	bool wheelRightDirection = false;
	bool encoderRightDirection = false;
};

int main(int argc, char** argv)
{
	ros::init(argc, argv, "pangolin_gmi_interface");
	ros::NodeHandle nh;
	ros::NodeHandle nhp("~");

	MyRobotHardware robot(nh, nhp);
	controller_manager::ControllerManager cm(&robot, nh);
	
	ros::AsyncSpinner spinner(1);
	spinner.start();

	ros::Time now = ros::Time::now();
	ros::Time last_time = ros::Time::now();
	ros::Duration elapsed_time = now - last_time;
	ros::Rate rate(50);
	while (ros::ok())
	{
		now = ros::Time::now();
		elapsed_time = now - last_time;
		last_time = now;

		robot.read(now, elapsed_time);
		cm.update(now, elapsed_time);
		robot.write(now, elapsed_time);
		
		rate.sleep();
	};
	spinner.stop();

	return 0;
}

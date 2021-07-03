with Ada.Text_IO;
with ProtectsObj; use ProtectsObj;


package follow_path with

SPARK_Mode => On

is

   type dirc_speed is array (0 .. 1) of Float;
   type ds is array (0 .. 1) of Integer;

   -------------set_steering_angle------------------------------------------------------------
   -- @name		set_steering_angle
   -- @brief		calculate the steering angle according to the wheel angle
   --
   -- @param		input: wheel_angle between -0.5 to 0.5
   --
   -- @return		wheel_angle between -0.5 to 0.5
   --function set_steering_angle (wheel_angle : in out Float) return Float

   function set_steering_angle (wheel_angle : in out Float) return Float with
     Pre => wheel_angle < 0.5 and wheel_angle > -0.5 and wheel_angle in Float,
     Post => wheel_angle <= 0.5 and wheel_angle >= -0.5 out Float,
     Contract_Cases =>
       ((wheel_angle > 0.1) => set_steering_angle'Result = (wheel_angle+0.1),
        (wheel_angle > 0.22 and wheel_angle < 0.2) => set_steering_angle'Result = (wheel_angle+0.1),
        (wheel_angle < -0.1) => set_steering_angle'Result = (wheel_angle-0.1),
        (wheel_angle < -0.1 and wheel_angle > -0.22) => set_steering_angle'Result = (wheel_angle-0.1),
        (wheel_angle > -0.11 and wheel_angle < 0.11) => set_steering_angle'Result = wheel_angle,
        wheel_angle > 0.5 => set_steering_angle'Result = 0.5,
        wheel_angle < -0.5 => set_steering_angle'Result = -0.5);


   -------------check_distance------------------------------------------------------------
   -- @name		check_distance
   -- @brief		check if the distance between truck and obstacle smaller than the set distance(200)
   --
   -- @param		input: ds_values of two values (900,1000)
   --
   -- @return		Return boolean true/false
   function check_distance (ds_values : ds) return Boolean with
     Pre => (ds_values(0) in Integer and ds_values(1) in Integer and ds_values(0) < 200 and ds_values(1) < 200),
     Contract_Cases =>
       ((ds_values(0) > 200 or ds_values(1) < 200) => check_distance'Result = False,
        (ds_values(0) > 200 and ds_values(1) > 200) => check_distance'Result = False,
        (ds_values(0) = 0 and ds_values(1) = 0) => check_distance'Result = False,
        (ds_values(0) < 200 and ds_values(1) < 200) => check_distance'Result = True);


   -------------color_diff------------------------------------------------------------

   -- @name		color_diff
   -- @brief		calculate the difference between two colors if its <128 then its the same color
   --
   -- @param		input: colorcode of two colors a and b
   --
   -- @return		Returns the different between the two colors
   --function color_diff (a : color_BGR; b : color_BGR) return Integer;

   function color_diff (a : color_BGR; b : color_BGR) return Integer with
     Pre => (a(0) in Integer and b(0) in Integer and a(1) in Integer  and b(1) in Integer and a(2) in integer and b(2) in Integer),
     Contract_Cases => (a(0) - b(0) + a(1) - b(1) + a(2) - b(2) > 128  => color_diff'Result > 128,
                        a(0) - b(0) + a(1) - b(1) + a(2) - b(2) < 128  => color_diff'Result <= 128);



   -------------process_camera_image------------------------------------------------------------

   -- @name		process_camera_image
   -- @brief		calculate the angle according to the camera image
   --
   -- @param		input: image_array of image;
   --                   color_BGR of color
   --
   -- @return		Returns the tan value of angle
   function process_camera_image
     (image : image_array; color : color_BGR) return Float with
     Pre => (image in image_array and color in color_BGR),
     Post => (process_camera_image'Result > 0.0 and process_camera_image'Result < Float'Last);


   -------------filter_angle------------------------------------------------------------


   -- @name		filter_angle
   -- @brief		Make angle changes smoother
   --
   -- @param		input: float of value between -0.5 to 0.5
   --
   -- @return		Returns float of value between -0.5 to 0.5
   function filter_angle (new_value : Float) return Float with
     Pre => (new_value in Float and new_value < Float'Last),
     Depends => (filter_angle'Result => new_value),
     Contract_Cases =>
       (new_value = 100.00 => filter_angle'Result = 100.00,
        new_value = 00.00 => filter_angle'Result = 00.00);


   -------------applyPID------------------------------------------------------------

   -- @name		applyPID
   -- @brief		Make angle changes smoother
   --
   -- @param		input: float of value between -0.5 to 0.5
   --
   -- @return		Returns float of value between -0.5 to 0.5
   function applyPID (line_angle : Float) return Float with
     Pre => (line_angle < Float'Last),
     Depends => (applyPID'Result => line_angle),
     Post => (applyPID'Result > 0.0 and applyPID'Result in Float);


   -------------follow_path------------------------------------------------------------


   -- @name		follow_path
   -- @brief		calculate the speed of left and right wheel speed according the image
   --
   -- @param		input: Integer of distances from two distance sensor; e.g. (900,1000)
   --                   Image_Array of camera image  size:16*16*3; e.g. ((255,255,0),(0,255,255).....)
   --                   color_BGR of Color_Code; e.g. (255,255,255)
   --
   -- @return		Return the left wheel speed and right wheel speed
   function follow_path
     (ds0, ds1   : in Integer; Cam_Image : image_array;
      Color_Code : in color_BGR) return dirc_speed;
end follow_path;

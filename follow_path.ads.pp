with Ada.Text_IO;
with ProtectsObj; use ProtectsObj;

package follow_path is

   type dirc_speed is array (0 .. 1) of Float;
   type ds is array (0 .. 1) of Integer;

-- @name             set_steering_angle
-- @brief            calculate the steering angle according to the wheel angle
   --
   -- @param            input: wheel_angle between -0.5 to 0.5
   --
   -- @return           wheel_angle between -0.5 to 0.5
   --function set_steering_angle (wheel_angle : in out Float) return Float;
   function set_steering_angle (wheel_angle : in out Float) return Float with
      Pre  => (wheel_angle >= -0.1 and wheel_angle <= -0.1),
      Post => wheel_angle <= 0.5 and wheel_angle >= -0.1;

      -- @name             check_distance
      -- @brief            check if the distance between truck and obstacle smaller than the set distance(200)
      --
      -- @param            input: ds_values of two values (900,1000)
      --
      -- @return           Return boolean true/false
   function check_distance (ds_values : ds) return Boolean;

   -- @name             color_diff
   -- @brief            calculate the difference between two colors if its <128 then its the same color
   --
   -- @param            input: colorcode of two colors a and b
   --
   -- @return           Returns the different between the two colors
   function color_diff (a : color_BGR; b : color_BGR) return Integer;

   -- @name             process_camera_image
   -- @brief            calculate the angle according to the camera image
   --
   -- @param            input: image_array of image;
   --                   color_BGR of color
   --
   -- @return           Returns the tan value of angle
   function process_camera_image
     (image : image_array;
      color : color_BGR) return Float;

   -- @name             filter_angle
   -- @brief            Make angle changes smoother
   --
   -- @param            input: float of value between -0.5 to 0.5
   --
   -- @return           Returns float of value between -0.5 to 0.5
   function filter_angle (new_value : Float) return Float;

   -- @name             applyPID
   -- @brief            Make angle changes smoother
   --
   -- @param            input: float of value between -0.5 to 0.5
   --
   -- @return           Returns float of value between -0.5 to 0.5
   function applyPID (line_angle : Float) return Float;

   -- @name             follow_line
   -- @brief            calculate the speed of left and right wheel speed according the image
   --
   -- @param            input: Integer of distances from two distance sensor; e.g. (900,1000)
   --                   Image_Array of camera image  size:16*16*3; e.g. ((255,255,0),(0,255,255).....)
   --                   color_BGR of Color_Code; e.g. (255,255,255)
   --
   -- @return           Return the left wheel speed and right wheel speed
   function follow_path
     (ds0, ds1   : in Integer;
      Cam_Image  :    image_array;
      Color_Code : in color_BGR) return dirc_speed;
end follow_path;

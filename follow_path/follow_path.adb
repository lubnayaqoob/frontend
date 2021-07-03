with Ada.Text_IO; use Ada.Text_IO;
with ProtectsObj; use ProtectsObj;


package body follow_path with

SPARK_Mode => On

is

   pragma Assertion_Policy (Pre => Check);

   steering_angle : Float   := 0.0;
   PID_need_reset : Boolean := False;
   red_signal     : Boolean := True;
   pause_counter  : Integer := 0;
   subtype rows is Integer range 1 .. 16;
   subtype cols is Integer range 1 .. 16;
   camera_fov : Float   := 1.0;
   oldValue   : Float   := 0.0;
   integral   : Float   := 0.0;
   first_call : Boolean := True;
   type filter is array (0 .. 2) of Float;
   old_value  : filter;
   line_angle : Float;
   r_red   : color_BGR := (0, 0, 255);
   r_white : color_BGR := (255, 255, 255);
   r_blue  : color_BGR := (255, 0, 0);
   r_green : color_BGR := (0, 255, 0);
   r_yellow : color_BGR := (0,255,255);
   --------------------------Not Sure----------------------------
   type Color_array is array (1..5) of color_BGR;
   line_plan : Color_array :=(r_white,r_blue,r_green,r_yellow,r_red);
   -------------------------------------------------------------
   speed_values : dirc_speed;

   angle       : Float;
   init_speed  : Float;
   speed       : Float;
   left_speed  : Float;
   right_speed : Float;
   ds_values : ds;

   UNKNOWN : constant Float := 99_999.99;
   KP      : constant Float := 0.25;
   KI      : constant Float := 0.006;
   KD      : constant Float := 2.0;

   TIME_STEP : Integer;

   --- set the steering angle of the Truck ---
   function set_steering_angle (wheel_angle : in out Float) return Float is

      pragma Assertion_Policy (Assert => Check);
      pragma Assert (wheel_angle >= 0.0);  --  executed at run time

   begin

      Ada.Text_IO.Put_Line
        (" --> Wheel Angle is: " & Float'Image (wheel_angle) &
           " Steering Angle is " & Float'Image (steering_angle));

      if (wheel_angle - steering_angle > 0.1) then
         wheel_angle := steering_angle + 0.1;

      end if;

      if (wheel_angle - steering_angle < -0.1) then
         wheel_angle := steering_angle - 0.1;
      end if;

      steering_angle := wheel_angle;

      if (wheel_angle > 0.5) then
         wheel_angle := 0.5;
      elsif (wheel_angle < -0.5) then
         wheel_angle := -0.5;
      end if;

      Ada.Text_IO.Put_Line ("Steering angle: " & Float'Image (wheel_angle));
      return wheel_angle;
   end set_steering_angle;

   ----Check the values of distance sensor (collision avoidance---
   function check_distance (ds_values : ds) return Boolean is

      --pragma Assertion_Policy (Assert => Check);
      --pragma Assert (ds_values (0) > 900 and ds_values(1) < 1000);  --  executed at run time

   begin
      if (ds_values (0) < 200 or else ds_values (1) < 200) then
         return True;--Stop
      else
         return False;
      end if;
   end  check_distance;

   ---Set speed---
   function set_speed (speed : Float) return Float is
   begin
      return speed;
   end set_speed;
   -------
   function signbit (x : Float) return Integer is
   begin
      if x < 0.0 then
         return 1;
      else
         return 0;
      end if;
   end signbit;

   ------------------[image process]----------------
   -------------color diff------------
   function color_diff (a : color_BGR; b : color_BGR) return Integer is
      diff : Integer := 0;
      d    : Integer;
   begin
      for i in 0 .. 2 loop
         d := a (i) - b (i);

         if d > 0 then
            diff := diff + d;
         else
            diff := diff - d;
         end if;
      end loop;
      return diff;
   end color_diff;

   --------------process camera image-------------
   function process_camera_image
     (image : image_array; color : color_BGR) return Float
   is
      num_pixels  : Integer := rows'Last * cols'Last;
      sumx        : Integer := 0;
      pixel_count : Integer := 0;
      pixel_row   : Integer := 1;
      pixel_col   : Integer := 1;
   begin

      if color = (-1,-1,-1) then
         return UNKNOWN;
      end if;

      for x in 0 .. num_pixels - 1 loop
         pixel_row := (x / cols'Last) + 1;
         pixel_col := (x rem cols'Last) + 1;
         if color_diff (image (pixel_row, pixel_col), color) < 255 then
            sumx        := sumx + (x rem cols'Last);
            pixel_count := pixel_count + 1;
         end if;
      end loop;
      if pixel_count = 0 then
         return UNKNOWN;
      end if;
      --  else
      return
        (Float (sumx) / Float (pixel_count) / Float (cols'Last) - 0.5) *
          camera_fov;
      --  end if;
   end process_camera_image;

   ---------------filter angle of the line----------------
   function filter_angle (new_value : Float) return Float is
      sum : Float;
   begin
      if (first_call or else new_value = UNKNOWN) then
         first_call := False;
         for i in 0 .. 2 loop
            old_value (i) := 0.0;
         end loop;
      else
         for i in 0 .. 1 loop
            old_value (i) := old_value (i + 1);
         end loop;
      end if;
      if (new_value = UNKNOWN) then
         return UNKNOWN;
      else
         old_value (2) := new_value;
         sum           := 0.0;
         for i in 0 .. 2 loop
            sum := sum + old_value (i);
         end loop;
         return Float (sum / 3.0);
      end if;
   end filter_angle;

   ------------------------PID----------------------------
   function applyPID (line_angle : Float) return Float is
      diff : Float;
   begin
      if PID_need_reset then
         oldValue       := line_angle;
         integral       := 0.0;
         PID_need_reset := False;
      end if;
      if signbit (line_angle) /= signbit (oldValue) then
         integral := 0.0;
      end if;
      diff := line_angle - oldValue;
      if abs (integral) < 30.0 then
         integral := integral + line_angle;
      end if;
      oldValue := line_angle;
      return KP * line_angle + KI * integral + KD * diff;
   end applyPID;

   function follow_path
     (ds0, ds1   : in Integer; Cam_Image : image_array;
      Color_Code : in color_BGR) return dirc_speed
   is
      img : image_array := Cam_Image;

   begin
      TIME_STEP  := 16;
      init_speed := SpeedObj.GetSpeed;
      speed      := init_speed;

      --Parameters passed from Webots controller-----------
      --Ada.Text_IO.Put_Line ("ds_values is:");
      ds_values (0) := ds0; --Integer'Value (Ada.Text_IO.Get_Line);
      ds_values (1) := ds1; --Integer'Value (Ada.Text_IO.Get_Line);
      --Ada.Text_IO.Put_Line("Links: " & Integer'Image(ds_values(0)) & " Rechts: " & Integer'Image(ds_values(1)));
      -----------------------------------------------------

      if check_distance (ds_values) then
         speed       := set_speed (0.0);
         left_speed  := speed;
         right_speed := speed;

      else
         left_speed := speed;
         right_speed := speed;
         line_angle := filter_angle (process_camera_image (img, line_plan(1)));

         if (filter_angle (process_camera_image (img, line_plan(2))) /= UNKNOWN) then
            line_angle := filter_angle (process_camera_image (img, line_plan(2)));
            line_plan(1) :=(-1,-1,-1);

         elsif (filter_angle (process_camera_image (img, line_plan(3))) /= UNKNOWN) then
            line_angle := filter_angle (process_camera_image (img, line_plan(3)));
            line_plan(2) :=(-1,-1,-1);

         elsif (filter_angle (process_camera_image (img, line_plan(4))) /= UNKNOWN) then
            line_angle := filter_angle (process_camera_image (img, line_plan(4)));
            line_plan(3) :=(-1,-1,-1);

         else
            line_angle := filter_angle (process_camera_image (img, line_plan(5)));
            line_plan(4) :=(-1,-1,-1);
         end if;

         if (line_angle /= UNKNOWN) then
            speed       := init_speed;
            angle       := applyPID (line_angle);
            left_speed  := speed + set_steering_angle (angle) * 400.0;
            right_speed := speed - set_steering_angle (angle) * 400.0;

            --if
            --  (red_signal
            --   and then filter_angle (process_camera_image (img, r_red)) /=
            --     UNKNOWN)
            --then
            --   pause_counter := 12800 / TIME_STEP;
            --   red_signal    := False;
            --end if;

            --if (pause_counter > 0) then
            --   left_speed    := 0.0;
            --   right_speed   := 0.0;
            --   pause_counter := pause_counter - 1;
            --elsif (not red_signal) then
            --   left_speed  := speed + set_steering_angle (angle) * 100.0;
            --   right_speed := speed - set_steering_angle (angle) * 100.0;
            --end if;
         else
            speed       := init_speed;
            line_angle := filter_angle (process_camera_image (img, r_white));
            angle       := applyPID (line_angle);
            left_speed  := speed + set_steering_angle (angle) * 400.0;
            right_speed := speed - set_steering_angle (angle) * 400.0;
         end if;


      end if;
      --------------Parameters passed to webots controller--------------
      Ada.Text_IO.Put_Line ("left speed:" & Float'Image (left_speed));
      Ada.Text_IO.Put_Line ("right speed:" & Float'Image (right_speed));
      ------------------------------------------------------------------
      speed_values (0) := left_speed;
      speed_values (1) := right_speed;
      return speed_values;

   end follow_path;

end follow_path;

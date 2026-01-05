rollout hlaecamimporter3 "HLAE Cam Importer 1.0.4" width:202 height:220
(
	bitmap the_bmp pos:[1,180] fileName:"hlaecamimport.bmp" 
	button loadandimport "Load and Import" pos:[28,116] width:144 height:18
	label lbl1 "www.advancedfx.org | www.mst-gaming.de" pos:[44,18] width:112 height:15 enabled:true
	label lbl2 "HLAE Cam Importer Script by msthavoc" pos:[4,4] width:192 height:15
	GroupBox grp2 "Importer Settings" pos:[5,32] width:190 height:81
	checkbox hlae_90fix "90° fix" pos:[40,74] width:120 height:16 triState:0
	edittext hlae_fov "FieldOfView" pos:[40,92] width:106 height:16 text:"90"
	button hlae_pathbutton "Path for cam file (*.bvh)" pos:[13,48] width:174 height:24
	button exitdialogbut "Exit" pos:[28,156] width:144 height:18 enabled:true
	GLOBAL filename
	button manual "Manual" pos:[28,136] width:144 height:18 enabled:true
	



	on exitdialogbut pressed do
	(
	DestroyDialog(hlaecamimporter3);
	)
	on manual pressed do
	(
	messagebox ("1. Select the directory of your cam file from your HLAE capture\n2. 90° fix if you use wrong map rotation (e.g. BSP Viewer)\n3. Enter your FieldOfView, you used in HLAE. Default in HL is 90°, so here it's also default\n4. Click on 'Load and Import' for importing the camera. \n\n A Importing Dialog appears and you can see in the background 3ds max set up the keyframes for the camera (loop from 0 to maximum frames).\nIf you selected 90° fix the script will loop a second time for rotating the cam 90 degree to fit the cam to your maps/objects.")
	)
	
	
	on hlae_pathbutton pressed do
	(
	filename = getOpenFileName types:"HLAE Cam(*.bvh)|*.bvh|All files|*.*|"
	hlae_pathbutton.caption = if filename == undefined then "No File Chosen, select file again..." else filename 
	)
	
	
	on loadandimport pressed do
	(
	if  filename == undefined 
	then (DestroyDialog(hlaecamimporter);) 
	else (
			local file = openFile filename;
			local motion, frames, frametime, fps = undefined ;
			local new_x, new_y, new_z, new_h, new_p, new_b = undefined ;
			local h,p,b = undefined ;
			local hlaecamera = undefined  ;
			DestroyDialog hlaecamimporter3;
	
			
			for i = 1 to 11 do ( motion = readLine file )
			if motion == "MOTION" 
			then (
				skipToString file " "
				frames = (readLine file) as Integer
				skipToString file " " 
				skipToString file " " 
				frametime = (readLine file) as Float 
				timer=1
				frameRate = 1/frametime; animationRange = interval 1 frames;
				c_date = localTime[1]+localTime[2]+"_"+localTime[4]+localTime[5]+"_"+localTime[7]+localTime[8]+localTime[9]+localTime[10]
				c_time = localTime[12]+localTime[13]+"_"+localTime[15]+localTime[16]+"_"+localTime[18]+localTime[19]; 
				
				local camname = "HLAECam"+(c_date as string)+(c_time as string) 
				hlaecamera=Freecamera name:(camname as string);
				hlaecamera.fov = hlae_fov.text as Integer;
				local position_cam=#()
				local rotation_cam=#()
				while eof file != true  do 
					(  
						new_x = (readDelimitedString file " ") as Float*-1
						new_z = (readDelimitedString file " ") as Float
						new_y = (readDelimitedString file " ") as Float
						new_b = (readDelimitedString file " ") as Float
						new_p = (readDelimitedString file " ") as Float*-1
						new_h = (readLine file) as Float
						position_cam[timer] = ([new_x,new_y,new_z])  
						rotation_cam[timer] = ([new_h,new_p,new_b])  
						timer+=1
					) 
				close file
				/* (eulerAngles -90 180 0)as quat */
				for t = animationrange.start to animationrange.end do 
				
				( 
					at time t h=rotation_cam[((t as String)as Integer)].x;
					at time t p=rotation_cam[((t as String)as Integer)].y;
					at time t b=rotation_cam[((t as String)as Integer)].z;
					with animate on 
					(   
					at time t hlaecamera.position = position_cam[((t as String)as Integer)];
					at time t hlaecamera.rotation = (eulerAngles -90 180 0)as quat;
					at time t hlaecamera.transform = preRotateY hlaecamera.transform h
					at time t hlaecamera.transform = preRotateX hlaecamera.transform (-1*p)
					at time t hlaecamera.transform = preRotateZ hlaecamera.transform b
					at time t hlaecamera.position = position_cam[((t as String)as Integer)];
					at time t about [0,0,hlaecamera.position.z] rotate hlaecamera (EulerAngles 0 0 90)
					
					if hlae_90fix.triState == 0 then(
						at time t about [hlaecamera.position.x, 0, 0] rotate hlaecamera (EulerAngles 90 0 0)
						)
					about [0,0,hlaecamera.position.z] rotate hlaecamera (EulerAngles 0 0 -90)
					) 
					
				)
					

					
					
				)
				
			else (messagebox ("not a valid HLAE cam file"))
			
	
			
	
		)
	sliderTime = sliderTime
		
	
	)
	
	
)
CreateDialog hlaecamimporter3
--print "HLAE Cam Importer Script by msthavoc loaded successfully" 





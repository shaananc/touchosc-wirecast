(*
	Korg Controller applescript for Wirecast and Black Magic ATEM

	Version: 1.0
	This script also has an iPad interface using TouchOSC and OSCBridge.  All of the code can be retrieved by going to the 
	projects section on mikemyers.me or by viewing the github: https://github.com/netnutmike/Wirecast


  VERSION HISTORY:

	07/10/13 - Initial Public Release of Version 1.0
*)



(*
	FUNCTION: button

	DESCRIPTION:
		This function is called when a button is pressed.  There is another function that determines which button is pressed.  This function is
		portable between different scripts and only the button detection routine needs to be swapped out.
*)

script button

	#This button press will take the channel number live with a cut
	on live(channelnumber)
		my switcher's liverow("normal", "cam" & channelnumber)
		my switcher's setTransition("1", "fast")
	end live

	#This button press will take the channel number and put it into preview
	on preview(channelnumber)
		my switcher's previewrow("normal", "cam" & channelnumber)
	end preview

	
	on livespecial(channelnumber)
		my switcher's liverow("normal", "cam" & channelnumber)
	end livespecial

	on topspecial(channelnumber)
		my switcher's previewrow("normal", "cam" & channelnumber)
	end topspecial
	
	#This button will put a doublebox based on channel number live
	on rightTwist(channelnumber)
		my switcher's liverow("normal", "cam" & channelnumber & "-db")
	end rightTwist
	
	#This button will put a doublebox based on teh channel into preview
	on leftTwist(channelnumber)
		my switcher's previewrow("normal", "cam" & channelnumber & "-db")
	end leftTwist

	on fx(channelnumber)
		my switcher's setTransition("3", "fast")
		my switcher's lower("Main Layer 1", "chl3rd-" & channelnumber)
		my switcher's setTransition("2", "normal")
	end fx
	

	#Display Lower 3rd
	on upSlide(channelnumber)
		my switcher's setTransition("3", "fast")
		my switcher's lower("foreground", "l3rd-" & channelnumber)
		my switcher's setTransition("2", "normal")
	end upSlide

	#Remove Lower 3rd
	on downSlide(channelnumber)
		my switcher's setTransition("3", "fast")
		my switcher's removelower("foreground", "Blank Shot")
		my switcher's setTransition("2", "normal")
	end downSlide

	#Take Button
	on play(state)
		if state is "down" then
			my switcher's take()
		end if
	end play

	#The Auto Button
	on stopMe()
		my switcher's auto()
	end stopMe

	#Record Button
	on recordMe(state)
		if state is "down" then
			my switcher's startRecord()
		end if
		if state is "up" then
			my switcher's stopRecord()
		end if
	end recordMe

end script


(*
	This function is the interface to the actual swithers (Wirecast and ATEM for now)
*)

script switcher
	property myDoc : "1"
	property normal_layer : "3"
	property foreground_layer : "2"
	property background_layer : "3"
	property fx_layer: "1"
	property title_layer : "1"
	property audio_layer : "4"
	property preview : "cam1"
	property program : "cam1"
	property fxstore : "cam1-fx"
	property buffer : "cam1"
	property cgstore : "l3rd-1"
	property wirecast : application "Wirecast"
	
	
	# This function is called for jsut about every function to make sure that the interface to Wirecast is properly setup
	on setup()
		tell application "Wirecast"
			activate
		end tell
		tell application "Wirecast"
			set my myDoc to last document
			--set my normal_layer to the layer named "normal" of myDoc
			--set my foreground_layer to the layer named "foreground" of myDoc
			--set my background_layer to the layer named "background" of myDoc
			--set my title_layer to the layer named "text" of myDoc
			--set my audio_layer to the layer named "audio" of myDoc
			set my myDoc's auto live to false
		end tell
	end setup
	

	#This function tells wirecast what type of transition is used for auto and the speed of the transition
	on setTransition(anumber, speed)
		setup()
		tell application "Wirecast"
			set my myDoc's active transition popup to anumber
			set my myDoc's transition speed to speed
		end tell
	end setTransition
	
	#take is a "hard cut" from what is in preview to live
	on take()
		setup()
		tell application "Wirecast"
			go myDoc
			end tell
	end take
	
	#auto will put what is in preview onto live using the transition and speed set
	on auto()
		setup()
		tell application "Wirecast"
			set my myDoc's transition speed to "fast"
			set my myDoc's active transition popup to 1
			go myDoc
			end tell
	end auto
	
	#displays the fx
	on fxrow(layername, shotname)
		setup()
		tell application "Wirecast"
			set the active shot of the layer named "Background" of my myDoc to the shot named shotname of my myDoc
			set the active shot of the layer named "Normal" of my myDoc to the shot named program of my myDoc
			set the active shot of the layer named "Foreground" of my myDoc to the shot named cgstore of my myDoc
			go myDoc
			set the active shot of the layer named "Normal" of my myDoc to the shot named preview of my myDoc
			set the active shot of the layer named "Foreground" of my myDoc to the shot named "Blank Shot" of my myDoc
		end tell
	end fxrow
	
	#does a hard cut to the shot
	on liverow(layername, shotname)
		setup()
		tell application "Wirecast"
			set the active shot of the layer named layername of my myDoc to the shot named shotname of my myDoc
			set program to the shot named shotname of my myDoc
			--set the active shot of the layer named "Foreground" of my myDoc to the shot named cgstore of my myDoc
			go myDoc
			--set the active shot of the layer named layername of my myDoc to the shot named preview of my myDoc
			--set the active shot of the layer named "Foreground" of my myDoc to the shot named "Blank Shot" of my myDoc
		end tell
		set program to shotname
	end liverow
	
	#put the shot into preview
	on previewrow(layername, shotname)
		setup()
		tell application "Wirecast"
			set the active shot of the layer named layername of my myDoc to the shot named shotname of my myDoc
			set preview to the shot named shotname of my myDoc
		end tell
		set preview to shotname
	end previewrow
	
	#start broadcasting
	on startBroadcast()
		setup()
		tell application "Wirecast"
			start broadcasting myDoc
		end tell
	end startBroadcast
	
	#stop broadcasting
	on stopBroadcast()
		setup()
		tell application "Wirecast"
			stop broadcasting myDoc
		end tell
	end stopBroadcast
	
	#start record
	on startRecord()
		setup()
		tell application "Wirecast"
			start recording myDoc
		end tell
	end startRecord
	
	#stop record
	on stopRecord()
		setup()
		tell application "Wirecast"
			stop recording myDoc
		end tell
	end stopRecord

	#activate a lower 3rd
	on lower(layername, shotname)
		setup()
		tell application "Wirecast"
			set the active shot of the layer named layername of my myDoc to the shot named shotname of my myDoc
		end tell
	end lower
	

	#remove a lower 3rd
	on removelower(layername, shotname)
		setup()
		tell application "Wirecast"
			set the active shot of the layer named layername of my myDoc to the shot named "Clear Layer" of my myDoc
		end tell
	end removelower
	
	
end script


(*
	the runme is the default function, it reads the midi input and then calls the correct button function
*)

on runme(message)
	
	-- transport controls
	
	if (item 1 of message = 176) and (item 2 of message = 4) and (item 3 of message = 127) then
		my button's play("down")
	end if

	if (item 1 of message = 176) and (item 2 of message = 4) and (item 3 of message = 0) then
		my button's play("up")
	end if

	if (item 1 of message = 176) and (item 2 of message = 5) and (item 3 of message = 127) then
		my button's recordMe("down")
	end if

	if (item 1 of message = 176) and (item 2 of message = 5) and (item 3 of message = 0) then
		my button's recordMe("up")
	end if
	
	
	-----------------------------------------
	-- Channel 1 block
	-----------------------------------------
	
	-- Show slides
	if (item 1 of message = 176) and (item 2 of message = 15) and (item 3 of message > 0) then
		do shell script "open -a Keynote"
	end if

	-- Main camera should hide lower third
	if (item 1 of message = 176) and (item 2 of message = 11) and (item 3 of message > 0) then
		my button's downSlide("1")
		my button's live("1")

	end if

	-- Main camera should hide lower third
	if (item 1 of message = 176) and (item 2 of message = 12) and (item 3 of message > 0) then
		my button's downSlide("1")
		my button's preview("1")
	end if

	if (item 1 of message = 176) and (item 2 of message = 13) and (item 3 of message = 0) then
		
		-- do stuff left twist
		my button's leftTwist("1")

	end if

	if (item 1 of message = 176) and (item 2 of message = 10) and (item 3 of message = 127) then
		
		-- do stuff fx
		my button's fx("1")
		
	end if

	if (item 1 of message = 176) and (item 2 of message = 13) and (item 3 of message = 127) then
		
		-- do stuff right twist
		my button's rightTwist("1")

	end if

	if (item 1 of message = 176) and (item 2 of message = 14) and (item 3 of message = 0) then
		
		-- do stuff down slide
		my button's downSlide("1")

	end if

	if (item 1 of message = 176) and (item 2 of message = 14) and (item 3 of message = 127) then
		
		-- do stuff up slide
		my button's upSlide("1")

	end if

	-----------------------------------------
	-- Channel 2 block
	-----------------------------------------
	
	-- Activate Keynote immediate and add lower third
	if (item 1 of message = 176) and (item 2 of message = 21) and (item 3 of message > 0) then
		my button's upSlide("2")
		my button's preview("2")
		my button's auto()
	end if

	if (item 1 of message = 176) and (item 2 of message = 22) and (item 3 of message > 0) then
		my button's preview("2")
		--my button's keynote()
	end if

	if (item 1 of message = 176) and (item 2 of message = 23) and (item 3 of message = 0) then
		
		-- do stuff left twist
		my button's leftTwist("2")
		
	end if

	if (item 1 of message = 176) and (item 2 of message = 20) and (item 3 of message = 127) then
		
		-- do stuff fx
		my button's fx("2")
		
	end if

	if (item 1 of message = 176) and (item 2 of message = 23) and (item 3 of message = 127) then
		
		-- do stuff right twist
		my button's rightTwist("2")

	end if

	if (item 1 of message = 176) and (item 2 of message = 24) and (item 3 of message = 0) then
		
		-- do stuff down slide
		my button's downSlide("2")

	end if

	if (item 1 of message = 176) and (item 2 of message = 24) and (item 3 of message = 127) then
		
		-- do stuff up slide
		my button's upSlide("2")

	end if
	
	-----------------------------------------
	-- Channel 3 block
	-----------------------------------------
	
	if (item 1 of message = 176) and (item 2 of message = 31) and (item 3 of message > 0) then

		-- do stuff for top button
		my button's live("3")

	end if

	if (item 1 of message = 176) and (item 2 of message = 32) and (item 3 of message > 0) then

		-- do stuff for bottom button
		my button's preview("3")

	end if

	if (item 1 of message = 176) and (item 2 of message = 33) and (item 3 of message = 0) then
		
		-- do stuff left twist
		my button's leftTwist("3")
		
	end if

	if (item 1 of message = 176) and (item 2 of message = 33) and (item 3 of message = 127) then
		
		-- do stuff right twist
		my button's rightTwist("3")

	end if

	if (item 1 of message = 176) and (item 2 of message = 34) and (item 3 of message = 0) then
		
		-- do stuff down slide
		my button's downSlide("3")

	end if

	if (item 1 of message = 176) and (item 2 of message = 34) and (item 3 of message = 127) then
		
		-- do stuff up slide
		my button's upSlide("3")

	end if

	if (item 1 of message = 176) and (item 2 of message = 30) and (item 3 of message = 127) then
		
		-- do stuff fx
		my button's fx(3)
		
	end if

	-----------------------------------------
	-- Channel 4 block
	-----------------------------------------
	
	if (item 1 of message = 176) and (item 2 of message = 41) and (item 3 of message > 0) then

		-- do stuff for top button
		my button's live("4")

	end if

	if (item 1 of message = 176) and (item 2 of message = 42) and (item 3 of message > 0) then

		-- do stuff for bottom button
		my button's preview("4")

	end if

	if (item 1 of message = 176) and (item 2 of message = 43) and (item 3 of message = 0) then
		
		-- do stuff left twist
		my button's leftTwist("4")
		
	end if

	if (item 1 of message = 176) and (item 2 of message = 43) and (item 3 of message = 127) then
		
		-- do stuff right twist
		my button's rightTwist("4")

	end if

	if (item 1 of message = 176) and (item 2 of message = 44) and (item 3 of message = 0) then
		
		-- do stuff down slide
		my button's downSlide("4")

	end if

	if (item 1 of message = 176) and (item 2 of message = 44) and (item 3 of message = 127) then
		
		-- do stuff up slide
		my button's upSlide("4")

	end if

	if (item 1 of message = 176) and (item 2 of message = 40) and (item 3 of message = 127) then
		
		-- do stuff fx
		my button's fx("4")
		
	end if

	-----------------------------------------
	-- Channel 5 block
	-----------------------------------------
	
	if (item 1 of message = 176) and (item 2 of message = 51) and (item 3 of message > 0) then

		-- do stuff for top button
		my button's live("5")

	end if

	if (item 1 of message = 176) and (item 2 of message = 52) and (item 3 of message > 0) then

		-- do stuff for bottom button
		my button's preview("5")

	end if

	if (item 1 of message = 176) and (item 2 of message = 53) and (item 3 of message = 0) then
		
		-- do stuff left twist
		my button's leftTwist("5")
		
	end if

	if (item 1 of message = 176) and (item 2 of message = 53) and (item 3 of message = 127) then
		
		-- do stuff right twist
		my button's rightTwist("5")

	end if

	if (item 1 of message = 176) and (item 2 of message = 54) and (item 3 of message = 0) then
		
		-- do stuff down slide
		my button's downSlide("5")

	end if

	if (item 1 of message = 176) and (item 2 of message = 54) and (item 3 of message = 127) then
		
		-- do stuff up slide
		my button's upSlide("5")

	end if

	if (item 1 of message = 176) and (item 2 of message = 50) and (item 3 of message = 127) then
		
		-- do stuff fx
		my button's fx("5")
		
	end if


	-----------------------------------------
	-- Channel 6 block
	-----------------------------------------
	
	if (item 1 of message = 176) and (item 2 of message = 61) and (item 3 of message > 0) then

		-- do stuff for top button
		my button's live("6")

	end if

	if (item 1 of message = 176) and (item 2 of message = 62) and (item 3 of message > 0) then

		-- do stuff for bottom button
		my button's preview("6")

	end if

	if (item 1 of message = 176) and (item 2 of message = 63) and (item 3 of message = 0) then
		
		-- do stuff left twist
		my button's leftTwist("6")
		
	end if

	if (item 1 of message = 176) and (item 2 of message = 63) and (item 3 of message = 127) then
		
		-- do stuff right twist
		my button's rightTwist("6")
	end if

	if (item 1 of message = 176) and (item 2 of message = 64) and (item 3 of message = 0) then
		
		-- do stuff down slide
		my button's downSlide("6")

	end if

	if (item 1 of message = 176) and (item 2 of message = 64) and (item 3 of message = 127) then
		
		-- do stuff up slide
		my button's upSlide("6")

	end if

	if (item 1 of message = 176) and (item 2 of message = 60) and (item 3 of message = 127) then
		
		-- do stuff fx
		my button's fx("6")
		
	end if

	
	-----------------------------------------
	-- Channel 7 block
	-----------------------------------------
	
	if (item 1 of message = 176) and (item 2 of message = 71) and (item 3 of message > 0) then

		-- do stuff for top button
		my button's livespecial(7)

	end if

	if (item 1 of message = 176) and (item 2 of message = 72) and (item 3 of message > 0) then

		-- do stuff for bottom button
		my button's preview("7")

	end if

	if (item 1 of message = 176) and (item 2 of message = 73) and (item 3 of message = 0) then
		
		-- do stuff left twist
		my button's leftTwist(7)
		
	end if

	if (item 1 of message = 176) and (item 2 of message = 73) and (item 3 of message = 127) then
		
		-- do stuff right twist
		my button's rightTwist(7)

	end if

	if (item 1 of message = 176) and (item 2 of message = 74) and (item 3 of message = 0) then
		
		-- do stuff down slide
		my button's downSlide(7)

	end if

	if (item 1 of message = 176) and (item 2 of message = 74) and (item 3 of message = 127) then
		
		-- do stuff up slide
		my button's upSlide(7)

	end if

	if (item 1 of message = 176) and (item 2 of message = 70) and (item 3 of message = 127) then
		
		-- do stuff fx
		my button's fxspecial(7)
		
	end if


	-----------------------------------------
	-- Channel 8 block
	-----------------------------------------
	
	if (item 1 of message = 176) and (item 2 of message = 81) and (item 3 of message > 0) then

		-- do stuff for top button
		my button's topspecial(8)

	end if

	if (item 1 of message = 176) and (item 2 of message = 82) and (item 3 of message > 0) then

		-- do stuff for bottom button
		my button's bottomspecial(8)

	end if

	if (item 1 of message = 176) and (item 2 of message = 83) and (item 3 of message = 0) then
		
		-- do stuff left twist
		my button's leftTwist(8)
		
	end if

	if (item 1 of message = 176) and (item 2 of message = 83) and (item 3 of message = 127) then
		
		-- do stuff right twist
		my button's rightTwist(8)

	end if

	if (item 1 of message = 176) and (item 2 of message = 84) and (item 3 of message = 0) then
		
		-- do stuff down slide
		my button's downSlide(8)

	end if

	if (item 1 of message = 176) and (item 2 of message = 84) and (item 3 of message = 127) then
		
		-- do stuff up slide
		my button's upSlide(8)

	end if

	if (item 1 of message = 176) and (item 2 of message = 80) and (item 3 of message = 127) then
		
		-- do stuff fx
		my button's fxspecial(8)
		
	end if
	
	if (item 1 of message = 176) and (item 2 of message = 80) and (item 3 of message = 127) then
		
		-- do stuff ddr
		my button's fx(8)
		
	end if

	
end runme
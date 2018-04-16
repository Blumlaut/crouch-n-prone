local crouched = false
local proned = false
crouchKey = 26
proneKey = 36

Citizen.CreateThread( function()
	while true do 
		Citizen.Wait( 1 )
		local ped = GetPlayerPed( -1 )
		if ( DoesEntityExist( ped ) and not IsEntityDead( ped ) ) then 
			ProneMovement()
			DisableControlAction( 0, proneKey, true ) 
			DisableControlAction( 0, crouchKey, true ) 
			if ( not IsPauseMenuActive() ) then 
				if ( IsDisabledControlJustPressed( 0, crouchKey ) and not proned ) then 
					RequestAnimSet( "move_ped_crouched" )
					RequestAnimSet("MOVE_M@TOUGH_GUY@")
					
					while ( not HasAnimSetLoaded( "move_ped_crouched" ) ) do 
						Citizen.Wait( 100 )
					end 
					
					while ( not HasAnimSetLoaded( "MOVE_M@TOUGH_GUY@" ) ) do 
						Citizen.Wait( 100 )
					end 
					
					if ( crouched and not proned ) then 
						ResetPedMovementClipset( ped )
						ResetPedStrafeClipset(ped)
						SetPedMovementClipset( ped,"MOVE_M@TOUGH_GUY@", 0.5)
						crouched = false 
					elseif ( not crouched and not proned ) then
						SetPedMovementClipset( ped, "move_ped_crouched", 0.55 )
						SetPedStrafeClipset(ped, "move_ped_crouched_strafing")
						crouched = true 
					end 
				elseif ( IsDisabledControlJustPressed(0, proneKey) and not crouched and not IsPedInAnyVehicle(ped, true) and not IsPedFalling(ped) and not IsPedDiving(ped) and not IsPedInCover(ped, false) and not IsPedInParachuteFreeFall(ped) and (GetPedParachuteState(ped) == 0 or GetPedParachuteState(ped) == -1) ) then
					if proned then
						ClearPedTasksImmediately(ped)
						proned = false
					else
						RequestAnimSet( "move_crawl" )
						while ( not HasAnimSetLoaded( "move_crawl" ) ) do 
							Citizen.Wait( 100 )
						end 
						ClearPedTasksImmediately(ped)
						proned = true
						if IsPedSprinting(ped) or IsPedRunning(ped) or GetEntitySpeed(ped) > 5 then
							TaskPlayAnim(ped, "move_jump", "dive_start_run", 8.0, 1.0, -1, 0, 0.0, 0, 0, 0)
							Wait(1000)
						end
						SetProned()
					end
				end
			end
		else
			proned = false
			crouched = false
		end
	end
end)

function SetProned()
	ped = PlayerPedId()
	ClearPedTasksImmediately(ped)
	TaskPlayAnim(ped,"move_crawl","onfront_bwd",0.0,0.0,0,0,0.0,false,false,false)
	--TaskPlayAnim(ped, animDictionary, animationName, speed, speedMultiplier, duration, flag, playbackRate, lockX, lockY, lockZ)
end

function ProneMovement()
	if proned then
		ped = PlayerPedId()
		if IsControlPressed(0, 34) then
			SetEntityHeading(ped, GetEntityHeading(ped)+2.0 )
		elseif IsControlPressed(0, 35) then
			SetEntityHeading(ped, GetEntityHeading(ped)-2.0 )
		elseif IsControlPressed(0, 32) and not IsEntityPlayingAnim(ped, "move_crawl", "onfront_fwd", 3) then
			TaskPlayAnim(ped,"move_crawl","onfront_fwd",8.0,-4.0,-1,9,0.0,false,false,false)
		elseif IsControlPressed(0, 33) and not IsEntityPlayingAnim(ped, "move_crawl", "onfront_bwd", 3) then
			TaskPlayAnim(ped,"move_crawl","onfront_bwd",8.0,-4.0,-1,9,0.0,false,false,false)
			TaskPlayAnim(ped, animDictionary, animationName, speed, speedMultiplier, duration, flag, playbackRate, lockX, lockY, lockZ)
		elseif IsControlJustReleased(0, 32) or IsControlJustReleased(0, 33) then 
			TaskPlayAnim(ped,"move_crawl","onfront_bwd",0.0,0.0,0,9,0.0,false,false,false)
		end
	end
end
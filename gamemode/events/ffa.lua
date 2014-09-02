local event = event.new()

event:addHook('PlayerDeath',function(ply)
	print('I DIED IN FFA')
end)

event:addHook('PlayerSpawn',function(ply)
	print('I SPAWNED IN FFA')
end)

event:register(TYPE_FFA)
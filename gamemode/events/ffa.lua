EVENT.Name = "Free for all"
EVENT.ID = "FFA"

function EVENT:PlayerDeath(ply)
	if not ply:inEvent(self.ID) then return end
	print('I DIED IN FFA')
end
function EVENT:PlayerSpawn(ply)
	if not ply:inEvent(self.ID) then return end
	print('I SPAWNED IN FFA')
end
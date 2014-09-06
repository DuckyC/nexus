EVENT.Name = "Flood"
EVENT.Author = "GModCoders"
EVENT.IsPlayable = true
EVENT.ID = "EVENT_FLOOD"

EVENT_BASE = EVENT.ID

EVENT:DeriveEvent("base")

function EVENT:StartEvent(Room)
	print("Started event!")
end

function EVENT:StopEvent(Room)
	print("Stopped event!")
end

function EVENT:RegisterLocations()

end
extends Node

signal toiletFlushed

signal layoutGenerated

signal roomGenDone

signal startRoomPos

signal intro_dialogue_finished

signal gridGeneratorInstantiated

# Announces which location the player has entered.
signal locationChanged(location: String)

# Announces the final minute before the payment deadline.
signal deadlineApproaching

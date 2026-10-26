extends Node

signal toiletFlushed

signal layoutGenerated

signal roomGenDone

signal startRoomPos

signal intro_dialogue_finished

signal gridGeneratorInstantiated

signal don_parmesan_spawn_requested

signal don_parmesan_leave_requested

signal switchCameraState(state : String)

signal HUDloaded(hpBar: TextureProgressBar)

# emitted when the player pays Don Parmesan (a new day starts)
signal debt_paid

# Announces which location the player has entered.
signal locationChanged(location: String)

# Announces the final minute before the payment deadline.
signal deadlineApproaching

# Enemies announce changes to their overall combat involvement.
signal enemyCombatChanged(enemy: Node, active: bool)

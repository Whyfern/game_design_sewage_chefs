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

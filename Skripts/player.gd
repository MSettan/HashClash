extends Node2D
class_name Player

@export var pawn_paths: Array[NodePath] = []

var pawns: Array[Pawn] = []
var active_pawn: Pawn

func setup(tile_board: TileMapLayer, navigation_system: HexNavigationSystem) -> void:
	_collect_pawns()
	if pawns.is_empty():
		push_warning("Player has no pawns to setup.")
		return

	for pawn in pawns:
		pawn.set_active(false)
		pawn.setup(tile_board, navigation_system)

	set_active_pawn(pawns[0])

func set_active_pawn(pawn: Pawn) -> void:
	if pawn == null or not pawns.has(pawn):
		return

	if active_pawn != null:
		active_pawn.set_active(false)

	active_pawn = pawn
	active_pawn.set_active(true)

func reset_turn() -> void:
	for pawn in pawns:
		pawn.reset_turn()

	if active_pawn != null:
		active_pawn.refresh_reachable_tiles()

func _collect_pawns() -> void:
	pawns.clear()

	if not pawn_paths.is_empty():
		for pawn_path in pawn_paths:
			var pawn := get_node_or_null(pawn_path) as Pawn
			if pawn != null:
				pawns.append(pawn)
		return

	for child in get_children():
		var pawn := child as Pawn
		if pawn != null:
			pawns.append(pawn)

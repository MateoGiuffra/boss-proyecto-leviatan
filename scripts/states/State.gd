@abstract
class_name State extends Node

signal Transitioned

@abstract func get_input() -> void
@abstract func enter() -> void
@abstract func exit() -> void
@abstract func update(_delta: float) -> void
@abstract func physics_update(_delta: float) -> void

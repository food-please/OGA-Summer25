## Discrete actions that a [Battler] may take on its turn.
##
## The following class is an interface that specific actions should implement. [method execute] is
## called once an action has been chosen and is a coroutine, containing the logic of the action
## including any animations or effects.
class_name BattlerAction extends Resource

enum TargetScope { SELF, SINGLE, ALL }

@export_group("UI")
## An action-specific icon. Shown primarily in menus.
@export var icon: Texture
## The 'name' of the action. Shown primarily in menus.
@export var label: = "Base combat action"
## Tells the player exactly what an action does. Shown primarily in menus.
@export var description: = "A combat action."

# Action targeting properties.
@export_group("Targets")
## Determines how many [Battler]s this action targets. [b]Note:[/b] [enum TargetScope.SELF] will not
## make use of the [targets_friendlies] or [targets_enemies] flags.
@export var target_scope: = TargetScope.SINGLE
## Can this action target friendly [Battler]s? Has no effect if [target_scope] is
## [enum TargetScope.SELF].
@export var targets_friendlies: = false
## Can this action target enemy [Battler]s? Has no effect if [target_scope] is
## [enum TargetScope.SELF].
@export var targets_enemies: = false

@export_group("")


## The body of the action, where different animations/modifiers/damage/etc. will be played out.
## Battler actions are (almost?) always coroutines, so it is expected that the caller will wait for
## execution to finish.
## [br][br]Note: The base action class does nothing, but must be overridden to do anything.
func execute(source: Battler, _targets: Array[Battler] = []) -> void:
	await source.get_tree().process_frame

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**ClockWork** is a 2D action-combat game built in **Godot 4.7** (Forward Plus renderer, Jolt physics). The codebase is GDScript. There is no test suite, build script, or package manager — development happens through the Godot editor.

## Running & editing

- Open the project: `godot --editor` (or `godot -e`) from the repo root, or open `project.godot` in the Godot editor.
- Run the game: `godot` from the repo root, or F5 in the editor. The main scene is `Scenes/test.tscn` (`run/main_scene` in `project.godot`).
- `.godot/` is generated/cached state — it is gitignored but currently tracked; do not hand-edit it.
- Scenes (`.tscn`) and resources (`.tres`) are most reliably edited in the editor, not as text. Each script has a sibling `.uid` file that maps a `uid://` reference; autoloads and the main scene are referenced by these UIDs in `project.godot`, so renaming/moving a script means its UID binding must stay intact.

## Core architecture

### Finite state machines via LimboAI

The third-party **LimboAI** addon (`addons/limboai/`) drives both the player and the enemy. Each actor is a `CharacterBody2D` with a child `state_machine` node extending `LimboHSM`, and one child `LimboState` node per state. The relevant scripts:

- Player: `Player/Scripts/player.gd`, `Player/Scripts/state_machine.gd`, `Player/Scripts/States/*.gd`
- Enemy: `Enemy/Scripts/enemy.gd`, `Enemy/Scripts/state_machine.gd`, `Enemy/Scripts/States/*.gd`

**How a state machine is wired (`state_machine.gd`):**
- `fill_state_to_states_dictionary()` is the single source of truth for legal transitions — a `Dictionary` of `from_state -> [allowed to_states]`. To add/restrict a transition, edit this dictionary, not the per-state code.
- `_init_transitions()` walks that dictionary and registers each transition with an event StringName derived from `_get_event()`. State changes happen by calling `dispatch(&"event_name")`. The player also wires `ANYSTATE -> idle`.
- `initialize(get_parent())` makes the parent `CharacterBody2D` the `agent`; inside any state, `agent` is that body and `get_root()` is the state machine.
- The state machine forwards the sprite's `animation_finished` signal to the active state's `_on_animation_finished()` if it has one. States that end on animation completion (attacks, etc.) rely on this.

**State script convention** (`extends LimboState`): `_setup()` caches `agent`; `_enter()`/`_exit()` run on transition (`_exit()` typically stores `get_root().previous_state = self`); `_update(delta)` runs each frame and calls the transition-check helpers.

**Input is centralized, not per-state.** All player input→transition logic lives in the `#region Inputs` block of `Player/Scripts/state_machine.gd` (`input_for_run()`, `input_for_dash()`, `input_for_combo_light_atk()`, etc.). Each state's `_update()` calls the subset of these helpers that are valid from that state (see `call_transition_inputs()` in `idle.gd`). Add a new input-driven transition by adding an `input_for_*` helper here and calling it from the relevant states. Input action names are defined in `project.godot` under `[input]`.

### Autoload singletons (globals)

Registered in `project.godot` under `[autoload]`. These hold cross-cutting game state and are referenced globally by name:

- **`PlayerData`** (`Player/Scripts/Player_Data.gd`) — all player tuning constants (speeds, jump/dash/magic config, attack damage values) plus runtime resources (health/stamina/mana with regen+delay timers, invincibility, coyote/jump-buffer timers). Emits `*_changed` signals consumed by the UI juice scripts (`Player/Scripts/UI/*.gd`). Edit gameplay numbers here, not in state scripts.
- **`EnemyData`** (`Enemy/Scripts/EnemyData.gd`) — enemy tuning constants and a dominance tracker (`authority_score`/`resolve_score`) that classifies Marla's playstyle into a `CastRole`.
- **`Captain`** (`Scripts/Globals/Captain.gd`) — the active enemy "role" as a stateful vessel with four metrics: `poise`, `form` (combat HP pool), `role_integrity`, `audience_favor`, plus `volatility`. Combat damage depletes `form`; on collapse it scars the role and either recasts into a new vessel or triggers `true_death`. **Holds no memory of its own.**
- **`Audience`** (`Scripts/Globals/Audience.gd`) — the persistent memory layer. Records Marla's behavioral patterns (`brutality`, `precision`, `repetition`, etc.) across all encounters and applies that accumulated pressure onto `Captain`'s metrics. This is the intended design split: **Captain is stateless-per-life, Audience remembers.**

### Combat data flow

This is the conceptual backbone — combat is not just HP subtraction; player behavior reshapes enemy AI over time:

1. A player attack state activates the player `hitbox` (`Player/Scripts/hitbox.gd`) on specific animation frames via `_activate_hitbox(damage, atk_name)`.
2. On a hit, the hitbox calls the target's `take_damage()` **and** records the behavior to `Audience` via `_record_map` (each `atk_name` maps to a brutal/precise/repeat reading).
3. Enemy `take_damage()` routes combat damage into `Captain.take_damage()` and dispatches `stagger` or `recast`.
4. `Audience` periodically pushes accumulated patterns onto `Captain`'s metrics; `enemy.gd::_apply_captain_behaviour()` then derives concrete AI behavior (move speed, attack cooldown, jitter, heavy-attack chance, stagger/recover durations) from `Captain.volatility` and `Captain.poise`. So sustained brutal/repetitive play makes the enemy faster and more erratic.

Player damage intake goes through `player.gd::take_damage()`, which respects the `shield_block` and `parry` states (a successful parry calls `Captain.damage_back_attacking_vessel()`).

## Conventions

- Directory layout mirrors the actor split: `Player/` and `Enemy/` each contain `Scenes/` (or `.tscn` at root) and `Scripts/` with a `States/` subfolder; shared globals live in `Scripts/Globals/`.
- Animations are played through `player.gd::play_anim()` / frame-interval helpers; many attack states drive hitbox activation off `sprite.frame_changed` and connect/disconnect that signal within `_enter()`/`_exit()` — always disconnect in `_exit()` to avoid leaked connections.
- Tuning constants belong in the `*Data` autoloads; transition legality belongs in `fill_state_to_states_dictionary()`; input mapping belongs in the state machine's input region.

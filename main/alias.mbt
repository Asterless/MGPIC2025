///|
using @hashset {type HashSet}

///|
using @hashmap {type HashMap}

///|
using @math {type Vec2D}

///|
using @system {type Code, type Entity, type MouseButton, trait Backend}

///|
using @system {is_pressed, is_just_pressed}

///|
using @velocity {type Velocity}

///|
using @position {type Position}

///|
using @sprite {type Sprite, type Text, type Picture, type Animation}

///|
using @collision {
  type Collide,
  type CollisionLayer,
  type CollisionMask,
  type CollisionShape,
  type Area,
}

///|
pub let global_v : Map[Entity, Velocity] = @velocity.velocities

///|
pub let global_c : Map[Entity, Collide] = @collision.collides

///|
pub let global_a : Map[Entity, Area] = @collision.areas

///|
pub let global_s : Map[Entity, Sprite] = @sprite.sprites

///|
pub let global_p : Map[Entity, Position] = @position.positions

///|
pub let ptr_entity : Entity = game_state.pointer_entity

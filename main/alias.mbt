///|
using @hashset {type HashSet}

///|
using @hashmap {type HashMap}

///|
using @cmath {type Vec2D}

///|
using @system {type Code, type Entity, type MouseButton, trait Backend}

///|
using @system {is_pressed, is_just_pressed}

///|
using @velocity {type Velocity, velocities as g_velocity}

///|
using @position {type Position, positions as g_position}

///|
using @sprite {
  type Sprite,
  type Text,
  type Picture,
  type Animation,
  sprites as g_sprites,
}

///|
using @collision {
  type Collide,
  type CollisionLayer,
  type CollisionMask,
  type CollisionShape,
  type Area,
  collides as g_collides,
  areas as g_areas,
}

///|
pub let ptr_entity : Entity = game_state.pointer_entity

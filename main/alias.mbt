///|
using @hashset {type HashSet}

///|
using @hashmap {type HashMap}

///|
using @math {type Vec2D}

///|
using @system {type Code, type Entity}

///|
using @system {is_pressed, is_just_pressed}

///|
using @velocity {type Velocity}

///|
using @position {type Position}

///|
using @sprite {type Sprite, type Text, type Picture}

///|
using @collision {
  type Collide,
  type CollisionLayer,
  type CollisionMask,
  type CollisionShape,
}

///|
pub let global_v : Map[Entity, Velocity] = @velocity.velocities

///|
pub let global_c : Map[Entity, Collide] = @collision.collides

///|
pub let global_s : Map[Entity, Sprite] = @sprite.sprites

///|
pub let global_p : Map[Entity, Position] = @position.positions

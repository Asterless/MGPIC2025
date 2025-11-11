///|
pub fn game_start(_backend : &Backend) -> Unit {
  add_pointer()
  for x = 0.0; x < CANVAS_WIDTH; x = x + 16.0 {
    add_bottom(Vec2D::new(x, CANVAS_HEIGHT - 16.0))
  }
  for x = 0.0; x < CANVAS_HEIGHT; x = x + 16.0 * 3.0 {
    add_side_walls(Vec2D::new(0, x))
    add_side_walls(Vec2D::new(CANVAS_WIDTH - 16.0, x))
  }
  add_background()
  add_score_bar()
}

///|
pub fn add_pointer() -> Unit {
  global_position[ptr_entity] = Vec2D::new(CANVAS_WIDTH / 2.0, 80.0)
  let velocity = Vec2D::new(0.0, 0.0)
  global_velocity[ptr_entity] = velocity
  global_sprites[ptr_entity] = game_state.pointer_sprite
}

///|
pub fn add_bottom(pos : Vec2D) -> Unit {
  let entity = Entity::new()
  global_position[entity] = pos
  let animation = Animation::new(
    "./assets/Terrain/Terrain (16x16).png",
    max_frame=1,
    height=16,
    width=16,
    offset=Vec2D::new(16.0 * 7, 0.0),
  )
  let sprite = Sprite::new_animation(animation, 20)
  global_sprites[entity] = sprite
  let collide : Collide = Collide::{
    shape: CollisionShape::Rect(
      size=Vec2D::new(16.0, 16.0),
      offset=Vec2D::new(0.0, 0.0),
    ),
    layer: terrain_collision_layer,
    mask: CollisionMask::empty(),
  }
  global_collides[entity] = collide
}

///|
pub fn add_side_walls(pos : Vec2D) -> Unit {
  let animation = Animation::new(
    "./assets/Terrain/Terrain (16x16).png",
    max_frame=1,
    height=16 * 3,
    width=16,
    offset=Vec2D::new(16.0 * 15, 0.0),
  )
  // Left Wall
  let wall = Entity::new()
  global_position[wall] = pos
  let left_collide : Collide = Collide::{
    shape: CollisionShape::Rect(
      size=Vec2D::new(16.0, 16.0),
      offset=Vec2D::zero(),
    ),
    layer: terrain_collision_layer,
    mask: CollisionMask::new([pointer_collision_layer]),
  }
  global_sprites[wall] = Sprite::new_animation(animation, 5)
  global_collides[wall] = left_collide
}

///|
pub fn add_background() -> Unit {
  let entity = Entity::new()
  let picture = Picture::new(
    Vec2D::new(CANVAS_WIDTH, CANVAS_HEIGHT),
    "./assets/Background/Brown.png",
    repeat=true,
  )
  let sprite = Sprite::new_picture(picture, 0)
  global_sprites[entity] = sprite
  global_position[entity] = Vec2D::zero()
}

///|
pub fn add_score_bar() -> Unit {
  set_score(0)
  let entity = Entity::new()
  global_position[entity] = Vec2D::new(
    CANVAS_WIDTH / 2 - 200.0,
    CANVAS_HEIGHT * 0.10,
  )
  let sprite = Sprite::new_text(game_state.score_bar, 5)
  global_sprites[entity] = sprite
  let entity_2 = Entity::new()
  global_position[entity_2] = Vec2D::new(
    CANVAS_WIDTH / 2 - 120.0,
    CANVAS_HEIGHT * 0.30,
  )
  let entity_3 = Entity::new()
  global_position[entity_3] = Vec2D::new(
    CANVAS_WIDTH / 2 - 120.0,
    CANVAS_HEIGHT * 0.40,
  )
  let text = Text::new(
    "Pause A/D to move",
    font="30px ThaleahFat",
    color="Gray",
  )
  let text2 = Text::new(
    "Pause Q/E to switch",
    font="30px ThaleahFat",
    color="Gray",
  )
  let optional_sprite_2 = Sprite::new_text(text, 5)
  global_sprites[entity_2] = optional_sprite_2
  let optional_sprite_3 = Sprite::new_text(text2, 5)
  global_sprites[entity_3] = optional_sprite_3
}

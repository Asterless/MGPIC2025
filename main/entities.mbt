///|
pub fn game_start(_backend : &@system.Backend) -> Unit {
  add_pointer()
  for x = 0.0; x < CANVAS_WIDTH; x = x + 16.0 {
    add_bottom(@math.Vec2D::new(x, CANVAS_HEIGHT - 16.0))
  }
  for x = 0.0; x < CANVAS_HEIGHT; x = x + 16.0 * 3.0 {
    add_side_walls(@math.Vec2D::new(0, x))
    add_side_walls(@math.Vec2D::new(CANVAS_WIDTH - 16.0, x))
  }
  add_background()
  add_score_bar()
}

///|
pub fn add_pointer() -> Unit {
  @position.positions[game_state.pointer_entity] = @math.Vec2D::new(
    CANVAS_WIDTH / 2.0,
    80.0,
  )
  let velocity = @math.Vec2D::new(0.0, 0.0)
  @velocity.velocities[game_state.pointer_entity] = velocity
  @sprite.sprites[game_state.pointer_entity] = game_state.pointer_sprite
}

///|
pub fn add_bottom(pos : @math.Vec2D) -> Unit {
  let entity = @system.Entity::new()
  @position.positions[entity] = pos
  let animation = @sprite.Animation::new(
    "./assets/Terrain/Terrain (16x16).png",
    max_frame=1,
    height=16,
    width=16,
    offset=@math.Vec2D::new(16.0 * 7, 0.0),
  )
  let sprite = @sprite.Sprite::new_animation(animation, 20)
  @sprite.sprites[entity] = sprite
  let collide : @collision.Collide = @collision.Collide::{
    shape: @collision.CollisionShape::Rect(
      size=@math.Vec2D::new(16.0, 16.0),
      offset=@math.Vec2D::new(0.0, 0.0),
    ),
    layer: terrain_collision_layer,
    mask: @collision.CollisionMask::empty(),
  }
  @collision.collides[entity] = collide
}

///|
pub fn add_side_walls(pos : @math.Vec2D) -> Unit {
  let animation = @sprite.Animation::new(
    "./assets/Terrain/Terrain (16x16).png",
    max_frame=1,
    height=16 * 3,
    width=16,
    offset=@math.Vec2D::new(16.0 * 15, 0.0),
  )
  // Left Wall
  let wall = @system.Entity::new()
  @position.positions[wall] = pos
  let left_collide : @collision.Collide = @collision.Collide::{
    shape: @collision.CollisionShape::Rect(
      size=@math.Vec2D::new(16.0, 16.0),
      offset=@math.Vec2D::zero(),
    ),
    layer: terrain_collision_layer,
    mask: @collision.CollisionMask::new([pointer_collision_layer]),
  }
  @sprite.sprites[wall] = @sprite.Sprite::new_animation(animation, 5)
  @collision.collides[wall] = left_collide
}

///|
pub fn add_background() -> Unit {
  let entity = @system.Entity::new()
  let picture = @sprite.Picture::new(
    @math.Vec2D::new(CANVAS_WIDTH, CANVAS_HEIGHT),
    "./assets/Background/Brown.png",
    repeat=true,
  )
  let sprite = @sprite.Sprite::new_picture(picture, 0)
  @sprite.sprites[entity] = sprite
  @position.positions[entity] = @math.Vec2D::zero()
}

///|
pub fn add_score_bar() -> Unit {
  set_score(0)
  let entity = @system.Entity::new()
  @position.positions[entity] = @math.Vec2D::new(
    CANVAS_WIDTH / 2 - 200.0,
    CANVAS_HEIGHT * 0.10,
  )
  let sprite = @sprite.Sprite::new_text(game_state.score_bar, 5)
  @sprite.sprites[entity] = sprite
  let entity_2 = @system.Entity::new()
  @position.positions[entity_2] = @math.Vec2D::new(
    CANVAS_WIDTH / 2 - 120.0,
    CANVAS_HEIGHT * 0.30,
  )
  let entity_3 = @system.Entity::new()
  @position.positions[entity_3] = @math.Vec2D::new(
    CANVAS_WIDTH / 2 - 120.0,
    CANVAS_HEIGHT * 0.40,
  )
  let text = @sprite.Text::new(
    "Pause A/D to move",
    font="30px ThaleahFat",
    color="Gray",
  )
  let text2 = @sprite.Text::new(
    "Pause Q/E to switch",
    font="30px ThaleahFat",
    color="Gray",
  )
  let optional_sprite_2 = @sprite.Sprite::new_text(text, 5)
  @sprite.sprites[entity_2] = optional_sprite_2
  let optional_sprite_3 = @sprite.Sprite::new_text(text2, 5)
  @sprite.sprites[entity_3] = optional_sprite_3
}

///|
pub fn add_cat(position : @math.Vec2D, level : Int) -> Cat {
  let entity = @system.Entity::new()
  let data = get_level_data(level)
  let velocity = @velocity.Velocity(@math.Vec2D::zero())
  let picture = cat_picture(level)
  let cat_layer = get_cat_collision_layer(level)
  let collide : @collision.Collide = @collision.Collide::{
    shape: @collision.CollisionShape::Rect(
      size=@math.Vec2D::new(data.size, data.size),
      offset=@math.Vec2D::zero(),
    ),
    layer: cat_layer,
    mask: @collision.CollisionMask::new(cat_collision_mask_layers(level)),
  }
  let area : @collision.Area = @collision.Area::new(
    @collision.CollisionShape::Rect(
      size=@math.Vec2D::new(data.size * 1.2, data.size * 1.2),
      offset=@math.Vec2D::zero(),
    ),
    cat_layer,
    @collision.CollisionMask::new([cat_collision_layers[level - 1]]),
    monitoring_mouse=true,
  )
  let self_entity = entity
  area.on_enter(fn(other : @system.Entity) {
    // CRITICAL: Do not merge with yourself.
    if self_entity == other {
      return
    }
    game_state.to_merge.add((self_entity, other))
  })
  area.on_just_pressed(fn(_button : @system.MouseButton) {
    game_state.cats_clicked.add(self_entity)
  })
  let cat : Cat = { entity, level }
  cats_by_entity.set(entity, cat)
  @position.positions[entity] = position
  @velocity.velocities[entity] = velocity
  @collision.collides[entity] = collide
  @collision.areas[entity] = area
  @sprite.sprites[entity] = @sprite.Sprite::new_picture(picture, 10) //Zindex 10 to be above the pointer
  cat
}

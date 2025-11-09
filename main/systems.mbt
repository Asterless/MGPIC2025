///|
pub fn input_system(backend : &@system.Backend) -> Unit {
  let new_velocity = @velocity.velocities
    .get(game_state.pointer_entity)
    .unwrap()
  // Move pointer
  bind_key(KeyA, KeepPressed, () => ptr_move(Left))
  bind_key(KeyD, KeepPressed, () => ptr_move(Right))
  bind_keys([KeyA, KeyD], NotPressed, () => ptr_move(Stop))
  // Move Cats
  bind_key(KeyQ, Pressed, () => cat_move(Left))
  bind_key(KeyE, Pressed, () => cat_move(Right))
  if @system.is_just_pressed(@system.Code::Space) {
    // Start background music on first interaction
    if !game_state.background_music_started {
      backend.play_audio(
        "./assets/Sounds/background_music.wav",
        volume=0.2,
        loop_=true,
      )
      game_state.background_music_started = true
    }
    // Release cat
    let position = @position.positions[game_state.pointer_entity].0
    let _ = add_cat(position, game_state.next_cat_level)
    game_state.next_cat_level = random_cat_level()
    game_state.pointer_sprite = @sprite.Sprite::new_picture(
      cat_picture(game_state.next_cat_level),
      10,
    )
    backend.play_audio("./assets/sounds/jump.wav", volume=1.0, loop_=false)
  }
  @velocity.velocities[game_state.pointer_entity] = new_velocity
  let collide : Collide = Collide::{
    shape: CollisionShape::Rect(
      size=@math.Vec2D::new(32.0, 32.0),
      offset=@math.Vec2D::new(0.0, 0.0),
    ),
    layer: pointer_collision_layer,
    mask: CollisionMask::new([terrain_collision_layer]),
  }
  @sprite.sprites[game_state.pointer_entity] = game_state.pointer_sprite
  @collision.collides[game_state.pointer_entity] = collide
}

///|
pub fn merge_system(backend : &@system.Backend) -> Unit {
  let merged_this_frame = @hashset.HashSet::new() // Guard against multiple merges in one frame
  for pair in game_state.to_merge {
    let (cat1_entity, cat2_entity) = pair
    if merged_this_frame.contains(cat1_entity) ||
      merged_this_frame.contains(cat2_entity) {
      continue // if either cat has already been merged this frame, skip
    }
    let cat1_opt = cats_by_entity.get(cat1_entity)
    let cat2_opt = cats_by_entity.get(cat2_entity)
    if cat1_opt is Some(_) && cat2_opt is Some(_) {
      let cat1 = cat1_opt.unwrap()
      let cat2 = cat2_opt.unwrap()
      // Mark as merged
      merged_this_frame.add(cat1_entity)
      merged_this_frame.add(cat2_entity)
      // Get sound from config
      let sound_path = get_level_data(cat1.level + 1).sound
      // Perform merge
      cat1.merge(cat2)
      backend.play_audio(sound_path, volume=0.8, loop_=false)
    }
  }
  // Clear the merge list
  game_state.to_merge.clear()
}

///|
pub fn force_system(_backend : &@system.Backend) -> Unit {
  for pair in cats_by_entity {
    let (entity, _cat) = pair
    @velocity.velocities[entity].y += GRAVITY // Gravity
    @velocity.velocities[entity].x *= 1.0 - FRICTION // Friction
    if @velocity.velocities[entity].x < 0.01 &&
      @velocity.velocities[entity].x > -0.01 {
      @velocity.velocities[entity].x = 0.0
    }
  }
}

///|
fn play_sound_system(backend : &@system.Backend) -> Unit {
  for cat_entity in game_state.cats_clicked {
    let cat_opt = cats_by_entity.get(cat_entity)
    if cat_opt is Some(_) {
      let cat = cat_opt.unwrap()
      let sound_path = get_level_data(cat.level).sound
      backend.play_audio(sound_path, volume=1.0, loop_=false)
    }
  }
  game_state.cats_clicked.clear()
}

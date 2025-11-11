///|
pub fn bind_key(key : Code, trigger : Trigger, handler : () -> Unit) -> Unit {
  match trigger {
    Pressed => if is_just_pressed(key) { handler() }
    KeepPressed => if is_pressed(key) { handler() }
    NotPressed => if !is_pressed(key) { handler() }
  }
}

///|
pub fn bind_keys(
  keys : Array[Code],
  trigger : Trigger,
  handler : () -> Unit,
) -> Unit {
  let f = match trigger {
    KeepPressed => x => is_pressed(x)
    Pressed => x => is_just_pressed(x)
    NotPressed => x => !is_pressed(x)
  }
  let state = keys
    .map(x => f(x))
    .fold((acc, current) => acc && current, init=true)
  if state {
    handler()
  }
}

///|
pub fn ptr_move(move_state : MoveState) -> Unit {
  let v = global_velocity[ptr_entity]
  let p = global_position[ptr_entity]
  let ptr_size = 32.0 + game_state.next_cat_level.to_double() * 16.0
  let left_bound = 16.0
  let right_bound = CANVAS_WIDTH - 16.0 - ptr_size
  if p.x < left_bound {
    v.x = 0.0
    p.x = left_bound
  } else if p.x > right_bound {
    v.x = 0.0
    p.x = right_bound
  }
  match move_state {
    Stop => v.x = 0.0
    Left =>
      if p.x <= left_bound {
        v.x = 0.0
        p.x = left_bound
      } else if v.x > -PTR_MAX_VEC_H {
        v.x -= PTR_ACC_H
      }
    Right =>
      if p.x >= right_bound {
        v.x = 0.0
        p.x = right_bound
      } else if v.x < PTR_MAX_VEC_H {
        v.x += PTR_ACC_H
      }
  }
}

///|
pub fn cat_move(move_state : MoveState) -> Unit {
  cats_by_entity.each((e, c) => global_v[e].x = move_state.signum() *
    CAT_MOVE_FORCE /
    c.level.to_double())
}

///|
pub fn music_play(backend : &Backend) -> Unit {
  if !game_state.background_music_started {
    backend.play_audio(
      "./assets/Sounds/background_music.wav",
      volume=BACKGROUND_MUSIC_VOLUME,
      loop_=true,
    )
    game_state.background_music_started = true
  }
}

///|
pub fn cat_drop(backend : &Backend) -> Unit {
  let ptr_p = global_position[ptr_entity]
  let level = game_state.next_cat_level
  let _ = add_cat(ptr_p.0, level)
  game_state.next_cat_level = random_cat_level()
  let level = game_state.next_cat_level
  game_state.pointer_sprite = Sprite::new_picture(
    Cat::picture_by_level(level),
    10,
  )
  backend.play_audio("./assets/sounds/drop.wav", volume=1.0, loop_=false)
}

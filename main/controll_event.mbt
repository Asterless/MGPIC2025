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
  let state = keys.map(x => f(x)).fold((i, x) => i && x, init=true)
  if state {
    handler()
  }
}

///|
/// Pointer Horizontal Acceleration
const PTR_ACC_H : Double = 2.5

///|
/// Pointer Maximum Horizontal Speed
const PTR_MAX_VEC_H : Double = 7.5

///|
pub fn ptr_move(move_state : MoveState) -> Unit {
  let v = global_v.get(game_state.pointer_entity).unwrap()
  match move_state {
    Stop => v.x = 0.0
    Left => if v.x > -PTR_MAX_VEC_H { v.x -= PTR_ACC_H }
    Right => if v.x < PTR_MAX_VEC_H { v.x += PTR_ACC_H }
  }
}

///|
pub fn cat_move(move_state : MoveState) -> Unit {
  cats_by_entity.each((e, c) => global_v[e].x = move_state.signum() *
    4.0 /
    c.level.to_double())
}

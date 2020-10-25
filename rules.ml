type direction = Up | Right | Down | Left

type ball = {ballPos: Position.t; ballId: int}

type move = {movePos: Position.t; moveDir: direction}

type game = {ballList: ball list}

let ballIdAvailable = ref 0

(* automatic increment constructor *)
let make_ball p = incr ballIdAvailable; {ballPos = p; ballId = !ballIdAvailable - 1}

(* manual constructor in order to modify ball position without changing its color *)
let make_ball_with_id p id = {ballPos = p; ballId = id}

let new_game l = {ballList = l}

let position_of_ball b = b.ballPos

(* could also direcly use .ballPos but this isn't nice if change how ball position is stored another way *)
(* used to only check position but this involves color modification when using apply_move *)
let eq_ball b b' = b.ballId = b'.ballId

(* changed p for b because we are talking about a ball and not a position... *)
let make_move b d = {movePos = position_of_ball b; moveDir = d} 

(* given a position and a direction this function returns the next position *)
let next p d = let x = Position.proj_x p and y = Position.proj_y p in
    match d with
    | Up -> Position.from_int x (y + 1) (* let say that yBottom < yTop *)
    | Down -> Position.from_int x (y - 1)
    | Left -> Position.from_int (x - 1) y
    | Right -> Position.from_int (x + 1) y

let next move = next move.movePos move.moveDir

let contrary dir = let contraryDir = match dir with
    | Up -> Down
    | Left -> Right
    | Down -> Up
    | Right -> Left
    in contraryDir

let previous p d = next (make_move (make_ball p) (contrary d))

(* otherwise circular build *)
let is_out p = let x = Position.proj_x(*fst*) p and y = Position.proj_y(*snd*) p in
    (* should check if not +/- 1 *)
    x > (*Game.max_x*)15 || x < 0 || y > (*Game.max_y*)15 || y < 0

let get_balls g = g.ballList

let remove_ball game position =
    let rec aux ballList = match ballList with
    | t::q when Position.eq (position_of_ball t) position -> aux q
    | t::q -> t::(aux q)
    | _ -> []
    in new_game (aux (get_balls game))

let add_ball game position ballId =
    new_game ((make_ball_with_id position ballId)::(get_balls game))

(* like is_ball function here we don't return a boolean but the found element *)
let ball_of_position g p =
    let rec aux l = match l with
    | t::q when Position.eq (position_of_ball t) p -> t
    | t::q -> aux q
    | _ -> failwith "Function ball_of_position was designed to be called on a existing object" (* use is_ball before the use of this function if not sure of its use *)
    in aux (get_balls g)

let modify_ball game position newPosition =
    let ballId = (ball_of_position game position).ballId and currentGame = ref (remove_ball game position) in
        add_ball !currentGame newPosition ballId

(* check if there is a ball with same position as given in the game *)
let is_ball g p =
    let rec aux l = match l with
    | t::q when t.ballPos = p -> true
    | t::q -> aux q
    | _ -> false
    in aux (get_balls g) 

(* we are going to proceed one ball by one ball from an origin of the movement to the edge of the grid according to the good direction *)
let apply_move g move =
    let currentGame = ref g and initialPos = ref move.movePos and tmpPos = ref (next move) in
    while ((not ((*Game.*)(*AntiCircularBuild.*)is_out (!tmpPos)))) do
    (
        if is_ball !currentGame !tmpPos then
        (
            currentGame := modify_ball !currentGame !initialPos (previous !tmpPos move.moveDir);
            initialPos := !tmpPos;
        );
        tmpPos := (next (make_move (make_ball (!tmpPos)) move.moveDir));
    )
    done;
    currentGame := remove_ball !currentGame !initialPos;
    !currentGame

(* need to check before if we are working out of the grid *)
(* this function returns a boolean whether or not the ball b is in a given direction move.moveDir from a ball at move.movePos *)
let is_ball_in_view move b = let ballPos = position_of_ball b in
    let x = Position.proj_x ballPos and y = Position.proj_y ballPos and movePos = move.movePos in
    let mX = Position.proj_x movePos and mY = Position.proj_y movePos in
    match move.moveDir with
    | Up -> x = mX && y > mY
    | Down -> x = mX && y < mY
    | Right -> y = mY && x > mX
    | Left -> y = mY && x < mX

(* this function returns if a ball is reachable from the ball at move.movePos *)
let is_a_ball_in_view g move = List.exists (is_ball_in_view move) (get_balls g)

(* for a given move, check if there is a ball in the direction at least 2 slots from the origin of the move (cf 2.1 §2 "Deux boules côte à côte ne peuvent pas se lancer l'une l'autre") *)
let is_move_correct g move =
    let nextPos = next move in
    is_ball g move.movePos && not (is_ball g nextPos) && is_a_ball_in_view g {movePos = nextPos; moveDir = move.moveDir}

let is_move_correct_dir g b dir = is_move_correct g (make_move b dir)

(* returns a list of all possible direction for a given ball *)
let get_directions_correct g b =
    let l = ref [] in
    if is_move_correct_dir g b Up then
        l := Up::!l;
    if is_move_correct_dir g b Down then
        l := Down::!l;
    if is_move_correct_dir g b Left then
        l := Left::!l;
    if is_move_correct_dir g b Right then
        l := Right::!l;
    !l;;

(* returns a list of all possible moves for a given ball *)
let get_moves_correct g b =
    let l = get_directions_correct g b in
    let rec aux ll acc = match ll with
    | t::q -> aux q ((make_move b t)::acc)
    | _ -> acc
    in aux l [];;

(* given a ballList we retrieve all possible movements from them *)
let moves g =
    let rec aux ballList acc =
        match ballList with
        | t::q ->
                  let eDirs = get_moves_correct g t in
                    if eDirs <> [] then (aux q (eDirs@acc)) else aux q acc
        | _ -> acc
    in aux (get_balls g) []

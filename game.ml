module G = Graphics
module D = Draw

(* game is a reference to the initial game. *)
let game = ref (Rules.new_game [])

(* return the ball that the player wants to move *)
let rec get_ball game =
  let status = G.wait_next_event [G.Button_down] in
  let (x,y) = (status.G.mouse_x,status.G.mouse_y) in
  let p = D.position_of_coord x y in
  if Rules.is_ball game p then
    begin
      let ball = Rules.ball_of_position game p in
      D.draw_ball ~select:true ball; (* to show which ball has been selected *)
      ball
    end
  else
    get_ball game (* the player has selected an empty cell *)

(* convert the key pressed into a char and call the continuation k on it *)
let get_key_pressed k =
  let status = G.wait_next_event [G.Key_pressed] in
  let key = Char.code status.G.key in
  k (Char.chr key)

(* return the direction choosen by the player *)
let rec get_ball_direction () = (* why empty argument ? *)
  let dir_of_char c =
    Rules.(
      match c with
      | 'z' -> Some Up
      | 's' -> Some Down
      | 'd' -> Some Right
      | 'q' -> Some Left
      | _ -> None
    )
  in
  get_key_pressed (fun c -> match dir_of_char c with
      | Some (x) -> x
      | None -> get_ball_direction () (* wrong key pressed by the player *)
    )

(* get the next move of the player *)
let get_next_move game =
  let p = get_ball game in
  let d = get_ball_direction () in
  Rules.make_move p d

(* create_game allows the player to create its own game by putting balls over the grid *)
let create_game () =
  D.ready false;
  D.draw_game AntiCircularBuild.max_x AntiCircularBuild.max_y (Rules.new_game []);
  let rec add_balls l =
    let status = G.wait_next_event [G.Button_down; G.Key_pressed] in
    if status.G.keypressed = true && Char.chr (Char.code status.G.key) = 'e' then
      begin Draw.ready true; l end
    else
      let (x,y) = (status.G.mouse_x, status.G.mouse_y) in
      let p = D.position_of_coord x y in
      let (x',y') = Position.proj_x p, Position.proj_y p in
      (* balls can not be outside the grid *)
      if 0 <= x' && x' < AntiCircularBuild.max_x && 0 <= y' && y' < AntiCircularBuild.max_y then
        let ball = Rules.make_ball p in
        D.draw_ball ball;
        add_balls (ball::l)
      else
        add_balls l
  in
  let balls = add_balls [] in
  Rules.new_game balls

(* only Neven was enoughly deteminated to make a textfield with tabulation *)
let defaultTerrainFileName = "terrain.txt"

(* A menu is a pair of string * f where f is a function of type unit -> unit.
   If the player choose on the menu which function should be called *)
let rec menu = [("solve", solve); ("solve random", solveRandom); ("solve from file", solveFromFile); ("play", play); ("play random", playRandom); ("play from file", playFromFile); ("modify terrain.txt", modifyTerrain); ("exit", leave)]
(* it should be better to choose playground by option and not both in one *)

(* need ball ids and this function to be called in order to have color stability *)
and make_colors_stable game =
    D.colors := [];
    D.ready false;
    D.draw_game AntiCircularBuild.max_x AntiCircularBuild.max_y game;
    D.ready true;

(* play allows the player to create a new game, and then try to solve it *)
and play () =
  game := create_game ();
  loop !game

and playRandom () =
    game := Generator.generator_0 8;
    make_colors_stable !game;
    loop !game

and playFromFile () =
    game := File.opn defaultTerrainFileName;
    make_colors_stable !game;
    loop !game

(* solve allows the player to create a new game and then see if the game can be solved *)
and solve () =
  game := create_game ();
  solver !game;

and solveRandom () =
    game := Generator.generator_0 8; (* should make a user input for this *)
    make_colors_stable !game;
    solver !game;

and solveFromFile () =
    game := File.opn defaultTerrainFileName;
    make_colors_stable !game;
    solver !game;

and modifyTerrain () =
    game := create_game ();
    (* could also make a modification possibility but this needs to implement delete option *)
    File.save "terrain.txt" !game

(* loop game loops on the game while their is still moves possible for the player *)
and loop game =
  let currentGame = ref game and mvs = ref (Rules.moves game true) in
  while ((!mvs) <> []) do
  (
      D.draw_game AntiCircularBuild.max_x AntiCircularBuild.max_y !currentGame; (* required for terrain editing and various options like loading from file... *)
      let ball = get_ball (!currentGame) and dir = get_ball_direction () in
        let mv = (Rules.make_move ball dir) in
          if (List.mem mv (!mvs)) then (* here we check if the input move is correct *)
          (
              currentGame := (Rules.apply_move (!currentGame) mv);
              mvs := Rules.moves (!currentGame) true
          )
          else
          (
              mvs := Rules.moves (!currentGame) true
          );
          D.draw_game AntiCircularBuild.max_x AntiCircularBuild.max_y !currentGame
  )
  done;
  if (AntiCircularBuildRules.is_win !currentGame) then
      print_string "You win !"
  else
      print_string "You lose !";

(* solver game solve the game if it is possible *)
and solver game =
  D.draw_game AntiCircularBuild.max_x AntiCircularBuild.max_y game;
  let moves = Solver.solve game in
  match moves with
  | None -> D.draw_string "No solution!"; get_key_pressed (fun c -> main menu)
  | Some moves ->
    let g = List.fold_left (fun g m -> D.draw_game AntiCircularBuild.max_x AntiCircularBuild.max_y g ;
                             D.draw_string "Solved!";
                             get_key_pressed (fun c -> ());
                             Rules.apply_move g m) game moves
    in
    D.draw_game AntiCircularBuild.max_x AntiCircularBuild.max_y g;
    get_key_pressed (fun c -> main (("resolve", resolve)::menu))

(* replay the previous game *)
and replay () =
  loop !game

(* resolve the previous game *)
and resolve () =
  solver !game

(* leave the application *)
and leave () =
  D.close_window()

(* get the choice of the player *)
and main l =
  let choice c =
    let i = (int_of_char c) - (int_of_char '0') in
    if 0 <= i && i < List.length l then
      snd (List.nth l i) ()
    else
      main l
  in
  Random.self_init();
  D.init_window();
  D.draw_menu l;
get_key_pressed choice

let _ = main menu



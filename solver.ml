type gameMoves = {g: Rules.game; mvs: Rules.move list};;

(* for a given game instance and a list of n move possible we return a list of n games with a move of moveList applied *)
let configs_direct game moveList =
    let rec aux gameList mvs = match mvs with
    | move::q -> aux (({g = Rules.apply_move game move; mvs = [move]@moveList})::gameList) q
    | _ -> gameList
    in aux [] (Rules.moves game);;

let isWin game =
    List.length (Rules.get_balls game) <= 1

(* can't loop because at each iteration, a ball is removed in the game so let's explore all possibilities, so this function ends *)
(* this function is quite long when numerous balls on terrain, I haven't tried to optimize *)
(* we use a DFS here, from the original game, we compute all games reachable and if one is a winning one we stop the algorithm and returns it with moves required to reach it *)
let solve game =
    let allGames = ref [{ g = game; mvs = [] }] and winFound = ref false in
    while !allGames <> [] && not !winFound do
        (* could check if already have game as a win *)
        let currentGameData = List.hd !allGames in
        let currentGame = currentGameData.g in
        if isWin currentGame then
            winFound := true
        else
            allGames := (List.tl !allGames)@(configs_direct currentGame currentGameData.mvs)
    done;
    if !winFound then
        Some (List.hd !allGames).mvs
    else
    (
        print_string "No solution found !";
        None;
    )

(* assume that "rapide" is at least linear in ballList otherwise impossible to optimize if don't even know the data *)
(* checking not two balls one next to each other for instance (well this can happend normally if there are other balls) *)
(* a method to check if a game has clearly no solution is to check if a ball isn't in the smallest rectangle containing all other balls *)
let quick_solve game = ();


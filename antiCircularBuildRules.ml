(* a winning game is a game where there is only a single ball on the grid *)
let is_win game = List.length (Rules.get_balls game) <= 1

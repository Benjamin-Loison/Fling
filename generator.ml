(* assume that by saying "teste si la configuration est valide" this involves there is a solution *)

(* assume n <= max_y * max_x *)
(* the purpose of this function is defined in 5.1, question 3 of the subject *)
let generator_0 n =
    let rec aux i ballList =
        (
            if i = 0 then ballList
            else
            (
                let y = Random.int (*Game.max_y*)15 and x = Random.int (*Game.max_x*)15 in
                let pos = Position.from_int x y in
                if List.mem (Rules.make_ball pos) ballList then
                    aux i ballList
                else
                    aux (i - 1) ((Rules.make_ball pos)::ballList)
            )
        ) in let game = ref (aux n []) in
        while (Solver.solve (Rules.new_game !game)) = None do
            game := aux n [];
        done;
        Rules.new_game !game;;

let configs_direct_previous game =
    ()

(* this one seems slow if we take randomly any possible configuration but if we take the first one it is done in a quite constant time but this isn't the idea of the question I suppose *)
(*let generator_1 n = (* on préfère le récursif: faire des let rec au lieu de while ? *)
    let i = ref 1;
    let game = ref (generator_0 1);
    while (!i) < n do
        let games = configs_direct_previous !game;
        let gamesLen = List.length games;
        (*if gamesLen = 0 then failwith "generator_1 gamesLen = 0" else (); *)
        (* may gamesLen = 0 ?! *)
        incr i;
        game := List.nth games (Random.int gamesLen);
    done;
    !game*)



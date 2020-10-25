(* this function returns a char list for a given string *)
(* https://stackoverflow.com/questions/10068713/string-to-list-of-char *)
let string_to_list s =
    let l = ref [] in
    for i = 0 to String.length s - 1 do
        l := (!l)@[s.[i]]
    done;
    !l;;

(* for a given filename, this function returns a list of its lines as a char char list *)
(* taken from https://stackoverflow.com/questions/5774934/how-do-i-read-in-lines-from-a-text-file-in-ocaml *)
let get_file_content file =
    let lines = ref [] in
    let chan = open_in file in
    try
        while true; do
            lines := (string_to_list (input_line chan))::!lines
        done; !lines
    with End_of_file ->
        close_in chan;
        List.rev !lines;;

(* for a given line, this function returns the associated list of balls *)
let rec ballFromLine l x y ballList = match l with
| t::q when t = '1' -> ballFromLine q (x + 1) y ((Rules.make_ball (Position.from_int x y))::ballList)
| t::q when t = '0' -> ballFromLine q (x + 1) y ballList (* precise "when '0'" in order not to have troubles with possible "\n" or whatever *)
| _ -> ballList

(* this functions accumulates balls in ballList by subworking at each line with ballFromLine *)
let opn file = (* open is an OCaml keyword... *)
    let lines = get_file_content file in
    let rec auxLine l y ballList = match l with
    | t::q -> (auxLine q (y + 1) (ballFromLine t 0 y []))@ballList
    | _ -> ballList
    in Rules.new_game (auxLine lines 0 [])

(* this function write a given character in a given file stream *)
let write oc c = Printf.fprintf oc "%c" c

(* could also use kind of empty matrix save format, here don't save color because meaningless *)
(* this function opens a file stream, write at each slot of the grid if there is a ball and closes the file stream *)
let save file game =
    let oc = open_out file in 
    for y = 1 to (*Game.max_y*)15 do
        for x = 1 to (*Game.max_y*)15 do
            if Rules.is_ball game (Position.from_int x y) then
                write oc '1'
            else
                write oc '0'
        done;
        write oc '\n';
    done;
    close_out oc;


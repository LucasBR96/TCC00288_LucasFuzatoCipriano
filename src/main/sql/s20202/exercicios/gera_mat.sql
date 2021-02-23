
/*
create or replace function random_matriz( int , int , float , float ) returns float [][]
as $$
declare
    height alias for $1;
    width  alias for $2;
    mu     alias for $3;
    sigma  alias for $4;
    
    arr float [][];
    a float;
begin

    arr := array_fill( null :: float , array[ height , width ] );
    for x in 1..height loop
        for y in 1..width loop
            a := dbms_random.normal();
            a := a*sigma + mu;
            arr[ x ][ y ] := a;
        end loop;
    end loop;
    return arr;
end;
$$ language plpgsql;

--teste da função
do $$
declare 
    arr1 float [][] := random_matriz( 3 , 8 , 0. , 1. );
    arr2 float [][] := random_matriz( 4 , 6 , 2. , 5. );
    arr3 float [][] := random_matriz( 4 , 4 , 1. , 1. );
begin

    call show_arr( arr1 );
    call show_arr( arr2 );
    call show_arr( arr3 );
end$$
*/


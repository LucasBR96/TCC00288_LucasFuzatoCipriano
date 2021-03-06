DO $$ BEGIN

    PERFORM drop_functions();

    PERFORM drop_tables();

END $$;

create or replace function transpose_mat( mat float[][] ) returns float[][] as $$
declare    
    height int := array_length( mat , 1 );
    width  int := array_length( mat , 2 );
    arr float[][];
begin
    arr := array_fill( null :: float , array[ width , height ] );
    for x in 1..height loop
        for y in 1..width loop
            arr[ y ][ x ] := mat[ x ][ y ];
        end loop;
    end loop;
    return arr;
end;
$$ language plpgsql;

create or replace procedure exercicio7() as $$
declare
    /*
    arr1 float [][] := random_matriz( 3 , 8 , 0 , 1 );
    arr1 float [][] := random_matriz( 4 , 6 , 2 , 5 );
    arr1 float [][] := random_matriz( 4 , 4 , 1 , 1 );

    arr_t float [][];
    */

    arr1 float[][] := '{
    { 4, 1, 0, 5 },
    { 3, 6, 4, 3 },
    { 4, 6, 5, 1 },
    { 1, 7, 4, 1 },
    { 4, 2, 5, 1 },
    { 8, 6, 4, 8 }
    }';

    arr2 float[][] := '{
    {3 , .4 , 8 , 1 },
    {.2 , 5 , 9 , .3 },
    {8 , 7.3 , 10 , 1},
    {5 , 8 , 2.5 , 3 },
    { 4, 2, 5, 10. }
    }';

    arr_t float [][];
begin

    for i in 1..2 loop
        if i = 1 then
            arr_t := arr1;
        else
            arr_t := arr2;
        end if;

            raise notice 'Matriz original ----------------';
            call show_arr( arr_t );
            raise notice 'Matriz transposta --------------';
            call show_arr( transpose_mat( arr_t ) );

    end loop;

end;
$$ language plpgsql;

do $$ begin
    call exercicio7();
end$$;
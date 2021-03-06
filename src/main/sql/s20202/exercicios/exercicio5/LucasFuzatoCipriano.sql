DO $$ BEGIN

    PERFORM drop_functions();

    PERFORM drop_tables();

END $$;

create or replace function contar_alvo( mat float[][], target float ) returns int as $$
-- Essa função tem como objetivo achar, em uma matriz, a linha ou coluna com o maior nú-
-- -mero de ocorrências de um valor desejado. se o valor for positivo é linha e negativo coluna
declare
    row_spots int[] := array_fill( 0 , array[array_length( mat , 1 )] );
    
    col_spots int[] := array_fill( 0 , array[array_length( mat , 2 )] );

    max_row int := -1;
    max_col int := -1;

    arg_row int := 0;
    arg_col int := 0;

begin
    
    for i in 1..array_length( mat , 1  ) loop
        for j in 1..array_length( mat , 2 ) loop
            if mat[ i ][ j ] = target then
                row_spots[ i ] := row_spots[ i ] + 1;
                col_spots[ j ] := col_spots[ j ] + 1;
            end if;
        end loop;
    end loop;

    for i in 1..array_length( mat , 1  ) loop
        if row_spots[ i ] > max_row then
            max_row := row_spots[ i ];
            arg_row := i;
        end if;
    end loop;

    for j in 1..array_length( mat , 2  ) loop
        if col_spots[ j ] > max_col then
            max_col := col_spots[ j ];
            arg_col := j;
        end if;
    end loop;

    if max_col > max_row then
        return -arg_col;
    else
        return arg_row;
    end if;
end;
$$ language plpgsql;

create or replace function determinante( mat float[][] ) returns float as $$
declare
    x int := array_length( mat , 1 );
    y int := array_length( mat , 2 );

    pos int;
    ver bool;
    det float;
    a float;
    mat_prime float[][];
    i int;
    j int;
begin

    --casos triviais
    if x != y then
        raise notice 'matriz não é quadrada';
        return -1;
    elsif x = 2 then
        return mat[1][1]*mat[2][2] - mat[2][1]*mat[1][2];
    elsif x = 1 then
        return mat[1][1];
    end if;

    -- caso geral
    -- a função contar alvo é chamada para que o programa faça o menor numero de recursões 
    -- possível. 
    det := 0::float;
    pos := contar_alvo( mat , 0::float );
    ver := ( pos < 0 );
    for k in 1..x loop

        if ver then
            i := k;
            j := -pos;
        else
            i := pos;
            j := k;
        end if;
        continue when mat[ i ][ j ] = 0;

        a := mat[ i ][ j ];
        mat_prime := excluir_linha_e_col( mat , i , j );
        call show_arr( mat_prime );
        det := det + a*power( -1 , i + j )*determinante( mat_prime );
    end loop;
    return det;
end;
$$ language plpgsql;

create or replace procedure exercicio5() as $$
declare


    Arr1 float[][] := '{
        { 1, 8, 9, -1 },
        { 0, 5, 7, 6 },
        { 0, 3, 5, -1 },
        { 2, 0 , 3, 2}
        }';

/*

    Arr1 float[][] := '{
        { 1, 8},
        { 3, 5}
        }';
*/

    Arr2 float[][] := '{
        {0, 8, 2, 5, 6},
        {0, 8, 5, 7, 6},
        {0, 2, -1, 5, 3},
        {0, 1, 0, 7, 6},
        {0, 1, 1, 5, 2}
        }';

    Arr3 float[][] := '{
        { 0, 5, 7, 6 },
        { 0, 3, 5, -1 },
        { 2, 0 , 3, 2}
        }';

    det float;
    pos int;
begin

--    raise notice '% %', array_length( Arr3 , 1 ), array_length( Arr3 , 2 ); 

    raise notice 'Arr1: ----------------';
    call show_arr( Arr1 );
    det := determinante( Arr1 );
    raise notice 'determinate = %' , det;
    raise notice '';
    
    raise notice 'Arr2: ----------------';
    call show_arr( Arr2 );
    det := determinante( Arr2 );
    raise notice 'determinate = %' , det;
    raise notice '';

    raise notice 'Arr3: ----------------';
    call show_arr( Arr3 );
    det := determinante( Arr3 );
    raise notice 'determinate = %' , det;


  
end;
$$ language plpgsql;

do $$ begin
    call exercicio5();
end$$;
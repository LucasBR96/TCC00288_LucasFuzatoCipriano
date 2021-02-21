create or replace function excluir_linha_e_col( mat float[][] , i int, j int ) returns float[][] as $$
declare
    height int := array_length( mat , 1 );
    width int  := array_length( mat , 2 );

    L float[];
    arr float[][];

begin

    L = '{}';
    for x in 1..height loop
        continue when x = i;
        for y in 1..width loop
            continue when y = j;
            L := array_append( L , mat[ x ][ y ])
        end loop;
    end loop;

    arr := array_fill( null :: float , array[ height - 1 , width - 1 ] );
    for x in 1..( height - 1 ) loop
        for y in 1..(width - 1 ) loop
            arr[ x ][ y ] := L[ ( x - 1 )*width + y ];
        end loop;
    end loop;

    return arr;
end;
$$ language plpgsql;

create or replace procedure show_arr( m float[][] ) as $$
declare
    x float [];
begin
    raise notice '';
    foreach x slice 1 in array m loop
        raise notice '%', x;
    end loop;
    raise notice '';
end;
$$ language plpgsql;

create or replace procedure exercicio4() as $$
declare
    Ar_ex4 float[][] := '{
    { 4, 1, 0, 5 },
    { 3, 6, 4, 3 },
    { 4, 6, 5, 1 },
    { 1, 7, 4, 1 },
    { 4, 2, 5, 1 },
    { 8, 6, 4, 8 }
    }';


    Arr_prime float[][];
begin
    raise notice 'Antes de remover';
    raise notice '--------------------------';
    call show_arr( Ar_ex4 );

    for i in 1..5 loop
        for j in 1..4 loop
            Arr_prime := excluir_linha_e_col( Ar_ex4 , i , j );
            raise notice 'Depois de remover % %', i , j;
            raise notice '--------------------------';
            call show_arr( Arr_prime );
        end loop;
    end loop;

end;
$$ language plpgsql;

do $$
declare
    a int[] := '{1,2,3}'; 
    b int [][];
begin
    call exercicio4();
/*
    raise notice '%', a;
    raise notice '%', array[ a ];
    raise notice '%', array_cat( b , array[a] );
*/
end$$;
        
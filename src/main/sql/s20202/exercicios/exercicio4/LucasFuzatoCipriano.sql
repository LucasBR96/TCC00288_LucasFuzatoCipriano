create or replace function excluir_linha_e_col( mat numeric[][] , i int, j int ) returns numeric[][] as $$
declare
    x int := array_length( mat , 2 );
    y int := array_length( mat , 1 );
    Arr numeric[][];
    L numeric[];
    
begin
    
-- Achatando a matriz original enquanto remove a linha e coluna desejadas
    L := '{}';
    for a in 1..y loop
        continue when a = i;
        for b in 1..x loop
            continue when b = j;
            L := array_append( L , mat[a][b] );
        end loop;
    end loop;
    --raise notice '%' , L;

-- "Enrolando" em uma nova matriz   
    Arr := array_fill( null :: numeric , array[ y - 1 , x - 1 ] );
    for a in 1..( y - 1 ) loop
        for b in 1..( x - 1 ) loop
            Arr[ a ][ b ] := L[ ( a - 1 )*( x - 1 ) + b ];
        end loop;
    end loop;

    return Arr;
end;
$$ language plpgsql;

create or replace procedure show_arr( m numeric[][] ) as $$
declare
    x numeric [];
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
    Ar_ex4 numeric[][] := '{
    { 4, 1, 0, 5 },
    { 3, 6, 4, 3 },
    { 4, 6, 5, 1 },
    { 1, 7, 4, 1 },
    { 4, 2, 5, 1 },
    { 8, 6, 4, 8 }
    }';

    i int := 2;
    j int := 3;

    Arr_prime numeric[][];
begin
    raise notice 'Antes de remover';
    raise notice '--------------------------';
    call show_arr( Ar_ex4 );

    Arr_prime := excluir_linha_e_col( Ar_ex4 , i , j );
    raise notice 'Depois de remover';
    raise notice '--------------------------';
    call show_arr( Arr_prime );

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
        
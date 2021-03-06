DO $$ BEGIN

    PERFORM drop_functions();

    PERFORM drop_tables();

END $$;

create or replace function operar_matriz( mat float[][] , m int , n int, k1 float , k2 float)
returns float [][] as $$
declare
    width  int := array_length( mat , 2 );
    height int := array_length( mat , 1 );
    arr float[][] := array_fill( null :: float , array[ height , width ] );

    a float;
    b float;

begin
    for i in 1..height loop

        if i = m then
            a := k1;
            b := k2;
        else
            a := 1::float;
            b := 0::float;
        end if;

        for j in 1..width loop
            arr[ i ][ j ] := a*mat[ i ][ j ] + b*mat[ n ][ j ];
        end loop;
    end loop;

    return arr;

end;
$$ language plpgsql;

create or replace procedure exercicio6() as $$
declare
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

    m int[] := '{ 1 , 3 , 5 ,4 , 2 }';
    n int[] := '{ 2 , 5 , 2 ,1 , 3 }';
    k1 float[] := '{ .3 , 1.6 , .7 , 2 , 4.5 }';
    k2 float[] := '{ .417 , 1.1 , .5 , 1.02 , 3.1 }';
begin
    raise notice 'Array original----------';
    call show_arr( arr1 );
    for i in 1..5 loop
        raise notice 'Arr[%] -> %Arr[%] + %Arr[%]',m[i] ,k1[i] , m[i] , k2[i] , n[i];
        call show_arr( operar_matriz( arr1 , m[i] , n[i] , k1[i] , k2[i] ) );
    end loop;

    raise notice 'Array original----------';
    call show_arr( arr2 );
    for i in 1..5 loop
        raise notice 'Arr[%] -> %Arr[%] + %Arr[%]', m[i] ,k1[i] , m[i] , k2[i] , n[i];
        call show_arr( operar_matriz( arr2 , m[i] , n[i] , k1[i] , k2[i] ) );
    end loop;
end;
$$ language plpgsql;

do $$ begin
    call exercicio6();
end$$;
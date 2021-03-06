DO $$ BEGIN

    PERFORM drop_functions();

    PERFORM drop_tables();

END $$;

create or replace procedure fib_lst( int ) as $$
declare
    n alias for $1;
    a int := 0;
    b int := 1;
    aux int;
begin

    if n < 0 then
        raise notice 'Não existe fibonacci para inteiros negativos';
    else
        raise notice 'fibonnaci de 0 até % --------------', n;
        for i in 0..n loop
            raise notice '%: %', i , a;

            aux := a;
            a := b;
            b := b + aux;
        end loop;
        raise notice '';
    end if;
end;
$$ language plpgsql;

create or replace procedure exercicio8() as $$
declare
    arr int[] := '{ 8 , 1 , 3 , 5 , 10, 12 , -1}';
    x int;
begin
    foreach x in array arr loop
        call fib_lst( x );
    end loop;
end;
$$ language plpgsql;

do $$ begin
    call exercicio8();
end $$;
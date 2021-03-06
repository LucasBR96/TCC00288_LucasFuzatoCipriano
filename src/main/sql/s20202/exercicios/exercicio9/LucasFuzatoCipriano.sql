-- INCOMPLETA
DO $$ BEGIN

    PERFORM drop_functions();

    PERFORM drop_tables();

END $$;

create or replace function area_med( varchar(20) ) returns float as $$
declare
    nome_pais alias for $1;
    result alias for $0;
    type coluna_area is table of float;
    col coluna_area;

    n int;
    a int;
begin
    begin
        select area into col from estado 
        where origem in(
            select cod from pais
            where cod = nome_pais;
        )order by area;
    end;

    n := col.count;
    

end;
$$ language plpgsql;
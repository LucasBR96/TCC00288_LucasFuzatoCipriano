-- Aqui Ficara o Script
DO $$ BEGIN

    PERFORM drop_functions();

    PERFORM drop_tables();

END $$;

-- Aqui fica a Multiplicacao
CREATE FUNCTION mult( float [][] , int , int, float [][], int , int ) 
RETURNS float[][] AS $$
DECLARE

    A ALIAS FOR $1;
    x ALIAS FOR $2;
    y ALIAS FOR $3; -- Colunas de A

    B ALIAS FOR $4;
    w ALIAS FOR $5; -- Linhas de B
    z ALIAS FOR $6;
    
    RES float[][];
BEGIN

--     IF y != w THEN
--         raise VALUE_ERROR;
--     END IF;
    
    RES := array_fill(null::float, array[x,z]);
    FOR i IN 1..x LOOP 
      FOR j IN 1..z loop
        RES[i][j] := 0;
        FOR k IN 1..y loop
          RES[i][j] := RES[ i ][ j ] + A[ i ][ k ]*B[ k ][ j ];
        end loop;
      end loop;
    end loop;
    Return RES;
END;
$$ LANGUAGE plpgsql;

create FUNCTION show( Mat float[][] , x int , y int ) RETURNS void AS $$
declare
    n float;
begin
    for i in 1..x Loop
        for j in 1..y Loop
            n := Mat[i][j];
            raise notice 'MAT at % % = %', i , j , n;
        end loop;
    end loop;
    raise notice '';
end;
$$ LANGUAGE plpgsql;

create FUNCTION MAIN_SCRIPT() RETURNS int AS $$
DECLARE
    ARR1 float[3][3] := '{
      {1.,4.,8.},
      {.3,.1,.6},
      {.8,1.1,1.3}
    }';

    ARR2 float[ 2 ][ 3 ] :='{
      {.8,.1,.7},
      {1.,3.,2.}
      }';
    
    ARR3 float[][];  

BEGIN
    
    raise notice 'Arr1-----------------------------------';
    PERFORM show( ARR1 , 3 , 3 );

    raise notice 'Arr2-----------------------------------';
    PERFORM show( ARR2 , 2 , 3 );
    
    raise notice 'Arr3-----------------------------------';
    ARR3 := Mult( ARR2 , 2 , 3 , ARR1 , 3 , 3 );
    PERFORM Show( ARR3 , 2 , 3 );
    Return 0;
END;
$$ LANGUAGE plpgsql;

DO $$ BEGIN
    PERFORM MAIN_SCRIPT();
END $$;
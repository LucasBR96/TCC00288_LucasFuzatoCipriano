/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Lucas
 * Created: 27 de fev. de 2021
 */

drop table if exists foo cascade;
create table foo(
    x int,
    y int,
    nome varchar( 10 )
);

insert into foo values
    ( 14, 14, 'axiaghdx' ),
    ( -1, 16, 'nxqfpbuo' ),
    ( 8, 11, 'gxdvvdzk' ),
    ( -10, -6, 'hjkcbnpi' ),
    ( 3, 7, 'igkhnntd' ),
    ( 4, 15, 'mmkpfbjo' ),
    ( -10, 11, 'unbqrten' ),
    ( 2, 15, 'fyxiydyw' ),
    ( 1, 7, 'kzdllhpc' ),
    ( -9, 17, 'lllguszt' ),
    ( 0, 4, 'yutasaid' ),
    ( -9, 18, 'ngwnqfhl' ),
    ( 5, 15, 'gtqforen' ),
    ( -4, 0, 'cgrdbrvr' ),
    ( -9, -4, 'eiqrmrwz' ),
    ( -3, 2, 'nziulpvi' ),
    ( -10, 3, 'raskgyjd' ),
    ( -7, -4, 'vdbwnqyp' ),
    ( 14, 16, 'ocooirlu' ),
    ( -6, 14, 'khnnymlw' ),
    ( 4, 5, 'jxnbdpjb' ),
    ( 5, 15, 'xetfohzu' ),
    ( -5, -4, 'vgntywuu' ),
    ( 4, 14, 'xztozfgt' ),
    ( -2, 0, 'objdiapv' ),
    ( -9, 7, 'wypqjlop' ),
    ( 11, 16, 'sriwgche' ),
    ( -9, -8, 'dnnxhfmm' ),
    ( 16, 17, 'csmzngsr' ),
    ( -4, 9, 'noekvfsc' ),
    ( 7, 17, 'difromjg' ),
    ( -4, 8, 'aulcucar' ),
    ( -6, 8, 'asfhkjrs' ),
    ( -5, 19, 'nkbvpohc' ),
    ( 5, 19, 'epxenrch' ),
    ( -9, -5, 'cygrtpzh' ),
    ( -7, 17, 'lynbqxpp' ),
    ( 4, 17, 'nhsqspde' ),
    ( -6, -3, 'yqxrfvib' ),
    ( 6, 16, 'iuakagci' ),
    ( -6, 0, 'dphiajua' ),
    ( -7, 15, 'wvvnenel' ),
    ( -1, 12, 'elnvbanp' ),
    ( 7, 19, 'yfodurar' ),
    ( 7, 13, 'lmuftdvx' ),
    ( -4, 2, 'vgyqbtie' ),
    ( -6, -4, 'wwsxtijk' ),
    ( -3, 7, 'aikdlije' ),
    ( -5, 11, 'hytmtefy' ),
    ( 2, 18, 'cdxbwvms' );

create or replace function acha_centro( int ) returns setof foo as $$
begin
    return query
    select * from foo 
    where foo.x < $1 and $1 < foo.y;

    return;
end;
$$ language plpgsql;

create or replace function range_of_foo() returns table( nome text, range int) as $$
begin
    return query
    select foo.nome::text , y - x from foo;
    return;
end;
$$ language plpgsql;

--create or replace function conflict_() returns table( f1 text , f2 text, con_s int, con_e int ) as $$
--begin
--    return query
    --- bla bla bla
--    return;
--end;
--$$ language plpgsql;

--select * from acha_centro( 5 );
--select * from range_of_foo( );

do $$
declare
    curs1 refcursor;
    rec record;
begin
    open curs1 for select * from foo;
    loop
        fetch curs1 into rec;
        exit when not found;
        raise notice '% , % , %', rec.nome , rec.x, rec.y;
    end loop;
end;
$$ language plpgsql



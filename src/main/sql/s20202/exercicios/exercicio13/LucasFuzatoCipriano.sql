-- INCOMPLETA
/*
create or replace function classfc( nome_cmp text ) returns
table( time_pr text , pontos int ,vitorias int ) as $$
begin
    return query
    with jogos as (
        select numero, time1, time2, gols1, gols2 from partida
        where partida.campeonato in(
            select codigo from campeonato
            where campeonato.nome = nome_cmp
        )
    )
    ,vitorias as(
        select foo.time_pr as "tim_" , sum( foo.num_vt ):: int as "ct_vt" from(
            select numero , time1 as "time_pr" , 1 as "num_vt"
            from jogos where jogos.gols1 > jogos.gols2
            union select numero , time1 as "time_pr" , 0 as "num_vt"
            from jogos where jogos.gols1 <= jogos.gols2
            union select numero , time2 as "time_pr" , 1 as "num_vt"
            from jogos where jogos.gols1 < jogos.gols2 
            union select numero , time2 as "time_pr" , 0 as "num_vt"
            from jogos where jogos.gols1 >= jogos.gols2
        ) as foo
        group by foo.time_pr
    )   
    ,empates as(
        select foo.time_pr as "tim_" , sum( foo.num_dr):: int as "ct_emp" from(
            select numero , time1 as "time_pr" , 1 as "num_dr"
            from jogos where jogos.gols1 = jogos.gols2
            union select numero , time1 as "time_pr" , 0 as "num_dr"
            from jogos where jogos.gols1 != jogos.gols2
            union select numero , time2 as "time_pr" , 1 as "num_dr"
            from jogos where jogos.gols1 = jogos.gols2 
            union select numero , time2 as "time_pr" , 0 as "num_dr"
            from jogos where jogos.gols1 != jogos_cmp.gols_2
        ) as foo
        group by foo.time_pr
    )
    select * from( 
        select time_pr, ( 3*ct_vt + ct_emp ):: int as "pontos", ct_vt :: int as "vitorias"
        from  vitorias natural join empates
    ) as foo
    order by foo.pontos , foo.vitorias desc;
end;
$$ language plpgsql;
*/

create or replace function classfc( nome_cmp text ) returns 
table( time_pr text , pontos int ,vitorias int )
as $$
begin
    return query
    with
    jogos_cmp as(
        select
            numero as "num",
            time1 as "par_1",
            gols1 as "gols_1",
            time2 as "par_2",
            gols2 as "gols_2"
        from partida
        where partida.campeonato in(
            select codigo from campeonato
            where campeonato.nome = nome_cmp
        )
    )
    ,vitorias as(
        select
            foo.time_pr as "tim_",
            sum( foo.num_vt ):: int as "ct_vt"
        from(
            select numero , par_1 as "time_pr" , 1 as "num_vt"
            from jogos_cmp where jogos_cmp.gols_1 > jogos_cmp.gols_2
            union select numero , par_1 as "time_pr" , 0 as "num_vt"
            from jogos_cmp where jogos_cmp.gols_1 <= jogos_cmp.gols_2
            union select numero , par_2 as "time_pr" , 1 as "num_vt"
            from jogos_cmp where jogos_cmp.gols_1 < jogos_cmp.gols_2 
            union select numero , par_2 as "time_pr" , 0 as "num_vt"
            from jogos_cmp where jogos_cmp.gols_1 >= jogos_cmp.gols_2
            ) as foo
        group by "tim_"
    )
    ,empates as(
        select
            foo.time_pr as "tim_",
            sum( foo.numdr ):: int as "ct_emp"
        from(
            select numero , par_1 as "time_pr" , 1 as "num_dr"
            from jogos_cmp where jogos_cmp.gols_1 = jogos_cmp.gols_2
            union select numero , par_1 as "time_pr" , 0 as "num_dr"
            from jogos_cmp where jogos_cmp.gols_1 != jogos_cmp.gols_2
            union select numero , par_2 as "time_pr" , 1 as "num_dr"
            from jogos_cmp where jogos_cmp.gols_1 = jogos_cmp.gols_2 
            union select numero , par_2 as "time_pr" , 0 as "num_dr"
            from jogos_cmp where jogos_cmp.gols_1 != jogos_cmp.gols_2
            ) as foo
        group by "tim_"
    )
    select
        time_pr,
        ( 3*ct_vt + ct_emp ):: int as "pontos",
        ct_vt :: int as "vitorias"
    from
        vitorias natural join empates
    order by pontos , vitorias desc;
    return;
end;
$$ language plpgsql;
   

create or replace procedure exercicio13() as $$
declare
    nome text := 'Carioca'; 
begin
    perform classfc( nome );
end;
$$ language plpgsql;

do $$ begin
    call exercicio13();
end $$;
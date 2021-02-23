-- INCOMPLETA

create or replace procedure exercicio13() as $$
declare

    -- tipos a serem usados -------------------------------
    type rec1 is record(
        num_part int,
        time_1 text,
        gols_1 int,
        time_2 text,
        gols_2 int
    );
    type filtradas_por_campeonato is table of rec1
    
    type rec2 is record(
        time_n text,
        vitorias int,
        empates int
    );
    type performace is table of rec2;

    -- funcoes auxiliares --------------------------------

    create or replace function filtrar ( text ) returns filtradas_por_campeonato is
    declare
        nome_camp alias for $1;
        partidas_filtradas alias for $0;
    begin
        select numero , time1 , gols1 , time2 , gols2
        into partidas_filtradas from partida
        where partida.campeonato in(
            select campeonato.codigo from campeonato
            where campeonato.nome = nome_camp 
        );
        return partidas_filtradas;
    end;
begin

end;
$$language plpgsql

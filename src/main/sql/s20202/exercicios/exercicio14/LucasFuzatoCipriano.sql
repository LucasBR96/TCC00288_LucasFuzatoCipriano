create or replace function lig_médias( date , date ) returns
table ( cidade text , bairro text , dur_med float ) as $$
declare
    t_inicial alias for $1;
    t_final alias for $2;
begin
    
    return query
    with
    tab1 as(
        select
            ligacao_id,
            antena_orig,
            antena_dest,
            duracao
        from ligacao where
            t_inicial <= dia
            and
            dia <= t_final
    )
    ,tab2 as(
        select
            ligacao,
            antena_orig as "ant_num",
            duracao
        from tab1
        union
        select
            ligacao,
            antena_dest as "ant_num",
            duracao
        from tab1
    )
    ,tab3_a as(
        select
            antena_id,
            nome as "bairro_nome"
        from
            antena inner join bairro on antena.bairro_id = bairro.bairro_id
    )
    ,tab3_b as(
        select
            antena_id,
            nome as "cidade_nome"
        from
            antena inner join cidade on antena.cidade_id = cidade.cidade_id
    )
    ,tab3 as(
        select *
        from tab3_a natural join tab3_b
    )
    ,tab4 as(
        select
            cidade_nome,
            bairro_nome,
            duracao
        from
            tab3 inner join tab2 on tab3.antena_id = tab2.antena_num
    )
    select
        cidade_nome as "cidade",
        bairro_nome as "bairro",
        avg ( duracao ) as "dur_med"
    from
        tab4
    group by ( cidade_nome , bairro_nome )
    order by dur_med;
    return
end;
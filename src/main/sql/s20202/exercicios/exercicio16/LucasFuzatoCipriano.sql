DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

create table produto(
    nome text not null,
    id bigint not null,

    constraint produto_pk primary key ( id )
);

create table venda(
    dia timestamp not null,
    prod bigint not null,
    quantidade int not null,

    constraint venda_pk primary key ( dia , produto ),
    constraint venda_fk foreign key ( prod )
    references produto( id )
);

---------------inserçoes
---------------programa

create or replace function best_sellers( timestamp , timestamp ) returns 
table( mes month, ano year , text ) as $$
declare
    d1 alias for $1;
    d2 alias for $2;
begin
    return query
    with
    dias_de_venda as(
        select 
            dia,
            extract( month from dia) as "mes",
            extract( year from dia ) as "ano"
        from vendas
        where
            d1 <= vendas.dia
            and d2 >= vendas.dia
    )
    ,vendas_mensais as(
        select
            prod,
            mes,
            ano,
            sum( quantidade ) as "total"
        from
            dias_de_venda inner join vendas
            on dias_de_venda.dia = venda.dia
        group by ( prod, mes , ano )
    )
    ,medias_mensais as(
        select
            mes,
            ano,
            mean( total ) as "v_med"
        from vendas_mensais
        group by ( mes , ano )
    )
    ,best_1 as( 
        select
            prod,
            mes,
            ano
        from 
            vendas_mensais inner join medias_mensais
            on vendas_mensais.total > 1.6*medias_mensais.v_med
        order by ano , mes;
    )
    select
        mes,
        ano,
        nome
    from
        best_1 inner join produto
        on best1.prod = produto.id
    return;
end;
$$ language plpgsql;




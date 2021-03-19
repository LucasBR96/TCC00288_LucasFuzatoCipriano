do $$ begin
    PERFORM drop_functions();
    PERFORM drop_tables();
end $$;

create table venda(
    id  int       not null,
    dia timestamp not null,

    constraint venda_pk primary key ( id )
);

create table produto(
    id      int  not null,
    nome    text not null,
    preco   int  not null,
    estoque int  not null,
    minimo  int  not null,
    maximo  int  not null,

    constraint produto_pk primary key ( id )
);

create table venda_item(
    id      int not null,
    item    int not null,
    produto int not null,
    qtd     int not null,

    constraint item_pk primary key ( id , item ),
    --constraint item_fk1 foreign key ( id )
    --references venda( id ),
    constraint item_fk2 foreign key ( produto )
    references produto( id )
);

create table ordem_reposicao(
    produto int not null,
    qtd     int not null,

    constraint ordem_fk foreign key ( produto )
    references produto( id )
);
-----------------------------------------------------------------

insert into produto values
    ( 0 , 'A', 100, 50 , 10 , 100 ),
    ( 1 , 'B', 130, 100, 20 , 150 ),
    ( 2 , 'C', 100, 20 , 10 , 90 );

-----funcoes-----------------------------------------------------

create or replace function insere_from_item() returns trigger as $$
declare
    reg record;
begin
    select * into reg from venda  where venda.id = new.id;
    if not found then
        insert into venda values ( new.id , now() );
        return new;
    end if;
    return null;
end;
$$ language plpgsql;

create trigger venda
after insert on venda_item
for each row execute procedure insere_from_item();

create or replace function atualiza_estoque_after_venda() returns trigger as $$
declare
    reg record;
    qtd int;
begin
    qtd := new.qtd;
    select * into reg from produto where produto.id = new.produto;
    raise notice '%', found;
    if found then
        update produto
        set estoque = estoque - qtd
        where id = reg.id;

        return new;
    end if;
    return null;
end;
$$ language plpgsql;

create trigger produto_trg
after insert on venda_item
for each row execute procedure atualiza_estoque_after_venda();


create or replace function ordem_repo() returns trigger as $$
declare
    reg record;
begin 
    if new.estoque < new.minimo then
        insert into ordem_reposicao values( new.id, new.maximo - new.estoque );
    end if;
    return new;
    return null;
end;
$$ language plpgsql;

create trigger reposicoes_trg
after update on produto
for each row execute procedure ordem_repo();

---Teste-------------------------------------------------------------

insert into venda_item values
    ( 0 , 1 , 1, 10 ),
    ( 0 , 2 , 1, 3 ),
    ( 1 , 0 , 1, 3 ),
    ( 1 , 1 , 0 , 45);

select * from venda;
select * from produto;
select * from ordem_reposicao;
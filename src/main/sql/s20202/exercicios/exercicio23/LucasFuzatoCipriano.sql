do $$ begin
    PERFORM drop_functions();
    PERFORM drop_tables();
end $$;

-- Tabelas -------------------------------------------------------
create table restaurante(
    cnpj int primary key
);

create table prato(
    id int primary key
);

create table menu(
    rest_num int not null,
    prato_num int not null,
    preco numeric not null
    default 0,

    constraint menu_fk1 foreign key ( rest_num )
    references restaurante( cnpj ),

    constraint menu_fk2 foreign key ( prato_num )
    references prato( id ),

    constraint menu_pk primary key ( rest_num , prato_num )
);

create table pedido( 
    numero int not null,
    rest int not null,

    constraint pedido_fk1 foreign key ( rest )
    references restaurante( cnpj ),

    constraint pedido_pk primary key ( numero )
);

create table pedido_item(
    id int not null,
    ped_id int not null,
    prato_id int not null,
    restaurante_id int not null,
    qtd int not null
    default 1,

    constraint item_pk primary key ( id , ped_id )

    -- constraint item_fk1 foreign key ( ped_id )
    -- references pedido( numero ),

    -- constraint item_fk2 foreign key ( restaurante_id , prato_id )
    -- references menu( rest_num, prato_num )
);

-- Funcoes --------------------------------------------------------------

create or replace function coerencia_com_restaurante( int , int ) returns boolean as $$
declare
    restaurante_id alias for $1;
    ped_id alias for $2;

    rec record;
begin

    select * into rec from pedido
    where numero = ped_id;
    
    if found then 
        return ( rec.rest = restaurante_id );
    else
        insert into pedido values ( ped_id , restaurante_id );
        return true;
    end if;
end; 
$$ language plpgsql;

create or replace function coerencia_com_prato( int , int ) returns boolean as $$
declare
    restaurante_id alias for $1;
    prato_id alias for $2;

    i record;
begin

    select * into i from menu
    where
        menu.prato_num = prato_id
        and menu.rest_num = restaurante_id;

    return found; 

end; 
$$ language plpgsql;

create or replace function manter_consistencia( ) returns trigger as $$
declare
    a boolean;
    b boolean;

begin

    a := coerencia_com_restaurante( new.restaurante_id , new.ped_id );
    b := coerencia_com_prato( new.restaurante_id , new.prato_id );

    if not ( a and b ) then
        delete from pedido_item
        where
            id = new.id and
            ped_id = new.ped_id;
    end if;

    return null;

end;
$$ language plpgsql;

-- Triggers -------------------------------------------------------
create trigger consistent_trigger
    after insert on pedido_item
    -- referencing new table as new_tab
    -- for each statement execute function manter_consistencia();
    for each row execute function manter_consistencia();

-- Testes ----------------------------------------------------------

insert into restaurante values ( 1 ) , ( 2 ) , ( 3 );
insert into prato values ( 1 ) , ( 2 ) , ( 3 ) , ( 4 );
insert into menu( rest_num , prato_num ) values
    ( 1 , 1 ),
    ( 1 , 2 ),
    ( 2 , 1 ),
    ( 2 , 3 ),
    ( 3 , 1 ),
    ( 3 , 2 ),
    ( 3 , 3 ),
    ( 3 , 4 );

-- insert into pedido( numero , rest ) values ( 1 , 1 );
insert into pedido_item( ped_id , id , prato_id , restaurante_id ) values
    ( 1 , 1 , 1 , 1 ),
    ( 1 , 2 , 2 , 1 ),
    ( 1 , 3 , 3 , 1 ),
    ( 1 , 4 , 2 , 2 );

-- insert into pedido( numero , rest ) values ( 2 , 3 );
insert into pedido_item( ped_id , id , prato_id , restaurante_id ) values
    ( 2 , 1 , 1 , 3 ),
    ( 2 , 2 , 2 , 3 ),
    ( 2 , 3 , 3 , 3 ),
    ( 2 , 4 , 3 , 2 );

-- insert into pedido( numero , rest ) values ( 3 , 2 );
insert into pedido_item( ped_id , id , prato_id , restaurante_id ) values
    ( 3 , 1 , 1 , 2 ),
    ( 3 , 2 , 2 , 2 ),
    ( 3 , 3 , 3 , 3 );

select * from pedido;
select * from pedido_item;
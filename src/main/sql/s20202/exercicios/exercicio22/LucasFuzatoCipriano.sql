do $$ begin
    PERFORM drop_functions();
    PERFORM drop_tables();
end $$;

create table cliente(
    id int primary key,
    nome text not null
);

create table conta_corrente(
    start timestamp not null
    default now(),
    fim timestamp default null,
    id int primary key
);

create table correntista(
    id_cliente int not null,
    id_conta int not null,

    constraint correntista_fk1 foreign key ( id_cliente )
    references cliente( id ),

    constraint correntista_fk2 foreign key ( id_conta )
    references conta_corrente( id )
);

create table limite_credito(
    conta_id int 
    references conta_corrente( id ),

    valor int not null,
    inicio timestamp not null
    default now(),
    fim timestamp
);

create table movimento(

    valor_mov int not null,
    dia timestamp not null
    default now(),
    conta_id int references conta_corrente( id ),

    primary key ( conta_id , dia )
);


--Insercoes---------------------------------------------

insert into cliente values
    ( 0 , 'Joao' ),
    ( 1 , 'Pedro' ),
    ( 2 , 'Maria' ),
    ( 3, 'Carlos' );

insert into conta_corrente( id ) values
    ( 1 ),
    ( 2 ),
    ( 3 );

insert into correntista values
    ( 0, 1 ),
    ( 1, 2 ),
    ( 2, 3 ),
    ( 3, 3 );

insert into conta_corrente( id , start , fim ) values
    ( 4,
    '01/01/2000' :: timestamp,
    '01/01/2005' :: timestamp 
    );

insert into limite_credito( conta_id , valor ) values
    ( 1, 1000),
    ( 2, 1000),
    ( 3, 1000);

--Funcoes-----------------------------------------------

create or replace function obstruir_mov() returns trigger as $$
declare
    dia_num timestamp;
    conta_num int;
    delta_v int;
    saldo int;

    valido bool;
    limite_c int;
    saldo_c int;
begin

    dia_num = date_trunc( 'hour' , new.dia  );
    conta_num = new.conta_id;
    delta_v = new.valor_mov;

    create temporary table if not exists saldo_diario(
        dia timestamp,
        conta_id int,
        saldo int
    );

    select
        fim = null 
    into valido
    from conta_corrente
    where id = conta_num;

    if valido then

        select
            valor
        into
            limite_c
        from
            limite_credito
        where
            conta_id = conta_num and
            fim = null;
        if not found then
            limite_c = 0;
        end if;

        select
            saldo
        into
            saldo_c
        from
            saldo_diario
        where
            conta_id = conta_num and
            dia = dia_num;
        if not found then
            saldo_c = 0;
            insert into saldo_diario values ( dia_num , conta_num , saldo_c );
        end if;
    end if;

    if saldo_c + delta_v < -limite_c then 
        delete from movimento
        where dia = new.dia and conta_id = new.conta_id ;
    else
        update saldo_diario
        set saldo = saldo_c + delta_v
        where
            conta_id = conta_num and
            dia = dia_num;
    end if;

    
    return null;
end;
$$ language plpgsql;

/*
create or replace obstruir_mov() returns trigger as $$
declare
    dia_num int;
    conta_num int;
    delta_v int;
begin

    create temporary table saldos_diarios


end;
$$ language plspsql;
*/

--Triggers----------------------------------------------

create trigger obstruir
after insert on movimento
for each row perform procedure obstruir_mov();
-- for each satement perform obstruir_mov()
--Testes------------------------------------------------

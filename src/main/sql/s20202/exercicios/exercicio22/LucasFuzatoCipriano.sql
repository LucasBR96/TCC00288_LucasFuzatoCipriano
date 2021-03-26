do $$ begin
    PERFORM drop_functions();
    PERFORM drop_tables();
end $$;

create table cliente(
    id int primary key,
    nome text not null
);

create table conta_corrente(
    comeco timestamp not null
    default now(),
    fechada timestamp default null,
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
    fechada timestamp
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

insert into conta_corrente( id , comeco , fechada ) values
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
end;

--Triggers----------------------------------------------

create trigger obstruir
after insert on movimento
for each row execute procedure obstruir_mov();
-- for each satement perform obstruir_mov()
--Testes------------------------------------------------

insert into movimento values
    ( 100 , now() , 1 ),
    ( 100 , now() , 2 ),
    ( -5000, now() , 3 );

select * from movimento;
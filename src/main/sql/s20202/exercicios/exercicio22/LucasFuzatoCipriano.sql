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
    fechada timestamp default null
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
    ( 3, 100);

--Funcoes-----------------------------------------------

create or replace procedure atualizar_tab_saldos( int , timestamp , int ) as $$
declare
begin

    update saldo_hist
    set saldo = $3
    where 
        dia = date_trunc( 'day' , $2 )
        and conta_id = $1;
    
    if not found then

        insert into saldo_hist( saldo , dia , conta_id ) values
        ( $3 , date_trunc( 'day' , $2 ) , $1 );
    
    end if;
end;
$$ language plpgsql;

create or replace function buscar_limite( int ) returns int as $$
declare
   
    conta_id_mov alias for $1;
    limite int;
 
begin

    select valor 
    into limite
    from limite_credito
    where
        conta_id = conta_id_mov
        and fechada is null;
    if not found then
        limite := 0;
    end if;

    return limite;
end;
$$ language plpgsql;

create or replace function buscar_saldo( int , timestamp ) returns int as
$$
declare
   
    conta_id_mov alias for $1;
    dia_mov alias for $2;
    
    saldo_mov int;
 
begin

    select saldo 
    into saldo_mov
    from saldo_hist
    where
        conta_id = conta_id_mov
        and dia = date_trunc( 'day' , dia_mov );
    if not found then
        saldo_mov := 0;
    end if;

    return saldo_mov;
end;
$$ language plpgsql;

create or replace function verifica_se_ativa( int ) returns int as $$
declare
    num int;
    conta_id alias for $1;
begin

    select count( * ) 
    into num
    from conta_corrente
    where
        id = conta_id
        and fechada is null;
    
    return num;
end;
$$ language plpgsql;

create or replace function obstruir_mov() returns trigger as $$
declare
    dia_mov timestamp;
    conta_id int;

    conta_ativa int;
    saldo int;
    limite int;
begin
    
    -- tabela temporaria ---------------------------------------
    create temporary table if not exists saldo_hist(
        conta_id int,
        dia timestamp,
        saldo int
    );
    ------------------------------------------------------------


    conta_ativa := verifica_se_ativa( new.conta_id );
    saldo  := buscar_saldo( new.conta_id , new.dia );
    limite := buscar_limite( new.conta_id );

    raise notice '%', ( conta_ativa != 0 );
    raise notice '%', saldo;
    raise notice '%', limite;

    saldo := saldo + new.valor_mov;
    if ( saldo > -limite ) and ( conta_ativa != 0 ) then
        call atualizar_tab_saldos( new.conta_id , new.dia, saldo );
        return new;
    else
        delete from movimento
        where
            valor_mov = new.valor_mov
            and dia = new.dia
            and movimento.conta_id = new.conta_id; 
    end if;
    return null;

end;
$$ language plpgsql;

--Triggers----------------------------------------------

create trigger obstruir
after insert on movimento
for each row execute procedure obstruir_mov();
--for each satement perform obstruir_mov();
--Testes------------------------------------------------

insert into movimento values
    ( 100 , now() , 1 ),
    ( 100 , now() , 2 ),
    ( 100 , now() , 3 ),
    ( -100 ,  now() + 1*interval '1second' , 1 ),
    ( -100 ,  now() + 2*interval '1second' , 1 ),
    ( -100 ,  now() + 3*interval '1second' , 2 ),
    ( 100 ,   now() + 1*interval '1second' , 3 ),
    ( -1500 , now() + 1*interval '1second' , 2 );

-- select * from saldo_hist;

select * from movimento;
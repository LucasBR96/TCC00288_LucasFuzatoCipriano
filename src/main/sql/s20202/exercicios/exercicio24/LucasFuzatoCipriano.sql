do $$ begin
    PERFORM drop_functions();
    PERFORM drop_tables();
end $$;

create table hotel(
    id int primary key,
    nome text not null
);

insert into hotel values
    ( 1 , 'a' ),
    ( 2 , 'b' );

create table quarto(
    numero int not null,
    hotel_id int not null,

    constraint quarto_pk primary key ( numero , hotel_id ),

    constraint quarto_fk foreign key ( hotel_id )
    references hotel( id )
);

insert into quarto( hotel_id , numero ) values
    ( 1 , 1 ),
    ( 1 , 2 ),
    ( 1 , 3 ),
    ( 2 , 1 ),
    ( 2 , 2 ),
    ( 2 , 3 );

create table reserva(
    numero int not null,
    hotel_id int not null,
    quarto_num int not null,

    reservista int not null,
    inicio timestamp not null,
    fim timestamp not null
);

create table motivo_termino(
    id int primary key,
    nome text not null
);

insert into motivo_termino values
    ( 1 , 'atraso' ),
    ( 2 , 'cancelamento remoto' ),
    ( 3 , 'check out');

create table reserva_terminada(
    numero int not null,
    hotel_id int not null,
    quarto_num int not null,

    reservista int not null,
    inicio timestamp not null,
    fim_previsto timestamp not null,
    fim_real timestamp not null,

    motivo int not null,

    constraint termino_fk foreign key ( motivo )
    references motivo_termino( id )
);

create table estadia(
    numero int not null,
    reservista int not null,
    inicio timestamp not null,
    fim timestamp
);

-- funcoes auxiliares ---------------------------------------------

create or replace function quarto_existe( int , int ) returns boolean as $$
declare
    cont int;
begin
    select count( * )::int
    into cont
    from quarto
    where
        numero = $1 and
        hotel_id = $2;
    
    return not( cont = 0 );
end;
$$ language plpgsql;

create or replace function ja_reservado( int , int , timestamp , timestamp ) returns boolean as $$
declare
    cont int;
begin

    with 
    reservas_quarto as(
        select
            inicio,
            fim
        from reserva
        where
            quarto_num = $1
            and hotel_id = $2
    )
    select count( * )::int
    into cont
    from reservas_quarto
    where
        ( reservas_quarto.inicio <= $3 
        and $3 <= reservas_quarto.fim ) or
        ( reservas_quarto.inicio <= $4 
        and $4 <= reservas_quarto.fim );
    if cont is null then cont := 0; end if;
    return not ( cont = 0 );
    
end;
$$ language plpgsql;

create or replace procedure achar_motivo( int ) as $$
declare
    mot int;
    msg text;
begin
    select motivo into mot
    from reserva_terminada
    where numero = $1;

    if mot is null then
        raise notice 'Essa reserva não existe';
    elsif mot = 1 then
        raise notice 'Cliente atrasado';
    elsif mot = 2 then
        raise notice 'Reserva cancelada';
    elsif mot = 3 then
        raise notice 'Reserva terminada';
    end if;

end;      
$$ language plpgsql;

create or replace procedure eliminar_atrasos( timestamp ) as $$
declare
    mot int;
    msg text;
begin
    with tabela_1 as( 
        select
        numero,
        inicio + 1*interval '1day' as "prazo_chegada"
        from reserva
    ), tabela_2 as (
        select numero
        from estadia
    ), tabela_3 as (
        select * from tabela_1 
        where 
        numero not in ( select numero from tabela_2 )
        and $1 >= prazo_chegada
    )
    delete from reserva 
    where numero in( select numero from tabela_3 );
    
end;      
$$ language plpgsql;

-- funcoes dos triggers -------------------------------------------
create or replace function analisar_reserva( ) returns trigger as $$
declare

    a boolean;
    b boolean;

begin

    a := not quarto_existe( new.quarto_num , new.hotel_id );
    if a then
        raise notice 'Quarto ou hotel inexistente';
        return null;
    end if;

    b := ja_reservado( new.quarto_num , new.hotel_id , new.inicio , new.fim );
    --raise notice '%', b;
    if b then
        raise notice 'Esse quarto ja esta reservado para esse periodo';
        return null;
    end if;

    raise notice 'Reserva Confirmada';
    return new;
end;
$$ language plpgsql;

create function analise_checkin( ) returns trigger as $$
declare
    rec record;
begin

    select * into rec
    from reserva
    where numero = new.numero;

    if rec is null then
        raise notice 'check in obstruido';
        call achar_motivo( rec.numero );
        return null;
    elsif rec.reservista <> new.reservista then
        raise notice 'identificação não bate';
        return null;
    end if;
    
    raise notice 'Check in confirmado';
    return new;
end;
$$ language plpgsql;

create or replace function analise_checkout() returns trigger as $$
declare
    rec record;
begin
    select * into rec
    from reserva where
    numero = old.numero;

    if rec is null then
        raise notice 'essa reserva não existe!';
        return null;
    end if;

    delete from reserva where
    numero = old.numero;
    raise notice 'Checkout feito com sucesso';

    insert into reserva_terminada values
    (
        rec.numero,
        rec.hotel_id,
        rec.quarto_num,
        rec.reservista,
        rec.inicio,
        rec.fim,
        now()::timestamp,
        3
    );

    return old; 
end;
$$ language plpgsql;

create function liberar_reserva() returns trigger as $$
declare
    rec record;
begin
    select * into rec from estadia where numero = old.numero;
    if found then
        raise notice 'Essa reserva não pode ser desfeita, pois esta ligada a uma estadia ativa';
        return null;
    end if;
    return old;
end;
$$ language plpgsql;

-- tiggers -------------------------------------------

create trigger trigger_1
before insert on reserva
for each row execute function analisar_reserva();

create trigger trigger_2
before insert on estadia
for each row execute function analise_checkin();

create trigger trigger_3
after delete on estadia
for each row execute function analise_checkout();

create trigger trigger_4
before delete on reserva
for each row execute function liberar_reserva();
-- testes --------------------------------------------

insert into reserva( numero, reservista, hotel_id, quarto_num, inicio, fim ) values
    ( 1 , 1 , 1 , 1 , '01/01/2018'::timestamp , '07/01/2018'::timestamp ),
    ( 2 , 2 , 1 , 1 , '02/01/2018'::timestamp , '05/01/2018'::timestamp ),
    ( 3 , 3 , 1 , 2 , '10/01/2018'::timestamp , '12/01/2018'::timestamp ),
    ( 4 , 4 , 2 , 2 , '01/01/2018'::timestamp , '07/01/2018'::timestamp ),
    ( 5 , 5 , 1 , 3 , '01/01/2018'::timestamp , '07/01/2018'::timestamp );

select * from reserva;

-- call eliminar_atrasos( '02/01/2018'::timestamp );

insert into estadia( numero , reservista, inicio ) values
    ( 4 , 4 , '01/01/2018'::timestamp ),
    ( 5 , 5 , '01/01/2018'::timestamp ),
    ( 3 , 2 , '02/01/2018'::timestamp ),
    ( 2 , 2 , '02/01/2018'::timestamp ),
    ( 1 , 1 , '02/01/2018'::timestamp );

select * from estadia;

delete from estadia where numero = 5;
delete from estadia where numero = 4;
delete from estadia where numero = 6;

select * from reserva_terminada;
DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

create table cliente(
    nome text not null,
    cpf integer not null,

    constraint cliente_pk primary key ( cpf )
);

create table conta(
    agencia integer not null,
    numero integer not null,
    cliente integer not null,
    saldo real not null default 0,

    constraint conta_pk primary key ( agencia , numero ),
    constraint conta_fk foreign key ( cliente )
    references cliente( cpf )
);

create table movimentacao(
    agencia integer not null,
    conta integer not null,
    /*
    data_hora timestamp not null
    default current_timestamp,
    */
    valor real not null,
    index int not null,

    -- constraint mov_pk primary key
    -- ( conta ,agencia, data_hora ),

    constraint mov_pk primary key
    ( conta ,agencia, index ),

    constraint mov_fk foreign key
    ( conta , agencia ) 
    references conta( numero , agencia  )

);

-------------------- Inserções aqui ---------------------

insert into cliente values
    ( 'Pedro'  ,  0 ),
    ( 'Paulo'  ,  1 ),
    ( 'Marcos' ,  2 );

insert into conta( agencia , numero , cliente ) values
    ( 1 , 0 , 0 ),
    ( 1 , 1 , 0 ),
    ( 2 , 1 , 1 ),
    ( 2 , 2 , 2 ),
    ( 3 , 2 , 1 ),
    ( 3 , 1 , 2 );

insert into movimentacao( agencia , conta , valor , index ) values
    ( 1 , 0 ,  300 :: real , 1 ),
    ( 1 , 0 , -200 :: real , 2 ),
    ( 1 , 1 ,  100 :: real , 3 ),
    ( 1 , 1 ,  150 :: real , 4 ),
    ( 1 , 1 ,  -50 :: real , 5 ),
    ( 2 , 1 ,  100 :: real , 6 ),
    ( 2 , 1 ,  -30 :: real , 7 ),
    ( 2 , 2 , -150 :: real , 8 ),
    ( 2 , 2 ,  100 :: real , 9 ),
    ( 3 , 2 ,  100 :: real , 10),
    ( 3 , 1 , -200 :: real , 11);

---------------------Funçoes aqui----------------------

create or replace function compila_mov( ) returns 
table( agencia_comp int , conta_comp int , saldo real ) as $$
begin
    return query
    select
        agencia,
        conta,
        sum( valor ) :: real
    from movimentacao
    group by ( agencia , conta );
    return;
end;
$$ language plpgsql;

create or replace procedure atualiza_saldo() as $$
declare
    curs1 refcursor;
    -- curs2 refcursor;
    rec record;
begin
    open curs1 for 
        select * from compila_mov()
        order by agencia_comp , conta_comp ;

    loop
        fetch curs1 into rec;
        exit when not found;

        update conta
        set
            saldo = saldo + rec.saldo
        where
            agencia = rec.agencia_comp
            and
            numero  = rec.conta_comp;
    end loop;
end;
$$ language plpgsql;


do $$ begin
    call atualiza_saldo();
end$$;


select * from conta;


--select * from compila_mov();
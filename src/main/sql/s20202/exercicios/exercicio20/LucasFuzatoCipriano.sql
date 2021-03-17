do $$ begin
    PERFORM drop_functions();
    PERFORM drop_tables();
end $$;

create table empregado(
    nome    text  not null,
    salario int   not null
);

create table emp_alter(
    operacao text       not null,
    stamp    timestamp  not null,
    user_id  text       not null,

    nome     text       not null,
    sal      int        not null,
    old_sal  int    default null         -- Usado somente em updates

);

create or replace function processa_alter() returns trigger as $$
begin
    if ( tg_op = 'DELETE' ) then
/*
        delete from empregado where empregado.nome = old.nome;
        if not found then
            return null;
        end if;
*/

        insert into emp_alter( 
            operacao, 
            stamp, 
            user_id, 
            nome, 
            sal
        )values(
            'D',
            now(),
            user,
            old.nome,
            old.salario
        );
        return old;

    elsif ( tg_op = 'UPDATE' ) then

/*
        update empregado
        set
            salario = new.salario
        where nome = old.nome;

        if not found then
            return null;
        end if;
*/

        insert into emp_alter values(
            'U',
            now(),
            user,
            old.nome,
            new.salario,
            old.salario
        );
        return new;
    
    elsif ( tg_op = 'INSERT' ) then

        --insert into empregado values( new.nome, new.salario );

        insert into emp_alter values(
            'I',
            now(),
            user,
            new.nome,
            new.salario
        );
        return new;
    end if;
    return null;
end;
$$ language plpgsql;

create trigger emp_alter
after insert or delete or update on empregado
for each row execute procedure processa_alter();

--------------------------------------------------------------------------------------

insert into empregado values
    ( 'pedro'  , 1000 ),
    ( 'joao'   , 1500 ),
    ( 'carlos' , 8000 );

update empregado
set
    salario = 2000
where nome = 'joao';

delete from 
    empregado
where nome = 'pedro';

select * from emp_alter;
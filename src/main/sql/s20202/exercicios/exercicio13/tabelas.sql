drop table if exists campeonato cascade;
create table campeonato(
    codigo text not null,
    nome text not null,
    ano integer not null,
    constraint campeonato_pk primary key ( codigo )
);
insert into campeonato values( '001' , 'Carioca' , 2015 );

drop table if exists time_ cascade;
create table time_(
    sigla text not null,
    nome text not null,
    constraint time_pk primary key ( sigla )
);
insert into time_ values( 'FLA' , 'Flamengo' );
insert into time_ values( 'BOT' , 'Botafogo' );
insert into time_ values( 'VAS' , 'Vasco' );
insert into time_ values( 'FLU' , 'Fluminense' );
insert into time_ values( 'MAD' , 'Madureira' );
insert into time_ values( 'OLA' , 'Olaria' );

drop table if exists partida cascade;
create table partida(
    campeonato text not null,
    numero integer NOT NULL,
    time1 text NOT NULL,
    time2 text NOT NULL,
    gols1 integer not null,
    gols2 integer not null,
    data_ date not null,
    CONSTRAINT partida_pk PRIMARY KEY
    (campeonato,numero),
    CONSTRAINT partida_campeonato_fk FOREIGN KEY
    (campeonato) REFERENCES campeonato
    (codigo),
    CONSTRAINT jogo_time_fk1 FOREIGN KEY
    (time1) REFERENCES time_ (sigla),
    CONSTRAINT jogo_time_fk2 FOREIGN KEY
    (time2) REFERENCES time_ (sigla)
);

insert into partida values    
    ( '001', 0,  'FLA', 'VAS', 2, 1, '01/01/2015'::date ),
    ( '001', 1,  'FLA', 'BOT', 1, 3, '01/01/2015'::date ),
    ( '001', 2,  'FLA', 'FLU', 4, 1, '01/01/2015'::date ),
    ( '001', 3,  'FLA', 'OLA', 3, 2, '01/01/2015'::date ),
    ( '001', 4,  'FLA', 'MAD', 0, 2, '01/01/2015'::date ),
    ( '001', 5,  'VAS', 'BOT', 1, 1, '01/01/2015'::date ),
    ( '001', 6,  'VAS', 'FLU', 0, 4, '01/01/2015'::date ),
    ( '001', 7,  'VAS', 'OLA', 4, 4, '01/01/2015'::date ),
    ( '001', 8,  'VAS', 'MAD', 0, 2, '01/01/2015'::date ),
    ( '001', 9,  'BOT', 'FLU', 4, 2, '01/01/2015'::date ),
    ( '001', 10, 'BOT', 'OLA', 1, 3, '01/01/2015'::date ),
    ( '001', 11, 'BOT', 'MAD', 0, 0, '01/01/2015'::date ),
    ( '001', 12, 'FLU', 'OLA', 4, 0, '01/01/2015'::date ),
    ( '001', 13, 'FLU', 'MAD', 0, 1, '01/01/2015'::date ),
    ( '001', 14, 'OLA', 'MAD', 3, 1, '01/01/2015'::date );

with partidas_filtradas as(
    select numero, time1, time2, gols1, gols2 from partida
    where partida.campeonato in(
        select codigo from campeonato
        where campeonato.nome = 'Carioca'
    )
)
,vitorias_time as ( 
    select time1 as "time", 
    count( numero ) as "vitorias" 
    from(
        select numero, time1 from partidas_filtradas
        where partidas_filtradas.gols1 > partidas_filtradas.gols2
        union
        select numero, time2 from partidas_filtradas
        where partidas_filtradas.gols2 > partidas_filtradas.gols1
    ) as foo group by time1
)
,sem vitorias as(
    
)
,empates as(
    select time1 , time2 , numero from partidas_filtradas
    where gols1 = gols2 
)
,empates_time as(
    select time1 as "time",
    count( numero ) as "empates" 
    from(
        select time1 , numero from empates
        union
        select time2 , numero from empates
    ) as foo group by time1
)
select * from vitorias_time natural join empates_time;

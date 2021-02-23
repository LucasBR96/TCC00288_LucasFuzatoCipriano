create table pais( 
    nome varchar( 20 ),
    cod  char( 4 ) primary key 
);

insert into pais values( 'Brasil' , 'cg48');
insert into pais values( 'Estados unidos' , 'pp38');
insert into pais values( 'Alemanha' , 'h124');
insert into pais values( 'França' , 'vd24');


create table estado(
    origem char( 4 ) references pais( cod ) ,
    nome varchar( 20 ),
    area float -- km²    
);

insert into estado values ( 'cg48', 'Amazonas'	            ,1559167 );
insert into estado values ( 'cg48', 'Pará'                  ,1245870 );
insert into estado values ( 'cg48', 'Mato Grosso'           ,903207);
insert into estado values ( 'cg48', 'Minas Gerais'	        ,586521);
insert into estado values ( 'cg48', 'Bahia' 	            ,564760);
insert into estado values ( 'cg48', 'Mato Grosso do Sul'    ,357145);
insert into estado values ( 'cg48', 'Goiás'	                ,340203);
insert into estado values ( 'cg48', 'Maranhão'	            ,329642);
insert into estado values ( 'cg48', 'Rio Grande do Sul'	    ,281707);
insert into estado values ( 'cg48', 'Tocantins'	            ,277466);
insert into estado values ( 'cg48', 'Piauí'	                ,251756);
insert into estado values ( 'cg48', 'São Paulo'	            ,248219);
insert into estado values ( 'cg48', 'Rondônia'	            ,237765);
insert into estado values ( 'cg48', 'Roraima'	            ,223644);
insert into estado values ( 'cg48', 'Paraná'	            ,199298);
insert into estado values ( 'cg48', 'Acre'	                ,164123);
insert into estado values ( 'cg48', 'Ceará'	                ,148894);
insert into estado values ( 'cg48', 'Amapá'	                ,142470);
insert into estado values ( 'cg48', 'Pernambuco'	        ,98067);
insert into estado values ( 'cg48', 'Santa Catarina'	    ,95730);
insert into estado values ( 'cg48', 'Paraíba'	            ,56467);
insert into estado values ( 'cg48', 'Rio Grande do Norte'	,52809);
insert into estado values ( 'cg48', 'Espírito Santo'	    ,46074);
insert into estado values ( 'cg48', 'Rio de Janeiro'	    ,43750);
insert into estado values ( 'cg48', 'Alagoas'	            ,27843);
insert into estado values ( 'cg48', 'Sergipe'	            ,21925);
insert into estado values ( 'cg48', 'Distrito Federal'	    ,5760);

insert into estado values ( 'h124', 'Bavaria'                   ,70542.03 );
insert into estado values ( 'h124', 'Lower Saxony'              ,47709.83 );
insert into estado values ( 'h124', 'Baden-Württemberg'         ,35673.71 );
insert into estado values ( 'h124', 'North Rhine-Westphalia'	,34112.74 );
insert into estado values ( 'h124', 'Brandenburg'               ,29654.38 );
insert into estado values ( 'h124', 'Mecklenburg-Vorpommern'	,23292.73 );
insert into estado values ( 'h124', 'Hesse'	                    ,21115.67 );
insert into estado values ( 'h124', 'Saxony-Anhalt'	            ,20452.14 );
insert into estado values ( 'h124', 'Rhineland-Palatinate'      ,19858.00 );
insert into estado values ( 'h124', 'Saxony'	                ,18449.99 );
insert into estado values ( 'h124', 'Thuringia'	                ,16202.37 );
insert into estado values ( 'h124', 'Schleswig-Holstein'        ,15802.27 );
insert into estado values ( 'h124', 'Saarland'	                ,2571.10  );
insert into estado values ( 'h124', 'Berlin'	                ,891.12   );
insert into estado values ( 'h124', 'Hamburg'	                ,755.09   );
insert into estado values ( 'h124', 'Bremen'                    ,419.84   );


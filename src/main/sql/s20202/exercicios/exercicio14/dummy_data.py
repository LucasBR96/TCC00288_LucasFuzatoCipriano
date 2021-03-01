import itertools
import random
import string
import datetime
import time

def gerar_tuplas_1( n , tam_nome ):

    res = []
    for i in range( n ):
        nome = ''.join( random.choices( string.ascii_lowercase , k = tam_nome ) )
        nome = "'" + nome + "'"
        res.append( ( str(i) , nome ) )
    random.shuffle( res )

    with open( "dummy.txt" , 'a' ) as f:
        for  k , ( i , nome ) in enumerate( res ):
            end = "," if k < n -1 else ";"
            s = "( " + i + " ," + nome + " )" + end + "\n"
            f.write( s.rjust( 30 , " ") )
        f.write( "\n" )  
    

def gerar_tuplas_antena( num_cid , num_bairro, num_ant ):

    res = []
    for i in range( num_ant ):
        a = random.choice( range( num_bairro ) ) 
        b = random.choice( range( num_cid ) )
        
        s = "( {}, {}, {} )".format( str( i ) , str( a ) , str( b ) ) 
        res.append( s )

    random.shuffle( res )
    with open( "dummy.txt" , 'a' ) as f:
        for i , s in enumerate( res ):
            end = "," if i < num_ant - 1 else ";"
            f.write( s + end + "\n" )
        f.write( "\n" )
    
    return res

def gerar_tuplas_ligação( num_ant , d_max, d_min , num_lig ):

    dt_value_min = time.mktime(time.strptime( d_min, "%d/%m/%Y") )
    dt_value_max = time.mktime(time.strptime( d_max, "%d/%m/%Y") )
    random_day = lambda x: dt_value_min + x*( dt_value_max - dt_value_min )

    with open( "dummy.txt", 'a' ) as f:
        for i in range( num_lig ):
            
            ligacao_id = str( i ) + "::bigint"

            ant1 , ant2 = random.choices( range( num_ant ) , k = 2  )
            ant1 = str( ant1 )
            ant2 = str( ant2 )

            x = random.random()
            d = random_day( x )
            dia = time.strftime( "%d/%m/%Y" , time.localtime( d ) )
            dia = "'" + dia + "'" + "::date"

            duracao = 10 + 110*random.random()
            duracao = str( duracao )

            s = "( {} , {} , {} , {} , {} )".format(
                ligacao_id,
                ant1,
                ant2,
                dia,
                duracao
            )

            end = "," if i < num_lig - 1 else ";"

            f.write( "\t" + s + end + "\n" )
        f.write("\n")

if __name__ == "__main__":

    CIDADES = 15
    BAIRROS = 25
    ANTENAS = 100
    LIGACOES = 1200
    INICIO = "01/01/2018"
    FIM = "01/01/2020"

    # gerar_tuplas_1( BAIRROS , 10 )
    # gerar_tuplas_1( CIDADES , 10 )
    # gerar_tuplas_antena( CIDADES , BAIRROS, ANTENAS )
    gerar_tuplas_ligação( ANTENAS , FIM , INICIO , LIGACOES )

import numpy
import numpy.random
import time
import random

def gerar_dias( d1 , d2 , n , seed = 10 ):

    d1 = time.strptime( d1 , '%m/%d/%Y')
    stamp_1 = time.mktime( d1 )

    d2 = time.strptime( d2 , '%m/%d/%Y')
    stamp_2 = time.mktime( d2 )

    numpy.random.seed( seed )
    p = numpy.random.rand( n )
    stamps = stamp_1*p + stamp_2*( 1 - p )
    
    dias = []
    for d in stamps:

        dform = time.localtime( d )
        day = time.strftime( '%m/%d/%Y', dform )
        dias.append( day )
    
    return dias

def gerar_pares( produtos_ids , dias , num ):

    pares = set()
    while len( pares ) != num:

        dia = random.choice( dias )
        prod_id = random.choice( produtos_ids )

        pares.add( ( dia , prod_id ) )
    return list( pares )

def gerar_vendas( pares , min_vend = 1 , max_vend = 20 ):

    p = numpy.random.rand( len( pares ) )
    vendas = ( min_vend*p + max_vend*( 1 - p ) ).astype( int )
    return [ par + ( vend , ) for par , vend in zip( pares , list( vendas ) ) ]

def gerar_produtos( nomes ):

    return [ ( i , nome ) for i , nome in enumerate( nomes ) ]


if __name__ == "__main__":
    nomes = [
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        'G',
        'H'
    ]

    # mes , dia , ano
    dia_1 = '01/01/2000'
    dia_2 = '01/01/2020'

    linhas_vendas = 1000

    with open( "exercicio16/dummy.txt", 'a' ) as f:

        produtos = gerar_produtos( nomes )
        for i , ( codigo , nome ) in enumerate( produtos ):
            codigo = str( codigo ) + "::bigint"
            s = "( " + codigo + ", '" + nome + "' )"
            end = ";" if i == len( produtos ) - 1 else ","
            s = s + end
            print( s )
            f.write( s  + "\n" )
        f.write( "\n" )

        dias = gerar_dias( dia_1 , dia_2 , 300 , 20 )
        prods_ids = range( len( produtos ) )
        pares = gerar_pares( prods_ids , dias , linhas_vendas )
        vendas = gerar_vendas( pares )
        for i , ( dia , prod_id , qtd ) in enumerate( vendas ):

            dia = dia + "::timestamp"
            prod_id = str( prod_id ) + "::bigint"
            qtd = str( qtd )
            end = ";" if i == linhas_vendas - 1 else ","
            s = "( " + ", ".join( [ dia , prod_id , qtd ] ) + " )" + end
            print( s )
            f.write( s + "\n")
        f.write( "\n" )


require_relative "./earley.rb"

# Legenda
# S - Soma
# D - Diferença
# M - Multiplicação
# R - Razão (Divisão)
# E - Elevado (Power)
# P - Parênteses
# T - Termo
# N - Número
def main()
    grammar = {    
        'S' => [['D', 'Mais' ,'S'] , ['D']],
        'D' => [['M', 'Menos' ,'D'] , ['M']],
        'M' => [['R', 'Mult' ,'M'] , ['R']],
        'R' => [['E', 'Razao' ,'R'] , ['E']],
        'E' => [['T', 'Elevado' ,'E'] , ['T']],
        'T' => [['Menos', 'T'] , ['P']],
        'P' => [['AP', 'S', 'FP'] , ['N']],
        'N' => [['N','Numero'] , ['Numero']],
        
        'Mais'    =>   ['+'],
        'Menos'   =>   ['-'],
        'Mult'    =>   ['*'],
        'Razao'   =>   ['/'],
        'Elevado' =>   ['^'],
        'AP'      =>   ['('],
        'FP'      =>   [')'],
        
        'Numero'  =>     ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
    }
    terminals = ['Numero', 'Mais', 'Menos', 'Mult', 'Razao', 'Elevado', 'AP', 'FP']

    testCases = [
    '(1+4)*2^4',
    '7/(1-3)',
    '9^(1*6/2+4)',
    '2+4^-4/4',
    '34+2-4*4/4^2-(-3)',
    '1234',
    '42/123+311^(22 + 3)',
    '0/0',

    '^2+4',
    '9*2+',
    '9++3',
    '()*3',
    '(3+3',
    '1+'
    ]

    puts "1 - Digitar uma expressão"
    puts "2 - Usar test cases"
    op = gets.chomp.to_i
    if(op == 1)
        puts
        print "Digite a expressão: "
        ex = gets.chomp
        checarPalavra(ex, grammar, terminals, true)
    else
        runTestCases(testCases, grammar, terminals, false)
    end
end


def runTestCases (testCases, gramatica, terminals, printCharts)
    for t in testCases
        checarPalavra(t, gramatica, terminals, printCharts)
    end
end

def checarPalavra(palavra, gramatica, terminals, printCharts)
    earley = Earley.new(palavra, gramatica, terminals)
    earley.parse()
    puts (printCharts ? earley.to_s + "\n": "")
    earley.check  
end


if __FILE__ == $0
    main
end

# earley = Earley.new("13555+1", grammar, terminals)
# earley.parse()
# #print earley.to_s
# earley.check

# grammar = {
#     'S'       =>     [['Numero', 'Mais', 'S'], ['Numero'], ['T']],
#     'Mais'    =>     ['+'],
#     'Numero'  =>     ['1', '2'],
#     'T' => [['Menos', 'T'] , ['Numero']],
#     'Menos'   =>   ['-']
# }
# terminals = ['Numero', 'Mais', 'Menos']

# earley = Earley.new(['-','-', '1'], grammar, terminals)
# earley.parse()
# print earley.to_s
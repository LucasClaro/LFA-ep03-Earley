class Estado

    attr_accessor :label, :rules, :dot_index, :start_index, :end_index, :index, :made_from, :producer

    def initialize(label, rules, dot_index, start_index, end_index, index, made_from, producer)
        @label = label
        @rules = rules
        @dot_index = dot_index
        @start_index = start_index
        @end_index = end_index
        @index = index
        @made_from = made_from
        @producer = producer
    end

    def proximo
        return @rules[@dot_index]
    end

    def completo?
        return @rules.length() == @dot_index 
    end

    def ==(other)
        return (
            self.label == other.label &&
            self.rules == other.rules &&
            self.start_index == other.start_index &&
            self.end_index == other.end_index &&
            self.dot_index == other.dot_index
        )
    end

    def to_s
        aux = ""
        @rules.each_with_index do |rule,i|
            if i == @dot_index
                aux += "° "
            end
            aux += rule + " "
        end
        if self.completo?()
            aux += "°"
        end
        return "S#{@index} #{@label} -> #{aux} [#{@start_index}, #{@end_index}] #{@made_from} #{@producer}"
    end
end

class Earley

    attr_accessor :chart, :current_id, :palavras, :gramatica, :terminals

    def initialize(palavras, gramatica, terminals)
        @palavras = palavras.split(/\s*/)
        @chart = Array.new(@palavras.length() + 1){ [] }
        @current_id = 0
        @gramatica = gramatica
        @terminals = terminals
    end

    def novoId
        @current_id += 1
        return (@current_id - 1) 
    end

    def terminal?(simbolo)
        @terminals.include? simbolo
        # return simbolo in @terminals
    end

    def enqueue(estado, idChart)
        if !(@chart[idChart].include? estado)
            @chart[idChart].append(estado)
        else
            @current_id -= 1
        end
    end

    def predictor(estado)
        puts "PREDICTOR"
        puts estado.to_s
        
        for regra in @gramatica[estado.proximo()]
            teste = Estado.new(estado.proximo(), regra, 0, estado.end_index, estado.end_index, self.novoId(), [], "predictor")
            puts teste.to_s
            self.enqueue(teste, estado.end_index)
        end
        puts
    end

    def scanner(estado)
        puts "SCANNER"
        puts estado.to_s

        if @gramatica[estado.proximo()].include? @palavras[estado.end_index]
            teste = Estado.new(estado.proximo(), [@palavras[estado.end_index]], 1, estado.end_index, (estado.end_index + 1), self.novoId(), [], "scanner")
            puts teste
            self.enqueue(teste, (estado.end_index + 1))
        end
        puts 
    end

    def completer(estado) 
        puts "COMPLETER"
        puts estado.to_s
        for e in @chart[estado.start_index]
            if !e.completo? && e.proximo() == estado.label && e.end_index == estado.start_index && e.label != "gamma" && estado.completo?
                teste = Estado.new(e.label, e.rules, (e.dot_index + 1), e.start_index, estado.end_index, self.novoId(), (e.made_from + [estado.index]), "completer")
                puts teste
                self.enqueue(teste, estado.end_index) 
            end
        end
        puts
    end

    def parse
        self.enqueue(Estado.new("gamma", ['S'], 0, 0, 0, self.novoId(), [], "Estado Inicial"), 0)

        (0..@palavras.length()).step(1) do |i|
            for estado in @chart[i]
                if !estado.completo? && !self.terminal?(estado.proximo())
                    self.predictor(estado)            
                elsif i != @palavras.length() && !estado.completo? && self.terminal?(estado.proximo())
                    self.scanner(estado)
                else
                    self.completer(estado)
                end
            end
        end
    end

    def to_s
        aux = ""
        @chart.each_with_index do |chart, i|
            aux += "\nChart[#{i}]\n"
            for estado in chart
                aux += estado.to_s + "\n"
            end
        end

        controle = false
        for e in @chart[@palavras.length()]
            if e.label == "S" && e.start_index == 0 && e.completo?
                controle = true
            end
        end
                
        if controle
            aux += "\nEXPRESSÃO VÁLIDA\n"
        else 
            aux += "\nEXPRESSÃO INVÁLIDA\n"
        end

        return aux
    end

end


# Legenda
# S - Soma
# D - Diferença
# M - Multiplicação
# R - Razão (Divisão)
# E - Elevado (Power)
# P - Parênteses
# T - Termo
# N - Número

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

unitTests = [
'(1+4)*2^4',
'7/(1-3)',
'9^(1*6/2+4)',
'2+4^-4/4',

'^2+4',
'9*2+',
'9++3',
'()*3',
'(3+3'
]

earley = Earley.new("1+ 1", grammar, terminals)
earley.parse()
print earley.to_s


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
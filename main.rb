class Pilha 
  def initialize
    @pilha = []
  end

  def push(e)
    @pilha << e
  end

  def pop
    @pilha.pop
  end

  def double_pop(e1, e2)
    @nova_pilha = @pilha.dup

    if @nova_pilha.last == e1
      @nova_pilha.pop

      if @nova_pilha.last == e2
        @nova_pilha.pop

        @pilha = @nova_pilha.dup
        return true
      end
    end

    return false
  end

  def last
    @pilha.last
  end

end

class JsonParser 
  BRACE = '{'
  BRACE_END = '}'

  BRACKET = '['
  BRACKET_END = ']'

  SLASH = '/'
  BACK_SLASH = '\\'
  NEW_LINE = "\n"
  TAB = "\t"
  CARRIAGE_RETURN = "\r"

  COLON = ':'
  COMMA = ','
  POINT = '.'

  QUOTE = '"'
  SINGLE_QUOTE = "'"

  SPACE = ' '
  EMPYT = ''

  NEGATIVE = '-'
  ZERO = '0'
  NUMBERS = /[1-9]/

  CARACTERS = /[\p{L}_\-.0-9:\/#]/
  A = 'a'
  E = 'e'
  F = 'f'
  L = 'l'
  N = 'n'
  R = 'r'
  S = 's'
  T = 't'
  U = 'u'

  def inicializar(text)
    @current_state = :q0

    @symbols = Pilha.new
    @hashes = Pilha.new

    @key = ""
    @value = ""
    @caractere = 0
    @linha = 1

    text.each_char do |char|
      @caractere = @caractere + 1
      parser(char)
    end

    @hashes.pop
  end

  def parser(char)

    if char == NEW_LINE
      @linha = @linha + 1
      @caractere = 0
    end

    case [@current_state, char, @symbols.last] 
      in [:q0, BRACE, _]
        @current_state = :q1
        @symbols.push(:json)
        @hashes.push(Hash.new)
      
      in[:q1, SPACE | SLASH | BACK_SLASH | NEW_LINE | TAB | CARRIAGE_RETURN, :json]
        @symbols.pop
        @current_state = :q1
        @symbols.push(:json)

      in[:q1, SPACE | SLASH | BACK_SLASH | NEW_LINE | TAB | CARRIAGE_RETURN, :object]
        @symbols.pop
        @current_state = :q1
        @symbols.push(:object)

      in [:q1, QUOTE, _]
        @current_state = :q2
        @symbols.push(:key)

      in[:q1, BRACE_END, :json]
        @symbols.pop
        @current_state = :qf

      in[:q2, CARACTERS | SPACE, :key]
        @symbols.pop
        @current_state = :q2
        @key += char
        @symbols.push(:key)

      in[:q2, QUOTE, :key]
        @symbols.pop
        @current_state = :q3
        @symbols.push(:s_value)
        
      in[:q3, SPACE | SLASH | BACK_SLASH | NEW_LINE | TAB | CARRIAGE_RETURN, :s_value]
        @symbols.pop
        @current_state = :q3
        @symbols.push(:s_value)

      in[:q3, SPACE | SLASH | BACK_SLASH | NEW_LINE | TAB | CARRIAGE_RETURN, :value]
        @symbols.pop
        @current_state = :q3
        @symbols.push(:value)

      in[:q3, COLON, :s_value]
        @symbols.pop
        @current_state = :q3
        @symbols.push(:value)

      in[:q3, BRACKET, :value]
        @symbols.pop
        @current_state = :q3
        @symbols.push(:list)
        @symbols.push(:value)
        @lista = Array.new
        if @hashes.last.is_a?(Hash)
          @hashes.last[@key] = @lista
        elsif @hashes.last.is_a?(Array)
          @hashes.last.push(@lista)
        end
        @hashes.push(@lista)
        @key = ""
        @value = ""

      in[:q3, BRACKET_END, :value]
        if @symbols.double_pop(:value, :list)
          @current_state = :q6
          @hashes.pop
        end

      in[:q3, BRACE, :value]
        @symbols.pop
        @current_state = :q4
        @symbols.push(:object)
        @objeto = Hash.new
        
        if @hashes.last.is_a?(Hash)
          @hashes.last[@key] = @objeto
          @key = ""
        elsif @hashes.last.is_a?(Array)
          @hashes.last.push(@objeto)
        end
        @hashes.push(@objeto)

      in[:q3, QUOTE, :value]
        @symbols.pop
        @current_state = :q5
        @symbols.push(:string)

      in[:q3, NEGATIVE, :value]
        @symbols.pop
        @current_state = :q7
        @symbols.push(:negative)
        @value += char

      in[:q3, NUMBERS, :value]
        @symbols.pop
        @current_state = :q8
        @symbols.push(:number)
        @value += char

      in[:q3, ZERO, :value]
        @symbols.pop
        @current_state = :q9
        @symbols.push(:number)
        @value += char

      in[:q3, T, :value]
        @symbols.pop
        @current_state = :q11
        @symbols.push(:t1)

      in[:q3, F, :value]
        @symbols.pop
        @current_state = :q12
        @symbols.push(:f1)

      in[:q3, N, :value]
        @symbols.pop
        @current_state = :q13
        @symbols.push(:n1)

      in[:q4, SPACE | SLASH | BACK_SLASH | NEW_LINE | TAB | CARRIAGE_RETURN, :object]
        @symbols.pop
        @current_state = :q4
        @symbols.push(:object)

      in[:q4, QUOTE, _]
        @current_state = :q2
        @symbols.push(:key)

      in[:q4, BRACE_END, :object]
        @symbols.pop
        @current_state = :q6
        @hashes.pop

      in[:q5, CARACTERS | SPACE, :string]
        @symbols.pop
        @current_state = :q5
        @symbols.push(:string)
        @value += char

      in[:q5, QUOTE, :string]
        @symbols.pop
        @current_state = :q6
        if @hashes.last.is_a?(Hash)
          @hashes.last[@key] = @value
        elsif @hashes.last.is_a?(Array)
          @hashes.last.push(@value)
        end
        @key = ""
        @value = ""
       
      in[:q6, SPACE | SLASH | BACK_SLASH | NEW_LINE | TAB | CARRIAGE_RETURN, :object]
        @symbols.pop
        @current_state = :q6
        @symbols.push(:object)

      in[:q6, SPACE | SLASH | BACK_SLASH | NEW_LINE | TAB | CARRIAGE_RETURN, :json]
        @symbols.pop
        @current_state = :q6
        @symbols.push(:json)

      in[:q6, SPACE | SLASH | BACK_SLASH | NEW_LINE | TAB | CARRIAGE_RETURN, :list]
        @symbols.pop
        @current_state = :q6
        @symbols.push(:list)

      in[:q6, BRACE_END, :object]
        @symbols.pop
        @current_state = :q6
        @hashes.pop

      in[:q6, BRACKET_END, :list]
        @symbols.pop
        @current_state = :q6
        @hashes.pop

      in[:q6, COMMA, :list]
        @symbols.pop
        @current_state = :q3
        @symbols.push(:list)
        @symbols.push(:value)

      in[:q6, COMMA, :object]
        @symbols.pop
        @current_state = :q1
        @symbols.push(:object)

      in[:q6, COMMA, :json]
        @symbols.pop
        @current_state = :q1
        @symbols.push(:json)

      in[:q6, BRACE_END, :json]
        @symbols.pop
        @current_state = :qf

      in[:q7, NUMBERS, :negative]
        @symbols.pop
        @current_state = :q8
        @symbols.push(:number)
        @value += char

      in[:q7, ZERO, :negative]
        @symbols.pop
        @current_state = :q9
        @symbols.push(:number)
        @value += char

      in[:q8, BRACE_END, :number]
        if @symbols.double_pop(:number, :object)
          @current_state = :q6
          @hashes.last[@key] = Integer(@value)
          @hashes.pop
          @key = ""
          @value = ""
        elsif @symbols.double_pop(:number, :json)
          @current_state = :qf
          @hashes.last[@key] = Integer(@value)
          @key = ""
          @value = ""
        end

      in[:q8, BRACKET_END, :number]
        if@symbols.double_pop(:number, :list)
          @current_state = :q6
          @hashes.last.push(Integer(@value))
          @hashes.pop
          @value = ""
        end

      in[:q8, SPACE | SLASH | BACK_SLASH | NEW_LINE | TAB | CARRIAGE_RETURN, :number]
        @symbols.pop
        @current_state = :q6
        if @hashes.last.is_a?(Hash)
          @hashes.last[@key] = Integer(@value)
          @key = ""
          @value = ""
        elsif @hashes.last.is_a?(Array)
          @hashes.last.push(Integer(@value))
          @value = ""
        end

      in[:q8, COMMA, :number]
        if @symbols.double_pop(:number, :object)
          @current_state = :q1
          @symbols.push(:object)
          @hashes.last[@key] = Integer(@value)
          @key = ""
          @value = ""
        elsif @symbols.double_pop(:number, :list)
          @current_state = :q3
          @symbols.push(:value)
          @hashes.last.push(Integer(@value))
          @value = ""
        elsif @symbols.double_pop(:number, :json)
          @current_state = :q1
          @symbols.push(:json)
          @hashes.last[@key] = Integer(@value)
          @key = ""
          @value = ""
        end

      in[:q8, ZERO | NUMBERS, :number]
        @symbols.pop
        @current_state = :q8
        @symbols.push(:number)
        @value += char

      in[:q8, POINT, :number]
        @symbols.pop
        @current_state = :q10
        @symbols.push(:number)
        @value += char

      in[:q9, BRACE_END, :number]
        if @symbols.double_pop(:number, :object)
          @current_state = :q6
          @hashes.last[@key] = Integer(@value)
          @hashes.pop
          @key = ""
          @value = ""
          
        elsif @symbols.double_pop(:number, :json)
          @current_state = :qf
          @hashes.last[@key] = Integer(@value)
          @key = ""
          @value = ""
        end

      in[:q9, BRACKET_END, :number]
        if @symbols.double_pop(:number, :list)
          @current_state = :q6
          @hashes.last.push(Integer(@value))
          @hashes.pop
          @value = ""
        end

      in[:q9, SPACE | SLASH | BACK_SLASH | NEW_LINE | TAB | CARRIAGE_RETURN, :number]
        @symbols.pop
        @current_state = :q6
        if @hashes.last.is_a?(Hash)
          @hashes.last[@key] = Integer(@value)
          @key = ""
          @value = ""
        elsif @hashes.last.is_a?(Array)
          @hashes.last.push(Integer(@value))
          @value = ""
        end

      in[:q9, COMMA, :number]
        if @symbols.double_pop(:number, :list)
          @current_state = :q3
          @symbols.push(:value)
          @hashes.last[@key] = Integer(@value)
          @key = ""
          @value = ""
        elsif @symbols.double_pop(:number, :object)
          @current_state = :q1
          @symbols.push(:object)
          @hashes.last[@key] = Integer(@value)
          @hashes.pop
          @key = ""
          @value = ""
        elsif @symbols.double_pop(:number, :json)
          @current_state = :q1
          @symbols.push(:json)
          @hashes.last[@key] = Integer(@value)
          @key = ""
          @value = ""
        end

      in[:q9, POINT, :number]
        @symbols.pop
        @current_state = :q10
        @symbols.push(:number)
        @value += char

      in[:q10, BRACE_END, :frac]
        if @symbols.double_pop(:frac, :object)
          @current_state = :q6
          @hashes.last[@key] = Float(@value)
          @hashes.pop
          @key = ""
          @value = ""
        elsif @symbols.double_pop(:frac, :json)
          @current_state = :qf
          @hashes.last[@key] = Float(@value)
          @key = ""
          @value = ""
        end

      in[:q10, BRACKET_END, :frac]
        if @symbols.double_pop(:frac, :list)
          @current_state = :q6
          @hashes.last.push(Float(@value))
          @value = ""
        end

      in[:q10, SPACE | SLASH | BACK_SLASH | NEW_LINE | TAB | CARRIAGE_RETURN, :frac]
        @symbols.pop
        @current_state = :q6
        if @hashes.last.is_a?(Hash)
          @hashes.last[@key] = Float(@value)
          @key = ""
          @value = ""
        elsif @hashes.last.is_a?(Array)
          @hashes.last.push(Float(@value))
          @value = ""
        end
        

      in[:q10, COMMA, :frac]
        if @symbols.double_pop(:frac, :object)
          @current_state = :q1
          @symbols.push(:object)
          @hashes.last[@key] = Float(@value)
          @hashes.pop
          @key = ""
          @value = ""
        elsif @symbols.double_pop(:frac, :list)
          @current_state = :q3
          @symbols.push(:value)
          @hashes.last.push(Float(@value))
          @value = ""
        elsif @symbols.double_pop(:frac, :json)
          @current_state = :q1
          @symbols.push(:json)
          @hashes.last[@key] = Float(@value)
          @key = ""
          @value = ""
        end

      in[:q10, ZERO | NUMBERS, :number]
        @symbols.pop
        @current_state = :q10
        @symbols.push(:frac)
        @value += char

      in[:q10, ZERO | NUMBERS, :frac]
        @symbols.pop
        @current_state = :q10
        @symbols.push(:frac)
        @value += char

      in[:q11, R, :t1]
        @symbols.pop
        @current_state = :q11
        @symbols.push(:t2)

      in[:q11, U, :t2]
        @symbols.pop
        @current_state = :q11
        @symbols.push(:t3)

      in[:q11, E, :t3]
        @symbols.pop
        @current_state = :q6
        if @hashes.last.is_a?(Hash)
          @hashes.last[@key] = true
          @key = ""
        elsif @hashes.last.is_a?(Array)
          @hashes.last.push(true)
        end   

      in[:q12, A, :f1]  
        @symbols.pop
        @current_state = :q12
        @symbols.push(:f2)

      in[:q12, L, :f2]
        @symbols.pop
        @current_state = :q12
        @symbols.push(:f3)

      in[:q12, S, :f3]
        @symbols.pop
        @current_state = :q12
        @symbols.push(:f4)

      in[:q12, E, :f4]
        @symbols.pop
        @current_state = :q6
        if @hashes.last.is_a?(Hash)
          @hashes.last[@key] = false
          @key = ""
        elsif @hashes.last.is_a?(Array)
          @hashes.last.push(false)
        end      

      in[:q13, U, :n1]
        @symbols.pop
        @current_state = :q13
        @symbols.push(:n2)

      in[:q13, L, :n2]
        @symbols.pop
        @current_state = :q13
        @symbols.push(:n3)

      in[:q13, L, :n3]
        @symbols.pop
        @current_state = :q6
        if @hashes.last.is_a?(Hash)
          @hashes.last[@key] = nil
          @key = ""
        elsif @hashes.last.is_a?(Array)
          @hashes.last.push(nil)
        end      

      in[:qf, SPACE | SLASH | BACK_SLASH | NEW_LINE | TAB | CARRIAGE_RETURN | EMPYT, _]
        puts "json válido"

      in[_, _, _]
        raise "#{char} inválido na linha #{@linha} posicao #{@caractere}! "
    end
  end

end

input = '{
  "empresa": "ACME Inc.",
  "ano_fundacao": 1990,
  "funcionarios": [
    {
      "nome": "João Silva",
      "cargo": "Desenvolvedor",
      "idade": 35,
      "salario": 5000
    },
    {
      "nome": "Maria Souza",
      "cargo": "Gerente de Vendas",
      "idade": 42,
      "salario": 8000
    },
    {
      "nome": "Pedro Santos",
      "cargo": "Analista de Marketing",
      "idade": 28,
      "salario": 4500
    }
  ],
  "projetos": [
    {
      "nome": "Projeto A",
      "descricao": "Desenvolvimento de um novo aplicativo",
      "responsavel": "Joao Silva",
      "custo_estimado": 100000,
      "status": "Em andamento"
    },
    {
      "nome": "Projeto B",
      "descricao": "Implementacao de estrategias de marketing",
      "responsavel": "Pedro Santos",
      "custo_estimado": 75000,
      "status": true
    }
  ],
  "clientes": [
    {
      "nome": "Empresa XYZ",
      "tipo": "Corporativo",
      "contato": "Fernanda Oliveira",
      "receita_anual": 150.89
    },
    {
      "nome": "Loja ABC",
      "tipo": "Varejo",
      "contato": "Jose Pereira",
      "receita_anual": 80000
    }
  ],
  "faturamento": [
    {
      "filial": "Sorocaba",
      "mes": "Janeiro",
      "valor": -50000
    },
    {
      "filial": "São Paulo",
      "mes": "Janeiro",
      "valor": 10000
    }
  ]
}'

parser = JsonParser.new
json = parser.inicializar(input)
puts json
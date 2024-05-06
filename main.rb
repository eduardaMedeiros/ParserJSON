class Pilha 
  def initialize
    @pilha = []
  end

  def push(e)
    @pilha << e
  end

  def pop
    e = @pilha.pop
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
  CARRIAGE_RETURN = "\\r"
  
  COLON = ':'
  COMMA = ','
  POINT = '.'
  
  QUOTE = '"'
  SINGLE_QUOTE = "'"
  SPACE = ' '

  NEGATIVE = '-'
  ZERO = '0'
  NUMBERS = /[1-9]/
  
  CARACTERS = /[\p{L}_]/
  A = 'a'
  B = 'b'
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
    @hashes = []

    @key = ""
    @value = ""
    @caractere = 0
    @linha = 1

    text.each_char do |char|
      @caractere = @caractere + 1
      parser(char)
    end
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
        puts @key
        @key = ""
        
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

      in[:q3, BRACKET_END, :value]
        if @symbols.double_pop(:value, :list)
          @current_state = :q6
        end
      
      in[:q3, BRACE, :value]
        @symbols.pop
        @current_state = :q4
        @symbols.push(:object)
      
      in[:q3, QUOTE, :value]
        @symbols.pop
        @current_state = :q5
        @symbols.push(:string)

      in[:q3, NEGATIVE, :value]
        @symbols.pop
        @current_state = :q7
        @symbols.push(:negative)
        
      in[:q3, NUMBERS, :value]
        @symbols.pop
        @current_state = :q8
        @symbols.push(:number)
      
      in[:q3, ZERO, :value]
        @symbols.pop
        @current_state = :q9
        @symbols.push(:number)

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

      in[:q5, CARACTERS | SPACE, :string]
        @symbols.pop
        @current_state = :q5
        @symbols.push(:string)

      in[:q5, QUOTE, :string]
        @symbols.pop
        @current_state = :q6

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

      in[:q6, BRACKET_END, :list]
        @symbols.pop
        @current_state = :q6

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
        
      in[:q7, ZERO, :negative]
        @symbols.pop
        @current_state = :q9
        @symbols.push(:number)

      in[:q8, BRACE_END, :number]
        if @symbols.double_pop(:number, :object)
          @current_state = :q6
        elsif @symbols.double_pop(:number, :json)
          @current_state = :qf
        end

      in[:q8, BRACKET_END, :number]
        if@symbols.double_pop(:number, :list)
          @current_state = :q6
        end

      in[:q8, SPACE | SPACE | SLASH | BACK_SLASH | NEW_LINE | TAB | CARRIAGE_RETURN, :number]
        @symbols.pop
        @current_state = :q6

      in[:q8, COMMA, :number]
        if @symbols.double_pop(:number, :object)
          @current_state = :q1
          @symbols.push(:object)
        elsif @symbols.double_pop(:number, :list)
          @current_state = :q3
          @symbols.push(:value)
        elsif @symbols.double_pop(:number, :json)
          @current_state = :q1
          @symbols.push(:json)
        end

      in[:q8, ZERO | NUMBERS, :number]
        @symbols.pop
        @current_state = :q8
        @symbols.push(:number)
      
      in[:q8, POINT, :number]
        @symbols.pop
        @current_state = :q10
        @symbols.push(:number)
      
      in[:q9, BRACE_END, :number]
        if @symbols.double_pop(:number, :object)
          @current_state = :q6
        elsif @symbols.double_pop(:number, :json)
          @current_state = :qf
        end

      in[:q9, BRACKET_END, :number]
        if @symbols.double_pop(:number, :list)
          @current_state = :q6
        end

      in[:q9, SPACE | SLASH | BACK_SLASH | NEW_LINE | TAB | CARRIAGE_RETURN, :number]
        @symbols.pop
        @current_state = :q6
      
      in[:q9, COMMA, :number]
        if @symbols.double_pop(:number, :list)
          @current_state = :q3
          @symbols.push(:value)
        elsif @symbols.double_pop(:number, :object)
            @current_state = :q1
            @symbols.push(:object)
        elsif @symbols.double_pop(:number, :json)
          @current_state = :q1
          @symbols.push(:json)
        end
      
      in[:q9, POINT, :number]
        @symbols.pop
        @current_state = :q10
        @symbols.push(:number)
  
      in[:q10, BRACE_END, :frac]
        if @symbols.double_pop(:frac, :object)
          @current_state = :q6
        elsif @symbols.double_pop(:frac, :json)
            @current_state = :qf
        end
        
      in[:q10, BRACKET_END, :frac]
        if @symbols.double_pop(:frac, :list)
          @current_state = :q6
        end
      
      in[:q10, SPACE | SLASH | BACK_SLASH | NEW_LINE | TAB | CARRIAGE_RETURN, :frac]
        @symbols.pop
        @current_state = :q6

      in[:q10, COMMA, :frac]
        if @symbols.double_pop(:frac, :object)
          @current_state = :q1
          @symbols.push(:object)
        elsif @symbols.double_pop(:frac, :list)
          @current_state = :q3
          @symbols.push(:value)
        elsif @symbols.double_pop(:frac, :json)
          @current_state = :q1
          @symbols.push(:json)
        end

      in[:q10, ZERO | NUMBERS, :number]
        @symbols.pop
        @current_state = :q10
        @symbols.push(:frac)
      
      in[:q10, ZERO | NUMBERS, :frac]
        @symbols.pop
        @current_state = :q10
        @symbols.push(:frac)

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

      in[:q12, A, :f1]  
        @symbols.pop
        @current_state = :q11
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
          
      in[:qf, SPACE | SPACE | SLASH | BACK_SLASH | NEW_LINE | TAB | CARRIAGE_RETURN, _]
        puts "json válido"

      in[_, _, _]
        raise "#{char} inválido na linha #{@linha} posicao #{@caractere}! "
    end
  end

end

input = '{
  "empresa": "ACME Inc",
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
      "status": "Concluido"
    }
  ],
  "clientes": [
    {
      "nome": "Empresa XYZ",
      "tipo": "Corporativo",
      "contato": "Fernanda Oliveira",
      "receita_anual": 150000
    },
    {
      "nome": "Loja ABC",
      "tipo": "Varejo",
      "contato": "Jose Pereira",
      "receita_anual": 80000
    }
  ]
} '

parser = JsonParser.new
parser.inicializar(input)
# ParserJSON
Parser simplificado utilizando autômatos de pilha para analisar e validar dados no formato JSON. O parser é capaz de identificar as principais estruturas do JSON, como objetos, arrays, strings, números, valores booleanos e null.

## Principais Estruturas do JSON:

- **Objetos:** Representam coleções de pares nome-valor. São delimitados por chaves (`{}`) e cada par é composto por um nome (string) seguido de dois pontos (`:`), um valor (que pode ser de qualquer tipo JSON) e vírgula (`,`). O último par não precisa de vírgula.

  *{
    "nome": "João",
    "idade": 30,
    "profissao": "Desenvolvedor"
  }*

- **Arrays:** Representam listas ordenadas de valores. São delimitados por colchetes ([]) e os valores são separados por vírgulas.

  *["maçã", "banana", "laranja"]*

- **Strings:** Representam sequências de caracteres. São delimitadas por aspas duplas (") ou aspas simples ('). Aspas duplas são preferidas. Dentro das strings, caracteres especiais como aspas, barra invertida () e newline (\n) podem ser escapados usando a barra invertida ().

  *"Olá, mundo!"*
  
- **Números:** Representam valores numéricos, tanto inteiros quanto decimais.

  *123
  3.14*
  
- **Valores Booleanos:** Representam valores lógicos, true ou false.

  *true
  false*

- **Null:** Representa a ausência de valor.

  *null*

## Funções do Parser
- O parser é capaz de ler um arquivo JSON ou uma string contendo dados JSON e transforma em uma estrutra de dados da linguagem. Sendo elas: Hash, Lista, Strings e outros tipos primários
- O parser identifica e valida as principais estruturas do JSON: objetos, arrays, strings, números, valores booleanos e null.
- O parser deve sinaliza erros de sintaxe quando encontra estruturas JSON inválidas.
- Foi utilizado um autômato de pilha para a validação e identificação no parser.

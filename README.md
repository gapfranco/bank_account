# BankAccount API

## Sumário

API REST em Elixir/Phoenix, modelando um sistema de abertura de contas bacárias.

## Funcionalidades

A criação de uma conta poderá acontecer em etapas: a partir de um **`CPF`**, o(a) potencial cliente informa os
dados (através de uma ou várias requisições), e desta forma a abertura da conta ficará pendente até que
todos os dados estejam devidamente preenchidos.

- Campos definidos: **`cpf`**, **`password`**, **`email`**, **`name`**, **`birth_date`**, **`gender`**,
  **`city`**, **`state`**, **`country`**, **`referral_code`**

- Os campos **`cpf`**, **`email`**, **`name`**, e **`birth_date`** são encriptados no banco de dados.

- A conta será considerada **`pending`** até que todos os campos sejam preenchidos de forma válida. O usuário
  poderá fazer várias requisições parciais de registro até completar. Quando completar, a conta passará
  para o status **`completed`**.

- Ao completar todos os campos, um código de 8 dígitos será gerado e apresentado (_referral code_).
  Poderá ser enviado a outras pessoas, como convite para que também façam seu cadastro.

- Um usuário pode consultar quem se cadastrou com seu código de indicação (_referral code_) com uma chamada de API.
  Essa chamada só poderá ser feita por usuário autenticado. Para se autenticar, fazer a chamada de _login_, passando o **`CPF`**
  e senha. Se a conexão for bem sucedida, retornará um token **`JWT`**, que poderá ser usado nas chamadas autenticada.

## Implementação

A encriptação de dados foi implementada usando técnicas derivadas deste repositório:

https://github.com/dwyl/phoenix-ecto-encryption-example

Os campos protegidos são encriptados usando **`Advanced Encryption Standard (AES)`**.

Foi criado um campo **`cpf_hash`** derivado do cpf, unicamente para se fazer buscas de forma eficiente.
Esse algotitmo de hash é determinístico e rápido e deve _sempre_ retornar o mesmo valor.

O hash da senha usa o algoritmo _pbkdf2_, pseudo-aleatório e mais lento, mas que gera valores diferentes
por chamada, evitando ataques de adivinhação da senha por repetição de tentativas de hash.

As chaves para encriptação AES devem ser informadas na variável de ambiente **`ENCRYPTION_KEYS`** em produção e nunca
registradas em repositórios git. Ver repositório acima para detalhes.

Os campos que devem ser encriptados foram definidos como **`:binary`** e não **`:string`**,
por razões de eficiência
(ver o artigo https://dba.stackexchange.com/questions/56934/what-is-the-best-way-to-store-a-lot-of-user-encrypted-data).

## Instalação

Para rodar localmente:

- Instalar as dependências com `mix deps.get`
- Criar e e migrar o banco de dados com `mix ecto.setup`.
- Iniciar o serviço Phoenix com `mix phx.server`

Acessar os endpoints com um cliente API no endereço `localhost:4000`.

## Modelagem de dados

As seguintes entidades foram definidas:

### Users

Tabela de usuários

```
{
  "id": integer,
  "cpf": binary,
  "cpf_hash": binary,
  "email": binary,
  "name": binary,
  "birth_date": binary,
  "gender": string,
  "city": string,
  "state": string,
  "country": string,
  "referral_code": string,
  "referral_code_gen": string,
  "status": string,
  "password_hash": string,
  "inserted_at": string,
  "updates_at": string,
}
```

## Descrição do uso

## Registro

O registro é feito com a chamada **`POST /api/register`**.

O corpo da requisição deverá ter a seguinte estrutura:

```
{
  "cpf": "073.463.248-70",
  "name": "Nome do usuário",
  "password": "123123",
  "birth_date": "1959-02-11",
  "city": "Ribeirão Preto",
  "country": "Brasil",
  "email": "eu@email.com",
  "state": "SP",
  "gender": "male",
  "referral_code": "ZCRIX6T3"
}
```

O campo **`cpf`** é sempre obrigatório, pois identifica o usuário. O campo **`password`** de senha
é obrigatório apenas na primeira chamada, para poder criar um registro utilizável para autenticação.

As seguintes validações serão feitas:

- _cpf_ deve ser válido
- _birth_date_ deve ser uma data válida no formato AAAA-MM-DD
- _gender_ deve ser um gênero válido (_female_ ou _male_)
- _email_ deve ter um formato válido (com _@_ no meio)

O campo _referral_code_, se informado, vai vincular essa conta à conta de alguém como indicação.
Se informar um código errado, que não existe, nenhum erro será gerado, apenas não vai fazer a
vinculação.

### Retorno

Se for uma primeira chamada e não tiver informado a senha (_password_):

```
{
  "errors": [
    {
      "key": "password",
      "message": [
          "can't be blank"
      ]
    }
  ]
}
```

Quando o _cpf_ não for informado:

```
{
  "message": "Account creation",
  "status": "CPF missing"
}
```

Quando algum outro campo não for válido retornará um ou mais das seguintes mensagens:

```
{
  "errors": [
    {
      "key": "birth_date",
      "message": [
        "invalid date"
      ]
    },
    {
      "key": "cpf",
      "message": [
        "invalid CPF: 123.444.777-99"
      ]
    },
    {
      "key": "email",
      "message": [
        "Invalid e-mail"
      ]
    },
    {
      "key": "gender",
      "message": [
        "is invalid"
      ]
    }
  ]
}
```

Não havendo erros e tendo informado todos os campos vai retornar:

```
{
  "message": "Account creation",
  "referral_code": "ZCRII6T3",
  "status": "complete"
}
```

O _status_ é **`complete`** e **`referral_code`** é o codigo de indicação gerado.

> **`Sobre o Referral Code`**
>
> O referral code é um código gerado aleatoriamente com 8 caracteres
> entre letras maiúsculas, minúsculas e algarismos.
> Optei por usar letras e algaritmos para minimizar a possibilidade de
> se gerar códigos duplicados (62^8 combinações em vez de 10ˆ8).
> Se for desejável usar apenas números, basta alterar a linha 11 do
> módulo **`BankAccount.Randomizer`** de:
>
> ```
>
>   (alphabets <> String.downcase(alphabets) <> numbers)
>   |> String.split("", trim: true)
>
> ```
>
> para:
>
> ```
>
>   numbers
>   |> String.split("", trim: true)
>
> ```

Se nem todos os campos tiverem sido informados, vai retornar:

```
{
  "message": "Account creation",
  "status": "pending"
}
```

O _status_ ainda é **`pending`**.

## Conexão e autenticação

O conexão é feita com a chamada **`POST /api/login`**.

O corpo da requisição deverá ter a seguinte estrutura:

```
{
  "cpf": "123.444.555-77",
  "password": "123123"
}
```

Se existir a conta com esse _cpf_ e senha, vai retornar:

```
{
  "message": "Connected",
  "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJiYW5rX2FjY291bnQiLCJleHAiOjE2MTUxMjA1MTMsImlhdCI6MTYxMjcwMTMxMywiaXNzIjoiYmFua19hY2NvdW50IiwianRpIjoiNjc5ZmJhYTYtYjJiNC00ODY0LWI0MGYtZjE2MDk0Y2VmMDU0IiwibmJmIjoxNjEyNzAxMzEyLCJzdWIiOiIyIiwidHlwIjoiYWNjZXNzIn0.rWGibQfd_aa-FVv4miecy7Q-uxo__jdqkmtBbVQlVmLVwQaJCBU4ys6RbawWuzXUDe33riau2KA0ri00l2jCvw"
}
```

O campo **`token`** deverá ser usado para fazer as chamadas que exigem autenticação.
Determina quem é o usuário e se está autorizado.

Se houver erro vai retornar:

```
{
  "error": "login_error"
}
```

## Visialização de indicações

O consulta é feita com a chamada **`GET /api/referrals`**.

O usuário deve estar autenticado e com o registro completo. A autenticação é comprovada pela presença
de um **`Bearer token`** **`JWT`** na requisição, retornado pelo chamada de login.

Se estiver com registro completo, vai listar os registros que usaram o seu código de indicação:

```
{
  "data": [
    {
      "id": 3,
      "name": "Margarida"
    },
    {
      "id": 4,
      "name": "Aurora"
    },
    {
      "id": 5,
      "name": "Gregório"
    }
  ]
}
```

Se não estiver conectado vai responder com:

```
{
  "message": "Account register not completed"
}
```

Se o registro da conta não estiver completo vai retornar:

```
{
  "message": "Account register not completed"
}
```

## Como contribuir?

Este é um projeto totalmente livre que aceita contribuições via pull requests no GitHub. Este documento tem a responsabilidade de alinhar as contribuições de acordo com os padrões estabelecidos no mesmo. Em caso de dúvidas, abra uma issue.

### Primeiros passos

1. Fork este repositório
2. Envie seus commits em português
3. Solicite a pull request
4. Insira um pequeno sobre o que você colocou

## Contatos

- Author - [Gonçalo Franco](https://linkedin.com/in/gapfranco)

## License

Este projeto é licenciado como [MIT licensed](LICENSE).

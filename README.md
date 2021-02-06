# BankAccount API

## Sumário

Projeto de API REST em Elixir/Phonix, modelando um sistema de abertura de contas bacárias.

## Funcionalidades

A criação de uma conta poderá acontecer em etapas: a partir de um CPF, o(a) potencial cliente informa dados (através de uma ou várias requisições), e desta forma a abertura da conta ficará pendente até que todos os dados estejam devidamente preenchidos.

- Os seguintes campos estão definidos: cpf (obrigatório), name, email​, birth_date, gender, city, state, country, referral_code

- Os campos cpf, email, name, e birth_date serão encriptados no banco de dados.

- A conta será considerada _pending_ até todos os campos serem preenchidos de forma válida. O usuário
  poderá fazer várias requisições parciais até completar. Quando completar a conta passara'para o status _completed_

- Quando completar todos os campos, o usuário receberá um código de 8 dígitos (referral_code) que poderá enviar
  a outras pessoas como convite para que também façam seu cadastro.

- Há uma requisição definida para se consultar as contas criadas a partir de uma determinado usuário pelo seu
  _referral code_

- Autenticação da API com JWT

- Endpoint para autenticação (sign-in)

- Todos os demais endpoints exigem autenticação por token JWT

## Implementação

A encriptação de dados foi implementada usando técnicas derivadas deste repositório:

https://github.com/dwyl/phoenix-ecto-encryption-example

Os campos protegisdos são encriptados usando Advanced Encryption Standard (AES).

Foi criado um campo _cpf_hash_ derivado do cpf, unicamente para se fazer buscas de forma eficiente. O algotitmo de hash é determinístico e rápido e deve _sempre_ retornar o mesmo valor.

O hash da senha usa o algoritmo _pbkdf2_ pseudo-aleatório e mais lento.

Os campos que devem ser encriptados foram definidos como :binary e não :string, por razões de eficiência (ver o artigo https://dba.stackexchange.com/questions/56934/what-is-the-best-way-to-store-a-lot-of-user-encrypted-data).

## Instalação

Para rodar localmente:

- Instalar as dependências com `mix deps.get`
- Criar e e migrar o banco de dados com `mix ecto.setup`.
- Iniciar o endpoint Phoenix com `mix phx.server`

Acessar os endpoints com um cliente API como o CURL ou Insomnia no endereço `localhost:4000`.

## Modelagem dos dados

As seguintes entidades estão definidas:

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
  "referral_code_gen": string,
  "referral_code_inf": string,
  "status": string,
  "password_hash": string,
  "inserted_at": string,
  "updates_at": string,
}
```

## Chamadas de API

**Autenticação**

- [Novo usuário (sign-on)](#sign-on)
- [Conectar (sign-in)](#sign-in)

## Autenticação

Para usar a API é preciso criar um usuário (sign-on) e conectar-se (sign-in).
A autenticação gera um token JWT que deverá ser incluido nas chamadas dos demais
endpoints para autenticar a solicitação.

## sign-on

Cria um novo usuário.

### Request

`POST /api/sign_on`

### Body

JSON com e-mail do usuário e senha. A senha deve ter pelo menos 6 caracteres.

```
{
  "email": "eu@algo.com",
  "password": "secreto",
}
```

### Response

JSON com campos do evento criado.

```
{
  "user": {
    "email": "eu@algo.com",
    "id": 123
  }
}
```

### Erros

Ocorrerá erro se o usuário já existir, se não informar uma senha ou se a senha tiver menos de 6 caracteres.
Nesses casos, a chamada retorna:

```
{
  "errors": [
    {
      "key": "email",
      "message": [
        "has already been taken"
      ]
    }
  ]
}
```

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

```
{
  "errors": [
    {
      "key": "password",
      "message": [
        "should be at least 6 character(s)"
      ]
    }
  ]
}
```

## sign-in

Conectar-se ao serviço

### Request

`POST /api/sign_in`

### Body

JSON com e-mail do usuário e senha.

```
{
  "email": "eu@algo.com",
  "password": "secreto",
}
```

### Response

JSON com o token JWT.

```
{
  "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJvZmZlcnMiLCJleHAiOjE2MDk4Njc0MTAsImlhdCI6MTYwNzQ0ODIxMCwiaXNzIjoib2ZmZXJzIiwianRpIjoiODAyNjQwNDEtODBjNS00NWIzLWJkNjctNGI3ZGFlYjAxNDFjIiwibmJmIjoxNjA3NDQ4MjA5LCJzdWIiOiIxOSIsInR5cCI6ImFjY2VzcyJ9.GGmy0jj-wkCgnyWU7mCLOD3h1zxga5T_kJQSBnFQB68jYspyIqN9r42YcsCutGPrhBtNRRFa5dZkDiZeSaTm0g"
}
```

### Erros

Ocorrerá erro se o usuário não existir ou a senha vor inválida.
Nesses casos, a chamada retorna:

```
{
  "error": "login_error"
}
```

## Consultar indicações

### Request

`GET /api/referrals/:id`

:id é o código da indicação

### Response

JSON com os dados cadastrados.

```
{
  "data": {
    "id": 1,
    "name": "Zé das Couves"
  }
}
```

### Erros

Se ocorrer algum erro ele será mostrado no retorno. Por exemplo:

```
{
  "errors": {
    "detail": "Not Found"
  }
}
```

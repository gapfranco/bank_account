# BankAccount API

## Sumário

API REST em Elixir/Phoenix, modelando um sistema de abertura de contas bacárias.

## Funcionalidades

A criação de uma conta poderá acontecer em etapas: a partir de um **`CPF`**, o(a) potencial cliente informa dados (através de uma ou várias requisições), e desta forma a abertura da conta ficará pendente até que todos os dados estejam devidamente preenchidos.

- Campos definidos: **`cpf`**, **`password`**, **`name`**, **`email`**​, **`birth_date`**, **`gender`**, **`city`**, **`state`**, **`country`**, **`referral_code`**

- Os campos **`cpf`**, **`email`**, **`name`**, e **`birth_date`** são encriptados no banco de dados.

- A conta será considerada **`pending`** até todos os campos serem preenchidos de forma válida. O usuário
  poderá fazer várias requisições parciais até completar. Quando completar a conta passara'para o status **`completed`**

- Quando completar todos os campos, o usuário receberá um código de 8 dígitos (referral_code) que poderá enviar
  a outras pessoas como convite para que também façam seu cadastro.

- Um usuário pode consultar quem se cadastrou com seu código de indicação (_referral code_) com uma chamada de API. Essa chamada só
  pode ser feita se o usuário estiver autenticado. Para se autenticar um usuário deve fazer uma chamada de _login_ passando seu **`CPF`**
  e senha. Se a conexão for bem sucedida, vai retornar um toke **`JWT`** que poderá ser usado nas chamadaautenticada.

## Implementação

A encriptação de dados foi implementada usando técnicas derivadas deste repositório:

https://github.com/dwyl/phoenix-ecto-encryption-example

Os campos protegidos são encriptados usando **`Advanced Encryption Standard (AES)`**.

Foi criado um campo **`cpf_hash`** derivado do cpf, unicamente para se fazer buscas de forma eficiente. Esse algotitmo de hash é determinístico e rápido e deve _sempre_ retornar o mesmo valor.

O hash da senha usa o algoritmo _pbkdf2_, pseudo-aleatório e mais lento.

Os campos que devem ser encriptados foram definidos como **`:binary`** e não **`:string`**, por razões de eficiência (ver o artigo https://dba.stackexchange.com/questions/56934/what-is-the-best-way-to-store-a-lot-of-user-encrypted-data).

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
  "referral_code": string,
  "referral_code_gen": string,
  "status": string,
  "password_hash": string,
  "inserted_at": string,
  "updates_at": string,
}
```

## Chamadas de API

**Autenticação**

- [Nova conta (register)](#register)
- [Conectar (login)](#login)

## register

Registra uma novo conta.

### Request

`POST /api/register`

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

## login

Conectar-se ao serviço

### Request

`POST /api/login`

### Body

JSON com e-mail do usuário e senha.

```
{
  "cpf": "999.999.999-99",
  "password": "secreto",
}
```

### Response

JSON com o token JWT.

```
{
  "message": "Connected",
  "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJvZmZlcnMiLCJleHAiOjE2MDk4Njc0MTAsImlhdCI6MTYwNzQ0ODIxMCwiaXNzIjoib2ZmZXJzIiwianRpIjoiODAyNjQwNDEtODBjNS00NWIzLWJkNjctNGI3ZGFlYjAxNDFjIiwibmJmIjoxNjA3NDQ4MjA5LCJzdWIiOiIxOSIsInR5cCI6ImFjY2VzcyJ9.GGmy0jj-wkCgnyWU7mCLOD3h1zxga5T_kJQSBnFQB68jYspyIqN9r42YcsCutGPrhBtNRRFa5dZkDiZeSaTm0g"
}
```

### Erros

Ocorrerá erro se a conta não existir ou a senha vor inválida.
Nesses casos, a chamada retorna:

```
{
  "error": "login_error"
}
```

## Consultar indicações

### Request

`GET /api/referrals`

### Response

JSON com a lista de contas convidadas pelo usuário atual (logado).

```
{
  "data": {
    "id": 1,
    "name": "Zé das Couves"
  },
  "data": {
    "id": 5,
    "name": "Maria do Carmo"
  }
}
```

### Erros

Se o cadastro do usuário atual não estiver completo retorna erro::

```
{
    "message": "Account register not completed"
}
```

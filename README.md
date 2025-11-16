# IPIGG Conecta

Aplicativo completo (Flutter + Node.js) para conectar membros da IPIGG com mural oficial, feed comunitário e gestão básica de permissões.  
**Produção (Vercel):** [ipiggconecta.vercel.com](https://ipiggconecta.vercel.com)

## Visão geral

- **Frontend:** Flutter (mobile e web), com telas para mural oficial, feed público, perfil, lista administrativa de membros e fluxo de autenticação.
- **Backend:** API REST em Node.js + Express, MySQL e autenticação JWT. Expõe endpoints públicos/privados para mural, feed, comentários, curtidas e administração de usuários.
- **Banco:** MySQL (migrations em `api/database/migrations`). Todas as conexões usam `mysql2/promise` com pool configurável via `.env`.

Estrutura:

```
api/               # API Node.js / Express
ipiggconecta/      # Aplicativo Flutter (mobile/web)
```

## Funcionalidades principais

- Cadastro/login com armazenamento seguro das senhas (bcrypt) e sessões JWT.
- Mural oficial (somente administradores criam/gerenciam avisos; membros apenas leem).
- Feed comunitário com postagens, curtidas, comentários e contagem agregada por usuário.
- Perfil pessoal com dados persistidos e opção de logout.
- Aba “Membros” exclusiva para administradores, incluindo promoção/degradação de papéis.

---

## Backend (api/)

### Requisitos

- Node.js ≥ 18
- MySQL 8 (ou compatível)

### Configuração

1. `cd api`
2. `cp .env.example .env` (crie o arquivo se necessário) e ajuste os valores abaixo:

| Variável             | Descrição                                               |
|----------------------|---------------------------------------------------------|
| `PORT`               | Porta HTTP (padrão 3000).                               |
| `DB_HOST` / `DB_PORT`| Host/porta do MySQL.                                    |
| `DB_SOCKET_PATH`     | Caminho do socket Unix (se aplicável).                  |
| `DB_USER` / `DB_PASSWORD` | Credenciais do banco.                           |
| `DB_NAME`            | Nome do schema (padrão `ipiggconect`).                  |
| `DB_CONNECTION_LIMIT`| Limite do pool (padrão 10).                             |
| `JWT_SECRET`         | Segredo para assinar tokens.                            |

3. Execute as migrations em ordem (`001_create_users.sql`, `002_create_mural.sql`, `003_create_community_feed.sql`, `004_add_role_to_users.sql`).
4. Instale dependências: `npm install`
5. Ambientes:
   - Desenvolvimento: `npm run dev`
   - Produção: `npm start`

### Endpoints principais

- `POST /auth/register`, `POST /auth/login`, `GET /auth/me`
- `GET /mural`, `POST /mural`, `DELETE /mural/:id` (POST/DELETE exigem admin + Bearer token)
- `GET /community`, `POST /community`, `POST /community/:id/like`, `POST /community/:id/comments`, `GET /community/:id/comments`
- `GET /users` (lista membros) e `PATCH /users/:id/role` – ambos restritos a administradores

Swagger/Docs disponíveis em `/docs`.

---

## Frontend (ipiggconecta/)

### Requisitos

- Flutter SDK 3.x
- Dart ≥ 3.x

### Configuração

1. `cd ipiggconecta`
2. Instale dependências: `flutter pub get`
3. Rode o app apontando para sua API:

```bash
flutter run \
  --dart-define API_BASE_URL=http://10.0.2.2:3000
```

Substitua a URL pela instância desejada (ex.: produção usa `https://ipiggconecta.vercel.com` para a Web, e os apps móveis apontam para a API hospedada).

### Principais telas

- **Mural:** lista avisos oficiais, com FloatingActionButton exclusivo para admin publicar.
- **Público:** feed comunitário com posts, curtidas e comentários.
- **Perfil:** mostra dados pessoais e permite logout; carrega via `GET /auth/me`.
- **Membros:** só para administradores; exibe cards com ação “Tornar admin/membro”.
- **Autenticação:** telas de login, cadastro e esqueci minha senha.

### Sessão & navegação

- Sessão persistida em `SharedPreferences` (token + usuário); Bootstrap decide rota inicial (`/home` ou `/login`).
- Navegação inferior dinâmica (aba “Membros” aparece apenas para administradores).

---

## Scripts úteis

| Comando                              | Descrição                                            |
|--------------------------------------|------------------------------------------------------|
| `npm run dev` (na pasta `api/`)      | API em modo watch.                                   |
| `npm start`                          | API em produção.                                     |
| `flutter run --dart-define ...`      | Executa o app apontando para qualquer backend.       |
| `flutter build apk` / `flutter build web` | Builds mobile/web.                               |

---

## Deploy

- **Frontend:** publicado na Vercel em [ipiggconecta.vercel.com](https://ipiggconecta.vercel.com).
- **Backend:** hospede a API (Render, Railway, VPS etc.) e ajuste `API_BASE_URL` nos builds Flutter/Dart define.

---

## Contribuindo

1. Crie um branch a partir do `main`.
2. Faça as alterações com testes manuais (API e app).
3. Abra um PR descrevendo claramente mudanças em frontend/backend/migrations.

Sinta-se à vontade para reportar issues ou sugerir melhorias 💙

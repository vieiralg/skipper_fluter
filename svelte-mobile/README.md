# Skipper Mobile Portal

Pagina Svelte para apresentar o jogo Skipper dentro de um `iframe`, com visual mobile.

## Rodar localmente

1. Gere a versao web do Flutter na raiz do projeto:

```bash
flutter build web
```

2. Instale as dependencias do Svelte:

```bash
cd svelte-mobile
npm install
```

3. Rode a pagina:

```bash
npm run dev
```

Por padrao, o iframe aponta para `http://localhost:8080/`.

Para testar localmente, rode o Flutter Web em um servidor separado:

```bash
cd ../build/web
python -m http.server 8080
```

Em outro terminal, rode o Svelte:

```bash
cd ../../svelte-mobile
npm run dev
```

Se o jogo estiver hospedado em outro caminho, use:

```bash
VITE_GAME_URL="https://exemplo.com/skipper/" npm run dev
```

No PowerShell:

```powershell
$env:VITE_GAME_URL="https://exemplo.com/skipper/"; npm run dev
```

## Build

```bash
npm run build
```

O resultado fica em `svelte-mobile/dist`.

## O que enviar para o repositório

Envie a pasta `svelte-mobile` sem `node_modules` e sem `dist`.

Se precisar servir tudo estaticamente, coloque a build web do Flutter em uma pasta publica do portal e ajuste `VITE_GAME_URL` para esse caminho antes de rodar `npm run build`.

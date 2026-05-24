# 🌿 EcoSnap 🌿

O **EcoSnap** é um aplicativo mobile desenvolvido em **Flutter** para identificação de plantas por meio de imagens. Utilizando a câmera do dispositivo ou imagens da galeria, o app permite reconhecer espécies vegetais de forma rápida, prática e acessível.

Além da identificação, o EcoSnap também funciona como uma rede social voltada à natureza, permitindo que usuários compartilhem informações, experiências e conteúdos sobre suas plantas em uma comunidade interativa.

---

## Funcionalidades

- Captura de imagem pela câmera para identificação de plantas  
- Seleção de imagens diretamente da galeria  
- Identificação de plantas utilizando a API **Plant.id**  
- Sistema de perfil de usuário  
- Comunidade com feed de publicações  
- Criação de postagens contendo:
  - Nome da planta  
  - Descrição  
  - Imagem  
  - Data de publicação  
- Visualização pública de todas as postagens  

---

## Objetivo

O EcoSnap tem como objetivo facilitar o reconhecimento de plantas e promover o compartilhamento de conhecimento entre usuários, criando uma comunidade colaborativa voltada à botânica e à preservação da natureza.

---

## Tecnologias Utilizadas

- **Flutter** (Desenvolvimento mobile)  
- **Dart** (Linguagem de programação)
- **Firebase** (Armazenamento de dados)  
- **Plant.id API** (Reconhecimento de plantas por imagem)  
- **Imgbb API** (Armazenamento de imagens)
- **Git & GitHub** (Controle de versão)  

---

## Como Executar o Projeto

### Pré-requisitos

- Flutter instalado  
- Dart configurado  
- Emulador Android/iOS ou dispositivo físico  
- Chave de API da Plant.id
- Chave de API do Imgbb  

---


### Passo a passo

```bash
# Clone o repositório
git clone https://github.com/AliceBiju/Ecosnap

# Acesse a pasta do projeto
cd Ecosnap

# Instale as dependências
flutter pub get

# Execute o aplicativo
flutter run --dart-define-from-file=.env

# Executar web-only
flutter run --dart-define-from-file=.env -d web-server

# Criar APK para android
flutter build apk --dart-define-from-file=.env --release
```

---

## Configuração do Firebase

Este projeto utiliza o Firestore para banco de dados.

Para conectar seu próprio Firebase ao aplicativo, siga o passo a passo abaixo:

### 1. Criar um projeto no Firebase
1. Acesse o [Console do Firebase](https://console.firebase.google.com/).
2. Clique em **Adicionar projeto** e siga as instruções para criar um novo projeto.
3. No painel do projeto, ative o serviço:
   - **Cloud Firestore** (crie o banco de dados e defina as regras de segurança apropriadas).

### 2. Configurar o FlutterFire CLI
A forma mais rápida de gerar as configurações do Firebase no projeto é utilizando a ferramenta oficial **FlutterFire CLI**:

1. Certifique-se de ter o Node.js instalado em sua máquina.
2. Instale o Firebase CLI globalmente:
   ```bash
   npm install -g firebase-tools
   ```
3. Realize o login na sua conta do Firebase:
   ```bash
   firebase login
   ```
4. Ative o CLI do FlutterFire globalmente:
   ```bash
   dart pub global activate flutterfire_cli
   ```
5. Na raiz do projeto EcoSnap, execute o comando de configuração:
   ```bash
   flutterfire configure
   ```
6. Selecione o projeto criado no passo 1 e marque as plataformas desejadas. O CLI gerará automaticamente o arquivo `lib/firebase_options.dart` e baixará o `google-services.json` para o local correto.

---


## Configuração da Plant.ID API

Para utilizar a identificação de plantas, é necessário obter uma chave da API Plant.id:

- Acesse: https://web.plant.id/
- Crie uma conta
- Gere sua chave de API
- Configure a chave no projeto (.env)

## Configuração do IMGBB API

Para utilizar o envio de imagens, é preciso utilizar um hospedeiro de imagens:

- Acesse https://imgbb.com
- Crie uma conta
- Gere sua chave de API
- Configure a chave no Projeto (.env)


---

## Melhorias Futuras
- Sistema de comentários nas postagens
- Notificações em tempo real
- Integração com localização geográfica das plantas

---

## Licença

Este projeto está sob a licença MIT.

---


##🌿 Sobre o EcoSnap 🌿

O EcoSnap é um projeto de Dispositivos Móveis de alunos do IFSP - Campus Jacaréi que une tecnologia e natureza, permitindo que usuários identifiquem plantas e compartilhem conhecimento em uma comunidade colaborativa. A proposta é tornar o aprendizado sobre o meio ambiente mais acessível, interativo e integrado ao cotidiano.

💚 Conectando pessoas à natureza através da tecnologia.

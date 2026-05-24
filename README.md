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
- **Plant.id API** (Reconhecimento de plantas por imagem)  
- **Git & GitHub** (Controle de versão)  

---

## Tecnologias Futuras

- **Firebase Authentication** (Autenticação de usuários)  
- **Cloud Firestore** (Banco de dados em tempo real)  
- **Firebase Storage** (Armazenamento de imagens)  
- **Firebase Hosting / Functions** (Expansão de backend)  


---

## Como Executar o Projeto

### Pré-requisitos

- Flutter instalado  
- Dart configurado  
- Emulador Android/iOS ou dispositivo físico  
- Chave de API da Plant.id  

### Passo a passo

```bash
# Clone o repositório
git clone https://github.com/AliceBiju/Ecosnap

# Acesse a pasta do projeto
cd Ecosnap

# Instale as dependências
flutter pub get

#

# Execute o aplicativo
flutter run --dart-define-from-file=.env

# Para web-only
flutter run --dart-define-from-file=.env -d web-server
```


---

## Configuração da API

Para utilizar a identificação de plantas, é necessário obter uma chave da API Plant.id:

- Acesse: https://web.plant.id/
- Crie uma conta
- Gere sua chave de API
- Configure a chave no projeto (arquivo de configuração ou variável de ambiente)


---

## Melhorias Futuras
- Sistema de curtidas e comentários nas postagens
- Notificações em tempo real
- Integração com localização geográfica das plantas
- Histórico e estatísticas de identificações
- Contribuição


---

## Licença

Este projeto está sob a licença MIT.

---


##🌿 Sobre o EcoSnap 🌿

O EcoSnap é um projeto de Dispositivos Móveis de alunos do IFSP - Campus Jacaré que une tecnologia e natureza, permitindo que usuários identifiquem plantas e compartilhem conhecimento em uma comunidade colaborativa. A proposta é tornar o aprendizado sobre o meio ambiente mais acessível, interativo e integrado ao cotidiano.

💚 Conectando pessoas à natureza através da tecnologia.

[Canva](https://canva.link/b96q0fu1hno1x35)

---

## 🚀 Arquitetura & Estado Atual de Desenvolvimento (Complemento)

Com as recentes evoluções no desenvolvimento do aplicativo, o **EcoSnap** consolidou-se como um app de produção completo e funcional. Abaixo estão documentados os pilares da arquitetura do projeto e as novas tecnologias e funcionalidades implementadas:

### 📐 Estrutura de Arquitetura (Service-Repository)

O aplicativo foi reestruturado seguindo boas práticas de engenharia de software e os princípios **SOLID**, dividindo as responsabilidades de forma clara e modular em camadas:

- **`lib/screens/` (Apresentação / UI):** Telas do aplicativo (Widgets declarativos como `home_page.dart`, `profile_page.dart`, etc.) focadas unicamente em renderizar a interface e controlar o estado local das interações do usuário.
- **`lib/layout/` (Template Comum):** `main_layout.dart` envelopa as páginas principais fornecendo a barra de navegação inferior premium e o cabeçalho padronizado da marca de forma responsiva.
- **`lib/services/` (Regras de Negócio):** Serviços estruturados (`auth_service.dart`, `post_service.dart`, `history_service.dart`) que executam as validações do sistema e orquestram a comunicação com os repositórios.
- **`lib/repository/` (Acesso a Dados):** Repositórios (`user_repository.dart`, `post_repository.dart`, etc.) encarregados da integração direta com o Firebase e transformação de payloads brutos em modelos de dados tipados.
- **`lib/models/` (Modelos / Entidades):** Classes puras do Dart (`plant_scan.dart`, `post.dart`, `user.dart`) que descrevem a estrutura de dados e oferecem métodos de serialização (`toMap` e `fromMap`).

### 📦 Tecnologias Já Integradas (Da teoria à prática!)

As tecnologias descritas anteriormente como futuras foram **totalmente implementadas e integradas** ao core do projeto:

- **Firebase Authentication:** Controle de login e cadastro dinâmico em tempo real de forma segura.
- **Cloud Firestore:** Armazenamento das publicações da comunidade, histórico de plantas escaneadas e dados de cadastro dos usuários.
- **Firebase Storage:** Upload de fotos capturadas pela câmera ou selecionadas da galeria para os posts da comunidade.
- **SHA-256 Cryptography:** Hashing criptográfico das senhas dos usuários utilizando o pacote oficial `crypto` antes de salvá-las no Firestore, garantindo privacidade e conformidade com boas práticas de segurança.
- **Abstração Multiplataforma (Stubs):** O app utiliza condicionais de compilação com stubs (`session_manager_stub.dart` vs `session_manager_web.dart` e `blob_helper_stub.dart` vs `blob_helper_web.dart`) permitindo executar o gerenciamento de sessões e envio de bytes no navegador (Web) e em emuladores/aparelhos (Mobile) sem erros de compilação.

### 🌟 Funcionalidades Avançadas & Correções Recentes

1. **Homepage Premium Estática:**
   - Visual responsivo livre de rolagens desnecessárias com espaçamentos otimizados.
   - Carrossel principal de espécies com fotos locais majestosas de carregamento offline imediato.
   - Slider de categorias de plantas circular com efeito dinâmico de destaque central (`enlargeCenterPage`).
   - Grande banner interativo de escaneamento em degradê botânico com atalho direto à Câmera.
2. **Fluxo de Login & Registro Integrados:** Tela moderna em modo duplo que alterna suavemente entre cadastro de dados (Nome, E-mail, Senha e Confirmação de Senha) e login simples.
3. **Edição Segura de Perfil:** Atualização de nome e senha. O campo de senha inicia em branco por padrão e a atualização é opcional (sem a necessidade de expor ou digitar a senha antiga).
4. **Criação de Postagens Dinâmicas:** Tela de publicação focada (sem barra de navegação) com cabeçalho de retorno, seletores visuais tracejados para carregamento de fotos da galeria e formulários arredondados.
5. **Histórico de Plantas com Navegação Fluida:** Tela de histórico de escaneamentos integrada ao `MainLayout` que agora exibe uma seta de voltar (`showBackButton`) no topo esquerdo para retornar de forma nativa e integrada à aba de perfil.

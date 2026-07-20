# DesafIA 🧠🤖

**DesafIA** é uma aplicação móvel inovadora desenvolvida em **Flutter**, focada na criação e resolução de quizzes utilizando o poder da Inteligência Artificial. Com a integração da **API do Google Generative AI** (Gemini) e do **Firebase**, os utilizadores podem desafiar-se com perguntas geradas dinamicamente, criar os seus próprios quizzes e acompanhar o seu progresso de forma intuitiva.

## ✨ Funcionalidades Principais

- **Autenticação Segura**: Registo e login de utilizadores utilizando o Firebase Auth (incluindo suporte nativo para Google Sign-In e Apple Sign-In).
- **Geração de Quizzes com IA**: Criação automática de quizzes personalizados em tempo real através da inteligência artificial.
- **Jogabilidade Dinâmica**: Uma interface interativa e fluida para responder a perguntas e testar conhecimentos de diversas áreas.
- **Gestão de Perfil**: Edição e gestão do perfil do utilizador.
- **Dashboard e Resultados**: Acompanhamento dos resultados obtidos nos quizzes e histórico detalhado das atividades.
- **Criação e Edição**: Os utilizadores podem criar novos quizzes, editar perguntas e gerir o seu conteúdo de forma independente.
- **Design Moderno**: Interface amigável com suporte a *Dark Mode* e microinterações atraentes.

## 🛠️ Stack Tecnológico

- **Framework:** [Flutter](https://flutter.dev/)
- **Backend & Base de Dados:** [Firebase](https://firebase.google.com/) (Auth, Cloud Firestore)
- **Inteligência Artificial:** [Google Generative AI (Gemini)](https://ai.google.dev/)
- **Navegação:** [GoRouter](https://pub.dev/packages/go_router)
- **Gestão de Estado:** [Provider](https://pub.dev/packages/provider)
- **Armazenamento Local:** [Sqflite](https://pub.dev/packages/sqflite) e [Shared Preferences](https://pub.dev/packages/shared_preferences)

## 🚀 Como Começar

### Pré-requisitos

Para executar este projeto, necessita das seguintes ferramentas instaladas:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão suportada: `>=3.0.0 <4.0.0`)
- Editor de código (ex: VS Code ou Android Studio)
- Conta no Firebase (para criar o projeto e configurar os acessos)
- Chave de API do Gemini da Google (Google Generative AI)

### Instalação e Execução

1. **Clone este repositório:**
   ```bash
   git clone https://github.com/seu-utilizador/DesafIA.git
   ```

2. **Aceda ao diretório do projeto:**
   ```bash
   cd desaf_i_a
   ```

3. **Instale as dependências do Flutter:**
   ```bash
   flutter pub get
   ```

4. **Configuração do Firebase:**
   Certifique-se de que configura a ligação ao seu projeto Firebase. Pode utilizar a CLI do [FlutterFire](https://firebase.flutter.dev/docs/cli/):
   ```bash
   flutterfire configure
   ```

5. **Configuração da Chave da API (Gemini):**
   Garanta que a chave da API do *Google Generative AI* está devidamente configurada no ambiente do projeto para a geração de quizzes funcionar corretamente.

6. **Execute a aplicação:**
   ```bash
   flutter run
   ```

## 📂 Estrutura do Projeto

O projeto segue uma arquitetura modularizada para facilitar a navegação e escalabilidade do código:

- `lib/pages/`: Contém os principais ecrãs da aplicação, separados por pastas (ex: `dashboard`, `authentication`, `responder_quiz`, `add_quiz`, etc.).
- `lib/auth/`: Tratamento de estado da sessão e utilitários de autenticação (Firebase).
- `lib/backend/`: Ficheiros de comunicação com o Firestore e configurações do Firebase.
- `lib/components/`: Componentes visuais e widgets reutilizáveis ao longo da aplicação.
- `lib/flutter_flow/`: Tema e funções utilitárias partilhadas.

## 🌟 Potenciais Melhorias no Futuro

- **Modo Multiplayer em Tempo Real**: Permitir desafios diretos entre amigos ou utilizadores aleatórios, com pontuação ao vivo.
- **Categorias Mais Avançadas**: Expansão do motor de IA para criar perguntas complexas com suporte a imagens, sons ou fórmulas matemáticas.
- **Sistema de Níveis e Gamificação**: Implementar conquistas (achievements), níveis de experiência (XP) e leaderboards (tabelas de classificação) globais e locais.
- **Suporte Offline Limitado**: Guardar quizzes e resultados no dispositivo utilizando Sqflite para revisão e modo de estudo sem acesso à internet.
- **Notificações Push**: Alertas de novos desafios gerados por IA ou desafios lançados por amigos (via Firebase Cloud Messaging).
- **Exportação de Quizzes**: Possibilidade de exportar os quizzes para formatos PDF ou para plataformas de educação.

## 🤝 Contribuições

Este projeto pode ser utilizado como base ou expandido! Sintam-se à vontade para abrir uma *Issue* ou enviar um *Pull Request* se quiserem sugerir novas ideias, melhorias de código ou adicionar novos recursos.

---
**Desenvolvido com 💙 em Flutter.**

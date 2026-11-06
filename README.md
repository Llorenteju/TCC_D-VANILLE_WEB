# ☕ D’Vanille — Sistema Web

**Cafeteria Inclusiva | Trabalho de Conclusão de Curso**

## Sobre o Projeto

A **D’Vanille** é uma aplicação web desenvolvida com **Flutter e Dart**, como parte do Trabalho de Conclusão de Curso (TCC) do curso Técnico em Desenvolvimento de Sistemas.

O projeto apresenta uma proposta de cafeteria tecnológica e inclusiva, voltada a pessoas com diferentes necessidades e restrições alimentares, como diabetes, Síndrome dos Ovários Policísticos (SOP), intolerância à lactose, doença celíaca e alergias alimentares.

A plataforma web permite que os clientes conheçam a cafeteria, consultem o cardápio, visualizem informações nutricionais, realizem reservas e adquiram vale-presentes. Além disso, disponibiliza um sistema de autoatendimento presencial por QR Code e um painel administrativo para gerenciamento da cafeteria.

## Objetivo

Desenvolver um sistema web que facilite o acesso às informações dos produtos e aos serviços da cafeteria, proporcionando uma experiência de navegação intuitiva, acessível e personalizada.

O sistema busca integrar **inclusão alimentar, autoatendimento e gerenciamento digital**, utilizando recursos tecnológicos para melhorar a experiência dos clientes e a organização do estabelecimento.

## Funcionalidades do Sistema

### 1. Site Público

A área pública permite que visitantes conheçam a D’Vanille e acessem seus serviços.

- **Home:** apresentação da cafeteria, produtos em destaque, ofertas e informações do estabelecimento.
- **Cardápio Digital:** visualização dos produtos organizados por categorias.
- **Detalhes do Produto:** descrição, ingredientes, informações nutricionais, alergênicos e preço.
- **Ofertas:** consulta aos produtos promocionais.
- **Reservas:** agendamento de mesas por data e horário.
- **Shopping:** compra de vale-presentes.
- **Contato:** informações sobre a cafeteria e seus canais de atendimento.
- **Login e Cadastro:** autenticação e criação de contas.
- **Recuperação de Senha:** fluxo de recuperação de acesso.

O cardápio público é destinado à consulta. A realização de pedidos de alimentos pelo site ocorre exclusivamente no fluxo presencial por QR Code.

### 2. Cardápio Digital

O cardápio possui seis categorias principais:

- Bolos
- Salgados
- Doces
- Sobremesas geladas
- Bebidas quentes
- Bebidas geladas

**Recursos implementados na interface:**

- Pesquisa de produtos por nome.
- Filtragem por categoria.
- Seleção simultânea de restrições alimentares.
- Exibição de produtos compatíveis com todos os filtros selecionados.
- Visualização de produtos em oferta.
- Recomendações baseadas nas restrições cadastradas no perfil.

**Filtros alimentares disponíveis:**

Sem APLV, Sem Soja, Sem Oleaginosas, Sem Açúcar Adicionado, Sem Sal Adicionado, Low FODMAP, Low Carb, Sem Aditivos Artificiais, Vegano, Vegetariano, Sem Lactose e Sem Glúten.

Os filtros utilizam as informações cadastradas nos produtos e auxiliam na escolha alimentar. A verificação dos ingredientes e alergênicos continua sendo necessária.

### 3. Autoatendimento por QR Code

O sistema possui um fluxo específico para pedidos presenciais, acessado por meio do QR Code da mesa.

**Funcionalidades:**

- Acesso ao cardápio no contexto da mesa.
- Identificação da mesa.
- Adição de produtos à comanda.
- Alteração das quantidades.
- Remoção de produtos.
- Visualização dos itens pendentes.
- Cálculo de subtotal, desconto e total.
- Aplicação de cupom de aniversário.
- Solicitação de atendimento de garçom.
- Envio do pedido ao caixa.

**Regra de autenticação:** o cliente pode navegar pelo cardápio e montar sua comanda sem estar logado. Entretanto, para enviar o pedido ao caixa, é necessário realizar login ou cadastro.

As páginas de autenticação acessadas pelo fluxo da comanda são apresentadas sem o cabeçalho e o rodapé do site público.

O fluxo de QR Code não disponibiliza reservas ou compras de vale-presentes.

### 4. Área do Cliente

A aplicação possui páginas específicas para usuários autenticados:

- Perfil do usuário.
- Meus Pedidos.
- Acompanhar Pedido.
- Minhas Reservas.
- Meus Vale-presentes.
- Carrinho e checkout dos serviços correspondentes.

O sistema também permite cadastrar preferências e restrições alimentares utilizadas nas recomendações de produtos.

### 5. Painel Administrativo

A área administrativa possui navegação própria, independente do site público, sem exibição do cabeçalho e rodapé utilizados pelos clientes.

**Módulos administrativos:**

| Módulo | Funcionalidade |
|---|---|
| Dashboard | Visão geral das informações do sistema |
| Produtos | Listagem, cadastro, edição e exclusão de produtos |
| Pedidos | Consulta e gerenciamento dos pedidos |
| Reservas | Gerenciamento das reservas de mesas |
| Vale-presentes | Consulta e gerenciamento de vale-presentes |
| Usuários | Visualização e gerenciamento de usuários |

O painel utiliza componentes próprios de navegação, incluindo um menu lateral com ícones SVG.

## Tecnologias Utilizadas

| Tecnologia | Utilização |
|---|---|
| Flutter | Framework para desenvolvimento da interface web |
| Dart | Linguagem de programação |
| Material Design | Componentes de interface |
| Flutter SVG | Exibição de ícones e imagens vetoriais |
| Shared Preferences | Biblioteca de armazenamento local |
| Flutter Localizations | Suporte à localização da aplicação |
| PDF e Printing | Recursos para documentos e impressão |
| Git | Controle de versão |
| GitHub | Versionamento e hospedagem do código-fonte |

### Dependências do Projeto

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_localizations:
    sdk: flutter

  flutter_svg: ^2.2.0
  pdf: ^3.12.0
  printing: ^5.14.3
  shared_preferences: ^2.5.5
```

## Arquitetura e Organização

O projeto utiliza uma estrutura organizada em diretórios, separando páginas, modelos, serviços, configurações e componentes reutilizáveis.

```text
TCC_D-VANILLE_WEB/
│
├── assets/
│   ├── fonts/
│   └── images/
│
├── lib/
│   ├── app/
│   ├── data/
│   ├── models/
│   ├── pages/
│   │   ├── admin/
│   │   ├── home/
│   │   └── ...
│   ├── services/
│   ├── theme/
│   ├── widgets/
│   └── main.dart
│
├── web/
├── pubspec.yaml
└── README.md
```

### Principais Diretórios

**`lib/app/`**

Contém a configuração da aplicação e das rotas de navegação, incluindo os caminhos das páginas públicas, privadas e administrativas.

**`lib/data/`**

Armazena dados de demonstração utilizados pela aplicação, como produtos, usuários, pedidos, reservas e vale-presentes.

**`lib/models/`**

Define os modelos de dados utilizados pelo sistema, como Produto, Usuario, Pedido, Reserva e ValePresente.

**`lib/pages/`**

Contém as telas da aplicação, incluindo Home, Cardápio, Login, Cadastro, Reservas, Shopping, Comanda e páginas administrativas.

**`lib/services/`**

Contém os serviços responsáveis pelo gerenciamento de estados e regras de negócio.

O arquivo `app_state.dart` centraliza funcionalidades como:

- Sessão do usuário.
- Login e logout.
- Cadastro e atualização de perfil.
- Gerenciamento do carrinho.
- Aplicação de cupons.
- Pedidos e reservas.
- Recomendações de produtos.
- Gerenciamento de dados de demonstração.

**`lib/theme/`**

Contém a identidade visual da aplicação, incluindo cores, fontes e configurações dos temas claro e escuro.

**`lib/widgets/`**

Contém componentes reutilizáveis, como:

- `PageShell`
- `DVanilleHeader`
- `DVanilleFooter`
- `ProductCard`
- `AdminShell`
- Componentes do kit de interface

## Regras de Negócio

### Cadastro e Login

- Cadastro de usuários em etapas.
- Validação de e-mail duplicado.
- Senha com no mínimo seis caracteres, uma letra maiúscula e um caractere especial.
- Confirmação de senha.
- Controle de sessão.
- Restrição de acesso às páginas administrativas.
- Redirecionamento para autenticação quando necessário.

### Cupons e Descontos

O sistema contempla regras para aplicação de cupons.

**Cupom de aniversário — `ANIVERSARIO`:**

- Desconto de 15%.
- Válido durante a semana do aniversário.
- Exige usuário autenticado.
- Exige itens pendentes na comanda.
- Não permite aplicar o mesmo cupom mais de uma vez na comanda.

### Pedidos

Os pedidos possuem estados utilizados para acompanhamento e gerenciamento:

- Recebido.
- Em preparação.
- Pronto.
- Finalizado.

### Produtos

O gerenciamento administrativo contempla validações de cadastro, como verificação de nomes duplicados e valores inválidos.

## Interface e Identidade Visual

A identidade visual da D’Vanille utiliza uma paleta de tons suaves, com destaque para creme, rosa e marrom.

| Cor | Código hexadecimal |
|---|---|
| Creme | `#FFF4E8` |
| Creme secundário | `#FFEEDD` |
| Taupe | `#9C8A73` |
| Taupe escuro | `#7C6C58` |
| Rosa claro | `#EFCDCC` |
| Rosa secundário | `#F6DEDC` |
| Rosa destaque | `#C98F8C` |
| Marrom escuro | `#2B2420` |

### Tipografia

- **CreamCake:** títulos e elementos de destaque.
- **DancingScript:** elementos tipográficos personalizados.

### Responsividade e Acessibilidade

O sistema contempla:

- Adaptação de componentes para diferentes larguras de tela.
- Menu de navegação compacto em resoluções menores.
- Layouts com organização responsiva.
- Tema claro e escuro.
- Ajustes de tamanho de fonte.
- Componentes visuais reutilizáveis.

## Como Executar o Projeto

### Pré-requisitos

Para executar o sistema, é necessário possuir:

- Flutter SDK instalado.
- Dart SDK.
- Visual Studio Code ou Android Studio.
- Git.
- Navegador Google Chrome.

### 1. Clonar o repositório

```bash
git clone https://github.com/Llorenteju/TCC_D-VANILLE_WEB.git
```

### 2. Acessar o diretório

```bash
cd TCC_D-VANILLE_WEB
```

### 3. Instalar as dependências

```bash
flutter pub get
```

### 4. Executar a aplicação web

```bash
flutter run -d chrome
```

## Contas de Demonstração

O projeto possui contas fictícias para testes das funcionalidades de cliente e administrador.

| Perfil | E-mail | Senha |
|---|---|---|
| Cliente | `marina@email.com` | `Marina@123` |
| Administrador | `admin@dvanille.com` | `Admin@123` |

Essas credenciais são destinadas exclusivamente ao ambiente acadêmico de demonstração.

## Armazenamento de Dados

O protótipo utiliza dados de demonstração definidos no projeto e gerenciamento de estado por meio do `AppState`.

As listas de produtos, usuários, pedidos, reservas e vale-presentes são utilizadas para simular o funcionamento do sistema.

O pacote `shared_preferences` está incluído nas dependências. A persistência de cada informação depende da implementação correspondente, não devendo ser confundida com um banco de dados de produção.

## Status do Projeto

**Em desenvolvimento acadêmico.**

O sistema web está sendo aprimorado com ajustes de interface, responsividade, navegação, regras de negócio e organização do código.

## Equipe do TCC

**Projeto:** D’Vanille — Cafeteria Inclusiva

**Curso:** Técnico em Desenvolvimento de Sistemas

**Turma:** DS2B

**Integrantes:**

- Ana Clara de Souza Torres
- Julia Leite Llorente
- Karina de Souza Honorato do Nascimento
- Viviane Dias Nunes

## Repositório

**Sistema Web D’Vanille**

https://github.com/Llorenteju/TCC_D-VANILLE_WEB

---

**D’Vanille — Sabor, acolhimento e inclusão.**

*Projeto desenvolvido para fins acadêmicos como parte do Trabalho de Conclusão de Curso.*
# D'Vanille — versão Flutter fiel ao protótipo HTML

Protótipo da cafeteria D'Vanille reescrito em Flutter seguindo as regras do
protótipo HTML (dados, validações, fluxos e telas).

## Como abrir
1. Extraia a pasta.
2. Abra a pasta no VS Code.
3. No terminal:
   flutter pub get
   flutter run -d chrome

## Login de demonstração
- Cliente: marina@email.com / Marina@123
- Administrador: admin@dvanille.com / Admin@123

## Estrutura
- lib/app: rotas + guarda de rotas privadas/admin (equivale ao navigate() do HTML)
- lib/theme: paleta, tema claro/escuro e selos de status
- lib/models: Produto, Usuario, Pedido, Reserva, ValePresente, ItemCarrinho
- lib/data: os 16 produtos, usuários, pedidos, reservas, vale-presentes, cupons e horários
- lib/services: AppState (sessão, carrinho, cupom, CRUD, acessibilidade) e navegação/toast
- lib/widgets: header, footer, shell, card de produto e kit de UI
- lib/pages: cada tela do protótipo

## O que foi reproduzido do HTML
- 16 produtos com descrição, ingredientes, tabela nutricional, alergênicos,
  restrições, preço antigo e selo de oferta
- Login com senha, cadastro em 2 etapas (e-mail duplicado, senha com maiúscula
  e caractere especial, confirmação) e recuperação de senha
- Rotas privadas e de administrador, com redirecionamento de volta após o login
- Cardápio com busca, abas de categoria, filtros múltiplos por restrição
  (todas precisam bater) e bloco "Recomendado para você"
- Carrinho com quantidades, remoção, cupons PRIMEIRACOMPRA (10%) e
  ANIVERSARIO (15%), subtotal/desconto/total
- Checkout nos dois modos ("enviar ao caixa" e "retirar na cafeteria"),
  gerando pedido PDxxxx, recibo e acompanhamento em 5 etapas
- Reservas com data, horários fixos do protótipo e validação de data passada
- Shopping: vale-presente selecionável, emissão do código e envio ao carrinho
- Admin: dashboard, CRUD de produtos com validações (nome duplicado, preço
  negativo), status de pedidos e reservas, vale-presentes e usuários
- Widget de acessibilidade: aumento/redução de fonte e modo escuro

## Diferença consciente
O HTML persiste os dados em localStorage. Aqui o estado fica em memória
(reinicia ao recarregar a página). Para persistir, basta adicionar o pacote
shared_preferences e salvar/ler o AppState.

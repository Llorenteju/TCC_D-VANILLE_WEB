import '../models/pedido.dart';
import '../models/produto.dart';
import '../models/reserva.dart';
import '../models/usuario.dart';
import '../models/vale_presente.dart';

/// URLs das imagens (as mesmas do protótipo HTML).
class Img {
  static const hero =
      'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=1200&q=80';
  static const about =
      'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=900&q=80';
  static const espresso =
      'https://images.unsplash.com/photo-1510707577719-ae7c14805e3a?auto=format&fit=crop&w=500&q=80';
  static const cappuccino =
      'https://images.unsplash.com/photo-1572442388796-11668a67e53d?auto=format&fit=crop&w=500&q=80';
  static const mocha =
      'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?auto=format&fit=crop&w=500&q=80';
  static const latte =
      'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=500&q=80';
  static const cupcake =
      'https://images.unsplash.com/photo-1587668178277-295251f900ce?auto=format&fit=crop&w=500&q=80';
  static const brownie =
      'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=500&q=80';
  static const cinnamon =
      'https://images.unsplash.com/photo-1509365465985-25d11c17e812?auto=format&fit=crop&w=500&q=80';
  static const donut =
      'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=500&q=80';
  static const carrotcake =
      'https://images.unsplash.com/photo-1621303837174-89787a7d4729?auto=format&fit=crop&w=500&q=80';
  static const appletart =
      'https://images.unsplash.com/photo-1568571780765-9276ac8b75a2?auto=format&fit=crop&w=500&q=80';
  static const croissant =
      'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=500&q=80';
  static const quiche =
      'https://images.unsplash.com/photo-1623334044303-241021148842?auto=format&fit=crop&w=500&q=80';
  static const empada =
      'https://images.unsplash.com/photo-1541599468348-e96984315921?auto=format&fit=crop&w=500&q=80';
  static const shakeStraw =
      'https://images.unsplash.com/photo-1541658016709-82535e94bc69?auto=format&fit=crop&w=500&q=80';
  static const shakeChoc =
      'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=500&q=80';
  static const shakeVanilla =
      'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=500&q=80';
}

class Categoria {
  final String id;
  final String label;
  final String emoji;
  const Categoria(this.id, this.label, this.emoji);
}

/// Mesmas categorias e ordem do HTML.
const List<Categoria> categorias = [
  Categoria('bolo', 'Bolo', '🎂'),
  Categoria('salgados', 'Salgados', '🥐'),
  Categoria('doces', 'Doces', '🧁'),
  Categoria('sobremesas-geladas', 'Sobremesas Geladas', '🍧'),
  Categoria('bebidas-quentes', 'Bebidas Quentes', '☕'),
  Categoria('bebidas-geladas', 'Bebidas Geladas', '🥤'),
];

String labelCategoria(String id) {
  for (final c in categorias) {
    if (c.id == id) return c.label;
  }
  return id;
}

/// Chaves de restrição e rótulos — iguais ao objeto RESTRICOES_LABEL do HTML.
const Map<String, String> restricoesLabels = {
  'semAPLV': 'Sem APLV',
  'semSoja': 'Sem Soja',
  'semOleaginosas': 'Sem Oleaginosas',
  'semAcucarAdicionado': 'Sem Açúcar Adicionado',
  'semSalAdicionado': 'Sem Sal Adicionado',
  'lowFODMAP': 'Low FODMAP',
  'lowCarb': 'Low Carb',
  'semAditivosArtificiais': 'Sem Aditivos Artificiais',
  'vegano': 'Vegano',
  'vegetariano': 'Vegetariano',
  'semLactose': 'Sem Lactose',
  'semGluten': 'Sem Glúten',
};

/// Cupons aceitos no carrinho (valor = percentual de desconto).
const Map<String, double> cupons = {
  'PRIMEIRACOMPRA': 0.10,
  'ANIVERSARIO': 0.15,
};

const List<String> horariosReserva = [
  '09:00',
  '10:30',
  '12:00',
  '14:00',
  '15:30',
  '17:00',
  '18:30',
  '20:00',
];

/// Opções do passo 2 do cadastro (mesma lista do HTML).
const List<List<String>> opcoesRestricaoCadastro = [
  ['nenhuma', 'Nenhuma'],
  ['diabetes', 'Diabetes'],
  ['sop', 'SOP (Síndrome dos Ovários Policísticos)'],
  ['hipertensao', 'Hipertensão'],
  ['sii', 'Síndrome do Intestino Irritável (SII)'],
  ['semLactose', 'Intolerância à Lactose'],
  ['celiaca', 'Doença Celíaca'],
  ['sensibilidadeGluten', 'Sensibilidade ao Glúten'],
  ['aplv', 'Alergia à Proteína do Leite (APLV)'],
  ['alergiaOleaginosas', 'Alergia a Oleaginosas'],
  ['vegetariano', 'Vegetariano'],
  ['vegano', 'Vegano'],
  ['lowCarb', 'Low Carb'],
  ['outra', 'Outra'],
];

List<Produto> seedProdutos() => [
      Produto(
        id: 1,
        nome: 'Espresso Tradicional',
        categoria: 'bebidas',
        preco: 8.50,
        imagem: Img.espresso,
        icon: '☕',
        descricao:
            'Café espresso encorpado, extraído na hora, com notas amadeiradas e final levemente adocicado.',
        ingredientes: ['Café arábica torrado', 'Água filtrada'],
        nutricional: Nutricional(calorias: 5, carboidratos: 1),
        restricoes: [
          'semGluten',
          'semLactose',
          'vegano',
          'vegetariano',
          'menosAcucar'
        ],
        alergenicos: ['Nenhum alergênico conhecido'],
      ),
      Produto(
        id: 2,
        nome: 'Cappuccino Clássico',
        categoria: 'bebidas',
        preco: 12.90,
        imagem: Img.cappuccino,
        icon: '☕',
        descricao:
            'Espresso, leite vaporizado e uma camada aveludada de espuma finalizada com canela.',
        ingredientes: ['Café arábica', 'Leite integral', 'Canela em pó'],
        nutricional: Nutricional(
            calorias: 110,
            carboidratos: 10,
            proteinas: 6,
            gorduras: 5,
            acucares: 9),
        restricoes: ['semGluten', 'vegetariano'],
        alergenicos: ['Leite'],
      ),
      Produto(
        id: 3,
        nome: 'Mocha Rosé',
        categoria: 'bebidas',
        preco: 15.90,
        precoAntigo: 19.90,
        oferta: true,
        imagem: Img.mocha,
        icon: '☕',
        descricao:
            'Espresso com chocolate belga, leite vaporizado e finalização em pétalas de flor comestível.',
        ingredientes: [
          'Café arábica',
          'Chocolate belga',
          'Leite integral',
          'Flor comestível'
        ],
        nutricional: Nutricional(
            calorias: 190,
            carboidratos: 22,
            proteinas: 6,
            gorduras: 8,
            fibras: 1,
            acucares: 18),
        restricoes: ['semGluten', 'vegetariano'],
        alergenicos: ['Leite', 'Cacau'],
      ),
      Produto(
        id: 4,
        nome: 'Latte Baunilha',
        categoria: 'bebidas',
        preco: 14.50,
        imagem: Img.latte,
        icon: '☕',
        descricao:
            'Café suave com leite cremoso e xarope artesanal de baunilha.',
        ingredientes: ['Café arábica', 'Leite integral', 'Xarope de baunilha'],
        nutricional: Nutricional(
            calorias: 160,
            carboidratos: 20,
            proteinas: 6,
            gorduras: 6,
            acucares: 17),
        restricoes: ['semGluten', 'vegetariano'],
        alergenicos: ['Leite'],
      ),
      Produto(
        id: 5,
        nome: 'Cupcake de Morango',
        categoria: 'doces',
        preco: 11.90,
        imagem: Img.cupcake,
        icon: '🧁',
        descricao:
            'Massa fofinha de baunilha, recheio de morango e cobertura de buttercream rosé.',
        ingredientes: [
          'Farinha de trigo',
          'Ovos',
          'Manteiga',
          'Leite',
          'Morango',
          'Açúcar'
        ],
        nutricional: Nutricional(
            calorias: 320,
            carboidratos: 38,
            proteinas: 4,
            gorduras: 16,
            fibras: 1,
            acucares: 26),
        restricoes: ['vegetariano'],
        alergenicos: ['Glúten', 'Leite', 'Ovo'],
      ),
      Produto(
        id: 6,
        nome: 'Brownie Sem Glúten',
        categoria: 'doces',
        preco: 13.90,
        imagem: Img.brownie,
        icon: '🍫',
        descricao:
            'Brownie intenso de chocolate 70%, feito com farinha de amêndoas, sem glúten.',
        ingredientes: [
          'Chocolate 70%',
          'Farinha de amêndoas',
          'Ovos',
          'Manteiga',
          'Açúcar demerara'
        ],
        nutricional: Nutricional(
            calorias: 290,
            carboidratos: 24,
            proteinas: 5,
            gorduras: 19,
            fibras: 3,
            acucares: 18),
        restricoes: ['semGluten', 'vegetariano'],
        alergenicos: ['Leite', 'Ovo', 'Amêndoas'],
      ),
      Produto(
        id: 7,
        nome: 'Cinnamon Roll',
        categoria: 'doces',
        preco: 12.50,
        imagem: Img.cinnamon,
        icon: '🥐',
        descricao:
            'Rolinho de canela amanteigado, coberto com cream cheese glacê.',
        ingredientes: [
          'Farinha de trigo',
          'Manteiga',
          'Canela',
          'Cream cheese',
          'Açúcar'
        ],
        nutricional: Nutricional(
            calorias: 340,
            carboidratos: 42,
            proteinas: 5,
            gorduras: 16,
            fibras: 1,
            acucares: 24),
        restricoes: ['vegetariano'],
        alergenicos: ['Glúten', 'Leite', 'Ovo'],
      ),
      Produto(
        id: 8,
        nome: 'Donut Rosé',
        categoria: 'doces',
        preco: 9.90,
        imagem: Img.donut,
        icon: '🍩',
        descricao: 'Donut macio coberto com glacê rosé e confeitos delicados.',
        ingredientes: [
          'Farinha de trigo',
          'Ovos',
          'Leite',
          'Açúcar',
          'Corante natural de beterraba'
        ],
        nutricional: Nutricional(
            calorias: 250,
            carboidratos: 32,
            proteinas: 3,
            gorduras: 11,
            fibras: 1,
            acucares: 20),
        restricoes: ['vegetariano'],
        alergenicos: ['Glúten', 'Leite', 'Ovo'],
      ),
      Produto(
        id: 9,
        nome: 'Bolo de Cenoura Vegano',
        categoria: 'bolos',
        preco: 14.90,
        precoAntigo: 17.90,
        oferta: true,
        imagem: Img.carrotcake,
        icon: '🍰',
        descricao:
            'Bolo fofinho de cenoura com cobertura de chocolate, 100% livre de ingredientes de origem animal.',
        ingredientes: [
          'Farinha de trigo',
          'Cenoura',
          'Óleo vegetal',
          'Açúcar',
          'Cacau'
        ],
        nutricional: Nutricional(
            calorias: 280,
            carboidratos: 36,
            proteinas: 3,
            gorduras: 12,
            fibras: 2,
            acucares: 22),
        restricoes: ['vegano', 'vegetariano', 'semLactose'],
        alergenicos: ['Glúten'],
      ),
      Produto(
        id: 10,
        nome: 'Torta de Maçã Sem Açúcar',
        categoria: 'bolos',
        preco: 16.90,
        imagem: Img.appletart,
        icon: '🥧',
        descricao:
            'Torta crocante de maçã adoçada naturalmente, sem adição de açúcar refinado.',
        ingredientes: [
          'Farinha de trigo',
          'Maçã',
          'Manteiga',
          'Canela',
          'Adoçante natural'
        ],
        nutricional: Nutricional(
            calorias: 210,
            carboidratos: 29,
            proteinas: 2,
            gorduras: 9,
            fibras: 3,
            acucares: 8),
        restricoes: ['vegetariano', 'menosAcucar'],
        alergenicos: ['Glúten', 'Leite'],
      ),
      Produto(
        id: 11,
        nome: 'Croissant Amanteigado',
        categoria: 'salgados',
        preco: 10.90,
        imagem: Img.croissant,
        icon: '🥐',
        descricao:
            'Croissant folhado clássico, amanteigado e crocante por fora.',
        ingredientes: [
          'Farinha de trigo',
          'Manteiga',
          'Ovos',
          'Leite',
          'Fermento'
        ],
        nutricional: Nutricional(
            calorias: 270,
            carboidratos: 26,
            proteinas: 5,
            gorduras: 15,
            fibras: 1,
            acucares: 3),
        restricoes: ['vegetariano'],
        alergenicos: ['Glúten', 'Leite', 'Ovo'],
      ),
      Produto(
        id: 12,
        nome: 'Quiche de Espinafre',
        categoria: 'salgados',
        preco: 17.90,
        imagem: Img.quiche,
        icon: '🥧',
        descricao:
            'Massa amanteigada recheada com espinafre, queijos finos e um toque de noz-moscada.',
        ingredientes: [
          'Farinha de trigo',
          'Espinafre',
          'Ovos',
          'Queijo',
          'Creme de leite'
        ],
        nutricional: Nutricional(
            calorias: 310,
            carboidratos: 18,
            proteinas: 11,
            gorduras: 21,
            fibras: 2,
            acucares: 2),
        restricoes: ['vegetariano'],
        alergenicos: ['Glúten', 'Ovo', 'Leite'],
      ),
      Produto(
        id: 13,
        nome: 'Empada de Palmito Vegana',
        categoria: 'salgados',
        preco: 13.90,
        imagem: Img.empada,
        icon: '🥟',
        descricao: 'Massa crocante recheada com palmito refogado, 100% vegana.',
        ingredientes: [
          'Farinha de trigo',
          'Palmito',
          'Óleo vegetal',
          'Temperos naturais'
        ],
        nutricional: Nutricional(
            calorias: 230,
            carboidratos: 27,
            proteinas: 4,
            gorduras: 11,
            fibras: 2,
            acucares: 1),
        restricoes: ['vegano', 'vegetariano', 'semLactose'],
        alergenicos: ['Glúten'],
      ),
      Produto(
        id: 14,
        nome: 'Milk Shake de Morango',
        categoria: 'sobremesas-geladas',
        preco: 16.90,
        precoAntigo: 19.90,
        oferta: true,
        imagem: Img.shakeStraw,
        icon: '🥤',
        descricao:
            'Milk shake cremoso de morango natural com chantilly e calda artesanal.',
        ingredientes: [
          'Leite',
          'Sorvete de morango',
          'Morango natural',
          'Chantilly'
        ],
        nutricional: Nutricional(
            calorias: 380,
            carboidratos: 48,
            proteinas: 7,
            gorduras: 16,
            fibras: 2,
            acucares: 40),
        restricoes: ['vegetariano'],
        alergenicos: ['Leite'],
      ),
      Produto(
        id: 15,
        nome: 'Milk Shake Vegano de Chocolate',
        categoria: 'sobremesas-geladas',
        preco: 17.90,
        imagem: Img.shakeChoc,
        icon: '🥤',
        descricao:
            'Milk shake encorpado feito com leite e sorvete vegetal de chocolate.',
        ingredientes: [
          'Leite de aveia',
          'Sorvete vegetal de chocolate',
          'Cacau'
        ],
        nutricional: Nutricional(
            calorias: 310,
            carboidratos: 44,
            proteinas: 4,
            gorduras: 11,
            fibras: 3,
            acucares: 30),
        restricoes: ['vegano', 'vegetariano', 'semLactose'],
        alergenicos: ['Aveia'],
      ),
      Produto(
        id: 16,
        nome: 'Milk Shake Baunilha Sem Açúcar',
        categoria: 'sobremesas-geladas',
        preco: 16.90,
        imagem: Img.shakeVanilla,
        icon: '🥤',
        descricao:
            'Milk shake leve de baunilha, adoçado naturalmente, sem açúcar adicionado.',
        ingredientes: ['Leite', 'Sorvete diet de baunilha', 'Baunilha natural'],
        nutricional: Nutricional(
            calorias: 220,
            carboidratos: 26,
            proteinas: 6,
            gorduras: 9,
            fibras: 1,
            acucares: 10),
        restricoes: ['vegetariano', 'menosAcucar'],
        alergenicos: ['Leite'],
      ),
    ];

List<Usuario> seedUsuarios() => [
      Usuario(
        id: 1,
        nome: 'Marina Ferreira',
        email: 'marina@email.com',
        senha: 'Marina@123',
        telefone: '(11) 98888-1234',
        endereco: 'Rua das Flores, 120 — São Paulo/SP',
        tipo: 'cliente',
        restricoes: ['semGluten', 'vegano'],
      ),
      Usuario(
        id: 2,
        nome: "Administrador D'Vanille",
        email: 'admin@dvanille.com',
        senha: 'Admin@123',
        telefone: '(11) 3333-4444',
        endereco: '—',
        tipo: 'admin',
      ),
    ];

List<Pedido> seedPedidos() => [
      Pedido(
        id: 'PD1042',
        clienteEmail: 'marina@email.com',
        itens: [
          ItemPedido(
              produtoId: '1', nome: 'Espresso Tradicional', preco: 8.5, qtd: 2),
          ItemPedido(
              produtoId: '5', nome: 'Cupcake de Morango', preco: 11.9, qtd: 1),
        ],
        total: 28.90,
        data: '02/09/2026 09:15',
        status: 'finalizado',
      ),
      Pedido(
        id: 'PD1077',
        clienteEmail: 'marina@email.com',
        itens: [
          ItemPedido(
              produtoId: '9',
              nome: 'Bolo de Cenoura Vegano',
              preco: 14.9,
              qtd: 1),
          ItemPedido(
              produtoId: '15',
              nome: 'Milk Shake Vegano de Chocolate',
              preco: 17.9,
              qtd: 1),
        ],
        total: 32.80,
        data: '08/09/2026 16:40',
        status: 'em preparação',
      ),
    ];

List<Reserva> seedReservas() => [
      Reserva(
        id: 'RS301',
        nome: 'Marina Ferreira',
        email: 'marina@email.com',
        telefone: '(11) 98888-1234',
        data: '2026-09-15',
        horario: '18:00',
        pessoas: 2,
        preferencias: 'Mesa perto da janela',
        status: 'confirmada',
      ),
    ];

List<ValePresente> seedValePresentes() => [
      ValePresente(
        id: 'VP001',
        valor: 50,
        codigo: 'DVAN-8841-ROSE',
        status: 'ativo',
        criadoEm: '2026-08-20',
        destinatario: 'Camila Souza',
      ),
    ];

/*
===============================================================================
PROJETO: Sistema de Vendas Diretas para Revendedores
BANCO: PostgreSQL

OBJETIVO:
Criar a estrutura inicial de um sistema de vendas B2B/diretas para
revendedores.

ENTIDADES PRINCIPAIS:
- categorias
- produtos
- revendedores
- pedidos
- itens_pedido
- pagamentos

RELACIONAMENTOS:

categorias 1 ---- N produtos

revendedores 1 ---- N pedidos

pedidos 1 ---- N itens_pedido

produtos 1 ---- N itens_pedido

pedidos 1 ---- N pagamentos
===============================================================================
*/


/*
===============================================================================
1. TABELA: categorias
-------------------------------------------------------------------------------
Armazena as categorias dos produtos.
===============================================================================
*/

CREATE TABLE categorias (
    id_categoria SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


/*
===============================================================================
2. TABELA: produtos
-------------------------------------------------------------------------------
Cadastro dos produtos comercializados.
===============================================================================
*/

CREATE TABLE produtos (
    id_produto SERIAL PRIMARY KEY,

    id_categoria INTEGER NOT NULL,

    nome VARCHAR(150) NOT NULL,
    descricao TEXT,

    preco_venda NUMERIC(10,2) NOT NULL,
    custo NUMERIC(10,2),

    estoque INTEGER NOT NULL DEFAULT 0,

    ativo BOOLEAN NOT NULL DEFAULT TRUE,

    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_produto_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES categorias(id_categoria),

    CONSTRAINT chk_produto_preco
        CHECK (preco_venda >= 0),

    CONSTRAINT chk_produto_custo
        CHECK (custo IS NULL OR custo >= 0),

    CONSTRAINT chk_produto_estoque
        CHECK (estoque >= 0)
);


/*
===============================================================================
3. TABELA: revendedores
-------------------------------------------------------------------------------
Cadastro dos clientes que compram os produtos para revenda.
===============================================================================
*/

CREATE TABLE revendedores (
    id_revendedor SERIAL PRIMARY KEY,

    nome VARCHAR(150) NOT NULL,

    cpf_cnpj VARCHAR(20) UNIQUE,

    telefone VARCHAR(30),

    email VARCHAR(150) UNIQUE,

    endereco VARCHAR(200),
    numero VARCHAR(20),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado CHAR(2),
    cep VARCHAR(10),

    ativo BOOLEAN NOT NULL DEFAULT TRUE,

    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


/*
===============================================================================
4. TABELA: PEDIDOS
-------------------------------------------------------------------------------
Representa cada venda realizada para um revendedor.
===============================================================================
*/

CREATE TABLE pedidos (
    id_pedido SERIAL PRIMARY KEY,

    id_revendedor INTEGER NOT NULL,

    data_pedido TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    status VARCHAR(30) NOT NULL DEFAULT 'PENDENTE',

    desconto NUMERIC(10,2) NOT NULL DEFAULT 0,

    valor_total NUMERIC(10,2) NOT NULL DEFAULT 0,

    observacao TEXT,

    CONSTRAINT fk_pedido_revendedor
        FOREIGN KEY (id_revendedor)
        REFERENCES revendedores(id_revendedor),

    CONSTRAINT chk_pedido_desconto
        CHECK (desconto >= 0),

    CONSTRAINT chk_pedido_valor_total
        CHECK (valor_total >= 0),

    CONSTRAINT chk_pedido_status
        CHECK (
            status IN (
                'PENDENTE',
                'CONFIRMADO',
                'SEPARACAO',
                'ENVIADO',
                'ENTREGUE',
                'CANCELADO'
            )
        )
);


/*
===============================================================================
5. TABELA: ITENS_PEDIDO
-------------------------------------------------------------------------------
Cada registro representa um produto dentro de um pedido.

Exemplo:

Pedido 1001
- 10 camisetas
- 5 calças
- 20 bonés

Cada produto será uma linha nesta tabela.
===============================================================================
*/

CREATE TABLE itens_pedido (
    id_item SERIAL PRIMARY KEY,

    id_pedido INTEGER NOT NULL,

    id_produto INTEGER NOT NULL,

    quantidade INTEGER NOT NULL,

    preco_unitario NUMERIC(10,2) NOT NULL,

    desconto NUMERIC(10,2) NOT NULL DEFAULT 0,

    subtotal NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_item_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedidos(id_pedido)
        ON DELETE CASCADE,

    CONSTRAINT fk_item_produto
        FOREIGN KEY (id_produto)
        REFERENCES produtos(id_produto),

    CONSTRAINT chk_item_quantidade
        CHECK (quantidade > 0),

    CONSTRAINT chk_item_preco
        CHECK (preco_unitario >= 0),

    CONSTRAINT chk_item_desconto
        CHECK (desconto >= 0),

    CONSTRAINT chk_item_subtotal
        CHECK (subtotal >= 0)
);


/*
===============================================================================
6. TABELA: PAGAMENTOS
-------------------------------------------------------------------------------
Registra os pagamentos relacionados aos pedidos.

Um pedido pode ter um ou mais pagamentos.
===============================================================================
*/

CREATE TABLE pagamentos (
    id_pagamento SERIAL PRIMARY KEY,

    id_pedido INTEGER NOT NULL,

    data_pagamento TIMESTAMP,

    valor NUMERIC(10,2) NOT NULL,

    forma_pagamento VARCHAR(30) NOT NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'PENDENTE',

    observacao TEXT,

    CONSTRAINT fk_pagamento_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedidos(id_pedido),

    CONSTRAINT chk_pagamento_valor
        CHECK (valor > 0),

    CONSTRAINT chk_pagamento_forma
        CHECK (
            forma_pagamento IN (
                'PIX',
                'DINHEIRO',
                'CARTAO_CREDITO',
                'CARTAO_DEBITO',
                'BOLETO',
                'TRANSFERENCIA'
            )
        ),

    CONSTRAINT chk_pagamento_status
        CHECK (
            status IN (
                'PENDENTE',
                'PAGO',
                'CANCELADO'
            )
        )
);


/*
===============================================================================
7. ÍNDICES
-------------------------------------------------------------------------------
Índices ajudam o banco a encontrar registros com mais eficiência.

Neste primeiro momento estamos criando apenas alguns índices importantes.
===============================================================================
*/

CREATE INDEX idx_produtos_categoria
    ON produtos(id_categoria);

CREATE INDEX idx_pedidos_revendedor
    ON pedidos(id_revendedor);

CREATE INDEX idx_pedidos_data
    ON pedidos(data_pedido);

CREATE INDEX idx_itens_pedido_pedido
    ON itens_pedido(id_pedido);

CREATE INDEX idx_itens_pedido_produto
    ON itens_pedido(id_produto);

CREATE INDEX idx_pagamentos_pedido
    ON pagamentos(id_pedido);


/*
===============================================================================
8. DADOS INICIAIS
-------------------------------------------------------------------------------
Dados fictícios para podermos testar o banco.

IMPORTANTE:
Estes dados são apenas para estudo.
===============================================================================
*/

INSERT INTO categorias (nome, descricao)
VALUES
    ('Roupas', 'Produtos de vestuário'),
    ('Calçados', 'Calçados em geral'),
    ('Acessórios', 'Acessórios diversos');


INSERT INTO produtos
    (id_categoria, nome, descricao, preco_venda, custo, estoque)
VALUES
    (1, 'Camiseta Básica', 'Camiseta básica de algodão', 39.90, 20.00, 100),
    (1, 'Calça Jeans', 'Calça jeans tradicional', 89.90, 45.00, 50),
    (2, 'Tênis Casual', 'Tênis casual para uso diário', 129.90, 70.00, 30),
    (3, 'Boné Tradicional', 'Boné ajustável', 29.90, 12.00, 80);


INSERT INTO revendedores
    (
        nome,
        cpf_cnpj,
        telefone,
        email,
        endereco,
        numero,
        bairro,
        cidade,
        estado,
        cep
    )
VALUES
    (
        'João da Silva',
        '12345678000100',
        '31999999999',
        'joao@example.com',
        'Rua das Flores',
        '100',
        'Centro',
        'Belo Horizonte',
        'MG',
        '30000000'
    ),
    (
        'Maria Comércio',
        '98765432000100',
        '31888888888',
        'maria@example.com',
        'Avenida Brasil',
        '500',
        'Centro',
        'Contagem',
        'MG',
        '32000000'
    );


/*
===============================================================================
9. PEDIDO DE EXEMPLO
===============================================================================
*/

INSERT INTO pedidos
    (id_revendedor, status, desconto, valor_total, observacao)
VALUES
    (
        1,
        'CONFIRMADO',
        10.00,
        359.00,
        'Pedido de demonstração'
    );


/*
===============================================================================
10. ITENS DO PEDIDO DE EXEMPLO
===============================================================================
*/

INSERT INTO itens_pedido
    (
        id_pedido,
        id_produto,
        quantidade,
        preco_unitario,
        desconto,
        subtotal
    )
VALUES
    (
        1,
        1,
        5,
        39.90,
        0,
        199.50
    ),
    (
        1,
        4,
        6,
        29.90,
        0,
        179.40
    );


/*
===============================================================================
11. PAGAMENTO DE EXEMPLO
===============================================================================
*/

INSERT INTO pagamentos
    (
        id_pedido,
        data_pagamento,
        valor,
        forma_pagamento,
        status
    )
VALUES
    (
        1,
        CURRENT_TIMESTAMP,
        359.00,
        'PIX',
        'PAGO'
    );


/*
===============================================================================
12. CONSULTAS INICIAIS PARA TESTE
-------------------------------------------------------------------------------
Estas consultas não criam nada.
Servem apenas para verificar se os dados foram inseridos corretamente.
===============================================================================
*/


-- Todas as categorias
SELECT *
FROM categorias;


-- Todos os produtos
SELECT *
FROM produtos;


-- Todos os revendedores
SELECT *
FROM revendedores;


-- Todos os pedidos
SELECT *
FROM pedidos;


-- Itens dos pedidos
SELECT *
FROM itens_pedido;


-- Pagamentos
SELECT *
FROM pagamentos;


/*
===============================================================================
13. PRIMEIRO JOIN
-------------------------------------------------------------------------------
Mostra o produto junto com sua categoria.
===============================================================================
*/

SELECT
    p.id_produto,
    p.nome AS produto,
    c.nome AS categoria,
    p.preco_venda,
    p.estoque
FROM produtos AS p
INNER JOIN categorias AS c
    ON c.id_categoria = p.id_categoria;


/*
===============================================================================
14. PEDIDOS COM REVENDEDOR
===============================================================================
*/

SELECT
    p.id_pedido,
    r.nome AS revendedor,
    p.data_pedido,
    p.status,
    p.valor_total
FROM pedidos AS p
INNER JOIN revendedores AS r
    ON r.id_revendedor = p.id_revendedor;


/*
===============================================================================
15. DETALHAMENTO DO PEDIDO
===============================================================================
*/

SELECT
    p.id_pedido,
    r.nome AS revendedor,
    pr.nome AS produto,
    ip.quantidade,
    ip.preco_unitario,
    ip.subtotal
FROM itens_pedido AS ip
INNER JOIN pedidos AS p
    ON p.id_pedido = ip.id_pedido
INNER JOIN revendedores AS r
    ON r.id_revendedor = p.id_revendedor
INNER JOIN produtos AS pr
    ON pr.id_produto = ip.id_produto;


/*
===============================================================================
FIM DO SCRIPT
===============================================================================
*/
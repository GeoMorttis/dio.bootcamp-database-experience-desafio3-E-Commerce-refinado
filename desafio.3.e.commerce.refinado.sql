-- Script para criar banco de dados E-Commerce

create database ecommerce;
use ecommerce;

-- CLIENTE
create table PessoaFisica(
	idPessoaFisica int auto_increment primary key unique,
    CPF char(11) not null unique,
    Nome varchar(20) not null,
    NomeMeio varchar(20),
    Sobrenome varchar(20) not null,
    DataNascimento date not null,
    Endereço varchar(45) not null,
    TelResidencial int(12),
    Celular int(13) not null
);
desc PessoaFisica;

create table PessoaJuridica(
	idPessoaJuridica int auto_increment primary key unique,
    CNPJ char(14) not null unique,
    RazaoSocial varchar(45) not null,
    NomeFantasia varchar(45),
    Endereço varchar(45) not null,
    Telefone int(12) not null
);
desc PessoaJuridica;

create table Cliente(
	idCliente int auto_increment primary key unique,
    constraint fk_pFisica foreign key (idCliente) references PessoaFisica(idPessoaFisica),
    constraint fk_pJuridica foreign key (idCliente) references PessoaJuridica(idPessoaJuridica)
);
desc Cliente;

-- PRODUTO
create table Produto(
	idProduto int auto_increment primary key unique,
    Categoria enum('Eletrônicos','Eletrodomésticos','Informática','Games') not null,
    Descrição varchar(45) not null,
    Valor float not null
);
desc Produto;

-- FORMA DE PAGAMENTO
create table CartaoCredito(
	idCartaoCredito int auto_increment primary key unique,
    Numero char(16) not null unique,
    Nome varchar(45) not null,
    RazaoSocial varchar(45),
    Validade date not null,
    CVC char(3) not null,
    CPF char(11) unique,
    CNPJ char(14) unique
);
desc CartaoCredito;

create table Boleto(
	idBoleto int auto_increment primary key unique,
    Codigo int(16) not null unique,
    ImpressaoBoleto varchar(200) not null unique
);
desc Boleto;

create table Pix(
	idPix int auto_increment primary key unique,
    Chave varchar(100) not null unique,
    Descricao varchar(100) not null,
    ValorPagar float not null
);
desc Pix;

create table PayPal(
	idPayPal int auto_increment primary key unique,
    emailPayPal varchar(45) not null unique,
    ValorPagar float not null,
    link varchar(200) not null
);
desc PayPal;

create table FormaDePagamento(
	idFormaDePagamento int auto_increment primary key unique,
    ValorTotalPagar float not null,
    constraint fk_cartaoCredito foreign key (idFormaDePagamento) references CartaoCredito(idCartaoCredito),
    constraint fk_boleto foreign key (idFormaDePagamento) references Boleto(idBoleto),
    constraint fk_pix foreign key (idFormaDePagamento) references Pix(idPix),
	constraint fk_paypal foreign key (idFormaDePagamento) references PayPal(idPayPal)
);
desc FormaDePagamento;

-- ENTREGA
create table Entrega(
	idEntrega int auto_increment primary key unique,
    DataPedido date not null,
    EnderecoEntrega varchar(45) not null unique,
    DataEntregaEstimado date not null,
    CodRastreamento date not null,
    StatusEntrega enum('Processado', 'Enviado', 'Em percurso', 'Entregue') not null default('Processando'),
    DataEntregaEfetuado date
);
desc Entrega;

-- PEDIDO
create table Pedido(
	idPedido int auto_increment primary key unique,
    StatusPedido enum('Em andamento', 'Pago', 'Processado', 'Enviado', 'Entregue') not null default('Processando'),
    Descricao varchar(200) not null,
    Frete float not null,
    ValorTotalPedido float not null,
    constraint fk_entrega foreign key (idPedido) references Entrega(idEntrega),
    constraint fk_cliente foreign key (idPedido) references Cliente(idCliente),
	constraint fk_formaPagamento foreign key (idPedido) references FormaDePagamento(idFormaDePagamento)
);
desc Pedido;

-- RELAÇÃO DE PRODUTO/PEDIDO
create table ProdutoPedido(
	idProduto int,
    idPedido int,
    Quantidade float not null default('1'),
    Status enum('Disponível', 'Sem estoque') not null default('Disponível'),
    constraint fk_pedido foreign key (idPedido) references Pedido(idPedido),
    constraint fk_Produto foreign key (idProduto) references Produto(idproduto)
);
desc ProdutoPedido;

-- ESTOQUE LOCAL
create table Estoque(
	idEstoque int auto_increment primary key unique,
    Categoria enum('Eletrônicos', 'Eletrodomésticos', 'Informática', 'Games') not null,
    idProdutoDisponivel bool not null default('False'),
    QuantDisponivel int not null default('0'),
    Localizacao varchar(45) not null
);
desc Estoque;

-- PRODUTO EM ESTOQUE LOCAL
create table ProdutoEstoque(
	idProduto int primary key,
    idProdutoEstoque int,
    Quantidade float not null,
    constraint fk_estoque foreign key (idProduto) references Produto(idProduto),
    constraint fk_produtoEstoque foreign key (idProdutoEstoque) references Estoque(idEstoque)
);
desc ProdutoEstoque;

-- FORNECEDOR PRINCIPAL
create table Fornecedor(
	idFornecedor int auto_increment primary key unique,
    CNPJ char(14) not null unique,
    RazaoSocial varchar(45) not null,
    NomeFantasia varchar(45),
    Endereço varchar(45) not null,
    Telefone int(12) not null
);
desc Fornecedor;

-- FORNECEDOR TERCEIRO
create table FTerceiro(
	idFTerceiro int auto_increment primary key unique,
    CNPJ char(14) not null unique,
    RazaoSocial varchar(45) not null,
    NomeFantasia varchar(45),
    Endereço varchar(45) not null,
    Telefone int(12) not null
);
desc FTerceiro;

-- PRODUTOS NO ESTOQUE FORNECEDOR PRINCIPAL (VERIFICAÇÃO DE DISPONIBILIDADE DE ESTOQUE NO FORNECEDOR PRINCIPAL)
create table EstoqFornPrinc(
	idEstoqFornPrinc int,
    idProdFornPrinc int,
    Quantidade float not null default('1'),
    constraint fk_estoqFornPrinc foreign key (idEstoqFornPrinc) references Fornecedor(idFornecedor),
    constraint fk_prodFornPrinc foreign key (idProdFornPrinc) references Produto(idProduto)
);
desc EstoqFornPrinc;

-- PRODUTOS NO ESTOQUE FORNECEDOR TERCEIRO (VERIFICAÇÃO DE DISPONIBILIDADE DE ESTOQUE NO FORNECEDOR TERCEIRO)
create table EstoqFornTerc(
	idEstoqFornTerc int,
    idProdFornTerc int,
    Quantidade float not null default('1'),
    constraint fk_estoqFornTerc foreign key (idEstoqFornTerc) references Fornecedor(idFTerceiro),
    constraint fk_prodFornTerc foreign key (idProdFornTerc) references Produto(idProduto)
);
desc EstoqFornTerc;
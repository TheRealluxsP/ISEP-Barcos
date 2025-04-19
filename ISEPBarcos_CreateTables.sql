-- ### Tabela ISEPBarcos
CREATE TABLE Empresa (
	NIF				CHAR(9)			CONSTRAINT nnEmpresaNIF		PRIMARY KEY,
	nome			VARCHAR(30)		CONSTRAINT nnEmpresaNome	NOT NULL,
    moradaSede		VARCHAR(100)	CONSTRAINT nnEmpresaMorada	NOT NULL	
);

-- ### Tabela Frota
CREATE TABLE Frota (
    cod				INT					CONSTRAINT pkFrotaCod		PRIMARY KEY,
    nome			VARCHAR(50)			CONSTRAINT nnFrotaNome		NOT NULL,
	NIFEmpresa		CHAR(9)				CONSTRAINT nnFrotaNIF		NOT NULL,

	CONSTRAINT		fkFrotaNIFEmpresa	FOREIGN KEY (NIFEmpresa)	REFERENCES Empresa(NIF)
);


-- ### Tabela Funcionário
CREATE TABLE Funcionario (
    numCC		CHAR(9)											CONSTRAINT pkFuncionarioNumCC		PRIMARY KEY,		-- num cc pode ter letras (caso seja o nr de documento, que no civil so tem numeros mesmo)
    nome		VARCHAR(50)										CONSTRAINT nnFuncionarioNome		NOT NULL,
    telefone	VARCHAR(20)										CONSTRAINT nnFuncionarioTelefone	NOT NULL,	--utilizei VARCHAR para dados que podem variar e CHAR para dados que tem sempre o mesmo numero de digitos
    morada		VARCHAR(100)									CONSTRAINT nnFuncionarioMorada		NOT NULL,
    funcao		VARCHAR(20)										CONSTRAINT nnFuncionarioFuncao		NOT NULL
																CONSTRAINT ckFuncionarioFuncao		CHECK (funcao IN('Responsável', 'Administrativo', 'Trabalhador de doca', 'Monitor')),
    codLocadora INT,

);

-- ### Tabela Locadora
CREATE TABLE Locadora (
    cod						INT				CONSTRAINT pkLocadoraCod		PRIMARY KEY,
    porto					VARCHAR(20)		CONSTRAINT nnLocadoraPorto		NOT NULL,
	NIF						CHAR(9)			CONSTRAINT nnLocadoraNIF		NOT NULL,
    telefone				VARCHAR(20)		CONSTRAINT nnLocadoraTelefone	NOT NULL,	
    morada					VARCHAR(100)	CONSTRAINT nnLocadoraMorada		NOT NULL,
    numCCResponsavel		CHAR(9)			CONSTRAINT nnLocadoraResponsavel NOT NULL,		
    codFrota				INT				CONSTRAINT nnLocadoraFrota		NOT NULL,

    CONSTRAINT fkLocadoraNumCCFuncionario	FOREIGN KEY (numCCResponsavel)		REFERENCES Funcionario(numCC),
    CONSTRAINT fkLocadoraCodFrota			FOREIGN KEY (codFrota)				REFERENCES Frota(cod),
	CONSTRAINT fkLocadoraNIFEmpresa			FOREIGN KEY (NIF)					REFERENCES Empresa(NIF)
);


-- ### Tabela Cliente
CREATE TABLE Cliente (
    numDocumento			VARCHAR(50)		CONSTRAINT pkClienteNumDocumento	PRIMARY KEY,		
    nome					VARCHAR(50)		CONSTRAINT nnClienteNome			NOT NULL,		
    telefone				VARCHAR(20)		CONSTRAINT nnClienteTelefone		NOT NULL,
    morada					VARCHAR(100)	CONSTRAINT nnClienteMorada			NOT NULL,
    numCartaMarinheiro		VARCHAR(20)
);

CREATE TABLE TipoEmbarcacao (
	nome					VARCHAR(20)		CONSTRAINT	pkTipoEmbarcacaoNome		PRIMARY KEY
											CONSTRAINT	ckTipoEmbarcacaoNome		CHECK (nome IN('Remos', 'Motor', 'Vela', 'Gaivota')),
	preco					MONEY			CONSTRAINT	nnTipoEmbarcacaoPreco		NOT NULL,
	tipoPreco				CHAR(1)			CONSTRAINT	nnTipoEmbarcacaoTipoPreco	NOT NULL
											CONSTRAINT	ckTipoEmbarcacaoTipoPreco	CHECK (tipoPreco IN('D', 'H'))
);

-- ### Tabela Embarcação
CREATE TABLE Embarcacao (
    matricula				VARCHAR(50)		CONSTRAINT	pkEmbarcacaoMatricula	PRIMARY KEY,		--nao sei quao grandes sao as matriculas de barcos mas provavelmente nao precisa de ser 50
    nome					VARCHAR(50)		CONSTRAINT	nnEmbarcacaoNome		NOT NULL,
    tipo					VARCHAR(20)		CONSTRAINT	nnEmbarcacaoTipo		NOT NULL
											CONSTRAINT	fkEmbarcacaoTipo		FOREIGN KEY (tipo)			REFERENCES TipoEmbarcacao(nome),
    codFrota				INT				CONSTRAINT	fkEmbarcacaoCodFrota	FOREIGN KEY (codFrota)		REFERENCES Frota(cod)

);

-- ### Tabela Artefacto
CREATE TABLE Artefacto (
    cod						INT				CONSTRAINT	pkArtefactoCod			PRIMARY KEY,
    nome					VARCHAR(50)		CONSTRAINT	nnArtefactoNome			NOT NULL,
    preco					MONEY			CONSTRAINT	nnArtefactoPreco		NOT NULL
);

-- ### Tabela Reserva
CREATE TABLE Reserva (
    cod						INT				CONSTRAINT pkReservaCod				PRIMARY KEY,
    matriculaEmbarcacao		VARCHAR(50)		CONSTRAINT nnReservaMatrEmbarcacao	NOT NULL,
    dataInicio				DATE			CONSTRAINT nnReservaDataInicio		NOT NULL,
    dataFim					DATE,
    numDocumentoCliente		VARCHAR(50)		CONSTRAINT nnReservaDocCliente		NOT NULL,
    codFuncionario			CHAR(9)			CONSTRAINT nnReservaCodFuncionario	NOT NULL,

    CONSTRAINT fkReservaMatriculaEmbarcacao	FOREIGN KEY (matriculaEmbarcacao)	REFERENCES Embarcacao(matricula),
    CONSTRAINT fkReservaNumDocumentoCliente FOREIGN KEY (numDocumentoCliente)	REFERENCES Cliente(numDocumento),
    CONSTRAINT fkReservaCodFuncionario		FOREIGN KEY (codFuncionario)		REFERENCES Funcionario(numCC)
);

-- ### Tabela ForaDeServico
CREATE TABLE ForaDeServico(
	cod						INT				CONSTRAINT pkForaDeServicoCod			PRIMARY KEY,
	matriculaEmbarcacao		VARCHAR(50)		CONSTRAINT nnForaServMatrEmbarcacao		NOT NULL,
	dataInicio				DATE			CONSTRAINT nnForaDeServicoDataInicio	NOT NULL,
	dataFim					DATE,

	CONSTRAINT fkForaDeServicoMatriculaEmbarcacao	FOREIGN KEY (matriculaEmbarcacao)	REFERENCES Embarcacao(matricula)

)

-- ### Tabela Aluguer
CREATE TABLE Aluguer (
    cod						INT				CONSTRAINT pkAluguerCod				PRIMARY KEY,
    matriculaEmbarcacao		VARCHAR(50)		CONSTRAINT nnAluguerMatrEmb			NOT NULL,
    horaInicio				TIME,
    horaFim					TIME,
    dataInicio				DATE			CONSTRAINT nnDataInicioAluguer		NOT NULL,
    dataFim					DATE,
    numDocumentoCliente		VARCHAR(50)		CONSTRAINT nnClienteAluguer			NOT NULL,

    CONSTRAINT fkAluguerMatriculaEmbarcacao FOREIGN KEY (matriculaEmbarcacao) REFERENCES Embarcacao(matricula),
    CONSTRAINT fkAluguerNumDocumentoCliente FOREIGN KEY (numDocumentoCliente) REFERENCES Cliente(numDocumento) 
);

CREATE TABLE ArtefactoAluguer(
	codArtefacto	INT											CONSTRAINT nnArtefactoAluguerCodArtefacto		NOT NULL,
	codAluguer		INT											CONSTRAINT nnArtefactoAluguerCodAluguer			NOT NULL,

	CONSTRAINT pkArtefactoAluguerCodArtefactoCodAluguer			PRIMARY KEY (codArtefacto, codAluguer),
	CONSTRAINT pkArtefactoAluguerCodArtefacto					FOREIGN KEY (codArtefacto)						REFERENCES Artefacto(cod),
    CONSTRAINT pkArtefactoAluguerCodAluguer						FOREIGN KEY (codAluguer)						REFERENCES Aluguer(cod)

)

CREATE TABLE ArtefactoReserva(
	codArtefacto	INT											CONSTRAINT nnArtefactoReservaCodArtefacto		NOT NULL,
	codReserva		INT											CONSTRAINT nnArtefactoReservaCodReserva			NOT NULL,

	CONSTRAINT pkArtefactoReservaCodArtefactoCodReserva			PRIMARY KEY (codArtefacto, codReserva),
	CONSTRAINT pkArtefactoReservaCodArtefacto					FOREIGN KEY (codArtefacto)						REFERENCES Artefacto(cod),
    CONSTRAINT pkArtefactoReservaCodReserva						FOREIGN KEY (codReserva)						REFERENCES Reserva(cod)
)


-- ### Tabela Atividade
CREATE TABLE Atividade (
    cod						INT					CONSTRAINT pkAtividadeCod				PRIMARY KEY,
    codLocadora				INT					CONSTRAINT nnAtividadeCodLocadora		NOT NULL,
    data					DATE				CONSTRAINT nnAtividadeData				NOT NULL,
    nome					VARCHAR(50)			CONSTRAINT nnAtividadeNome				NOT NULL,
    descricao				VARCHAR(100)		CONSTRAINT nnAtividadeDescricao			NOT NULL,
    lotacaoMaxima			INT					CONSTRAINT nnAtividadeLotacaoMaxima		NOT NULL,
    custoPessoa				DECIMAL(5, 2)		CONSTRAINT nnAtividadeCustoPessoa		NOT NULL,

    FOREIGN KEY (codLocadora) REFERENCES Locadora(cod)
);

-- ### Tabela Atividade_Embarcação (relação N:N)
CREATE TABLE AtividadeEmbarcacao (
    codAtividade			INT								CONSTRAINT nnAtividadeEmbarcacaoCodAtividade				NOT NULL,
    matriculaEmbarcacao		VARCHAR(50)						CONSTRAINT nnAtividadeEmbarcacaoMatriculaEmbarcacao			NOT NULL,

    CONSTRAINT pkAtividadeEmbarcacaoCodMatricula			PRIMARY KEY (codAtividade, matriculaEmbarcacao),
    CONSTRAINT pkAtividadeEmbarcacaoCodAtividade			FOREIGN KEY (codAtividade)									REFERENCES Atividade(cod),
    CONSTRAINT pkAtividadeEmbarcacaoMatriculaEmbarcacao		FOREIGN KEY (matriculaEmbarcacao)							REFERENCES Embarcacao(matricula)
);

-- ### Tabela Atividade_Funcionários (relação N:N)
CREATE TABLE AtividadeFuncionarios (
    codAtividade			INT								CONSTRAINT nnAtividadeFuncionariosCodAtividade				NOT NULL,
    numCCFuncionario		CHAR(9)							CONSTRAINT nnAtividadeFuncionariosNumCCFuncionario			NOT NULL,
    CONSTRAINT pkAtividadeFuncionariosCodNumCC				PRIMARY KEY (codAtividade, numCCFuncionario),
    CONSTRAINT fkAtividadeFuncionariosCodAtividade			FOREIGN KEY (codAtividade)									REFERENCES Atividade(cod),
    CONSTRAINT fkAtividadeFuncionariosNumCCFuncionario		FOREIGN KEY (numCCFuncionario)								REFERENCES Funcionario(numCC)
);


-- ### Tabela Cliente_Atividade (relação N:N)
CREATE TABLE ClienteAtividade (
    codAatividade				INT							CONSTRAINT nnClienteAtividadeCodAtividade					NOT NULL,
    numDocCliente				VARCHAR(50)					CONSTRAINT nnClienteAtividadeNumDocCliente					NOT NULL,

    CONSTRAINT pkClienteAtividadeCodNumDocumento			PRIMARY KEY (codAatividade, numDocCliente),
    CONSTRAINT fklienteAtividadeCodAtividade				FOREIGN KEY (codAatividade)									REFERENCES Atividade(cod),
    CONSTRAINT fklienteAtividadeNumDocCliente				FOREIGN KEY (numDocCliente)									REFERENCES Cliente(numDocumento)
);


ALTER TABLE Funcionario	ADD CONSTRAINT fkFuncionarioCodLocadora FOREIGN KEY (codLocadora) REFERENCES Locadora(cod)
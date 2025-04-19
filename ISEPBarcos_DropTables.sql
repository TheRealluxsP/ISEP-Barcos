-- Remove Constraints de chave estrangeira manualmente para todas as relaçoes

ALTER TABLE Locadora DROP CONSTRAINT fkLocadoraNumCCFuncionario;
ALTER TABLE Locadora DROP CONSTRAINT fkLocadoraCodFrota;
ALTER TABLE Locadora DROP CONSTRAINT fkLocadoraNIFEmpresa;
ALTER TABLE Funcionario DROP CONSTRAINT fkFuncionarioCodLocadora;
ALTER TABLE Frota DROP CONSTRAINT fkFrotaNIFEmpresa;
ALTER TABLE Embarcacao DROP CONSTRAINT fkEmbarcacaoCodFrota;
ALTER TABLE Embarcacao DROP CONSTRAINT fkEmbarcacaoTipo;
ALTER TABLE Reserva DROP CONSTRAINT fkReservaMatriculaEmbarcacao;
ALTER TABLE Reserva DROP CONSTRAINT fkReservaNumDocumentoCliente;
ALTER TABLE Reserva DROP CONSTRAINT fkReservaCodFuncionario;
ALTER TABLE Aluguer DROP CONSTRAINT fkAluguerMatriculaEmbarcacao;
ALTER TABLE Aluguer DROP CONSTRAINT fkAluguerNumDocumentoCliente;
ALTER TABLE AtividadeEmbarcacao DROP CONSTRAINT pkAtividadeEmbarcacaoCodMatricula;
ALTER TABLE AtividadeEmbarcacao DROP CONSTRAINT pkAtividadeEmbarcacaoCodAtividade;
ALTER TABLE AtividadeFuncionarios DROP CONSTRAINT pkAtividadeFuncionariosCodNumCC;
ALTER TABLE ClienteAtividade DROP CONSTRAINT pkClienteAtividadeCodNumDocumento;
ALTER TABLE ArtefactoReserva NOCHECK CONSTRAINT ALL;
ALTER TABLE ArtefactoAluguer NOCHECK CONSTRAINT ALL;
ALTER TABLE ForaDeServico	   DROP CONSTRAINT fkForaDeServicoMatriculaEmbarcacao;

-- Destroi tabelas de relações N:N primeiro
DROP TABLE IF EXISTS ClienteAtividade;
DROP TABLE IF EXISTS AtividadeFuncionarios;
DROP TABLE IF EXISTS AtividadeEmbarcacao;
DROP TABLE IF EXISTS ArtefactoReserva;
DROP TABLE IF EXISTS ArtefactoAluguer;
DROP TABLE IF EXISTS TipoEmbarcacao;

-- Destroi tabelas dependentes depois
DROP TABLE IF EXISTS Atividade;
DROP TABLE IF EXISTS Aluguer;
DROP TABLE IF EXISTS Reserva;
DROP TABLE IF EXISTS ForaDeServico;
DROP TABLE IF EXISTS Artefacto;
DROP TABLE IF EXISTS Embarcacao;
DROP TABLE IF EXISTS Cliente;
DROP TABLE IF EXISTS Locadora;
DROP TABLE IF EXISTS Funcionario;
DROP TABLE IF EXISTS Frota;
DROP TABLE IF EXISTS Empresa;

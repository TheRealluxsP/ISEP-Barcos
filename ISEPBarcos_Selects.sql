--2.1.Listar para o cliente com o cartão de cidadão com o número ‘123456789’,o seu nome, a data, as suas reservas, o tipo e nome das embarcações utlizados.
SELECT 
    Cliente.nome AS NomeCliente,
    Reserva.dataInicio AS DataInicioReserva,
    Reserva.dataFim AS DataFimReserva,
    Embarcacao.nome AS NomeEmbarcacao,
    Embarcacao.tipo AS TipoEmbarcacao
FROM 
    Cliente
JOIN 
    Reserva ON Cliente.numDocumento = Reserva.numDocumentoCliente
JOIN 
    Embarcacao ON Reserva.matriculaEmbarcacao = Embarcacao.matricula
WHERE 
    Cliente.numDocumento = '123456789';

--2.2. Listar os clientes que realizaram alugueres ou reservas em 2016 e que ainda não efetuaram alugueres ou reservas em 2017.

-- Listar clientes com alugueres ou reservas em 2016
SELECT DISTINCT *
FROM Cliente C
WHERE C.numDocumento IN (
    -- Alugueres em 2016
    SELECT A.numDocumentoCliente
    FROM Aluguer A
    WHERE YEAR(A.dataInicio) = 2016

    UNION

    -- Reservas em 2016
    SELECT R.numDocumentoCliente
    FROM Reserva R
    WHERE YEAR(R.dataInicio) = 2016
)
AND C.numDocumento NOT IN (
    -- Clientes com alugueres ou reservas em 2017
    SELECT A.numDocumentoCliente
    FROM Aluguer A
    WHERE YEAR(A.dataInicio) = 2017

    UNION

    SELECT R.numDocumentoCliente
    FROM Reserva R
    WHERE YEAR(R.dataInicio) = 2017
);

--2.3. Listar todas as embarcações, apresentando para cada uma, o número de vezes que foi utilizada (alugada ou reservada).

SELECT
	E.matricula,
	E.nome,
	COALESCE(R.numReservas, 0) AS totalReservas,
	COALESCE(A.numAlugueres, 0) AS totalAlugueres,
	COALESCE(R.numReservas, 0) + COALESCE(A.numAlugueres, 0) AS totalUtilizacoes
FROM Embarcacao E
LEFT JOIN(
	--Contar reservas por embarcação
	SELECT
		matriculaEmbarcacao,
		COUNT(*) AS numReservas
	FROM Reserva
	GROUP BY matriculaEmbarcacao
)R ON E.matricula = R.matriculaEmbarcacao
LEFT JOIN(
	--Contar alugueres por embarcação
	SELECT
		matriculaEmbarcacao,
		COUNT(*) AS numAlugueres
	FROM Aluguer
	GROUP BY matriculaEmbarcacao
)A ON E.matricula = A.matriculaEmbarcacao
ORDER BY totalUtilizacoes DESC, E.nome;

--2.4 Liste o nome e tipo da(s) embarcação(ões) que em 2017 esteve
--(estiveram) mais vezes fora de serviço.

WITH ForaDeServicoCount AS (
    SELECT 
        e.nome AS nomeEmbarcacao,
        e.tipo AS tipoEmbarcacao,
        COUNT(*) AS totalForaDeServico
    FROM 
        ForaDeServico fs
    INNER JOIN 
        Embarcacao e ON fs.matriculaEmbarcacao = e.matricula
    WHERE 
        YEAR(fs.dataInicio) = 2017
    GROUP BY 
        e.nome, e.tipo
)
SELECT 
    nomeEmbarcacao,
    tipoEmbarcacao
FROM 
    ForaDeServicoCount
WHERE 
    totalForaDeServico = (SELECT MAX(totalForaDeServico) FROM ForaDeServicoCount);

--2.5. Liste os clientes que reservaram as mesmas embarcações que o cliente com o cartão de cidadão '123456789' durante o ano de 2016
WITH ReservasDoCliente AS(
	SELECT DISTINCT 
		matriculaEmbarcacao
	FROM 
		Reserva
	WHERE 
		numDocumentoCliente = '123456789'
		AND YEAR(dataInicio) = 2016
)
SELECT DISTINCT
	nome AS nomeCliente,
	numDocumento AS documentoCliente,
	telefone,
	morada,
	numCartaMarinheiro
FROM 
	Cliente
INNER JOIN
	Reserva ON Cliente.numDocumento = Reserva.numDocumentoCliente
WHERE
	matriculaEmbarcacao IN (SELECT matriculaEmbarcacao FROM ReservasDoCliente)
	AND YEAR(dataInicio) = 2016
	AND numDocumento != '123456789';

-- 2.6  Apresente o NIF e o nome do(s) cliente(s) com mais alugueres do que os clientes que fizeram alugueres na locadora de código ‘123’. 

SELECT nome, numDocumento, COUNT(Aluguer.cod) AS nrAluguer
FROM Cliente
LEFT JOIN Aluguer ON Cliente.numDocumento = Aluguer.numDocumentoCliente
GROUP BY nome, numDocumento
HAVING COUNT(DISTINCT Aluguer.cod) > (
	SELECT MAX(countAluguer) AS maximo
	FROM (
		SELECT clientes123.nome, COUNT(DISTINCT Aluguer.cod) AS countAluguer
		FROM (
			SELECT Cliente.nome, Cliente.numDocumento
				FROM Cliente
				LEFT JOIN Aluguer ON Cliente.numDocumento = Aluguer.numDocumentoCliente
				LEFT JOIN Embarcacao ON Embarcacao.matricula = Aluguer.matriculaEmbarcacao
				LEFT JOIN Frota ON Embarcacao.codFrota = Frota.cod
				LEFT JOIN Locadora ON Locadora.codFrota = Frota.cod
				WHERE Locadora.cod LIKE '123'
		) clientes123 
				LEFT JOIN Aluguer ON clientes123.numDocumento = Aluguer.numDocumentoCliente
			GROUP BY clientes123.nome
	) nrAlugueres
)

--2.7. Apresente a lista das locadoras (porto e morada) incluindo, se existirem, as atividades nelas desenvolvidas no 3.º trimestre de 2016. Das
-- atividades, apresente apenas o nome e a descrição. A lista deve vir
-- ordenada por nome da locadora (1.º critério) e nome da atividade (2.º
-- critério).

SELECT 
	Locadora.porto,
	Locadora.morada,
	Atividade.nome AS nomeAtividade,
	Atividade.descricao
FROM
	Locadora
LEFT JOIN
	Atividade ON Locadora.cod = Atividade.codLocadora AND data BETWEEN '2016-07-01' AND '2016-09-30'
ORDER BY
	Locadora.porto, Atividade.nome

-- 2.8 Apresente as embarcações da(s) locadora(s) situadas no porto de “Sesimbra” que tiveram reservas ou alugueres todos os dias entre ‘01-07-2016’ e ‘31-08-2016’. 
-- Apresente o número de alugueres e reservas. 
SELECT matricula, embarcacao.nome, tipo, COUNT(DISTINCT Aluguer.cod) AS numeroAlugueres, COUNT(DISTINCT Reserva.cod) AS numeroReservas
FROM Embarcacao
LEFT JOIN frota ON Embarcacao.codFrota = Frota.cod
LEFT JOIN locadora ON frota.cod = locadora.codFrota
LEFT JOIN Aluguer ON embarcacao.matricula = aluguer.matriculaEmbarcacao AND Aluguer.dataInicio BETWEEN '2016-07-01' AND '2016-08-31'
LEFT JOIN Reserva ON Embarcacao.matricula = Reserva.matriculaEmbarcacao AND Reserva.dataInicio BETWEEN '2016-07-01' AND '2016-08-31'
WHERE porto LIKE 'Sesimbra' AND Reserva.dataInicio IS NOT NULL AND Aluguer.dataInicio IS NOT NULL
GROUP BY matricula, embarcacao.nome, tipo


-- 2.9 Para embarcações da categoria gaivotas ou a remos, obter uma lista contendo o nome da embarcação e número médio de horas em que esteve alugada, 
-- por dia. Devem ser excluídas as embarcações que tenham um tempo médio inferior a 2 horas. A lista produzida deve vir ordenada de forma 
-- decrescente pelo segundo atributo (número médio de horas).  

SELECT nome, ABS(AVG(DATEDIFF(HOUR, Aluguer.horaInicio, Aluguer.horaFim))) AS numeroMedioHoras
FROM Embarcacao
LEFT JOIN Aluguer ON Embarcacao.matricula = Aluguer.matriculaEmbarcacao
WHERE tipo IN('gaivota', 'remos')
GROUP BY nome
HAVING AVG(DATEDIFF(HOUR, Aluguer.horaInicio, Aluguer.horaFim)) >= 2
ORDER BY numeroMedioHoras DESC



-- 2.10. Liste as atvidades de 2016, cujo número de partcipantes é igual à lotação máxima da atvidade, e onde estejam envolvidos mais do que um monitor

SELECT 
    A.cod AS CodigoAtividade,
    A.nome AS NomeAtividade,
    A.data AS DataAtividade,
    A.descricao AS Descricao,
    A.lotacaoMaxima AS LotacaoMaxima,
    COUNT(DISTINCT AF.numCCFuncionario) AS NumeroDeMonitores,
    COUNT(DISTINCT CA.numDocCliente) AS NumeroDeParticipantes
FROM 
    Atividade A
JOIN 
    AtividadeFuncionarios AF ON A.cod = AF.codAtividade
JOIN 
    Funcionario F ON AF.numCCFuncionario = F.numCC
JOIN 
    ClienteAtividade CA ON A.cod = CA.codAatividade
WHERE 
    F.funcao = 'Monitor'
    AND YEAR(A.data) = 2016
GROUP BY 
    A.cod, A.nome, A.data, A.descricao, A.lotacaoMaxima
HAVING 
    COUNT(DISTINCT CA.numDocCliente) = A.lotacaoMaxima
    AND COUNT(DISTINCT AF.numCCFuncionario) > 1;



-- 2.11. Liste os valores pagos pelos clientes para as reservas que já terminaram. Deve ser possível visualizar, para além do valor pago, quem foi o cliente,em que locadora fez a reserva e a data da reserva.
	SELECT 
    r.cod AS Codigo_Reserva,
    c.nome AS Nome_Cliente,
    l.porto AS Porto_Locadora,
    r.dataInicio AS Data_Reserva,
    te.preco AS Valor_Embarcacao
FROM 
    Reserva r
JOIN 
    Cliente c ON r.numDocumentoCliente = c.numDocumento
JOIN 
    Embarcacao e ON r.matriculaEmbarcacao = e.matricula
JOIN 
    TipoEmbarcacao te ON e.tipo = te.nome
JOIN 
    Locadora l ON e.codFrota = l.codFrota
WHERE 
    r.dataFim IS NOT NULL
ORDER BY 
    r.cod;

-- 2.12. Liste todas as atividades que cada cliente requereu, assim como o número de participantes nelas envolvidos.
SELECT 
    ca.numDocCliente AS Cliente_Numero_Documento,
    c.nome AS Cliente_Nome,
    a.cod AS Atividade_Codigo,
    a.nome AS Atividade_Nome,
    participantes.Numero_De_Participantes
FROM 
    Atividade a
JOIN 
    ClienteAtividade ca ON a.cod = ca.codAatividade
JOIN 
    Cliente c ON ca.numDocCliente = c.numDocumento  -- Assumindo que a tabela Cliente tenha 'numDocumento' e 'nome'
JOIN 
    (SELECT codAatividade, COUNT(numDocCliente) AS Numero_De_Participantes
     FROM ClienteAtividade
     GROUP BY codAatividade) AS participantes 
    ON a.cod = participantes.codAatividade
ORDER BY 
    ca.numDocCliente, a.cod;




--CONSULTAS PARTE 3


--Funcionarios que trabalharam em Atividades no 3 trimestre de 2016
SELECT 
    f.nome AS funcionario_nome, 
    f.funcao, 
    a.nome AS atividade_nome, 
    a.descricao
FROM 
    Funcionario f
JOIN 
    AtividadeFuncionarios af ON f.numCC = af.numCCFuncionario
JOIN 
    Atividade a ON af.codAtividade = a.cod
WHERE 
    a.data BETWEEN '2016-07-01' AND '2016-09-30'
    AND EXISTS (SELECT 1 
                FROM Embarcacao e 
                JOIN AtividadeEmbarcacao ae ON e.matricula = ae.matriculaEmbarcacao
                WHERE ae.codAtividade = a.cod)
ORDER BY 
    f.nome, a.nome;


-- Clientes que fizeram mais reservas e alugueres que a media de alugueres e reservas por cliente

SELECT DISTINCT nome, numDocumento, (COALESCE(COUNT(DISTINCT Aluguer.cod),0) + COALESCE(COUNT(DISTINCT Reserva.cod),0)) AS totalidade
FROM Cliente
LEFT JOIN Aluguer ON Cliente.numDocumento = Aluguer.numDocumentoCliente
LEFT JOIN Reserva ON Cliente.numDocumento = Reserva.numDocumentoCliente
GROUP BY nome, numDocumento
HAVING  (COALESCE(COUNT(DISTINCT Aluguer.cod),0) + COALESCE(COUNT(DISTINCT Reserva.cod),0)) > (
	SELECT DISTINCT (COALESCE(subQuery.avgAluguer,0) + COALESCE(subQuery.avgReserva,0)) AS Total 
	FROM (
		SELECT AVG(countAluguer) AS avgAluguer, AVG(countReserva) AS avgReserva
		FROM (
				SELECT DISTINCT Cliente.nome, Cliente.numDocumento, COUNT(DISTINCT Aluguer.cod) AS countAluguer, COUNT(DISTINCT Reserva.cod) AS countReserva 
				FROM Cliente
				LEFT JOIN Aluguer ON Cliente.numDocumento = Aluguer.numDocumentoCliente
				LEFT JOIN Reserva ON Cliente.numDocumento = Reserva.numDocumentoCliente
				GROUP BY Cliente.nome, Cliente.numDocumento
			) clientesQuery
	) subQuery
)
ORDER BY totalidade DESC



-- Clientes que participaram de mais atividades e o total gasto

SELECT c.nome AS Nome_Cliente, Total_Atividades, Gasto_Total
FROM Cliente c
JOIN (
    SELECT ca.numDocCliente, COUNT(*) AS Total_Atividades, SUM(a.custoPessoa) AS Gasto_Total
    FROM ClienteAtividade ca
    JOIN Atividade a ON ca.codAatividade = a.cod
    GROUP BY ca.numDocCliente
) SubAtividades ON c.numDocumento = SubAtividades.numDocCliente
WHERE SubAtividades.Total_Atividades > 2
ORDER BY Gasto_Total DESC;
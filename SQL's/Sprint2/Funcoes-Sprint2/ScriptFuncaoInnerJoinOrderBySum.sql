SELECT *
FROM USER_DEPENDENCIES
WHERE REFERENCED_NAME = 'T_SALDO_PACIENTE_OBJ';

DROP FUNCTION "FUN_SALDO_USUARIOS";
DROP TYPE "T_SALDO_PACIENTE_TABLE";

--------------------------------------------------------------------------------------------------------------------------------

-- Cria um objeto para usar na tabela
CREATE OR REPLACE TYPE "T_SALDO_PACIENTE_OBJ" AS OBJECT
(
    "id_pac"       NUMBER,
    "nome_paciente" VARCHAR2(200),
    "cpf_paciente" VARCHAR2(11),
    "saldo"        NUMBER
);

--------------------------------------------------------------------------------------------------------------------------------
-- Cria um tipo para a tabela de retorno
CREATE OR REPLACE TYPE "T_SALDO_PACIENTE_TABLE" AS TABLE OF "T_SALDO_PACIENTE_OBJ";

--------------------------------------------------------------------------------------------------------------------------------
-- Função com retorno tipo tabela, usando inner join e order by, que retorna os dados de
-- saldo de todos os usuários em um determinado intervalo de tempo de um paciente
CREATE OR REPLACE FUNCTION "FUN_SALDO_USUARIOS"(
    "data_inicio" DATE,
    "data_fim" DATE
) RETURN "T_SALDO_PACIENTE_TABLE" IS
    v_saldos "T_SALDO_PACIENTE_TABLE";
BEGIN
    SELECT "T_SALDO_PACIENTE_OBJ"(
            PAC."id_paciente",
            PAC."nm_paciente",
            PAC."nr_cpf",
            SUM(EXT."nr_numero_pontos")) BULK COLLECT
    INTO v_saldos
    FROM "T_OPBD_PACIENTE" PAC
             JOIN "T_OPBD_EXTRATO_PONTOS" EXT ON PAC."id_paciente" = EXT."id_paciente"
    WHERE EXT."dt_extrato" BETWEEN "data_inicio" AND "data_fim"
    GROUP BY PAC."id_paciente", PAC."nm_paciente", PAC."nr_cpf"
    ORDER BY PAC."nm_paciente";
    RETURN v_saldos;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(2000, 'ERRO DESCONHECIDO.');
        RETURN NULL;
END "FUN_SALDO_USUARIOS";
/

--------------------------------------------------------------------------------------------------------------------------------
-- Testando a função
SELECT *
FROM TABLE("FUN_SALDO_USUARIOS"(TO_DATE('01/01/2024'), TO_DATE('01/01/2025')));
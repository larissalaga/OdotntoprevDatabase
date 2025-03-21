SELECT *
FROM USER_DEPENDENCIES
WHERE REFERENCED_NAME = 'T_PACIENTE_CHECKIN_OBJ';

DROP FUNCTION "FUN_RELATORIO_PACIENTE_CHECK_IN";
DROP TYPE "T_PACIENTE_CHECKIN";

--------------------------------------------------------------------------------------------------------------------------------

-- Cria um objeto para usar na tabela
CREATE OR REPLACE TYPE "T_PACIENTE_CHECKIN_OBJ" AS OBJECT(
    "id_paciente" NUMBER(20),
    "nm_paciente" VARCHAR2(100),
    "nr_cpf" VARCHAR2(11),
    "dt_check_in" DATE,
    "ds_pergunta" VARCHAR2(300),
    "ds_resposta" VARCHAR2(400)
);
--------------------------------------------------------------------------------------------------------------------------------
-- Cria um tipo para a tabela de retorno
CREATE OR REPLACE TYPE "T_PACIENTE_CHECKIN" AS TABLE OF "T_PACIENTE_CHECKIN_OBJ";

--------------------------------------------------------------------------------------------------------------------------------
-- Função com retorno tipo tabela, usando cursor e joins, que retorna os dados de
-- perguntas e respostas do check_in de um paciente
CREATE OR REPLACE FUNCTION "FUN_RELATORIO_PACIENTE_CHECK_IN"(
    p_nr_cpf VARCHAR2
) RETURN "T_PACIENTE_CHECKIN" IS
    --Declara a tabela
    relatorio "T_PACIENTE_CHECKIN" := "T_PACIENTE_CHECKIN"();
    --Declarando o cursor
    CURSOR cur_relatorio IS
        SELECT
            p."id_paciente",
            p."nm_paciente",
            p."nr_cpf",
            ci."dt_check_in",
            pe."ds_pergunta",
            re."ds_resposta"
        FROM
            "T_OPBD_PACIENTE" p
            JOIN "T_OPBD_CHECK_IN" ci ON p."id_paciente" = ci."id_paciente"
            JOIN "T_OPBD_PERGUNTAS" pe ON ci."id_pergunta" = pe."id_pergunta"
            JOIN "T_OPBD_RESPOSTAS" re ON ci."id_resposta" = re."id_resposta"
        WHERE p."nr_cpf" = p_nr_cpf
        ORDER BY
            p."nm_paciente", ci."dt_check_in";
BEGIN
    --Insere as linhas no relatorio
    FOR x IN cur_relatorio LOOP
        relatorio.EXTEND;
        relatorio(relatorio.COUNT) := "T_PACIENTE_CHECKIN_OBJ"(
            x."id_paciente",
            x."nm_paciente",
            x."nr_cpf",
            x."dt_check_in",
            x."ds_pergunta",
            x."ds_resposta"
        );
    END LOOP;
    RETURN relatorio;
END "FUN_RELATORIO_PACIENTE_CHECK_IN";
/

--------------------------------------------------------------------------------------------------------------------------------
--Testando a função
SELECT *
FROM TABLE ("FUN_RELATORIO_PACIENTE_CHECK_IN"('18207586322'));

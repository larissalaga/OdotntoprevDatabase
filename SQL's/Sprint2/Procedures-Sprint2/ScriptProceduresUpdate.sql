--------------------------------------------------------------------------------------------------------------------------------
-- UPDATE_PACIENTE
SELECT *
FROM "T_OPBD_PACIENTE";
--
DECLARE
BEGIN
    update_paciente('11304377601',
                    'Jose Fidalgo',
                    '31999811710',
                    'jose.fidalgo@gmail.com',
                    TO_DATE('02/09/1992'),
                    'M',
                    'ODP002');
END;
--

CREATE OR REPLACE PROCEDURE "UPDATE_PACIENTE"(
    "p_nr_cpf" VARCHAR2,
    "p_ds_nome" VARCHAR2,
    "p_nr_telefone" VARCHAR2,
    "p_ds_email" VARCHAR2,
    "p_dt_nasc" DATE,
    "p_ds_sexo" VARCHAR2,
    "p_ds_cod_plano" VARCHAR2
) IS
    invalid_cpf EXCEPTION;
    paciente_not_found EXCEPTION;
    plano_not_found EXCEPTION;
    data_nasc_invalid EXCEPTION;
    telefone_invalid EXCEPTION;
    sexo_invalid EXCEPTION;
    email_invalid EXCEPTION;
    "paciente_id" NUMBER;
    "plano_id"    NUMBER;
BEGIN
    -- Validação de CPF
    IF NOT "FUN_VALIDA_CPF"("p_nr_cpf") THEN
        RAISE invalid_cpf;
    END IF;

    -- Busca o paciente
    BEGIN
        SELECT "id_paciente"
        INTO "paciente_id"
        FROM "T_OPBD_PACIENTE"
        WHERE "nr_cpf" = "p_nr_cpf";
    EXCEPTION
        WHEN no_data_found THEN
            RAISE paciente_not_found;
    END;

    -- Busca o Plano
    BEGIN
        SELECT "id_plano"
        INTO "plano_id"
        FROM "T_OPBD_PLANO"
        WHERE "ds_codigo_plano" = "p_ds_cod_plano";
    EXCEPTION
        WHEN no_data_found THEN
            RAISE plano_not_found;
    END;

    -- Valida a data de nascimento
    IF NOT "FUN_VALIDA_NASCIMENTO"("p_dt_nasc") THEN
        RAISE data_nasc_invalid;
    END IF;

    -- Valida o email
    IF NOT "FUN_VALIDA_EMAIL"("p_ds_email") THEN
        RAISE email_invalid;
    END IF;

    -- Valida o telefone
    IF NOT "FUN_VALIDA_TELEFONE"("p_nr_telefone") THEN
        RAISE telefone_invalid;
    END IF;

    -- Valida o sexo
    IF NOT "FUN_VALIDA_SEXO"("p_ds_sexo") THEN
        RAISE sexo_invalid;
    END IF;

    -- Faz o Update
    UPDATE "T_OPBD_PACIENTE"
    SET "nm_paciente"   = "p_ds_nome",
        "nr_telefone"   = "p_nr_telefone",
        "ds_email"      = "p_ds_email",
        "dt_nascimento" = TO_DATE("p_dt_nasc"),
        "ds_sexo"       = "p_ds_sexo",
        "id_plano"      = "plano_id"
    WHERE "id_paciente" = "paciente_id";


EXCEPTION
    WHEN invalid_cpf THEN
        RAISE_APPLICATION_ERROR(-20001, 'CPF Inv�lido.');
    WHEN paciente_not_found THEN
        RAISE_APPLICATION_ERROR(-20002, 'Paciente n�o existe.');
    WHEN plano_not_found THEN
        RAISE_APPLICATION_ERROR(-20003, 'Plano n�o existe.');
    WHEN data_nasc_invalid THEN
        RAISE_APPLICATION_ERROR(-20004, 'Data de nascimento inv�lida. Nascimento deve ser entre 01/01/1900 e hoje');
    WHEN email_invalid THEN
        RAISE_APPLICATION_ERROR(-20005,
                                'Email inv�lido. Email deve ter formato user@example.com, user@example.org, user@example.br');
    WHEN telefone_invalid THEN
        RAISE_APPLICATION_ERROR(-20006, 'Telefone inv�lido. Deve ter 11 digitos, com DDD sem 0, ex 11987654321');
    WHEN sexo_invalid THEN
        RAISE_APPLICATION_ERROR(-20007, 'Sexo Invalido. Deve ser M, F ou N');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
END;
/
--------------------------------------------------------------------------------------------------------------------------------
-- UPDATE_DENTISTA
SELECT *
FROM "T_OPBD_DENTISTA";
--
DECLARE
BEGIN
    "UPDATE_DENTISTA"(
            'Dr. Otto Canino Silva'
        , 'CRO312544'
        , 'otto.canino@gmail.com.br'
        , '31932151125'
        , '28797727000160'
    );
END;
--

CREATE OR REPLACE PROCEDURE "UPDATE_DENTISTA"(
    "p_nm_dentista" VARCHAR2,
    "p_ds_cro" VARCHAR2,
    "p_ds_email" VARCHAR2,
    "p_nr_telefone" VARCHAR2,
    "p_ds_doc" VARCHAR2
) IS
    invalid_doc EXCEPTION;
    dentista_not_found EXCEPTION;
    cro_invalid EXCEPTION;
    telefone_invalid EXCEPTION;
    email_invalid EXCEPTION;
    "dentista_id" NUMBER;
BEGIN
    -- Busca o dentista pelo CRO
    BEGIN
        SELECT "id_dentista"
        INTO "dentista_id"
        FROM "T_OPBD_DENTISTA"
        WHERE "ds_cro" = "p_ds_cro";
    EXCEPTION
        WHEN no_data_found THEN
            RAISE dentista_not_found;
    END;

    IF NOT "FUN_VALIDA_CPF"("p_ds_doc") THEN
        IF NOT "FUN_VALIDA_CNPJ"("p_ds_doc") THEN
            RAISE invalid_doc;
        END IF;
    END IF;

    -- Valida o email
    IF NOT "FUN_VALIDA_EMAIL"("p_ds_email") THEN
        RAISE email_invalid;
    END IF;

    -- Valida o telefone
    IF NOT "FUN_VALIDA_TELEFONE"("p_nr_telefone") THEN
        RAISE telefone_invalid;
    END IF;

    -- Faz o Update
    UPDATE "T_OPBD_DENTISTA"
    SET "nm_dentista"          = "p_nm_dentista",
        "nr_telefone"          = "p_nr_telefone",
        "ds_email"             = "p_ds_email",
        "ds_doc_identificacao" = "p_ds_doc"
    WHERE "id_dentista" = "dentista_id";
EXCEPTION
    WHEN invalid_doc THEN
        RAISE_APPLICATION_ERROR(-20001, 'CPF/CNPJ Inválido.');
    WHEN dentista_not_found THEN
        RAISE_APPLICATION_ERROR(-20002, 'Dentista não existe.');
    WHEN cro_invalid THEN
        RAISE_APPLICATION_ERROR(-20003, 'CRO Inválido.');
    WHEN email_invalid THEN
        RAISE_APPLICATION_ERROR(-20004,
                                'Email inválido. Email deve ter formato user@example.com, user@example.org, user@example.br');
    WHEN telefone_invalid THEN
        RAISE_APPLICATION_ERROR(-20005, 'Telefone inválido. Deve ter 11 dígitos, com DDD sem 0, ex 11987654321');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
END;
/

--------------------------------------------------------------------------------------------------------------------------------
-- UPDATE_PLANO
SELECT *
FROM "T_OPBD_PLANO";
--
DECLARE
BEGIN
    "UPDATE_PLANO"(
            'Básico',
            'ODP001'
    );
END;
--
CREATE OR REPLACE PROCEDURE "UPDATE_PLANO"(
    "p_nm_plano" VARCHAR2,
    "p_ds_cod_plano" VARCHAR2
) IS
    "plano_id" NUMBER;
    plano_not_found EXCEPTION;
BEGIN
    -- Busca o Plano
    BEGIN
        SELECT "id_plano"
        INTO "plano_id"
        FROM "T_OPBD_PLANO"
        WHERE "ds_codigo_plano" = "p_ds_cod_plano";
    EXCEPTION
        WHEN no_data_found THEN
            RAISE plano_not_found;
    END;

    -- Faz o Update
    UPDATE "T_OPBD_PLANO"
    SET "nm_plano" = "p_nm_plano"
    WHERE "id_plano" = "plano_id";

EXCEPTION
    WHEN plano_not_found THEN
        RAISE_APPLICATION_ERROR(-20001, 'Plano não existe.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
END;
/

--------------------------------------------------------------------------------------------------------------------------------
-- UPDATE_PERGUNTAS: Não faz sentido ter uma função de update das perguntas para a nossa funcionalidade
--------------------------------------------------------------------------------------------------------------------------------
-- UPDATE_RESPOSTA
SELECT *
FROM "T_OPBD_RESPOSTAS" r
         JOIN "T_OPBD_CHECK_IN" c ON r."id_resposta" = c."id_resposta"
         JOIN "T_OPBD_PERGUNTAS" p ON c."id_pergunta" = p."id_pergunta";
--
DECLARE
BEGIN
    "UPDATE_RESPOSTA"(
            3,
            1,
            TO_DATE('02/02/2024'),
            'Sim'
    );
END;
--

CREATE OR REPLACE PROCEDURE "UPDATE_RESPOSTA"(
    "p_id_paciente" NUMBER,
    "p_id_pergunta" NUMBER,
    "p_dt_date_checkin" DATE,
    "p_ds_resposta" VARCHAR2
)
    IS
    "resposta_id" NUMBER;
    resposta_not_found EXCEPTION;
BEGIN
    -- Busca a resposta com base na pergunta e na data
    BEGIN
        SELECT "id_resposta"
        INTO "resposta_id"
        FROM "T_OPBD_CHECK_IN"
        WHERE "id_pergunta" = "p_id_pergunta"
          AND "dt_check_in" = "p_dt_date_checkin"
          AND "id_paciente" = "p_id_paciente";
    EXCEPTION
        WHEN no_data_found THEN
            RAISE resposta_not_found;
    END;

    -- Faz o update
    UPDATE "T_OPBD_RESPOSTAS"
    SET "ds_resposta" = "p_ds_resposta"
    WHERE "id_resposta" = "resposta_id";
EXCEPTION
    WHEN resposta_not_found THEN
        RAISE_APPLICATION_ERROR(-20001, 'Resposta não existe.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
END;
/

--------------------------------------------------------------------------------------------------------------------------------
-- UPDATE_EXTRATO_PONTOS
SELECT *
FROM "T_OPBD_EXTRATO_PONTOS";
--
DECLARE
BEGIN
    "UPDATE_EXTRATO_PONTOS"(
            2,
            1,
            CURRENT_DATE,
            -100,
            'Comprou um Chevete'
    );
END;
--
CREATE OR REPLACE PROCEDURE "UPDATE_EXTRATO_PONTOS"(
    "p_id_paciente" NUMBER,
    "p_id_extrato" NUMBER,
    "p_dt_extrato" DATE,
    "p_nr_pontos" NUMBER,
    "p_ds_movimentacao" VARCHAR2)
    IS
    "extrato_id" NUMBER;
    extrato_not_found EXCEPTION;
    data_doc_invalid EXCEPTION;
BEGIN
    -- Valida se o extrato existe
    BEGIN
        SELECT "id_extrato_pontos"
        INTO "extrato_id"
        FROM "T_OPBD_EXTRATO_PONTOS"
        WHERE "id_extrato_pontos" = "p_id_extrato"
          AND "id_paciente" = "p_id_paciente";
    EXCEPTION
        WHEN no_data_found THEN
            RAISE extrato_not_found;
    END;

    -- Valida a data do raio x
    IF NOT "FUN_VALIDA_DATA_DOC"("p_dt_extrato", "p_id_paciente") THEN
        RAISE data_doc_invalid;
    END IF;
    -- Faz o update
    UPDATE "T_OPBD_EXTRATO_PONTOS"
    SET "dt_extrato"       = "p_dt_extrato",
        "nr_numero_pontos" = "p_nr_pontos",
        "ds_movimentacao"  = "p_ds_movimentacao"
    WHERE "id_extrato_pontos" = "p_id_extrato";

EXCEPTION
    WHEN extrato_not_found THEN
        RAISE_APPLICATION_ERROR(-20001, 'Extrato não existe.');
    WHEN data_doc_invalid THEN
        RAISE_APPLICATION_ERROR(-20001, 'Data do extrato não é válida.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
END;
/

--------------------------------------------------------------------------------------------------------------------------------
-- UPDATE_CHECK_IN: Não faz sentido ter uma função de update do Check_In para a nossa funcionalidade
--------------------------------------------------------------------------------------------------------------------------------
-- UPDATE_RAIO_X
SELECT *
FROM "T_OPBD_RAIO_X";
--
DECLARE
BEGIN
    "UPDATE_RAIO_X"(
            1,
            1,
            'Raio_x do siso',
            NULL,
            CURRENT_DATE
    );
END;
--
CREATE OR REPLACE PROCEDURE "UPDATE_RAIO_X"(
    "p_id_paciente" NUMBER,
    "p_id_raio_x" NUMBER,
    "p_ds_raio_x" VARCHAR2,
    "p_im_raio_x" BLOB,
    "p_dt_raio_x" DATE
)
    IS
    raio_x_not_found EXCEPTION;
    data_doc_invalid EXCEPTION;
    "raiox_id" NUMBER;
BEGIN
    -- Verifica se raio x existe
    BEGIN
        SELECT "id_raio_x"
        INTO "raiox_id"
        FROM "T_OPBD_RAIO_X"
        WHERE "id_raio_x" = "p_id_raio_x";
    EXCEPTION
        WHEN no_data_found THEN
            RAISE raio_x_not_found;
    END;

    -- Valida a data do raio x
    IF NOT "FUN_VALIDA_DATA_DOC"("p_dt_raio_x", "p_id_paciente") THEN
        RAISE data_doc_invalid;
    END IF;

    -- Faz o update
    UPDATE "T_OPBD_RAIO_X"
    SET "ds_raio_x"      = "p_ds_raio_x",
        "im_raio_x"      = "p_im_raio_x",
        "dt_data_raio_x" = "p_dt_raio_x"
    WHERE "id_raio_x" = "p_id_raio_x";
EXCEPTION
    WHEN raio_x_not_found THEN
        RAISE_APPLICATION_ERROR(-20001, 'Raio X não existe.');
    WHEN data_doc_invalid THEN
        RAISE_APPLICATION_ERROR(-20001, 'Data do raio x não é válida.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
END;
/

--------------------------------------------------------------------------------------------------------------------------------
-- UPDATE_ANALISE_RAIO_X
SELECT *
FROM "T_OPBD_ANALISE_RAIO_X";
--
DECLARE
BEGIN
    "UPDATE_ANALISE_RAIO_X"(
            1,
            1,
            'Cáries nos dentes superiores',
            CURRENT_DATE
    );
END;
--

CREATE OR REPLACE PROCEDURE "UPDATE_ANALISE_RAIO_X"(
    "p_id_paciente" NUMBER,
    "p_id_raio_x" NUMBER,
    "p_ds_analise" VARCHAR2,
    "p_dt_analise" DATE
) IS
    "analise_id" NUMBER;
    analise_not_found EXCEPTION;
    data_doc_invalid EXCEPTION;
BEGIN
    -- Verificar se a análise já existe
    BEGIN
        SELECT "id_analise_raio_x"
        INTO "analise_id"
        FROM "T_OPBD_ANALISE_RAIO_X"
        WHERE "id_raio_x" = "p_id_raio_x";
    EXCEPTION
        WHEN no_data_found THEN
            RAISE analise_not_found;
    END;

    -- Valida a data do raio x
    IF NOT "FUN_VALIDA_DATA_DOC"("p_dt_analise", "p_id_paciente") THEN
        RAISE data_doc_invalid;
    END IF;

    -- Faz o update
    UPDATE "T_OPBD_ANALISE_RAIO_X"
    SET "ds_analise_raio_x" = "p_ds_analise",
        "dt_analise_raio_x" = "p_dt_analise"
    WHERE "id_analise_raio_x" = "analise_id";

EXCEPTION
    WHEN analise_not_found THEN
        RAISE_APPLICATION_ERROR(-20001, 'Análise do raio X não existe.');
    WHEN data_doc_invalid THEN
        RAISE_APPLICATION_ERROR(-20001, 'Data da análise do raio X não é válida.');
       WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
END;
/
--------------------------------------------------------------------------------------------------------------------------------
-- UPDATE_PACIENTE_DENTISTA: Não faz sentido ter uma função de update de Paciente_Dentista para a nossa funcionalidade
--------------------------------------------------------------------------------------------------------------------------------

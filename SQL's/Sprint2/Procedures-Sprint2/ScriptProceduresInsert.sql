-- INSERT_PACIENTE
SELECT *
FROM "T_OPBD_PACIENTE"
ORDER BY "id_paciente";
--
DECLARE
BEGIN
    "INSERT_PACIENTE"(
            'Maria Josefina',
            TO_DATE('01/01/1965'),
            '11304377601',
            'F',
            '31955487610',
            'majao@gmail.br',
            '2'
    );
END;
--

CREATE OR REPLACE PROCEDURE "INSERT_PACIENTE"(
    "p_nm_paciente" VARCHAR2,
    "p_dt_nascimento" DATE,
    "p_nr_cpf" VARCHAR2,
    "p_ds_sexo" VARCHAR2,
    "p_nr_telefone" VARCHAR2,
    "p_ds_email" VARCHAR2,
    "p_id_plano" NUMBER
) IS
    invalid_cpf EXCEPTION;
    paciente_exists EXCEPTION;
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
        WHEN NO_DATA_FOUND THEN
            "paciente_id" := NULL;
    END;
    IF "paciente_id" IS NOT NULL THEN
        RAISE paciente_exists;
    END IF;

    -- Busca o Plano
    BEGIN
        SELECT "id_plano"
        INTO "plano_id"
        FROM "T_OPBD_PLANO"
        WHERE "id_plano" = "p_id_plano";
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE plano_not_found;
    END;

    -- Valida a data de nascimento
    IF NOT "FUN_VALIDA_NASCIMENTO"("p_dt_nascimento") THEN
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

    -- Inserindo pacientes
    INSERT INTO "T_OPBD_PACIENTE"
    ("id_paciente",
     "nm_paciente",
     "dt_nascimento",
     "nr_cpf",
     "ds_sexo",
     "nr_telefone",
     "ds_email",
     "id_plano")
    VALUES ("SEQ_T_OPBD_PACIENTE".nextval,
            "p_nm_paciente",
            "p_dt_nascimento",
            "p_nr_cpf",
            "p_ds_sexo",
            "p_nr_telefone",
            "p_ds_email",
            "p_id_plano");
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Paciente inserido com sucesso.');
EXCEPTION
    WHEN invalid_cpf THEN
        RAISE_APPLICATION_ERROR(-20001, 'CPF Inválido.');
    WHEN paciente_exists THEN
        RAISE_APPLICATION_ERROR(-20002, 'CPF já cadastrado.');
    WHEN plano_not_found THEN
        RAISE_APPLICATION_ERROR(-20003, 'Plano não existe.');
    WHEN data_nasc_invalid THEN
        RAISE_APPLICATION_ERROR(-20004, 'Data de nascimento inválida. Nascimento deve ser entre 01/01/1900 e hoje');
    WHEN email_invalid THEN
        RAISE_APPLICATION_ERROR(-20005, 'Email inválido. Email deve ter formato user@example.com, user@example.org, user@example.br');
    WHEN telefone_invalid THEN
        RAISE_APPLICATION_ERROR(-20006, 'Telefone inválido. Deve ter 11 dígitos, com DDD sem 0, ex 11987654321');
    WHEN sexo_invalid THEN
        RAISE_APPLICATION_ERROR(-20007, 'Sexo Inválido. Deve ser M, F ou N');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
END "INSERT_PACIENTE";
/
--------------------------------------------------------------------------------------------------------------------------------
-- INSERT_DENTISTA
SELECT *
FROM "T_OPBD_DENTISTA"
ORDER BY "id_dentista";
--
DECLARE
BEGIN
    "INSERT_DENTISTA"(
            'Dr. Jão Jãojão de Oliveira'
        , 'CRO3125441'
        , 'jao.jaojao@gmail.org'
        , '31932151122'
        , '28797727000160'
    );
END;
--
CREATE OR REPLACE PROCEDURE "INSERT_DENTISTA"(
    "p_nm_dentista" VARCHAR2,
    "p_ds_cro" VARCHAR2,
    "p_ds_email" VARCHAR2,
    "p_nr_telefone" VARCHAR2,
    "p_ds_doc_identificacao" VARCHAR2
) IS
    invalid_doc EXCEPTION;
    dentista_exists EXCEPTION;
    cro_invalid EXCEPTION;
    telefone_invalid EXCEPTION;
    email_invalid EXCEPTION;
    "dentista_id" NUMBER;
BEGIN
    -- Chamar a função para validar o CPF OU CNPJ
    IF (NOT "FUN_VALIDA_CPF"("p_ds_doc_identificacao")) AND (NOT "FUN_VALIDA_CNPJ"("p_ds_doc_identificacao")) THEN
        RAISE invalid_doc;
    END IF;

    -- Valida se o CRO está cadastrado
    BEGIN
        SELECT "id_dentista"
        INTO "dentista_id"
        FROM "T_OPBD_DENTISTA"
        WHERE "ds_cro" = "p_ds_cro";
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            "dentista_id" := NULL;
    END;
    IF "dentista_id" IS NOT NULL THEN
        RAISE dentista_exists;
    END IF;

    -- Valida o email
    IF NOT "FUN_VALIDA_EMAIL"("p_ds_email") THEN
        RAISE email_invalid;
    END IF;

    -- Valida o telefone
    IF NOT "FUN_VALIDA_TELEFONE"("p_nr_telefone") THEN
        RAISE telefone_invalid;
    END IF;

     INSERT INTO "T_OPBD_DENTISTA"
    ("id_dentista",
     "nm_dentista",
     "ds_cro",
     "ds_email",
     "nr_telefone",
     "ds_doc_identificacao")
    VALUES ("SEQ_T_OPBD_DENTISTA".nextval,
            "p_nm_dentista",
            "p_ds_cro",
            "p_ds_email",
            "p_nr_telefone",
            "p_ds_doc_identificacao");
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Dentista inserido com sucesso.');
EXCEPTION
    WHEN invalid_doc THEN
        RAISE_APPLICATION_ERROR(-20001, 'CPF / CNPJ Inválido.');
    WHEN dentista_exists THEN
        RAISE_APPLICATION_ERROR(-20002, 'CRO já cadastrado.');
    WHEN cro_invalid THEN
        RAISE_APPLICATION_ERROR(-20003, 'CRO Inválido.');
    WHEN email_invalid THEN
        RAISE_APPLICATION_ERROR(-20004, 'Email inválido. Email deve ter formato user@example.com, user@example.org, user@example.br');
    WHEN telefone_invalid THEN
        RAISE_APPLICATION_ERROR(-20005, 'Telefone inválido. Deve ter 11 dígitos, com DDD sem 0, ex 11987654321');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
END "INSERT_DENTISTA";
/

--------------------------------------------------------------------------------------------------------------------------------
-- INSERT_PLANO
SELECT *
FROM "T_OPBD_PLANO"
ORDER BY "id_plano";
--
DECLARE
BEGIN
    "INSERT_PLANO"(
            'ODP0011',
            'Básico'
    );
END;
--
CREATE OR REPLACE PROCEDURE "INSERT_PLANO"(
    "p_ds_codigo_plano" VARCHAR2,
    "p_nm_plano" VARCHAR2
) IS
    plano_exists EXCEPTION;
    "plano_id" NUMBER;
BEGIN
    -- Busca o Plano
    BEGIN
        SELECT "id_plano"
        INTO "plano_id"
        FROM "T_OPBD_PLANO"
        WHERE "ds_codigo_plano" = "p_ds_codigo_plano";
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            "plano_id" := NULL;
    END;
    IF "plano_id" IS NOT NULL THEN
        RAISE plano_exists;
    END IF;
     INSERT INTO "T_OPBD_PLANO"
    ("id_plano",
     "ds_codigo_plano",
     "nm_plano")
    VALUES ("SEQ_T_OPBD_PLANO".nextval,
            "p_ds_codigo_plano",
            "p_nm_plano");
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Plano inserido com sucesso.');
EXCEPTION
    WHEN plano_exists THEN
        RAISE_APPLICATION_ERROR(-20001, 'Código de plano já registrado');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-2001, 'ERRO DESCONHECIDO.' || SQLERRM);
END "INSERT_PLANO";
/
--------------------------------------------------------------------------------------------------------------------------------
-- INSERT_PERGUNTAS
SELECT *
FROM "T_OPBD_PERGUNTAS"
ORDER BY "id_pergunta";
--
DECLARE
BEGIN
    "INSERT_PERGUNTAS"(
            'Você é diabético?'
    );
END;
--
CREATE OR REPLACE PROCEDURE "INSERT_PERGUNTAS"(
    "p_ds_pergunta" VARCHAR2
) IS
    "pergunta_id" NUMBER;
    pergunta_exists EXCEPTION;
BEGIN
    BEGIN
        SELECT "id_pergunta"
        INTO "pergunta_id"
        FROM "T_OPBD_PERGUNTAS"
        WHERE "ds_pergunta" = "p_ds_pergunta";
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            "pergunta_id" := NULL;
    END;
    IF "pergunta_id" IS NOT NULL THEN
        RAISE pergunta_exists;
    END IF;

    INSERT INTO "T_OPBD_PERGUNTAS"
    ("id_pergunta",
     "ds_pergunta")
    VALUES ("SEQ_T_OPBD_PERGUNTAS".nextval,
            "p_ds_pergunta");
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Pergunta inserida com sucesso.');
EXCEPTION
    WHEN pergunta_exists THEN
        RAISE_APPLICATION_ERROR(-20001, 'Pergunta já existe.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
END "INSERT_PERGUNTAS";
/
--------------------------------------------------------------------------------------------------------------------------------
-- INSERT_RESPOSTAS
SELECT *
FROM "T_OPBD_RESPOSTAS";
--
CREATE OR REPLACE PROCEDURE "INSERT_RESPOSTAS"(
    "p_ds_resposta" VARCHAR2
) IS
BEGIN
    INSERT INTO "T_OPBD_RESPOSTAS"
    ("id_resposta",
     "ds_resposta")
    VALUES ("SEQ_T_OPBD_RESPOSTAS".nextval,
            "p_ds_resposta");
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Resposta inserida com sucesso.');
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERRO DESCONHECIDO.' || SQLERRM);
END "INSERT_RESPOSTAS";
/
--------------------------------------------------------------------------------------------------------------------------------
-- INSERT_EXTRATO_PONTOS
SELECT *
FROM "T_OPBD_EXTRATO_PONTOS"
ORDER BY "id_extrato_pontos";
--
DECLARE
BEGIN
    "INSERT_EXTRATO_PONTOS"(
                    CURRENT_DATE,
                    10,
                    'Respondeu a pergunta 10',
                    1
    );
END;
--
CREATE OR REPLACE PROCEDURE "INSERT_EXTRATO_PONTOS"(
    "p_dt_extrato" DATE,
    "p_nr_numero_pontos" NUMBER,
    "p_ds_movimentacao" VARCHAR2,
    "p_id_paciente" NUMBER
) IS
    paciente_not_found EXCEPTION;
    data_doc_invalid EXCEPTION;
    "id_found" NUMBER;
BEGIN
    -- Valida a data
    IF NOT "FUN_VALIDA_DATA_DOC"("p_dt_extrato", "p_id_paciente") THEN
        RAISE data_doc_invalid;
    END IF;

     -- Valida se o Paciente existe
    BEGIN
        SELECT "id_paciente"
        INTO "id_found"
        FROM "T_OPBD_PACIENTE"
        WHERE "id_paciente" = "p_id_paciente";
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE paciente_not_found;
    END;

    INSERT INTO "T_OPBD_EXTRATO_PONTOS"
    ("id_extrato_pontos",
     "dt_extrato",
     "nr_numero_pontos",
     "ds_movimentacao",
     "id_paciente")
    VALUES ("SEQ_T_OPBD_EXTRATO_PONTOS".nextval,
            "p_dt_extrato",
            "p_nr_numero_pontos",
            "p_ds_movimentacao",
            "p_id_paciente");
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Extrato inserido com sucesso.');
EXCEPTION

    WHEN paciente_not_found THEN
        RAISE_APPLICATION_ERROR(-20001, 'Paciente não existe.');
    WHEN data_doc_invalid THEN
        RAISE_APPLICATION_ERROR(-20002, 'Data do extrato não é válida.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
END "INSERT_EXTRATO_PONTOS";
/
--------------------------------------------------------------------------------------------------------------------------------
-- INSERT_CHECK_IN
SELECT *
FROM "T_OPBD_CHECK_IN"
ORDER BY "id_check_in";
--
BEGIN
    "INSERT_CHECK_IN"(
                    CURRENT_DATE,
                    10,
                    1,
                    1
    );
END;
--
CREATE OR REPLACE PROCEDURE "INSERT_CHECK_IN"(
    "p_dt_check_in" DATE,
    "p_id_paciente" NUMBER,
    "p_id_pergunta" NUMBER,
    "p_id_resposta" NUMBER
) IS
    data_doc_invalid EXCEPTION;
    paciente_not_found EXCEPTION;
    pergunta_not_found EXCEPTION;
    resposta_not_found EXCEPTION;
    "id_found" NUMBER;
BEGIN
    -- Valida se a Pergunta existe
    BEGIN
        SELECT "id_pergunta"
        INTO "id_found"
        FROM "T_OPBD_PERGUNTAS"
        WHERE "id_pergunta" = "p_id_pergunta";
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE pergunta_not_found;
    END;

    -- Valida se a Resposta existe
    BEGIN
        SELECT "id_resposta"
        INTO "id_found"
        FROM "T_OPBD_RESPOSTAS"
        WHERE "id_resposta" = "p_id_resposta";
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE resposta_not_found;
    END;

    -- Valida se o Paciente existe
    BEGIN
        SELECT "id_paciente"
        INTO "id_found"
        FROM "T_OPBD_PACIENTE"
        WHERE "id_paciente" = "p_id_paciente";
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE paciente_not_found;
    END;

    -- Valida a data
    IF NOT "FUN_VALIDA_DATA_DOC"("p_dt_check_in", "p_id_paciente") THEN
        RAISE data_doc_invalid;
    END IF;

    INSERT INTO "T_OPBD_CHECK_IN"
    ("id_check_in",
     "dt_check_in",
     "id_paciente",
     "id_pergunta",
     "id_resposta")
    VALUES ("SEQ_T_OPBD_CHECK_IN".nextval,
            "p_dt_check_in",
            "p_id_paciente",
            "p_id_pergunta",
            "p_id_resposta");
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Check_in inserido com sucesso.');
EXCEPTION
    WHEN paciente_not_found THEN
        RAISE_APPLICATION_ERROR(-20001, 'Paciente não existe.');
    WHEN pergunta_not_found THEN
        RAISE_APPLICATION_ERROR(-20002, 'Pergunta não existe.');
    WHEN resposta_not_found THEN
        RAISE_APPLICATION_ERROR(-20003, 'Resposta não existe.');
    WHEN data_doc_invalid THEN
        RAISE_APPLICATION_ERROR(-20004, 'Data do extrato não é válida.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
        ROLLBACK;
END "INSERT_CHECK_IN";
/
--------------------------------------------------------------------------------------------------------------------------------
-- INSERT_RAIO_X
SELECT *
FROM "T_OPBD_RAIO_X"
ORDER BY "id_raio_x";
--
BEGIN
    "INSERT_RAIO_X"(
            'Raio x de testa',
            NULL,
            CURRENT_DATE,
            10
    );
END;
--
CREATE OR REPLACE PROCEDURE "INSERT_RAIO_X"(
    "p_ds_raio_x" VARCHAR2,
    "p_im_raio_x" BLOB,
    "p_dt_data_raio_x" DATE,
    "p_id_paciente" NUMBER
) IS
    paciente_not_found EXCEPTION;
    data_doc_invalid EXCEPTION;
    "id_found" NUMBER;
BEGIN
    -- Valida se o Paciente existe
    BEGIN
        SELECT "id_paciente"
        INTO "id_found"
        FROM "T_OPBD_PACIENTE"
        WHERE "id_paciente" = "p_id_paciente";
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE paciente_not_found;
    END;

    -- Valida a data do raio x
    IF NOT "FUN_VALIDA_DATA_DOC"("p_dt_data_raio_x", "p_id_paciente") THEN
        RAISE data_doc_invalid;
    END IF;

    INSERT INTO "T_OPBD_RAIO_X"
    ("id_raio_x",
     "ds_raio_x",
     "im_raio_x",
     "dt_data_raio_x",
     "id_paciente")
    VALUES ("SEQ_T_OPBD_RAIO_X".nextval,
            "p_ds_raio_x",
            "p_im_raio_x",
            "p_dt_data_raio_x",
            "p_id_paciente");
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Raio_x inserido com sucesso.');
EXCEPTION
    WHEN paciente_not_found THEN
        RAISE_APPLICATION_ERROR(-20001, 'Paciente não existe.');
    WHEN data_doc_invalid THEN
        RAISE_APPLICATION_ERROR(-20002, 'Data do raio x não é válida.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
END "INSERT_RAIO_X";
/
--------------------------------------------------------------------------------------------------------------------------------
-- INSERT_ANALISE_RAIO_X
SELECT *
FROM "T_OPBD_ANALISE_RAIO_X" AN
         RIGHT JOIN "T_OPBD_RAIO_X" RA
                    ON AN."id_raio_x" = RA."id_raio_x"
ORDER BY "id_analise_raio_x";
--
--DELETE FROM "T_OPBD_ANALISE_RAIO_X" WHERE "id_analise_raio_x" = 11;
--
BEGIN
    "INSERT_ANALISE_RAIO_X"(
            'teste',
            CURRENT_DATE,
            11,
            10
    );
END;
--
CREATE OR REPLACE PROCEDURE "INSERT_ANALISE_RAIO_X"(
    "p_ds_analise_raio_x" CLOB,
    "p_dt_analise_raio_x" DATE,
    "p_id_raio_x" NUMBER,
    "p_id_paciente" NUMBER
) IS
    raio_x_not_found EXCEPTION;
    data_doc_invalid EXCEPTION;
    analise_exists EXCEPTION;
    "id_found" NUMBER;
BEGIN
    -- Verificar se a análise já existe
    BEGIN
        SELECT "id_analise_raio_x"
        INTO "id_found"
        FROM "T_OPBD_ANALISE_RAIO_X"
        WHERE "id_raio_x" = "p_id_raio_x";
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            "id_found" := NULL;
    END;
    IF "id_found" IS NOT NULL THEN
        RAISE analise_exists;
    END IF;

    -- Valida se o Raio X existe
    BEGIN
        SELECT "id_raio_x"
        INTO "id_found"
        FROM "T_OPBD_RAIO_X"
        WHERE "id_raio_x" = "p_id_raio_x"
          AND "id_paciente" = "p_id_paciente";
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE raio_x_not_found;
    END;

    -- Valida a data do Raio X
    IF NOT "FUN_VALIDA_DATA_DOC"("p_dt_analise_raio_x", "p_id_paciente") THEN
        RAISE data_doc_invalid;
    END IF;
    INSERT INTO "T_OPBD_ANALISE_RAIO_X"
    ("id_analise_raio_x",
     "ds_analise_raio_x",
     "dt_analise_raio_x",
     "id_raio_x")
    VALUES ("SEQ_T_OPBD_ANALISE_RAIO_X".nextval,
            "p_ds_analise_raio_x",
            "p_dt_analise_raio_x",
            "p_id_raio_x");
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Análise do raio_x inserida com sucesso.');
EXCEPTION
    WHEN raio_x_not_found THEN
        RAISE_APPLICATION_ERROR(-20001, 'Raio X não existe.');
    WHEN analise_exists THEN
        RAISE_APPLICATION_ERROR(-20002, 'Já existe uma análise para esse Raio X.');
    WHEN data_doc_invalid THEN
        RAISE_APPLICATION_ERROR(-20003, 'Data da análise não é válida.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
END "INSERT_ANALISE_RAIO_X";
/
--------------------------------------------------------------------------------------------------------------------------------
-- INSERT_PACIENTE_DENTISTA
SELECT *
FROM "T_OPBD_PACIENTE_DENTISTA" PD
LEFT JOIN "T_OPBD_DENTISTA" TOD ON TOD."id_dentista" = PD."id_dentista"
LEFT JOIN "T_OPBD_PACIENTE" PC ON PD."id_paciente" = PC."id_paciente"
ORDER BY PD."id_dentista", PD."id_paciente";
--
BEGIN
    "INSERT_PACIENTE_DENTISTA"(
            10,
            1
    );
END;
--
CREATE OR REPLACE PROCEDURE "INSERT_PACIENTE_DENTISTA"(
    "p_id_dentista" NUMBER,
    "p_id_paciente" NUMBER
) IS
    paciente_not_found EXCEPTION;
    dentista_not_found EXCEPTION;
    relacao_exists EXCEPTION;
    "id_found" NUMBER;
BEGIN
    -- Valida se a relação existe
    BEGIN
        SELECT "id_dentista"
        INTO "id_found"
        FROM "T_OPBD_PACIENTE_DENTISTA"
        WHERE "id_dentista" = "p_id_dentista"
          AND "id_paciente" = "p_id_paciente";
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            "id_found" := NULL;
    END;
    IF "id_found" IS NOT NULL THEN
        RAISE relacao_exists;
    END IF;
    -- Valida se o Paciente existe
    BEGIN
        SELECT "id_paciente"
        INTO "id_found"
        FROM "T_OPBD_PACIENTE"
        WHERE "id_paciente" = "p_id_paciente";
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE paciente_not_found;
    END;

    -- Valida se o Dentista existe
    BEGIN
        SELECT "id_dentista"
        INTO "id_found"
        FROM "T_OPBD_DENTISTA"
        WHERE "id_dentista" = "p_id_dentista";
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE dentista_not_found;
    END;

    INSERT INTO "T_OPBD_PACIENTE_DENTISTA"
    ("id_dentista",
     "id_paciente")
    VALUES ("p_id_dentista",
            "p_id_paciente");
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Relação paciente dentista inserida com sucesso.');
EXCEPTION
    WHEN relacao_exists THEN
        RAISE_APPLICATION_ERROR(-20001, 'Relação entre Paciente e Dentista já existe.');
    WHEN paciente_not_found THEN
        RAISE_APPLICATION_ERROR(-20002, 'Paciente não existe.');
    WHEN dentista_not_found THEN
        RAISE_APPLICATION_ERROR(-20003, 'Dentista não existe.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
        ROLLBACK;
END "INSERT_PACIENTE_DENTISTA";
/
-- Package para CRUD
CREATE OR REPLACE PACKAGE "PKG_CRUD_ANALISE_RAIO_X" AS
    -- Procedure para inserir uma nova análise de raio-x
    PROCEDURE "INSERT_ANALISE_RAIO_X"(
        "p_ds_analise_raio_x" CLOB,
        "p_dt_analise_raio_x" DATE,
        "p_id_raio_x" NUMBER,
        "p_id_paciente" NUMBER
    );

    -- Procedure para atualizar uma análise de raio-x
    PROCEDURE "UPDATE_ANALISE_RAIO_X"(
        "p_id_paciente" NUMBER,
        "p_id_raio_x" NUMBER,
        "p_ds_analise" VARCHAR2,
        "p_dt_analise" DATE
    );

    -- Procedure para deletar uma análise de raio-x
    PROCEDURE "DELETE_ANALISE_RAIO_X"(
        "p_id_analise_raio_x" NUMBER
    );

END "PKG_CRUD_ANALISE_RAIO_X";
/


-- Package Body para CRUD
CREATE OR REPLACE PACKAGE BODY "PKG_CRUD_ANALISE_RAIO_X" AS
    -- Exceções globais do pacote
    raio_x_not_found EXCEPTION;
    data_doc_invalid EXCEPTION;
    analise_exists EXCEPTION;
    analise_not_found EXCEPTION;

    -- Procedure de inserção
    PROCEDURE "INSERT_ANALISE_RAIO_X"(
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
            WHEN no_data_found THEN
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
            WHEN no_data_found THEN
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
        dbms_output.put_line('Análise do raio_x inserida com sucesso.');
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

    -- Procedure de atualização
    PROCEDURE "UPDATE_ANALISE_RAIO_X"(
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
    END "UPDATE_ANALISE_RAIO_X";

    -- Procedure de exclusão
    PROCEDURE "DELETE_ANALISE_RAIO_X"(
        "p_id_analise_raio_x" NUMBER
    ) IS
    BEGIN

        DELETE
        FROM "T_OPBD_ANALISE_RAIO_X"
        WHERE "id_analise_raio_x" = "p_id_analise_raio_x";
        dbms_output
            .
            put_line
        ('Análise do raio_x deletada com sucesso.');

        COMMIT;
    EXCEPTION
        WHEN no_data_found THEN
            RAISE_APPLICATION_ERROR(-20001, 'Análise do raio_x não encontrada.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "DELETE_ANALISE_RAIO_X";

END "PKG_CRUD_ANALISE_RAIO_X";
/

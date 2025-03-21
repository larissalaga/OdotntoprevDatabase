-- Package para CRUD
CREATE OR REPLACE PACKAGE "PKG_CRUD_RAIO_X" AS
    -- Procedure para inserir um novo raio-x
    PROCEDURE "INSERT_RAIO_X"(
        "p_ds_raio_x" VARCHAR2,
        "p_im_raio_x" BLOB,
        "p_dt_data_raio_x" DATE,
        "p_id_paciente" NUMBER
    );

    -- Procedure para atualizar um raio-x
    PROCEDURE "UPDATE_RAIO_X"(
        "p_id_paciente" NUMBER,
        "p_id_raio_x" NUMBER,
        "p_ds_raio_x" VARCHAR2,
        "p_im_raio_x" BLOB,
        "p_dt_raio_x" DATE
    );

    -- Procedure para deletar um raio-x
    PROCEDURE "DELETE_RAIO_X"(
        "p_id_raio_x" NUMBER
    );

END "PKG_CRUD_RAIO_X";
/

-- Package Body para CRUD
CREATE OR REPLACE PACKAGE BODY "PKG_CRUD_RAIO_X" AS
    -- Exceções globais do pacote
    paciente_not_found EXCEPTION;
    data_doc_invalid EXCEPTION;
    raio_x_not_found EXCEPTION;

    -- Procedure de inserção
    PROCEDURE "INSERT_RAIO_X"(
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
            WHEN no_data_found THEN
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
        dbms_output.put_line('Raio_x inserido com sucesso.');
    EXCEPTION
        WHEN paciente_not_found THEN
            RAISE_APPLICATION_ERROR(-20001, 'Paciente não existe.');
        WHEN data_doc_invalid THEN
            RAISE_APPLICATION_ERROR(-20002, 'Data do raio x não é válida.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "INSERT_RAIO_X";

    -- Procedure de atualização
    PROCEDURE "UPDATE_RAIO_X"(
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
    END "UPDATE_RAIO_X";

    -- Procedure de exclusão
    PROCEDURE "DELETE_RAIO_X"(
        "p_id_raio_x" NUMBER
    ) IS
    BEGIN
        -- Deleta da tabela Analise_Raio_x
        DELETE
        FROM "T_OPBD_ANALISE_RAIO_X"
        WHERE "id_raio_x" = "p_id_raio_x";
        dbms_output
            .
            put_line
        ('Análise deletada com sucesso.');

        -- Deleta da tabela Raio_x
        DELETE
        FROM "T_OPBD_RAIO_X"
        WHERE "id_raio_x" = "p_id_raio_x";
        dbms_output
            .
            put_line
        ('Raio_x deletado com sucesso.');

        COMMIT;
    EXCEPTION
        WHEN no_data_found THEN
            RAISE_APPLICATION_ERROR(-20001, 'Raio_x não encontrado.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "DELETE_RAIO_X";
END "PKG_CRUD_RAIO_X";
/
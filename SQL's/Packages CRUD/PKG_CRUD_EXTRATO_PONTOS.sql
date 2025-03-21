-- Package para CRUD
CREATE OR REPLACE PACKAGE "PKG_CRUD_EXTRATO_PONTOS" AS
    -- Procedure para inserir um novo extrato de pontos
    PROCEDURE "INSERT_EXTRATO_PONTOS"(
        "p_dt_extrato" DATE,
        "p_nr_numero_pontos" NUMBER,
        "p_ds_movimentacao" VARCHAR2,
        "p_id_paciente" NUMBER
    );

    -- Procedure para atualizar um extrato de pontos
    PROCEDURE "UPDATE_EXTRATO_PONTOS"(
        "p_id_paciente" NUMBER,
        "p_id_extrato" NUMBER,
        "p_dt_extrato" DATE,
        "p_nr_pontos" NUMBER,
        "p_ds_movimentacao" VARCHAR2
    );

    -- Procedure para deletar um extrato de pontos
    PROCEDURE "DELETE_EXTRATO_PONTOS"(
        "p_id_extrato_pontos" NUMBER
    );

END "PKG_CRUD_EXTRATO_PONTOS";
/

-- Package Body para CRUD
CREATE OR REPLACE PACKAGE BODY "PKG_CRUD_EXTRATO_PONTOS" AS
    -- Exceções globais do pacote
    paciente_not_found EXCEPTION;
    data_doc_invalid EXCEPTION;
    extrato_not_found EXCEPTION;

    -- Procedure de inserção
    PROCEDURE "INSERT_EXTRATO_PONTOS"(
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
            WHEN no_data_found THEN
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
        dbms_output.put_line('Extrato inserido com sucesso.');
    EXCEPTION

        WHEN paciente_not_found THEN
            RAISE_APPLICATION_ERROR(-20001, 'Paciente não existe.');
        WHEN data_doc_invalid THEN
            RAISE_APPLICATION_ERROR(-20002, 'Data do extrato não é válida.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "INSERT_EXTRATO_PONTOS";

    -- Procedure de atualização
    PROCEDURE "UPDATE_EXTRATO_PONTOS"(
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
    END "UPDATE_EXTRATO_PONTOS";

    -- Procedure de exclusão
    PROCEDURE "DELETE_EXTRATO_PONTOS"(
        "p_id_extrato_pontos" NUMBER
    ) IS
    BEGIN
        -- Deleta da tabela Extrato_pontos
        DELETE
        FROM "T_OPBD_EXTRATO_PONTOS"
        WHERE "id_extrato_pontos" = "p_id_extrato_pontos";
        dbms_output
            .
            put_line
        ('Extrato deletado com sucesso.');

        COMMIT;
    EXCEPTION
        WHEN no_data_found THEN
            RAISE_APPLICATION_ERROR(-20001, 'Extrato não encontrado.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "DELETE_EXTRATO_PONTOS";
END "PKG_CRUD_EXTRATO_PONTOS";
/
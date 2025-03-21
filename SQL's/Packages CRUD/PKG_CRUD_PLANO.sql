-- Package para CRUD
CREATE OR REPLACE PACKAGE "PKG_CRUD_PLANO" AS
    -- Procedure para inserir um novo plano
    PROCEDURE "INSERT_PLANO"(
        "p_ds_codigo_plano" VARCHAR2,
        "p_nm_plano" VARCHAR2
    );

    -- Procedure para atualizar um plano
    PROCEDURE "UPDATE_PLANO"(
        "p_nm_plano" VARCHAR2,
        "p_ds_cod_plano" VARCHAR2
    );

    -- Procedure para deletar um plano
    PROCEDURE "DELETE_PLANO"(
        "p_ds_codigo_plano" VARCHAR2
    );

END "PKG_CRUD_PLANO";
/

-- Package Body para CRUD
CREATE OR REPLACE PACKAGE BODY "PKG_CRUD_PLANO" AS
    -- Exceções globais do pacote
    plano_exists EXCEPTION;
    plano_not_found EXCEPTION;

    -- Procedure de inserção
    PROCEDURE "INSERT_PLANO"(
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
            WHEN no_data_found THEN
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
        dbms_output.put_line('Plano inserido com sucesso.');
    EXCEPTION
        WHEN plano_exists THEN
            RAISE_APPLICATION_ERROR(-20001, 'Código de plano já registrado');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-2001, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "INSERT_PLANO";

    -- Procedure de atualização
    PROCEDURE "UPDATE_PLANO"(
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
    END "UPDATE_PLANO";

    -- Procedure de exclusão
    PROCEDURE "DELETE_PLANO"(
        "p_ds_codigo_plano" VARCHAR2
    ) IS
        "plano_id" NUMBER;
    BEGIN
        -- Não vamos deletar um plano se ele já estiver sendo utilizado por um paciente
        DELETE
        FROM "T_OPBD_PLANO"
        WHERE "ds_codigo_plano" = "p_ds_codigo_plano"
          AND "id_plano" NOT IN (SELECT "id_plano"
                                 FROM "T_OPBD_PACIENTE");
        dbms_output
            .
            put_line
        ('Plano deletado com sucesso.');

        COMMIT;
    EXCEPTION
        WHEN no_data_found THEN
            RAISE_APPLICATION_ERROR(-20001, 'Plano não encontrado.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'ERRO DESCONHECIDO.' || SQLERRM);
    END "DELETE_PLANO";
END "PKG_CRUD_PLANO";
/
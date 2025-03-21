CREATE OR REPLACE TRIGGER "TR_OPBD_AUDITORIA_PACIENTE"
    AFTER INSERT OR UPDATE OR DELETE
    ON "T_OPBD_PACIENTE"
    FOR EACH ROW
DECLARE
    v_operacao           VARCHAR2(10);
    v_valores_anteriores CLOB;
BEGIN
    -- Definir a operação (INSERT, UPDATE, DELETE)
    IF INSERTING THEN
        v_operacao := 'INSERT';
        v_valores_anteriores := NULL;
    ELSIF UPDATING THEN
        v_operacao := 'UPDATE';
        v_valores_anteriores := 'ID: ' || :old."id_paciente" ||
                                ', Nome: ' || :old."nm_paciente" ||
                                ', Data Nascimento: ' || TO_CHAR(:old."dt_nascimento", 'DD/MM/YYYY') ||
                                ', CPF: ' || :old."nr_cpf" ||
                                ', Sexo: ' || :old."ds_sexo" ||
                                ', Telefone: ' || :old."nr_telefone" ||
                                ', Email: ' || :old."ds_email" ||
                                ', Plano ID: ' || :old."id_plano";
    ELSIF DELETING THEN
        v_operacao := 'DELETE';
        v_valores_anteriores := 'ID: ' || :old."id_paciente" ||
                                ', Nome: ' || :old."nm_paciente" ||
                                ', Data Nascimento: ' || TO_CHAR(:old."dt_nascimento", 'DD/MM/YYYY') ||
                                ', CPF: ' || :old."nr_cpf" ||
                                ', Sexo: ' || :old."ds_sexo" ||
                                ', Telefone: ' || :old."nr_telefone" ||
                                ', Email: ' || :old."ds_email" ||
                                ', Plano ID: ' || :old."id_plano";
    END IF;

    -- Inserindo os dados na auditoria
    INSERT INTO "T_OPBD_AUDITORIA" ("id_auditoria", "nm_tabela", "ds_operacao", "dt_operacao", "id_usuario",
                                    "nm_valores_anteriores")
    VALUES ("SEQ_T_OPBD_AUDITORIA".nextval,
            'T_OPBD_PACIENTE',
            v_operacao,
            SYSTIMESTAMP,
            USER,
            v_valores_anteriores);
END;
/
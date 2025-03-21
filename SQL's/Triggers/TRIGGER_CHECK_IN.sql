CREATE OR REPLACE TRIGGER "TR_OPBD_AUDITORIA_CHECKIN"
    AFTER INSERT OR UPDATE OR DELETE
    ON "T_OPBD_CHECK_IN"
    FOR EACH ROW
DECLARE
    v_operacao           VARCHAR2(10);
    v_valores_anteriores CLOB;
BEGIN
    -- verigica se a op = (INSERT, UPDATE, DELETE)
    IF INSERTING THEN
        v_operacao := 'INSERT';
        v_valores_anteriores := NULL;
    ELSIF DELETING THEN
        v_operacao := 'DELETE';
        v_valores_anteriores := 'ID: ' || :old."id_check_in" || -- Alterado: Aspas duplas para "id_check_in"
                                ', Data Check-in: ' ||
                                TO_CHAR(:old."dt_check_in", 'DD/MM/YYYY') || -- Alterado: Aspas duplas para "dt_check_in"
                                ', Paciente ID: ' || :old."id_paciente" || -- Alterado: Aspas duplas para "id_paciente"
                                ', Pergunta ID: ' || :old."id_pergunta" || -- Alterado: Aspas duplas para "id_pergunta"
                                ', Resposta ID: ' || :old."id_resposta"; -- Alterado: Aspas duplas para "id_resposta"
    END IF;
    -- Insere os dados na auditoria
    INSERT INTO "T_OPBD_AUDITORIA" ( -- Alterado: Aspas duplas para "T_OPBD_AUDITORIA"
        "id_auditoria", "nm_tabela", "ds_operacao", "dt_operacao", "id_usuario",
        "nm_valores_anteriores" -- Alterado: Aspas duplas para os atributos
    )
    VALUES ("SEQ_T_OPBD_AUDITORIA".nextval, -- Verifique se a sequence tem esse nome correto
            'T_OPBD_CHECK_IN', -- Tabela como string, sem mudança
            v_operacao, -- Variável com a operação
            SYSTIMESTAMP,
            USER,
            v_valores_anteriores -- Variável com os valores antigos
           );
END;
/

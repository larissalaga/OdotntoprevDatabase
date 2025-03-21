CREATE OR REPLACE TRIGGER "TR_OPBD_AUDITORIA_DENTISTA" -- Alterado: Aspas duplas para "TR_OPBD_AUDITORIA_DENTISTA"
    AFTER INSERT OR UPDATE OR DELETE
    ON "T_OPBD_DENTISTA" -- Alterado: Aspas duplas para "T_OPBD_DENTISTA"
    FOR EACH ROW
DECLARE
    v_operacao           VARCHAR2(10);
    v_valores_anteriores CLOB;
BEGIN
    IF inserting THEN
        v_operacao := 'INSERT';
        v_valores_anteriores := NULL;
    ELSIF updating THEN
        v_operacao := 'UPDATE';
        v_valores_anteriores := 'ID: ' || :OLD."id_dentista" || -- Alterado: Aspas duplas para "id_dentista"
                                ', Nome: ' || :OLD."nm_dentista" || -- Alterado: Aspas duplas para "nm_dentista"
                                ', CRO: ' || :OLD."ds_cro" || -- Alterado: Aspas duplas para "ds_cro"
                                ', Email: ' || :OLD."ds_email" || -- Alterado: Aspas duplas para "ds_email"
                                ', Telefone: ' || :OLD."nr_telefone" || -- Alterado: Aspas duplas para "nr_telefone"
                                ', Documento: ' ||
                                :OLD."ds_doc_identificacao"; -- Alterado: Aspas duplas para "ds_doc_identificacao"
    ELSIF deleting THEN
        v_operacao := 'DELETE';
        v_valores_anteriores := 'ID: ' || :OLD."id_dentista" || -- Alterado: Aspas duplas para "id_dentista"
                                ', Nome: ' || :OLD."nm_dentista" || -- Alterado: Aspas duplas para "nm_dentista"
                                ', CRO: ' || :OLD."ds_cro" || -- Alterado: Aspas duplas para "ds_cro"
                                ', Email: ' || :OLD."ds_email" || -- Alterado: Aspas duplas para "ds_email"
                                ', Telefone: ' || :OLD."nr_telefone" || -- Alterado: Aspas duplas para "nr_telefone"
                                ', Documento: ' ||
                                :OLD."ds_doc_identificacao"; -- Alterado: Aspas duplas para "ds_doc_identificacao"
    END IF;

    -- Inserindo os dados na auditoria
    INSERT INTO "T_OPBD_AUDITORIA" ( -- Alterado: Aspas duplas para "T_OPBD_AUDITORIA"
        "id_auditoria", "nm_tabela", "ds_operacao", "dt_operacao", "id_usuario",
        "nm_valores_anteriores" -- Alterado: Aspas duplas para os atributos
    )
    VALUES ("SEQ_T_OPBD_AUDITORIA".nextval, -- Verifique se a sequence tem esse nome correto
            'T_OPBD_DENTISTA', -- Tabela como string, sem mudança
            v_operacao, -- Variável com a operação
            SYSTIMESTAMP,
            USER,
            v_valores_anteriores -- Variável com os valores antigos
           );
END;
/

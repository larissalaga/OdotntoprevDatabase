DROP TABLE "T_OPBD_AUDITORIA";
DROP SEQUENCE "SEQ_T_OPBD_AUDITORIA";

--------------------------------------------------------------------------------------------------------------------------------
-- Criando a SEQUENCE para gerar IDs automaticamente
CREATE SEQUENCE "SEQ_T_OPBD_AUDITORIA" START WITH 1 INCREMENT BY 1;

CREATE TABLE "T_OPBD_AUDITORIA" (
    "id_auditoria" NUMBER(20) PRIMARY KEY,
    "nm_tabela" VARCHAR2(50) NOT NULL,
    "ds_operacao" VARCHAR2(10) NOT NULL,
    "dt_operacao" TIMESTAMP DEFAULT SYSTIMESTAMP,
    "id_usuario" VARCHAR2(100) DEFAULT USER,
    "nm_valores_anteriores" CLOB
);

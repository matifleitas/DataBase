-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2023-04-11 16:59:59.279

-- tables
-- Table: AUDIO
CREATE TABLE AUDIO (
    format varchar(20)  NOT NULL,
    duration int  NOT NULL,
    id_object int  NOT NULL,
    CONSTRAINT PK_AUDIO PRIMARY KEY (id_object)
);

-- Table: COLLECTION
CREATE TABLE COLLECTION (
    id_collection int  NOT NULL,
    tittle_collection varchar(80)  NOT NULL,
    description varchar(100)  NOT NULL,
    CONSTRAINT PK_COLLECTION PRIMARY KEY (id_collection)
);

-- Table: DOCUMENTO
CREATE TABLE DOCUMENTO (
    type_publication varchar(80)  NOT NULL,
    modos int  NOT NULL,
    color_modes varchar(20)  NOT NULL,
    resolution_capture varchar(20)  NOT NULL,
    id_object int  NOT NULL,
    CONSTRAINT PK_DOCUMENTO PRIMARY KEY (id_object)
);

-- Table: OBJECT
CREATE TABLE OBJECT (
    id_object int  NOT NULL,
    tittle varchar(80)  NOT NULL,
    description varchar(100)  NOT NULL,
    fuente varchar(100)  NOT NULL,
    date date  NOT NULL,
    type char(3)  NOT NULL,
    id_repositorio int  NOT NULL,
    id_collection int  NOT NULL,
    CONSTRAINT PK_OBJECT PRIMARY KEY (id_object)
);

-- Table: REPOSITORIO
CREATE TABLE REPOSITORIO (
    Id_repositorio int  NOT NULL,
    name varchar(100)  NOT NULL,
    publico varchar(20)  NOT NULL,
    description varchar(100)  NOT NULL,
    owner varchar(20)  NULL,
    CONSTRAINT PK_REPOSITORIO PRIMARY KEY (Id_repositorio)
);

-- Table: VIDEO
CREATE TABLE VIDEO (
    resolution varchar(20)  NOT NULL,
    fps int  NOT NULL,
    id_object int  NOT NULL,
    CONSTRAINT PK_VIDEO PRIMARY KEY (id_object)
);

-- foreign keys
-- Reference: DOCUMENTO_OBJECT (table: DOCUMENTO)
ALTER TABLE DOCUMENTO ADD CONSTRAINT DOCUMENTO_OBJECT
    FOREIGN KEY (id_object)
    REFERENCES OBJECT (id_object)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_AUDIO_OBJECT (table: AUDIO)
ALTER TABLE AUDIO ADD CONSTRAINT FK_AUDIO_OBJECT
    FOREIGN KEY (id_object)
    REFERENCES OBJECT (id_object)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_OBJECT_COLLECTION (table: OBJECT)
ALTER TABLE OBJECT ADD CONSTRAINT FK_OBJECT_COLLECTION
    FOREIGN KEY (id_collection)
    REFERENCES COLLECTION (id_collection)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_VIDEO_OBJECT (table: VIDEO)
ALTER TABLE VIDEO ADD CONSTRAINT FK_VIDEO_OBJECT
    FOREIGN KEY (id_object)
    REFERENCES OBJECT (id_object)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: OBJECT_REPOSITORIO (table: OBJECT)
ALTER TABLE OBJECT ADD CONSTRAINT OBJECT_REPOSITORIO
    FOREIGN KEY (id_repositorio)
    REFERENCES REPOSITORIO (Id_repositorio)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

INSERT INTO OBJECT (tittle)
VALUES (titulo1)/* titulo2, titulo3, titulo4, titulo5, titulo6, titulo7, titulo8, titulo9, titulo10);*/
-- End of file.



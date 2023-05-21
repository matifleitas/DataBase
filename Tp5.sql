CREATE TABLE matute_prueba (
    nombre VARCHAR(100) NOT NULL,
    id int NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    CONSTRAINT PK_ID PRIMARY KEY (id));

/* 1)a)Cómo debería implementar las Restricciones de Integridad Referencial (RIR) si se desea que cada vez que se elimine un
   registro de la tabla PALABRA , también se eliminen los artículos que la referencian en la tabla CONTIENE.*/

ALTER TABLE unc_251672.p5p1e1_palabra  ADD CONSTRAINT FK_CONTIENE
    FOREIGN KEY (idioma, cod_palabra)
    REFERENCES unc_251672.p5p1e1_contiene (idioma, cod_palabra)
    ON DELETE CASCADE;

/*Verifique qué sucede con las palabras contenidas en cada artículo, al eliminar una palabra,
si definen la Acción Referencial para las bajas (ON DELETE) de la RIR correspondiente
como:
    ii) Restrict
    iii) Es posible para éste ejemplo colocar SET NULL o SET DEFAULT para ON
    DELETE y ON UPDATE?*/

INSERT INTO unc_251672.p5p1e1_palabra (idioma, cod_palabra, descripcion) VALUES ('2', '445667', 'vb dsffsdffsdasdf jskodjk');

/* 2)
a) Indique el resultado de las siguientes operaciones, teniendo en cuenta las acciones
referenciales e instancias dadas. En caso de que la operación no se pueda realizar, indicar qué
regla/s entra/n en conflicto y cuál es la causa. En caso de que sea aceptada, comente el
resultado que produciría (NOTA: en cada caso considere el efecto sobre la instancia original de
la BD, los resultados no son acumulativos).*/

--b.1)
delete from tp5_p1_ej2_proyecto where id_proyecto = 3;
--INSERT INTO unc_251672.tp5_p1_ej2_proyecto (id_proyecto, nombre_proyecto, anio_inicio, anio_fin) VALUES ('3', 'Proy 3', '2020', NULL);

--b.2)
update tp5_p1_ej2_proyecto set id_proyecto = 3 where id_proyecto = 7;

--b.3)
delete from tp5_p1_ej2_proyecto where id_proyecto = 1;
--No se puede borrar porque en la tabla "trbaja_en" ya esta seteado el id_proyecto = 1, no deberia haber registros
--referenciados a id_proyecto = 1 para que se pueda realizar;

--b.4)
delete from tp5_p1_ej2_empleado where tipo_empleado = 'A' and nro_empleado = 2;
--INSERT INTO tp5_p1_ej2_empleado VALUES ('A ', 2, 'María', 'Casio', 'CIO');

--b.5)
update tp5_p1_ej2_trabaja_en set id_proyecto = 1 where id_proyecto =3;

--b.6)
update tp5_p1_ej2_proyecto set id_proyecto = 5 where id_proyecto = 2;
--No se puede hacer el update ya que id_proyecto esta asociado a la tabla TRABAJA_EN al empleado 2 y a la tabla
--AUSPICIO a McDonald;

--B)
/*
Indique el resultado de la siguiente operaciones justificando su elección:
UPDATE auspicio SET id_proyecto= 66, nro_empleado = 10
    WHERE id_proyecto = 22
        AND tipo_empleado = 'A'
        AND nro_empleado = 5;
*/
--i.




--d)
--.a)
    insert into unc_251672.tp5_p1_ej2_auspicio values (1, 'Dell' , 'B', null); --es rechazada, B (tipo_empleado) existe pero
    --viola la fk que en la tabla empleado debe existir un nro de empleado para que se pueda insertar en auspicio

--.b)
    insert into unc_251672.tp5_p1_ej2_auspicio values (2, 'Oracle', null, null); --matching full

--.c)
    insert into unc_251672.tp5_p1_ej2_auspicio values (3, 'Google', 'A', 3); --no existe el empleado = 3

--.d)
    insert into unc_251672.tp5_p1_ej2_auspicio values (1, 'HP', null, 3); --no existe el empleado = 3

--EJERCICIO 3
--1)a) No se puede. Ya esta registrada como foreign key en la tabla
--b) F el alter table, tendria que ser nombrado en auto y en vez de conductor, ser contacto ya que en la tabla equipo
-- no existe el atributo conductor
--c) F ya que etapa no existe como atributo en la tabla etapa.
--d) F debido a que nro_auto, es primary key de auto y no de la tabla etapa. Ademas faltaria la pk de auto llamado id_equipo
--e) V id_equipo es la primary key de la tabla equipo correctamente.
--f) V id_equipo y nro_auto son claves correctas para aplicarse como fk en dempEtapa




--TP5-PARTE_2

--3)A)
-- A. Controlar que las nacionalidades sean 'Argentina' 'Español' 'Inglés' 'Alemán' o 'Chilena'.
-- TIPO - check atributo = dominio
      ALTER TABLE unc_251672.p5p1e1_articulo
      ADD CONSTRAINT ck_articulo_nacionalidad
      CHECK (nacionalidad IN ( --NO ESTA CREADO EL ATRIBUTO NACIONALIDAD EN LA TABLA ARTICULO
          'Argentina', 'Español', 'Inglés', 'Alemán', 'Chilena'
          ));

--3)B)
-- B. Para las fechas de publicaciones se debe considerar que sean fechas posteriores o iguales al 2010.
-- TIPO TIPO - check atributo = dominio
    ALTER TABLE unc_251672.p5p1e1_articulo
    ADD CONSTRAINT ck_fecha_publicacion_mayores_a2010
    CHECK (
        EXTRACT(YEAR FROM fecha_publicacion) >= 2010 --NO ESTA CREADO EL ATRIBUTO FECHA_PUBLICACION EN LA TABLA ARTICULO
        );

--3)C)
--C. Cada palabra puede aparecer como máximo en 5 artículos.
-- buscar las palabras que aparecen en más de 5 articulos
-- TIPO - TABLA

    ALTER TABLE unc_251672.p5p1e1_contiene
    ADD CONSTRAINT ck_cant_max_palabra
    CHECK ( NOT EXISTS (
                SELECT 1
                FROM Contiene c
                GROUP BY c.idioma, c.cod_palabra
                HAVING COUNT(*) > 5
            ));

--3)D)
--D. Sólo los autores argentinos pueden publicar artículos que contengan más de
-- 10 palabras claves, pero con un tope de 15 palabras, el resto de los autores
-- sólo pueden publicar artículos que contengan hasta 10 palabras claves.
-- TIPO - general

CREATE ASSERTION autores_argentinos
CHECK (NOT EXISTS(
        SELECT 1
        FROM Articulo a
        WHERE (nacionalidad LIKE 'Argentina' AND
                id_articulo IN ( SELECT 1
                                 FROM Contiene
                                 GROUP BY id_articulo
                                 HAVING COUNT(*) > 15) ) OR
                                (nacionalidad NOT LIKE 'Argentina' AND
                                 id_articulo IN(SELECT 1
                                                FROM contiene
                                                GROUP BY id_articulo
                                                HAVING COUNT(*) > 10) ))
    );

--4)A)
    --TIPO - ATRIBUTO
    ALTER TABLE unc_251672.p5p2e4_imagen_medica
    ADD CONSTRAINT ck_valores_imagen_medica
    CHECK ( modalidad IN (
            'RADIOLOGIA', 'CONVENCIONAL', 'FLUOROSCOPIA', 'ESTUDIOS RADIOGRAFICOS CON
            FLUOROSCOPIA', 'MAMOGRAFIA', 'SONOGRAFIA'
        ));

--B)
    -- TIPO TABLA
    ALTER TABLE unc_251672.p5p2e4_procesamiento
    ADD CONSTRAINT ck_limite_imagenes
    CHECK ( NOT EXISTS(
            SELECT 1
            FROM procesamiento p
            GROUP BY id_imagen, id_paciente
            HAVING COUNT(*) > 5
    ) );

--C)
    --TIPO GENERAL
    ALTER TABLE unc_251672.p5p2e4_imagen_medica --Esta es la sintaxsis de agregacion de columnas
    ADD COLUMN fecha_imagen date;

    ALTER TABLE unc_251672.p5p2e4_procesamiento --Esta es la sintaxsis de agregacion de columnas
    ADD COLUMN fecha_procesamiento date;
-----
    CREATE ASSERTION
    CHECK (
        NOT EXISTS( SELECT 1
                    FROM imagen_medica i JOIN procesamiento p
                    ON ((i.id_paciente = p.id_paciente) AND (i.id_imagen = p.id_imagen))
                    WHERE i.fecha_imagen > p.fecha_procesamiento
    );

--D)
    ALTER TABLE unc_251672.p5p2e4_imagen_medica
    ADD CONSTRAINT ck_limite_procesamientos
    CHECK (NOT EXISTS(
            SELECT 1
            FROM imagen_medica
            WHERE (modalidad LIKE 'FLUOROSCOPIA')
            GROUP BY id_paciente, EXTRACT(YEAR FROM fecha_img)
            HAVING (*) > 2
        ));

   ALTER TABLE p5p2e4_imagen_medica
   ADD CONSTRAINT CK_CANTIDAD_PROCESAMIENTOS
   CHECK ( NOT EXISTS (
                SELECT 1
                FROM p5p2e4_imagen_medica
                WHERE modalidad = 'FLUOROSCOPIA'
                GROUP BY id_paciente, extract(year from fecha_img)
                HAVING COUNT(*) > 2 ))
;

--E)
    CREATE ASSERTION ASDAS
    CHECK (NOT EXISTS (
                SELECT 1
                FROM algoritmo a
                WHERE costo_computacional = 'O(n)'
                AND id_algoritmo IN (SELECT 1
                                     FROM procesamiento p JOIN imagen_medica i
                                     ON ((p.id_paciente = i.id_paciente) AND (i.id_imagen = p.id_imagen))
                                     WHERE i.modalidad = 'FLUOROSCOPIA'
                                    )
    ));
    ---
    CREATE ASSERTION
       CHECK ( NOT EXISTS (
                    SELECT 1
                    FROM p5p2e4_imagen_medica i JOIN p5p2e4_procesamiento p ON
                    (i.id_paciente = p.id_paciente AND i.id_imagen = p.id_imagen)
                    JOIN p5p2e4_algoritmo a ON ( p.id_algoritmo = a.id_algoritmo )
                    WHERE modalidad = 'FLUOROSCOPIA' AND
                    costo_computacional = 'O(n)'
));


--5)-A)
        ALTER TABLE venta
        ADD CONSTRAINT CK_DECUENTO
        CHECK( descuento IN
            (BETWEEN 0 AND 100)));

--B)
--TABLA
    ALTER TABLE VENTA
    ADD CONSTRAINT  CK_DESCUENTO_FECHA
    CHECK ( NOT EXISTS(
                SELECT 1
                FROM p5p2e5_venta
                GROUP BY descuento, EXTRACT(YEAR FROM fecha)
                HAVING COUNT(*) < 30
    ));

--C)
    ALTER TABLE


--D)
    CREATE ASSERTION OFERTA_SIN_DESCUENTO
    CHECK (NOT EXISTS (SELECT 1
                        FROM prenda p JOIN venta v ON (p.id_prenda = v.id_prenda)
                        WHERE p.categoria = 'oferta' AND v.descuento IS NOT NULL)
        );



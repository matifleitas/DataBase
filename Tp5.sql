CREATE TABLE matute_prueba (
    nombre VARCHAR(100) NOT NULL,
    id int NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    CONSTRAINT PK_ID PRIMARY KEY (id));

/* 1)a)Cómo debería implementar las Restricciones de Integridad Referencial (RIR) si se desea que cada vez que se elimine un
   registro de la tabla PALABRA , también se eliminen los artículos que la referencian en la tabla CONTIENE.*/

--Primero dropear constraint configurada
ALTER TABLE DROP CONSTRAINT fk_p5p1e1_contiene_palabra;

--Asignar constraint
ALTER TABLE unc_251672.p5p1e1_contiene
    ADD CONSTRAINT FK_CONTIENE_PALABRA
    FOREIGN KEY (idioma, cod_palabra)
    REFERENCES unc_251672.p5p1e1_palabra (idioma, cod_palabra)
    ON DELETE CASCADE
    ON UPDATE CASCADE
    NOT DEFERRABLE
    INITIALLY IMMEDIATE;

/*Verifique qué sucede con las palabras contenidas en cada artículo, al eliminar una palabra,
si definen la Acción Referencial para las bajas (ON DELETE) de la RIR correspondiente
como:
    ii) Restrict
    iii) Es posible para éste ejemplo colocar SET NULL o SET DEFAULT para ON
    DELETE y ON UPDATE?*/
------------------------------------------------------------------------------------------------------
--RESPUESTA:
    --Definidas las RIR como ON DELETE RESTRICT para las palabras, evita que pueda efectuar el borrado de las mismas
	--cuando estas esten referenciadas en la tabla CONTIENE.

	--Si defino la RIR como ON DELETE SET NULL deberia ocurrir un error ya que las palabras en la tabla contiene son PK, por lo tanto
	--no podrian ser valores nulos.
------------------------------------------------------------------------------------------------------

/* 2)
a) Indique el resultado de las siguientes operaciones, teniendo en cuenta las acciones
referenciales e instancias dadas. En caso de que la operación no se pueda realizar, indicar qué
regla/s entra/n en conflicto y cuál es la causa. En caso de que sea aceptada, comente el
resultado que produciría (NOTA: en cada caso considere el efecto sobre la instancia original de
la BD, los resultados no son acumulativos).*/

	-- tables
	-- Table: TP5_P1_EJ2_AUSPICIO
	CREATE TABLE TP5_P1_EJ2_AUSPICIO (
		id_proyecto int  NOT NULL,
		nombre_auspiciante varchar(20)  NOT NULL,
		tipo_empleado char(2)  NULL,
		nro_empleado int  NULL,
		CONSTRAINT TP5_P1_EJ2_AUSPICIO_pk PRIMARY KEY (id_proyecto,nombre_auspiciante)
	);

	-- Table: TP5_P1_EJ2_EMPLEADO
	CREATE TABLE TP5_P1_EJ2_EMPLEADO (
		tipo_empleado char(2)  NOT NULL,
		nro_empleado int  NOT NULL,
		nombre varchar(40)  NOT NULL,
		apellido varchar(40)  NOT NULL,
		cargo varchar(15)  NOT NULL,
		CONSTRAINT TP5_P1_EJ2_EMPLEADO_pk PRIMARY KEY (tipo_empleado,nro_empleado)
	);

	-- Table: TP5_P1_EJ2_PROYECTO
	CREATE TABLE TP5_P1_EJ2_PROYECTO (
		id_proyecto int  NOT NULL,
		nombre_proyecto varchar(40)  NOT NULL,
		anio_inicio int  NOT NULL,
		anio_fin int  NULL,
		CONSTRAINT TP5_P1_EJ2_PROYECTO_pk PRIMARY KEY (id_proyecto)
	);

	-- Table: TP5_P1_EJ2_TRABAJA_EN
	CREATE TABLE TP5_P1_EJ2_TRABAJA_EN (
		tipo_empleado char(2)  NOT NULL,
		nro_empleado int  NOT NULL,
		id_proyecto int  NOT NULL,
		cant_horas int  NOT NULL,
		tarea varchar(20)  NOT NULL,
		CONSTRAINT TP5_P1_EJ2_TRABAJA_EN_pk PRIMARY KEY (tipo_empleado,nro_empleado,id_proyecto)
	);

	-- foreign keys
	-- Reference: FK_TP5_P1_EJ2_AUSPICIO_EMPLEADO (table: TP5_P1_EJ2_AUSPICIO)
	ALTER TABLE TP5_P1_EJ2_AUSPICIO ADD CONSTRAINT FK_TP5_P1_EJ2_AUSPICIO_EMPLEADO
		FOREIGN KEY (tipo_empleado, nro_empleado)
		REFERENCES TP5_P1_EJ2_EMPLEADO (tipo_empleado, nro_empleado)
		MATCH FULL
		ON DELETE  SET NULL
		ON UPDATE  RESTRICT
	;

	-- Reference: FK_TP5_P1_EJ2_AUSPICIO_PROYECTO (table: TP5_P1_EJ2_AUSPICIO)
	ALTER TABLE TP5_P1_EJ2_AUSPICIO ADD CONSTRAINT FK_TP5_P1_EJ2_AUSPICIO_PROYECTO
		FOREIGN KEY (id_proyecto)
		REFERENCES TP5_P1_EJ2_PROYECTO (id_proyecto)
		ON DELETE  RESTRICT
		ON UPDATE  RESTRICT
	;

	-- Reference: FK_TP5_P1_EJ2_TRABAJA_EN_EMPLEADO (table: TP5_P1_EJ2_TRABAJA_EN)
	ALTER TABLE TP5_P1_EJ2_TRABAJA_EN ADD CONSTRAINT FK_TP5_P1_EJ2_TRABAJA_EN_EMPLEADO
		FOREIGN KEY (tipo_empleado, nro_empleado)
		REFERENCES TP5_P1_EJ2_EMPLEADO (tipo_empleado, nro_empleado)
		ON DELETE  CASCADE
		ON UPDATE  RESTRICT
	;

	-- Reference: FK_TP5_P1_EJ2_TRABAJA_EN_PROYECTO (table: TP5_P1_EJ2_TRABAJA_EN)
	ALTER TABLE TP5_P1_EJ2_TRABAJA_EN ADD CONSTRAINT FK_TP5_P1_EJ2_TRABAJA_EN_PROYECTO
		FOREIGN KEY (id_proyecto)
		REFERENCES TP5_P1_EJ2_PROYECTO (id_proyecto)
		ON DELETE  RESTRICT
		ON UPDATE  CASCADE
	;

--b.1)
delete from tp5_p1_ej2_proyecto where id_proyecto = 3;
-- Se pudo ejecutar correctamente el DELETE. Se borra la linea que contenga id_proyecto = 3.

--b.2)
update tp5_p1_ej2_proyecto set id_proyecto = 3 where id_proyecto = 7;
-- Se pudo ejecutar correctamente el UPDATE. Se modifica el id_proyecto = 3 a id_proyecto = 7.

--b.3)
delete from tp5_p1_ej2_proyecto where id_proyecto = 1;
--No se puede borrar porque en la tabla "trbaja_en" ya esta seteado el id_proyecto = 1, viola la restriccion ON DELETE RESTRICT.

--b.4)
delete from tp5_p1_ej2_empleado where tipo_empleado = 'A' and nro_empleado = 2;
--Se puede eliminar el empleado, se eliminara tambien de la tabla tp5_p1_ej2_trabaja_en y en la tabla
--tp5_p1_ej2_auspicio se colocan ambos valores en null. MIRAR LOS ARTER TABLES DE LAS TABLAS PARA RESOLVER

--b.5)
update tp5_p1_ej2_trabaja_en set id_proyecto = 1 where id_proyecto =3;
--Se pudo modificar id_proyecto. Ya que el id_proyecto = 3 existe en la tabla tp5_p1_ej2_proyecto.

--b.6)
update tp5_p1_ej2_proyecto set id_proyecto = 5 where id_proyecto = 2;
--No se puede hacer el update ya que id_proyecto esta referido como restrict a la tabla AUSPICIO a McDonald;

--B)
/*
Indique el resultado de la siguiente operaciones justificando su elección:
UPDATE auspicio SET id_proyecto= 66, nro_empleado = 10
    WHERE id_proyecto = 22
        AND tipo_empleado = 'A'
        AND nro_empleado = 5;
*/

--El resultado, es la primera ya que es UPDATE RESTRICT en la constraint FK_TP5_P1_EJ2_AUSPICIO_EMPLEADO

--d)
--.a)
    insert into unc_251672.tp5_p1_ej2_auspicio values (1, 'Dell' , 'B', null);
    --SIMPLE, PARCIAL

--.b)
    insert into unc_251672.tp5_p1_ej2_auspicio values (2, 'Oracle', null, null);
    --FULL, SIMPLE, PARCIAL

--.c)
    insert into unc_251672.tp5_p1_ej2_auspicio values (3, 'Google', 'A', 3);
    --SIMPLE, PARCIAL

--.d)
    insert into unc_251672.tp5_p1_ej2_auspicio values (1, 'HP', null, 3);
    --SIMPLE

--EJERCICIO 3

--1)a) No se puede. Ya esta registrada como foreign key en la tabla
--b) F el alter table, tendria que ser nombrado en auto y en vez de conductor, ser contacto ya que en la tabla equipo
-- no existe el atributo conductor
--c) F ya que etapa no existe como atributo en la tabla etapa.
--d) F debido a que nro_auto, es primary key de auto y no de la tabla etapa. Ademas faltaria la pk de auto llamado id_equipo
--e) V id_equipo es la primary key de la tabla equipo correctamente.
--f) V id_equipo y nro_auto son claves correctas para aplicarse como fk en dempEtapa


--TP5-PARTE_2

--EJERCICIO 1
--A --DOMINIIO -- No puede haber voluntarios de más de 70 años.
ALTER TABLE unc_esq_voluntarios
ADD CONSTRAINT ck_fecha_nacimiento
CHECK( NOT EXISTS (
		SELECT 1
		FROM unc_esq_voluntario.voluntario v
		WHERE extract(YEAR FROM(age(v.fecha_nacimiento))) <= '70'
		));

--B --DOMINIO -- Ningún voluntario puede aportar más horas que las de su coordinador.
ALTER TABLE unc_esq_voluntarios
ADD CONSTRAINT ck_horas_voluntario_coordinador
CHECK( NOT EXISTS (
		 SELECT 1
		 FROM voluntario v JOIN FROM voluntario v2 ON (v.nro_voluntario=v2.nro_voluntario)
		 	WHERE v.horas_aportadas > v2.horas_aportadas
		 )));

--C --GENERAL -- Las horas aportadas por los voluntarios deben estar dentro de los valores máximos y
              -- mínimos consignados en la tarea.
CREATE ASSERTION horas_validas
CHECK ( NOT EXISTS (
		SELECT 1
		FROM voluntario v
		JOIN tarea t ON (v.id_tarea=t.id_tarea)
		WHERE v.horas_aportadas < t.min_horas OR v.horas_aportadas > max_horas
	))

--D --TABLA -- Todos los voluntarios deben realizar la misma tarea que su coordinador.
ALTER TABLE voluntarios v
ADD CONSTRAINT ck_misma_tarea
CHECK( NOT EXISTS (
		SELECT 1 FROM
		FROM voluntario v JOIN voluntario v2 ON (v.nro_voluntario=v2.id_coordinador)
		WHERE v2.id_tarea <> v.id_tarea
));

--E --TABLA -- Los voluntarios no pueden cambiar de institución más de tres veces en el año.
ALTER TABLE
ADD CONSTRAINT ck_MAX_POR_ANIO
CHECK( NOT EXISTS (
		SELECT 1
		FROM historico h
		GROUP BY h.nro_voluntario, h.fecha_inicio
		HAVING COUNT(h.id_institucion) > 3
));

--F --TABLA -- En el histórico, la fecha de inicio debe ser siempre menor que la fecha de finalización.
ALTER TABLE historico
ADD CONSTRAINT ck_fecha_inicio
CHECK( NOT EXISTS (
		SELECT 1
		FROM historico h
		WHERE h.fecha_inicio < h.fecha_fin
))

--EJERCICIO 2
--A --TABLA -- Para cada tarea el sueldo máximo debe ser mayor que el sueldo mínimo.
ALTER TABLE tarea
ADD CONSTRAINT ck_max_de_tarea
CHECK( NOT EXISTS (
		SELECT 1
		FROM tarea t
		WHERE t.sueldo_maximo < t.sueldo_min
));

--B --DOMINIO -- No puede haber más de 70 empleados en cada departamento.
ALTER TABLE empleado
ADD CONSTRAINT ck_max_emp_departamentos
CHECK( NOT EXISTS(
		SELECT 1
		FROM unc_esq_peliculas.empleado e
		GROUP BY e.id_departamento
		HAVING COUNT(e.id_departamento) > '70'
));

--C --DOMINIO -- Los empleados deben tener jefes que pertenezcan al mismo departamento.
ALTER TABLE jefes
ADD CONSTRAINT ck_mismo_depto
CHECK ( NOT EXISTS(
                SELECT 1
                FROM unc_esq_peliculas.empleado e
                JOIN unc_esq_peliculas.empleado e2 on (e.id_empleado = e2.id_jefe)
                WHERE e2.
) )

ALTER TABLE empleado
ADD CONSTRAINT ck_mismo_jefe_departamento
CHECK( NOT EXISTS (
		SELECT 1
		FROM unc_esq_peliculas.empleado e
		JOIN unc_esq_peliculas.empleado e2 ON (e.id_empleado = e2.id_jefe)
		WHERE e.id_departamento <> e2.id_departamento --Simbolo <>, es un (No es igual a)
));

--D --DOMINIO -- Todas las entregas, tienen que ser de películas de un mismo idioma.
CREATE ASSERTION ck_mismo_idioma
CHECK ( NOT EXISTS(
		SELECT 1
		FROM unc_esq_peliculas.entrega e
		JOIN r_entrega r ON (e.nro_entrega = r.nro_entrega)
            JOIN pelicula p ON (r.nro_entrega=p.codigo_peliicula)
            GROUP BY r.nro_entrega
            HAVING COUNT((r.idioma)>1
));

--E -- No pueden haber más de 10 empresas productoras por ciudad.
ALTER TABLE ciudad
ADD CONSTRAINT ck_misma_ciudad
CHECK ( NOT EXISTS(
		SELECT 1
		FROM ciudad c
		GROUP BY c.id_ciudad
		HAVING COUNT (*) > 10	//es con *, pq se necesita devolver las peliculas completas
));

--F -- Para cada película, si el formato es 8mm, el idioma tiene que ser francés.
ALTER TABLE pelicula
ADD CONSTRAINT ck_formato
CHECK ( NOT EXISTS(
		SELECT 1
		FROM pelicula p
		WHERE (p.formato = '8mm') <> (p.idioma = 'frances')
));

--G --GENERAL
-- El teléfono de los distribuidores Nacionales debe tener la misma característica que la de su
-- distribuidor mayorista.
CREATE ASSERTION ck_caracteristica
CHECK (NOT EXISTS(
            SELECT 1
            FROM unc_esq_voluntario.nacional n
            JOIN unc_esq_voluntario.distribuidor d ON (d.id_distribuidor=n.id_distribuidor_mayorista)--d, lo asigno como distribuidor mayorista
            JOIN unc_esq_voluntario.distribuidor d2 ON (d.id_distribuidor=n.id_distribuidor)--d2, lo asigno como distribuidor nacional normal
            WHERE (d.tipo = 'N') AND "left"(d.telefono, 3)<>"left"(d2.telefono,3)
));

--3)A)
-- A. Controlar que las nacionalidades sean 'Argentina' 'Español' 'Inglés' 'Alemán' o 'Chilena'.
-- TIPO - check atributo = dominio
      ALTER TABLE unc_251672.p5p1e1_articulo
      ADD CONSTRAINT ck_articulo_nacionalidad
      CHECK (nacionalidad IN (  --NO ESTA CREADO EL ATRIBUTO NACIONALIDAD EN LA TABLA ARTICULO
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
    --TIPO - ATRIBUTO --La modalidad de la imagen médica puede tomar los siguientes valores RADIOLOGIA
    --CONVENCIONAL, FLUOROSCOPIA, ESTUDIOS RADIOGRAFICOS CON
    --FLUOROSCOPIA, MAMOGRAFIA, SONOGRAFIA,
    ALTER TABLE unc_251672.p5p2e4_imagen_medica
    ADD CONSTRAINT ck_valores_imagen_medica
    CHECK ( modalidad IN (
            'RADIOLOGIA', 'CONVENCIONAL', 'FLUOROSCOPIA', 'ESTUDIOS RADIOGRAFICOS CON
            FLUOROSCOPIA', 'MAMOGRAFIA', 'SONOGRAFIA'
        ));

--B) --Cada imagen no debe tener más de 5 procesamientos.
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
    --Agregue dos atributos de tipo fecha a las tablas Imagen_medica y Procesamiento, una
    --indica la fecha de la imagen y la otra la fecha de procesamiento de la imagen y controle
    --que la segunda no sea menor que la primera.
    ALTER TABLE unc_251672.p5p2e4_imagen_medica --Esta es la sintaxsis de agregacion de columnas
    ADD COLUMN fecha_imagen date;

    ALTER TABLE unc_251672.p5p2e4_procesamiento --Esta es la sintaxsis de agregacion de columnas
    ADD COLUMN fecha_procesamiento date;
-----
    CREATE ASSERTION
    CHECK (
        NOT EXISTS( SELECT 1
                    FROM imagen_medica i
                    JOIN procesamiento p ON ((i.id_paciente = p.id_paciente) AND (i.id_imagen = p.id_imagen))
                    WHERE i.fecha_imagen < p.fecha_procesamiento
    );

--D)
--Cada paciente sólo puede realizar dos FLUOROSCOPIA anuales.
    ALTER TABLE unc_251672.p5p2e4_imagen_medica
    ADD CONSTRAINT ck_limite_procesamientos
    CHECK (NOT EXISTS(
            SELECT 1
            FROM imagen_medica
            WHERE (modalidad LIKE 'FLUOROSCOPIA')
            GROUP BY id_paciente, EXTRACT(YEAR FROM fecha_img)--agrupe por paciente y por año de la img_medica
            HAVING COUNT (*) > 2
        ));

--E)
--No se pueden aplicar algoritmos de costo computacional “O(n)” a imágenes de FLUOROSCOPIA

    CREATE ASSERTION aplicar_algoritmos
    CHECK( NOT EXISTS(
            SELECT 1
            FROM p5p2e4_algoritmo a
            WHERE a.costo_computacional = 'O(n)'
            AND a.id_algoritmo IN ( --buscar los procesamientos con 'O(n)' de algoritmo
                                SELECT 1
                                FROM p5p2e4_procesamiento p JOIN p5p2e4_imagen_medica i
                                ON (p.id_paciente = i.id_paciente) AND (p.id_imagen=i.id_imagen)
                                WHERE i.modalidad = 'FLUOROSCOPIA'
            )
    ))
    ---
    CREATE ASSERTION
       CHECK ( NOT EXISTS (
                    SELECT 1
                    FROM p5p2e4_imagen_medica i JOIN p5p2e4_procesamiento p ON
                    (i.id_paciente = p.id_paciente AND i.id_imagen = p.id_imagen)
                    JOIN p5p2e4_algoritmo a ON ( p.id_algoritmo = a.id_algoritmo )
                    WHERE i.modalidad = 'FLUOROSCOPIA' AND a.costo_computacional = 'O(n)'
));

--5)-A)
        ALTER TABLE venta
        ADD CONSTRAINT CK_DECUENTO
        CHECK( descuento IN
            (BETWEEN 0 AND 100)));

--B)
--GENERAL
--Los descuentos realizados en fechas de liquidación deben superar el 30%.
    ALTER TABLE p5p2e5_venta
    ADD CONSTRAINT ck_descuentos
    CHECK ( NOT EXISTS(
        SELECT 1
        FROM venta v, fecha_liq fl
            WHERE v.fecha BETWEEN to_date(fl.dia_liq '/' || fl.mes_liq ||'/'||extract(year from v.fecha), 'dd/mm/yyyy')
            AND (to_date(fl.dia_liq '/' || fl.mes_liq ||'/'||extract(year from v.fecha), 'dd/mm/yyyy') + fl.cant_dias)
            AND v.descuento < 30
    ) );

--C)
    ALTER TABLE p5p2e5_fecha_liq
    ADD constraint ck_julio_diciembre
    CHECK ( NOT EXISTS(
                    SELECT 1
                    FROM fecha_liq f
                    WHERE (f.mes_liq LIKE 6 AND cant_dias > 5 ) OR --Se aplica el OR pq lo tengo que hacer mal
                    (f.mes_liq LIKE 12 AND cant_dias > 5)          --por el NOT EXISTS
    ) )


--D)
    CREATE ASSERTION OFERTA_SIN_DESCUENTO
    CHECK (NOT EXISTS (SELECT 1
                        FROM prenda p JOIN venta v ON (p.id_prenda = v.id_prenda)
                        WHERE p.categoria = 'oferta' AND v.descuento IS NOT NULL)
        );



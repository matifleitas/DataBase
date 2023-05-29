/*1.1. Listar todas las películas que poseen entregas de películas de idioma inglés durante
el año 2006. (P)*/
SELECT DISTINCT p.titulo, p.idioma, p.genero, e.fecha_entrega
FROM unc_esq_peliculas.pelicula p
JOIN unc_esq_peliculas.renglon_entrega r ON (p.codigo_pelicula = r.codigo_pelicula)
    JOIN unc_esq_peliculas.entrega e ON r.nro_entrega = e.nro_entrega
    WHERE EXTRACT(YEAR FROM e.fecha_entrega) = 2006 AND p.idioma = 'Inglés'
    ORDER BY p.titulo;


/*1.2. Indicar la cantidad de películas que han sido entregadas en 2006 por un distribuidor
nacional. Trate de resolverlo utilizando ensambles.(P)*/

SELECT *
FROM unc_esq_peliculas.renglon_entrega r JOIN unc_esq_peliculas.entrega e
ON (r.nro_entrega = e.nro_entrega)
JOIN unc_esq_peliculas.distribuidor d ON (e.id_distribuidor = d.id_distribuidor)

WHERE EXTRACT(YEAR FROM e.fecha_entrega) = 2006
AND d.tipo = 'N'
LIMIT 30

/* 1.3. Indicar los departamentos que no posean empleados cuya diferencia de sueldo
máximo y mínimo  no supere el 40% del sueldo máximo.
(P) (Probar con 10% para que retorne valores) */

SELECT d.id_distribuidor, d.id_departamento, d.nombre
FROM unc_esq_peliculas.departamento d
WHERE (d.id_distribuidor, d.id_departamento) NOT IN ( ---NOT IN para buscar deptos con empleados que NO cumplan la diferencia de sueldo
              SELECT e.id_distribuidor, e.id_departamento
              FROM unc_esq_peliculas.empleado e JOIN unc_esq_peliculas.tarea t ON (e.id_tarea = t.id_tarea)
              WHERE (t.sueldo_maximo - t.sueldo_minimo) <= (t.sueldo_maximo * 0.1));

/*1.4. Liste las películas que nunca han sido entregadas por un distribuidor nacional.(P)*/

SELECT p.codigo_pelicula, p.titulo, p.genero
FROM unc_esq_peliculas.pelicula p
    JOIN unc_esq_peliculas.renglon_entrega r ON (p.codigo_pelicula = r.codigo_pelicula)
        JOIN unc_esq_peliculas.entrega e ON (r.nro_entrega = e.nro_entrega)
        WHERE NOT EXISTS(
            SELECT
                1
            FROM unc_esq_peliculas.distribuidor d
            WHERE (e.id_distribuidor=d.id_distribuidor)
            AND (d.tipo = 'N')
        )
        ORDER BY p.codigo_pelicula ASC;
-----------------------------------------
--SIN JOINS--
SELECT codigo_pelicula, titulo
FROM unc_esq_peliculas.pelicula p
WHERE EXISTS (
    SELECT
        1
    FROM unc_esq_peliculas.renglon_entrega r
    WHERE (r.codigo_pelicula = p.codigo_pelicula)
        AND
        EXISTS(
            SELECT
                1
            FROM unc_esq_peliculas.entrega e
            WHERE (e.nro_entrega = r.nro_entrega)
                AND
                NOT EXISTS(
                    SELECT
                        1
                    FROM unc_esq_peliculas.distribuidor d
                    WHERE (d.id_distribuidor = e.id_distribuidor)
                    AND d.tipo = 'N'
                )
        )
    )
    ORDER BY p.codigo_pelicula ASC;

/*1.5. Determinar los jefes que poseen personal a cargo y cuyos departamentos (los del
jefe) se encuentren en la Argentina.*/

SELECT e1.id_empleado
FROM unc_esq_peliculas.empleado e1 --JEFE
WHERE e1.id_empleado IN (
        SELECT DISTINCT e.id_jefe
            FROM unc_esq_peliculas.empleado e
            WHERE e.id_jefe IS NOT NULL --corroborar que tengan personal a cargo
        )
        AND (e1.id_departamento, e1.id_distribuidor) IN --BUSCAR los deptos que esten en ARGENTINA
                                (SELECT d.id_departamento, d.id_distribuidor
                                FROM unc_esq_peliculas.departamento d
                                    JOIN unc_esq_peliculas.ciudad c ON (d.id_ciudad = c.id_ciudad)
                                    JOIN unc_esq_peliculas.pais p on (p.id_pais = c.id_pais)
                                    WHERE p.nombre_pais LIKE 'ARGENTINA'
                                );


/*1.6 Liste el apellido y nombre de los empleados que pertenecen a aquellos
departamentos de Argentina y donde el jefe de departamento posee una comisión de más
del 10% de la que posee su empleado a cargo.*/

select e.nombre, e.apellido, p.nombre_pais
from unc_esq_peliculas.empleado e
join unc_esq_peliculas.departamento d on ( e.id_departamento = d.id_departamento and e.id_distribuidor = d.id_distribuidor)
join unc_esq_peliculas.ciudad c on ( d.id_ciudad = c.id_ciudad)
join unc_esq_peliculas.pais p on ( c.id_pais = p.id_pais) --busco empleados que tengan deptos en ARGENTINA
where p.nombre_pais = 'ARGENTINA' and  --hago un exists donde el resultado sea de ARGENTINA
                  EXISTS (
                  select 1
                  from unc_esq_peliculas.empleado e1 --e1 para referirnos a un jefe
                   where (e1.porc_comision > ((e.porc_comision*1.1))) AND
                   d.jefe_departamento = e1.id_empleado --verificamos que el jefe de departamento de cada departamento
                );                                       --sea igual que el id de este empleado

-----------------------------
SELECT e.nombre, e.apellido, e.id_departamento,e.id_distribuidor
FROM unc_esq_peliculas.empleado e JOIN unc_esq_peliculas.departamento d ON (e.id_departamento = d.id_departamento AND e.id_distribuidor = d.id_distribuidor)
JOIN unc_esq_peliculas.empleado e2 ON (d.jefe_departamento = e2.id_empleado)
WHERE d.id_ciudad IN (SELECT c.id_ciudad
                        FROM unc_esq_peliculas.ciudad c
                        WHERE c.id_pais = 'AR')
AND e2.porc_comision >(e.porc_comision*1.1);


-------AGRUPAMIENTOS--------

/*1.7. Indicar la cantidad de películas entregadas a partir del 2010, por género.*/

SELECT count(*) AS pelis_post_2010 , p.genero
FROM unc_esq_peliculas.pelicula p
JOIN unc_esq_peliculas.renglon_entrega en ON (p.codigo_pelicula = en.codigo_pelicula)
    JOIN unc_esq_peliculas.entrega e ON (en.nro_entrega = e.nro_entrega)
    WHERE extract (YEAR FROM e.fecha_entrega) > 2009
    GROUP BY p.genero
    ORDER BY p.genero ASC;

/* 1.8. Realizar un resumen de entregas por día, indicando el video club al cual se le
realizó la entrega y la cantidad entregada. Ordenar el resultado por fecha.*/

SELECT distinct e.fecha_entrega, e.id_video, SUM(r.cantidad) AS cantidad_de_peliculas
    FROM unc_esq_peliculas.entrega e
        JOIN unc_esq_peliculas.renglon_entrega r ON (e.nro_entrega=r.nro_entrega)
        GROUP BY  e.fecha_entrega, e.id_video
        ORDER BY e.fecha_entrega, e.id_video;

/* 1.9 - Listar, para cada ciudad, el nombre de la ciudad y la cantidad de empleados
mayores de edad que desempeñan tareas en departamentos de la misma y que posean al
menos 30 empleados.*/

/*Manera correcta*/

SELECT c.nombre_ciudad, COUNT(*) AS cantidad_de_empleados
    FROM unc_esq_peliculas.ciudad as c
    JOIN unc_esq_peliculas.departamento d ON c.id_ciudad = d.id_ciudad
    JOIN unc_esq_peliculas.empleado e ON d.id_distribuidor = e.id_distribuidor and d.id_departamento = e.id_departamento
    WHERE (d.id_distribuidor, d.id_departamento) IN --IN devulve lo que sea igual a los id
                          (SELECT d2.id_distribuidor, d2.id_departamento --seleccionar devuelta para filtrar
                            FROM unc_esq_peliculas.departamento d2
                            JOIN unc_esq_peliculas.empleado e2 ON (d2.id_distribuidor = e2.id_distribuidor)AND(d2.id_departamento = e2.id_departamento)
                            WHERE EXTRACT(year FROM AGE(e2.fecha_nacimiento)) > 18 --filtrame los empleados mayores
                            GROUP BY (d2.id_distribuidor, d2.id_departamento)     --que esten en deptos con almenos 30 empleados
                            HAVING count(*) >= 30
                          )
    GROUP BY c.nombre_ciudad;

--------- EJERCICIO 2 ----------

/*2.1 Muestre, para cada institución, su nombre y la cantidad de voluntarios que realizan
aportes. Ordene el resultado por nombre de institución.*/

SELECT DISTINCT i.nombre_institucion, count(*) AS cant_voluntarios
FROM unc_esq_voluntario.institucion i
JOIN unc_esq_voluntario.voluntario v ON i.id_institucion = v.id_institucion
JOIN unc_esq_voluntario.tarea t ON v.id_tarea = t.id_tarea --La tarea puede o no estar ya que el atributo
GROUP BY i.nombre_institucion                              --id_tarea no puede ser NULL
ORDER BY i.nombre_institucion;

/*2.2. Determine la cantidad de coordinadores en cada país, agrupados por nombre de
país y nombre de continente. Etiquete la primer columna como 'Número de coordinadores' */

SELECT COUNT(v.id_coordinador) AS Número_de_coordinadores, p.nombre_pais, c.nombre_continente
FROM unc_esq_voluntario.continente c
JOIN unc_esq_voluntario.pais p ON (c.id_continente = p.id_continente)
    JOIN unc_esq_voluntario.direccion d ON (p.id_pais = d.id_pais)
        JOIN unc_esq_voluntario.institucion i ON (d.id_direccion = i.id_direccion)
            JOIN unc_esq_voluntario.voluntario v ON i.id_institucion = v.id_institucion
            GROUP BY p.nombre_pais, c.nombre_continente

/*2.3. Escriba una consulta para mostrar el apellido, nombre y fecha de nacimiento de
cualquier voluntario que trabaje en la misma institución que el Sr. de apellido Zlotkey.
Excluya del resultado a Zlotkey.*/

SELECT v.nro_voluntario, v.apellido, v.nombre, v.fecha_nacimiento
FROM unc_esq_voluntario.voluntario v
WHERE v.id_institucion IN (SELECT v2.id_institucion --Buscar los id de las instituciones el cual sean la misma que Zlotkey
                           FROM unc_esq_voluntario.voluntario v2
                           WHERE v2.apellido LIKE 'Zlotkey')
AND (v.apellido NOT LIKE 'Zlotkey'); --Ocultar al Sr.Zlotkey


/*2.4. Cree una consulta para mostrar los números de voluntarios y los apellidos de todos
los voluntarios cuya cantidad de horas aportadas sea mayor que la media de las horas
aportadas. Ordene los resultados por horas aportadas en orden ascendente.*/

SELECT v.nro_voluntario, v.apellido, v.horas_aportadas
FROM unc_esq_voluntario.voluntario v
WHERE v.horas_aportadas > (SELECT AVG(v2.horas_aportadas)
                           FROM unc_esq_voluntario.voluntario v2)
ORDER BY v.horas_aportadas ASC;

--EJERCICIO 3
/*3.1 Se solicita llenarla con la información correspondiente a los datos completos de todos los distribuidores nacionales.*/

--SINTAXIS PARA CREAR UNA TABLA CON VALORES DE OTRA
CREATE TABLE DistribuidorNac AS (SELECT d.id_distribuidor, d.nombre, d.direccion, d.telefono, dn.nro_inscripcion, dn.encargado, dn.id_distrib_mayorista
        FROM unc_esq_peliculas.distribuidor d
            JOIN unc_esq_peliculas.nacional dn ON d.id_distribuidor = dn.id_distribuidor);

ALTER TABLE DistribuidorNac
    ADD CONSTRAINT pk_distribuidorNac PRIMARY KEY (id_distribuidor);

/*3.2	Agregar a la definición de la tabla DistribuidorNac, el campo "codigo_pais" que indica el código
de país del distribuidor mayorista que atiende a cada distribuidor nacional.(codigo_pais character varying(5) NULL)*/

--SINTAXIS AGREGAR COLUMNA
ALTER TABLE DistribuidorNac
    ADD COLUMN codigo_pais character varying(5) NULL;

/*3.3.	Para todos los registros de la tabla DistribuidorNac,
llenar el nuevo campo "codigo_pais" con el valor correspondiente existente en la tabla "Internacional" (será nacional?).*/

--SINTAXIS EDITAR CAMPO
UPDATE DistribuidorNac AS d SET codigo_pais =
    (dn.codigo_pais FROM unc_esq_peliculas.nacional dn
    WHERE dn.id_distribuidor = DistribuidorNac.id_distribuidor);


/*3.4. 	Eliminar de la tabla DistribuidorNac los registros que no tienen asociado un distribuidor mayorista.*/

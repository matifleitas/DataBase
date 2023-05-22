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

SELECT e.nombre
FROM unc_esq_peliculas.empleado e
JOIN unc_esq_peliculas.departamento d ON (e.id_distribuidor = d.id_distribuidor and e.id_departamento = d.id_departamento)
    WHERE d.jefe_departamento IN (
                        SELECT c.id_ciudad
                        FROM unc_esq_peliculas.ciudad c
                        WHERE c.id_pais IN (
                            SELECT p.id_pais
                            FROM unc_esq_peliculas.pais p
                            WHERE p.nombre_pais = 'ARGENTINA'
                        )
        );

SELECT e.nombre --seleccioname el nombre del empleado que coincida con jefe_departamento
FROM unc_esq_peliculas.empleado e
WHERE e.id_empleado IN ( --buscame eempleado.id_empleado que esten en ... y su id coincida con el de jefe_departamento
    SELECT d.jefe_departamento
       FROM unc_esq_peliculas.departamento d
        WHERE d.id_ciudad IN ( --buscame departamento.id_ciudad que esten en ...
            SELECT c.id_ciudad
                FROM unc_esq_peliculas.ciudad c
                WHERE c.id_pais IN ( --buscame ciudad.id_pais que esten en ...
                    SELECT p.id_pais
                    FROM unc_esq_peliculas.pais p
                    WHERE p.nombre_pais = 'ARGENTINA'
            )
    )
); -- falta el and .. departamento tenga empleados!!!

/*1.6 Liste el apellido y nombre de los empleados que pertenecen a aquellos
departamentos de Argentina y donde el jefe de departamento posee una comisión de más
del 10% de la que posee su empleado a cargo.*/

select e.nombre, e.apellido, p.nombre_pais
from unc_esq_peliculas.empleado e
join unc_esq_peliculas.departamento d on ( e.id_departamento = d.id_departamento and e.id_distribuidor = d.id_distribuidor)
join unc_esq_peliculas.ciudad c on ( d.id_ciudad = c.id_ciudad)
join unc_esq_peliculas.pais p on ( c.id_pais = p.id_pais) --busco empleados que tengan deptos en ARGENTINA
where p.nombre_pais like 'ARGENTINA' and  --hago un exists donde el resultado sea de ARGENTINA
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
        WHERE EXTRACT(YEAR FROM AGE(e.fecha_nacimiento)) > 18 --buscar empleados mayores de edad, sin filtros previos
        AND (d.id_distribuidor, d.id_departamento) IN --IN devulve lo que sea igual a los id
                              (SELECT dep.id_distribuidor, dep.id_departamento --seleccionar devuelta para poder devolver
                                FROM unc_esq_peliculas.departamento dep        --deptos que cumplan con el filtro
                                JOIN unc_esq_peliculas.empleado emp ON (dep.id_distribuidor = emp.id_distribuidor)AND(dep.id_departamento = emp.id_departamento)
                                WHERE EXTRACT(year FROM AGE(emp.fecha_nacimiento)) > 18 --filtrame los empleados mayores
                                GROUP BY (dep.id_distribuidor, dep.id_departamento)     --que esten en deptos con almenos 30
                                HAVING count(*) >= 30)                                  --empleados
        GROUP BY c.nombre_ciudad;

--------- EJERCICIO 2 ----------

/*2.1 Muestre, para cada institución, su nombre y la cantidad de voluntarios que realizan
aportes. Ordene el resultado por nombre de institución.*/

SELECT DISTINCT i.nombre_institucion, count(*) AS cant_voluntarios
FROM unc_esq_voluntario.institucion i
    JOIN unc_esq_voluntario.voluntario v ON (i.id_institucion = v.id_institucion)
    GROUP BY i.nombre_institucion
    ORDER BY i.nombre_institucion;
-------------------------------------
SELECT DISTINCT i.nombre_institucion, count(v.nro_voluntario) AS cant_voluntarios_aportes
FROM unc_esq_voluntario.institucion i
    JOIN unc_esq_voluntario.voluntario v ON i.id_institucion = v.id_institucion
        JOIN unc_esq_voluntario.tarea t ON v.id_tarea = t.id_tarea
        GROUP BY i.nombre_institucion;

/*2.2. Determine la cantidad de coordinadores en cada país, agrupados por nombre de
país y nombre de continente. Etiquete la primer columna como 'Número de coordinadores' */

SELECT COUNT(v.id_coordinador) AS Número_de_coordinadores, p.nombre_pais, c.nombre_continente
FROM unc_esq_voluntario.continente c
    JOIN unc_esq_voluntario.pais p ON (c.id_continente = p.id_continente)
        JOIN unc_esq_voluntario.direccion d ON (p.id_pais = d.id_pais)
            JOIN unc_esq_voluntario.institucion i ON (d.id_direccion = i.id_direccion)
                JOIN unc_esq_voluntario.voluntario v ON i.id_institucion = v.id_institucion
                GROUP BY p.nombre_pais, c.nombre_continente
                ORDER BY p.nombre_pais;

/*2.3. Escriba una consulta para mostrar el apellido, nombre y fecha de nacimiento de
cualquier voluntario que trabaje en la misma institución que el Sr. de apellido Zlotkey.
Excluya del resultado a Zlotkey.*/

SELECT v.apellido, v.nombre, v.fecha_nacimiento, i.nombre_institucion
FROM unc_esq_voluntario.voluntario v
    JOIN unc_esq_voluntario.institucion i ON (i.id_institucion=v.id_institucion)
    WHERE (i.nombre_institucion = (SELECT *
                                   FROM unc_esq_voluntario.voluntario v
                                   WHERE (v.apellido = 'Zlotkey')
          ));

--NOC COMO HACERLO PARA QUE DEVUELVA EL NAME DE LA INSTITUCION


/*2.4. Cree una consulta para mostrar los números de voluntarios y los apellidos de todos
los voluntarios cuya cantidad de horas aportadas sea mayor que la media de las horas
aportadas. Ordene los resultados por horas aportadas en orden ascendente.*/

SELECT v.nro_voluntario, v.apellido, AVG(v.horas_aportadas), V.horas_aportadas
FROM unc_esq_voluntario.voluntario v
GROUP BY v.nro_voluntario, v.apellido
HAVING v.horas_aportadas > AVG(v.horas_aportadas)
--noandaaa

--age(fecha_nacimiento) - devuelve edad de la persona

--EJERCICIO 3
--3.2)
ALTER TABLE distribuidornac
ADD codigo_pais character varying(5) NULL

--3.4)
DELETE distribuidornac
WHERE
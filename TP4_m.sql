/*1.1. Listar todas las películas que poseen entregas de películas de idioma inglés durante
el año 2006. (P)*/
SELECT p.titulo, p.idioma, p.genero, e.fecha_entrega
FROM unc_esq_peliculas.pelicula p, unc_esq_peliculas.entrega e
WHERE  EXTRACT(YEAR FROM e.fecha_entrega) = '2006' AND idioma = 'Inglés'
LIMIT 20;

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

SELECT e.id_departamento
FROM unc_esq_peliculas.empleado e INNER JOIN
unc_esq_peliculas.departamento d ON (d.id_departamento = e.id_departamento)
INNER JOIN unc_esq_peliculas.tarea t ON (t.id_tarea = e.id_tarea)
WHERE (sueldo_maximo - t.sueldo_minimo > t.sueldo_maximo * 0.4)
GROUP BY e.id_departamento;

/*1.4. Liste las películas que nunca han sido entregadas por un distribuidor nacional.(P)*/

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
    );

/*1.5. Determinar los jefes que poseen personal a cargo y cuyos departamentos (los del
jefe) se encuentren en la Argentina.*/
SELECT id_jefe
FROM unc_esq_peliculas.empleado e
WHERE EXISTS(
    SELECT 1
    FROM unc_esq_peliculas.
)

/*1.6 Liste el apellido y nombre de los empleados que pertenecen a aquellos
departamentos de Argentina y donde el jefe de departamento posee una comisión de más
del 10% de la que posee su empleado a cargo.*/

SELECT
    id_empleado, apellido, nombre
FROM
    unc_esq_peliculas.empleado e
WHERE
    EXISTS(
        SELECT
            1
        FROM
            unc_esq_peliculas.departamento d
        WHERE
            e.id_departamento = d.id_departamento
            AND
            EXISTS(
                SELECT
                    1
                FROM
                    unc_esq_peliculas.ciudad c
                WHERE
                    c.id_ciudad = d.id_ciudad
                    AND
                    c.id_pais = 'AR'
            )
    );


-------AGRUPAMIENTOS--------

/*1.7. Indicar la cantidad de películas entregadas a partir del 2010, por género.*/

SELECT p.titulo, p.genero, r.nro_entrega, e.fecha_entrega
    FROM unc_esq_peliculas.pelicula p
    INNER JOIN unc_esq_peliculas.renglon_entrega r
    ON (p.codigo_pelicula = r.codigo_pelicula)
        INNER JOIN unc_esq_peliculas.entrega e
        ON (r.nro_entrega = e.nro_entrega)
        WHERE EXTRACT(YEAR FROM e.fecha_entrega) > 2009
        ORDER BY p.genero ASC;

/* 1.8. Realizar un resumen de entregas por día, indicando el video club al cual se le
realizó la entrega y la cantidad entregada. Ordenar el resultado por fecha.*/

SELECT c.id_ciudad, c.nombre_ciudad
FROM unc_esq_peliculas.ciudad c
    WHERE EXISTS(
        SELECT
            1
        FROM unc_esq_peliculas.departamento d
        WHERE (d.id_ciudad = c.id_ciudad)
            AND
            EXISTS(
                SELECT
                    1
                FROM unc_esq_peliculas.empleado e
                WHERE (d.id_departamento = e.id_departamento)
                AND EXTRACT(YEAR FROM e.fecha_nacimiento) > '1988'
            )
    )

/* 1.9 - Listar, para cada ciudad, el nombre de la ciudad y la cantidad de empleados
mayores de edad que desempeñan tareas en departamentos de la misma y que posean al
menos 30 empleados.*/


--------- EJERCICIO 2 ----------

/*2.1 Muestre, para cada institución, su nombre y la cantidad de voluntarios que realizan
aportes. Ordene el resultado por nombre de institución.*/

SELECT i.id_institucion, nombre_institucion, v.nro_voluntario, v.apellido, t.nombre_tarea, t.id_tarea
FROM unc_esq_voluntario.institucion i
    INNER JOIN  unc_esq_voluntario.voluntario v
    ON(i.id_institucion = v.id_institucion)
        INNER JOIN unc_esq_voluntario.tarea t
        ON(t.id_tarea = v.id_tarea)
            ORDER BY nombre_institucion ASC

/*2.2. Determine la cantidad de coordinadores en cada país, agrupados por nombre de
país y nombre de continente. Etiquete la primer columna como 'Número de coordinadores' */

SELECT v.id_coordinador, v.nombre, nombre_pais, nombre_continente
FROM unc_esq_voluntario.continente c
    INNER JOIN unc_esq_voluntario.pais p
    ON (c.id_continente = p.id_continente)
        INNER JOIN unc_esq_voluntario.direccion d
        ON(p.id_pais = d.id_pais)
            INNER JOIN unc_esq_voluntario.institucion i
            ON(d.id_direccion = i.id_direccion)
                INNER JOIN unc_esq_voluntario.voluntario v
                ON (i.id_institucion = v.id_institucion)


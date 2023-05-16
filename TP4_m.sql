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

SELECT e.id_departamento, d.nombre
FROM unc_esq_peliculas.empleado e
    JOIN unc_esq_peliculas.departamento d ON (d.id_departamento = e.id_departamento)
        INNER JOIN unc_esq_peliculas.tarea t ON (t.id_tarea = e.id_tarea)
        WHERE (t.sueldo_maximo - t.sueldo_minimo) < t.sueldo_maximo * 0.4
        GROUP BY e.id_departamento, d.nombre;

/*1.4. Liste las películas que nunca han sido entregadas por un distribuidor nacional.(P)*/

SELECT p.codigo_pelicula, p.titulo, p.genero
FROM unc_esq_peliculas.pelicula p
    JOIN unc_esq_peliculas.renglon_entrega r ON (p.codigo_pelicula = r.codigo_pelicula)
        JOIN unc_esq_peliculas.entrega e ON (r.nro_entrega = e.nro_entrega)
        WHERE NOT EXISTS(
            SELECT
                1
            FROM
                unc_esq_peliculas.distribuidor d
            WHERE (e.id_distribuidor=d.id_distribuidor)
            AND (d.tipo = 'N')
        )
        ORDER BY p.codigo_pelicula ASC;
---------
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

----ARREGLAR

SELECT jefe_departamento
);


/*1.6 Liste el apellido y nombre de los empleados que pertenecen a aquellos
departamentos de Argentina y donde el jefe de departamento posee una comisión de más
del 10% de la que posee su empleado a cargo.*/

---manera correcta

SELECT e.nombre, e.apellido, e.id_departamento, d.jefe_departamento
FROM unc_esq_peliculas.empleado e
    JOIN unc_esq_peliculas.departamento d
    ON (e.id_departamento = d.id_departamento AND d.id_distribuidor = e.id_distribuidor) --Ensamble entre departamento y empleados. Ensamble entre distribuidor y empleado
        JOIN unc_esq_peliculas.empleado e2 ON (d.jefe_departamento = e2.id_empleado)--empleado2 es una manera de llamar al JEFE ya que es un empleado
        WHERE (d.id_ciudad) IN (SELECT c.id_ciudad
                                FROM
                                    unc_esq_peliculas.ciudad c
                                WHERE c.id_pais = 'AR')
        AND (e2.porc_comision) > (e.porc_comision*1.1);



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
-----
SELECT r.cantidad AS CANTIDAD_ENTREGADA, r.nro_entrega
FROM
    unc_esq_peliculas.renglon_entrega r
WHERE
     EXISTS(
        SELECT
            1
        FROM
            unc_esq_peliculas.pelicula p
         WHERE (r.codigo_pelicula=p.codigo_pelicula)
         AND
            EXISTS(
                SELECT 1
                FROM
                    unc_esq_peliculas.entrega e
                WHERE (e.nro_entrega = r.nro_entrega) AND (EXTRACT(YEAR FROM e.fecha_entrega) > 2009)
                ORDER BY p.genero ASC
            )
    );


/* 1.8. Realizar un resumen de entregas por día, indicando el video club al cual se le
realizó la entrega y la cantidad entregada. Ordenar el resultado por fecha.*/

SELECT e.fecha_entrega, e.id_video, SUM(r.cantidad) AS cantidad_de_peliculas
    FROM unc_esq_peliculas.entrega e
        JOIN unc_esq_peliculas.renglon_entrega r ON (e.nro_entrega=r.nro_entrega)
        GROUP BY  e.fecha_entrega, e.id_video
        ORDER BY e.fecha_entrega, e.id_video;

/* 1.9 - Listar, para cada ciudad, el nombre de la ciudad y la cantidad de empleados
mayores de edad que desempeñan tareas en departamentos de la misma y que posean al
menos 30 empleados.*/

/*Manera correcta*/

SELECT c.nombre_ciudad, count(*)
    FROM unc_esq_peliculas.ciudad as c
    INNER JOIN unc_esq_peliculas.departamento d on c.id_ciudad = d.id_ciudad
        INNER JOIN unc_esq_peliculas.empleado e on d.id_distribuidor = e.id_distribuidor and d.id_departamento = e.id_departamento
        WHERE EXTRACT(year FROM AGE(e.fecha_nacimiento)) > 18
        AND
        (d.id_distribuidor, d.id_departamento)
            IN
              (SELECT dep.id_distribuidor, dep.id_departamento
                FROM unc_esq_peliculas.departamento as dep
                INNER JOIN unc_esq_peliculas.empleado as emp ON (dep.id_distribuidor = emp.id_distribuidor)and(dep.id_departamento = emp.id_departamento)
                WHERE EXTRACT(year FROM AGE(emp.fecha_nacimiento)) > 18
                GROUP BY (dep.id_distribuidor, dep.id_departamento)
                HAVING count(*) >= 30)
        GROUP BY c.nombre_ciudad;

--------- EJERCICIO 2 ----------

/*2.1 Muestre, para cada institución, su nombre y la cantidad de voluntarios que realizan
aportes. Ordene el resultado por nombre de institución.*/

SELECT i.id_institucion, i.nombre_institucion, COUNT(v.nro_voluntario) AS cantidad_de_voluntarios
FROM unc_esq_voluntario.institucion i
    JOIN unc_esq_voluntario.voluntario v ON (i.id_institucion = v.id_institucion)
        GROUP BY i.id_institucion, i.nombre_institucion
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
                ORDER BY p.nombre_pais;

/*2.3. Escriba una consulta para mostrar el apellido, nombre y fecha de nacimiento de
cualquier voluntario que trabaje en la misma institución que el Sr. de apellido Zlotkey.
Excluya del resultado a Zlotkey.*/

SELECT v.apellido, v.nombre, v.fecha_nacimiento, i.nombre_institucion
FROM unc_esq_voluntario.voluntario v
    JOIN unc_esq_voluntario.institucion i ON (i.id_institucion=v.id_institucion)
    WHERE (i.nombre_institucion = (SELECT
               *
           FROM unc_esq_voluntario.voluntario v
           WHERE (v.apellido = 'Zlotkey')
          ));

--NOC COMO HACERLO PARA QUE DEVUELVA EL NAME DE LA INSTITUCION

SELECT v.apellido, v.nombre, v.fecha_nacimiento, i.nombre_institucion
FROM unc_esq_voluntario.voluntario v
    INNER JOIN unc_esq_voluntario.institucion i ON (v.id_institucion = i.id_institucion)
    WHERE i.nombre_institucion = 'FUNDACION REGAZO' AND v.apellido NOT IN ('Zlotkey');

/*2.4. Cree una consulta para mostrar los números de voluntarios y los apellidos de todos
los voluntarios cuya cantidad de horas aportadas sea mayor que la media de las horas
aportadas. Ordene los resultados por horas aportadas en orden ascendente.*/

SELECT v.nro_voluntario, v.apellido, AVG(v.horas_aportadas), V.horas_aportadas
FROM unc_esq_voluntario.voluntario v
GROUP BY v.nro_voluntario, v.apellido
HAVING v.horas_aportadas > AVG(v.horas_aportadas)
--noandaaa

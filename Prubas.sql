/*Pruebas*/
SELECT codigo_pelicula, titulo, idioma, genero
FROM unc_esq_peliculas.pelicula
GROUP BY codigo_pelicula --agrupamiento GROUP BY
HAVING codigo_pelicula <= 31500 --filtra solamente grupos
ORDER BY codigo_pelicula DESC
------------------------------------
SELECT id_departamento, id_distribuidor, nombre, calle,
       (SELECT nombre FROM unc_esq_peliculas.distribuidor
        WHERE depto.id_distribuidor = id_distribuidor)
        AS name_distribuidor
FROM unc_esq_peliculas.departamento AS depto
LIMIT 50
------------------------------------
/*lo que hace el IN es devolver los valores que estan entre () y el NOT IN, lo contrario*/
SELECT * FROM unc_esq_peliculas.empleado
WHERE id_empleado IN (11576, 362, 133, 347) --(GERARDO, NORBERTO, ELDA, BADEN)
ORDER BY id_empleado DESC

SELECT * FROM unc_esq_peliculas.empleado
WHERE id_empleado IN (SELECT id_empleado FROM unc_esq_peliculas.empleado WHERE id_empleado < 500)
LIMIT 5


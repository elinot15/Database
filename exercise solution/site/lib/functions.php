<?php

function open_pg_connection() {
	$host = "localhost";
	$user = "***";
	$psw = "***";
	$db = "imdb";

    $connection = "host=" . $host . " dbname=" . $db . " user=" . $user . " password=" . $psw;

    return pg_connect($connection);
  }

  function close_pg_connection($db) {
    return pg_close($db);
  }
/*
returns an array of persons with associated movie information.
$db: the db connection to use
$role: the role to consider 
*/
function get_persons($db, $role=null){

  $params = Array();
  $sql = "SELECT given_name, official_title, p_role, character FROM movie INNER JOIN crew ON movie.id = crew.movie INNER JOIN person ON crew.person = person.id";

  if (!is_null($role)) {
    $sql .= " WHERE p_role = $1";
    $params[] = $role;
  }

  $sql .= " ORDER BY given_name";

  $result = pg_prepare($db, "persons", $sql);
  $result = pg_execute($db, "persons", $params);

  $persons = Array();
  while($row = pg_fetch_assoc($result)){
    $persons[] = $row;
  }

  return $persons;

}

/* 
returns an array of available roles.
$db: the db connection to use
*/
function get_roles($db) {
  $sql = "SELECT DISTINCT p_role FROM crew ORDER BY p_role";

  $result = pg_prepare($db, "roles", $sql);
  $result = pg_execute($db, "roles", array());

  $roles = Array();
  while($row = pg_fetch_assoc($result)){
    $roles[] = $row['p_role'];
  }

  return $roles;
}

?>
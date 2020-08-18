<?php
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('lib/functions.php'); 

	$db = open_pg_connection();
	if (!$db)
		die("Impossibile stabilire una connessione con il db.");
     	
    $result = pg_query($db, 'SET SEARCH_PATH TO imdb');

    $selected_role = null;
    if (isset($_POST) && isset($_POST['role'])) {
    	$selected_role = $_POST['role'];
    }

?>
<!DOCTYPE html>
<html>
	<head>
		<?php include ('lib/header.php'); ?>
		<title>
			BDLab exam
		</title>
	</head>
	<body>
		<div class="uk-container uk-margin-bottom uk-margin-top">
			<div class="uk-text-lead" style="color: #01205A">BDLab - App Exam</div>
			
			<div class="uk-section uk-section-default">
				<form method="POST" action="<?php echo($_SERVER['PHP_SELF']); ?>">
				<fieldset class="uk-fieldset"> 
					<legend class="uk-legend">Filtra le persone in base al ruolo</legend> 
						<div class="uk-margin">
							<select class="uk-select" name="role">
							<?php 
							if (is_null($selected_role)) {
								// non è stato selezionato alcun ruolo, quindi stampa l'opzione di default
								print ('<option selected="selected">Seleziona una voce</option>');

							}
							$roles = get_roles($db);

							foreach($roles as $value){
								$selected_option = "";
								if ($value == $selected_role) {
									$selected_option = 'selected="selected"';
								}

							?>
							<option value="<?php echo($value); ?>" <?php echo($selected_option); ?>><?php echo($value); ?></option>
							<?php
							}
							?>
							</select>
						</div>
					<button class="uk-button uk-button-default">Invia</button>
					<a class="uk-button uk-button-default" href="<?php echo($_SERVER['PHP_SELF']); ?>">Clear</a>
				</fieldset>	
				</form>
			</div>
	
			<hr>
			
			<h3 class="uk-card-title">Risultati disponibili</h3>
			<?php
			// Si invochi la funzione get_persons definita nel file lib/functions.php
			$persons = get_persons($db, $selected_role);

			if (!is_null($persons)) {
			?>
			<table class="uk-table uk-table-divider">
				<thead>
					<tr>
						<th>Attore</th>
						<th>Film</th>
						<th>Ruolo</th>
						<th>Personaggio</th>
					</tr>
				</thead>
				<tbody>
					<?php
					foreach($persons as $person){
					?>
					<tr>
						<td><?php echo $person['given_name']; ?></td>
						<td><?php echo $person['official_title']; ?></td>
						<td><?php echo $person['p_role']; ?></td>
						<td><?php echo $person['character']; ?></td>
					</tr>
					<?php
					}
					?>
				</tbody>
			</table>
			<?php
			} else {
				if (is_null($selected_role)) {
					print("Non ci sono persone da visualizzare.");
				} else {
					print("Non ci sono persone con ruolo di " . $selected_role . ".");
				}
			}
        	?>		  		
		</div>
	</body>
</html>
<?php
	close_pg_connection($db);
?>



----------------------------------------------------------------------
functions.php

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

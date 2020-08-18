<?php
	$db = open_pg_connection();
	
	$result = pg_query($db, 'SET SEARCH_PATH TO imdb');
	
	/**
	 * ESEMPIO DI INJECTION
	 * 2010'; DELETE FROM movie WHERE official_title = 'Quay
	 */

	$year_value = "";
	$where = "";
	if(isset($_POST['year'])){
		$year_value = 'value="' . $_POST['year'] . '"';
	    $where = " WHERE year = $1";
	}
	
	$sql = "SELECT movie.id, official_title, year, country FROM movie LEFT JOIN produced ON movie.id=produced.movie";
	$sql .= $where;

/*
 * NB: uso di pg_query senza parametri
 * USO DI PG_QUERY DA EVITARE. SI VEDANO I PREPARED STATEMENTS 
 */
 
 	// esegui la query
 	$result = pg_prepare($db, "the_query", $sql);
	if(!empty($where)){
	    $result = pg_execute($db, "the_query", array($_POST['year']));
	}else{
	    $result = pg_execute($db, "the_query", array());
	}
 
 	
	$movies = array();
	
	while($row = pg_fetch_assoc($result)){
	    $id = $row['id'];
	    // raggruppo le righe che si riferiscono allo stesso movie
	    if(in_array($id, array_keys($movies))){
	        $movies[$id]['country'][] = $row['country'];
	    }else{
	        $row['country'] = array($row['country']);
	        $movies[$id] = $row;
	    }
	}

/*
 * mostra array risultato
 */
//pre($movies);

?>

<h3 class="uk-card-title">Film disponibili in archivio</h3>
<form class="uk-form" action="<?php echo ($_SERVER['PHP_SELF']); ?>?mod=fix" method="post">
	<div class="uk-margin">     
		<label class="uk-form-label" for="movie-year">Filtra per anno di produzione</label>
		<div class="uk-form-controls">
			<input class="uk-input" id="movie-year" type="text" placeholder="inserisci l'anno" name="year" <?php echo $year_value; ?>>
		</div>
	</div>
	<button class="uk-button uk-button-primary">Cerca</button>
</form>
<table class="uk-table uk-table-divider">
<thead>
	<tr>
		<th>Titolo del film</th>
		<th>Anno di produzione</th>
		<th>Paese di produzione</th>
	</tr>
</thead>
<tbody>
<?php
/*
 * NB: differenze fra array pg_fetch_assoc e pg_fetch_num
 * scorri il risultato ricevuto
 */
	foreach($movies as $id=>$values){
		$title = $values['official_title'];
		$year = $values['year'];
		$countries = $values['country'];
?>
    	<tr>
            <td><?php echo $title; ?></td>
            <td><?php echo $year; ?></td>
            <td><?php echo implode(", ", $countries); ?></td>
        </tr>
<?php
	}
?>
</tbody>
</table>
<?php
	close_pg_connection($db);
?>
		
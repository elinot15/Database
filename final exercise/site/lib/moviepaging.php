<?php

	//numero predefinito di righe per pagina 
	$per_page = 10;	
	$offset = 0;
	$current_page = 0;
	if (isset($_GET['page'])) {
    	$current_page = max(0, $_GET['page']);
    	$offset = $current_page * $per_page;
    }

	$db = open_pg_connection();
	
	$result = pg_query($db, 'SET SEARCH_PATH TO imdb');
	
	$sql = "SELECT movie.id, official_title, year, country FROM movie LEFT JOIN produced ON movie.id=produced.movie ORDER BY year DESC";
	$sql .= " OFFSET $1 LIMIT $2";

 	$result = pg_prepare($db, "the_query", $sql);
	$result = pg_execute($db, "the_query", array($offset, $per_page));
 
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
//pre($data);

?>

<h3 class="uk-card-title">Film disponibili in archivio</h3>
<?php
	if (!empty($movies)) {
		$record_num = pg_query($db, "SELECT COUNT(*) FROM movie");
		$r_num = pg_fetch_row($record_num)[0];
		
		//paginator size
		$pages = ceil($r_num / $per_page);
		
		if ($pages > 1) {
			print('<ul class="uk-pagination uk-flex-center" uk-margin>');
			print("\n");
			print('<li><a href="' . $_SERVER['PHP_SELF'] . '?mod=paging&page=' . ($current_page - 1) . '"><span uk-pagination-previous></span></a></li>');
			print("\n");
			for ($i=1; $i<=$pages; $i++) {
				if ($current_page + 1 == $i) {
					$class = 'class="uk-active"';
					print('<li class="uk-active"><span>' . $i . '</span></li>');
					print("\n");
				} else {
					print('<li><a href="' . $_SERVER['PHP_SELF'] . '?mod=paging&page=' . ($i - 1) . '">' . $i . '</a></li>');
					print("\n");
				}
			}
			print('<li><a href="' . $_SERVER['PHP_SELF'] . '?mod=paging&page=' . ($current_page + 1) . '"><span uk-pagination-next></span></a></li>');
			print("\n");
			print('</ul>');
			print("\n");
		}
?>
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
	}	
	close_pg_connection($db);
?>
		
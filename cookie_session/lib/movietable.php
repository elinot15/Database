<h3 class="uk-card-title">Film disponibili in archivio</h3>
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
    	$all_movies = get_all_movies();
    	foreach ($all_movies as $country => $movies) {
    		foreach ($movies as $year => $title) {
    ?>
    	<tr>
            <td><?php echo $title; ?></td>
            <td><?php echo $year; ?></td>
            <td><?php echo $country; ?></td>
        </tr>
    <?php
    		}
    	}
    ?>
</tbody>
</table>
		
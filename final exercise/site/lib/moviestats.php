<?php
	$db = open_pg_connection();
	if(!$db) {exit("Errore di connessione al db.");}
	$result = pg_query($db, 'SET SEARCH_PATH TO imdb');
	$pagesize=10;
	
	//print_r($_COOKIE);
	
	
	if(isset($_GET['page'])){
		$currpage=$_GET['page'];
		$offset= ($currpage-1) * $pagesize;
	}	
	else{
		$offset=0;
		$currpage=1;
	}
	
	$mod = 'top10';
	$sql = "SELECT * FROM top10movie()";
	if(isset($_GET['smod'])){
	
		switch($_GET['smod']){
			case  'top10':
				$sql = "SELECT * FROM top10movie()";
				$mod = 'top10';
			break;
			
			case  'rat': 
				$sql = "SELECT * FROM topRatings(15)";
				$mod = 'rat';
			break;
			case  'cast':				
				$mod = 'cast';				
				$sql = "SELECT official_title, 
				(SELECT count(*) FROM get_movie_cast(m.official_title)) AS cast_component 
							FROM movie m 
							ORDER BY cast_component DESC
							OFFSET $1 LIMIT $2";											
// usiamo un cookie per tenere traccia del numero di pagine				
				if(isset($_COOKIE['pages'])){
					$pages = $_COOKIE['pages'];
				}else{
					$res = pg_query($db, "SELECT COUNT(*) FROM movie");
					$nmovies = pg_fetch_row($res)[0];
					print($nmovies);
					pg_free_result($res);	
					$pages = ceil($nmovies/$pagesize);				
				}
				setcookie('pages', $pages, time()+1000);													
			break;
			default:	 $sql = "SELECT * FROM top10movie()";
						$mod = 'top10';
		}
	
		
	}



?>

<!-- 
<nav class="uk-navbar-container" uk-navbar> 
-->
     <h2 class="uk-card-title">Statistiche disponibili</h2>

     <ul class="uk-tab uk-flex-center">
           <?php $class = ""; if($mod =='top10') $class = 'uk-active'?>
           <li class=<?php echo $class;?> 
           			uk-tooltip="title:Visualizza i 10 film con più alto score medio.; delay:300">
           			<a href="<?php echo $_SERVER['PHP_SELF'];?>?mod=stats&smod=top10">Top 10 film</a></li>
           <?php $class = ""; if($mod =='rat') $class = 'uk-active'?>
           <li class=<?php echo $class;?> 
           			uk-tooltip="title:Visualizza i 15 rating con score maggiore.; delay:300">
           			<a href="<?php echo $_SERVER['PHP_SELF'];?>?mod=stats&smod=rat"> Top 15 valutazioni</a></li>
           <?php $class = ""; if($mod =='cast') $class = 'uk-active'?>
           <li class=<?php echo $class;?> 
           			uk-tooltip="title: Visualizza i film ordinati per cast più numeroso.; delay :300">
           			<a href="<?php echo $_SERVER['PHP_SELF'];?>?mod=stats&smod=cast&page=1">Cast più numeroso</a></li>			
     </ul>
    
   <?php
   	switch($mod){
			case 'top10':
   			$res = pg_prepare($db, "top10", $sql);
				$res = pg_execute($db, "top10", array());
		
   ?>	
   			<h3 class="uk-card-small">Film valutati meglio</h3>
					<table class="uk-table uk-table-divider uk-text-bold uk-table-hover uk-table-striped">
						<thead>
							<tr>
								<th> Titolo </th>
								<th>Anno</th>
								<th>Numero rating</th>
								<th>Score</th>
							</tr>
						</thead>
					<tbody>
			<?php
				if($res){
					while($row = pg_fetch_assoc($res))
					{		
			?>
				 		<tr>
						   <td><?php echo $row['official_title']; ?></td>
						   <td><?php echo $row['year']; ?></td>
						   <td><?php echo $row['rating_number']; ?></td>
						   <td><?php echo number_format($row['score'],5); ?></td>
					  </tr>
		<?php
				  }
				  pg_free_result($res);			
				}  				
		?>
				</tbody>
				</table>
<?php
			break;
			case 'rat':
				$res = pg_prepare($db, "rat", $sql);
				$res = pg_execute($db, "rat", array());
		
   ?>	
   			<h3 class="uk-card-small">Valutazioni più elevate </h3>
					<table class="uk-table uk-table-divider uk-text-bold uk-table-hover uk-table-striped">
						<thead>
							<tr>							
								<th> Data </th>
								<th>Sorgente</th>
								<th>Film</th>
								<th>Scala</th>
								<th>Voti</th>
								<th>Score</th>
							</tr>
						</thead>
					<tbody>
			<?php
				if($res){
					while($row = pg_fetch_assoc($res))
					{		
			?>
				 		<tr>
						   <td><?php echo $row['data']; ?></td>
						   <td><?php echo $row['sorgente']; ?></td>
						   <td><?php echo $row['titolo']; ?></td>
						   <td><?php echo $row['scala']; ?></td>
						   <td><?php echo $row['voti']; ?></td>
						   <td><?php echo number_format($row['score_n'],5); ?></td>
					  </tr>
		<?php
				  }	
  				  pg_free_result($res);		
				}  				
		?>
				</tbody>
				</table>
		<?php
			break;
			case 'cast':
				$res = pg_prepare($db, "cast", $sql);
				$res = pg_execute($db, "cast", array($offset, $pagesize));
				
				echo '<h3 class="uk-card-small">Film con più attori</h3>';
				//print($pages . ' ' . $offset. ' '. $currpage . ' ' . $pagesize);
				if ($pages > 1) {
					print('<ul class="uk-pagination uk-flex-center" uk-margin>');
					print('<li><a href="' . $_SERVER['PHP_SELF'] . 
							'?mod=stats&smod=cast&page='. max($currpage-1,1) .'"><span uk-tooltip="title: previous page" style="color:blue" uk-pagination-previous></span></a></li>');	
							
					if($currpage > 1)
						print('<li class="uk-padding-right"><a href="' . $_SERVER['PHP_SELF'] . 
							'?mod=stats&smod=cast&page=1"> 1 </a></li>');	
					if($currpage > 2)
						print('<li class=""><span>...</span></li>');
					
					print('<li class="uk-active"><span  style="color:blue">' . $currpage . '</span></li>');
					if($currpage < $pages-1)
						print('<li class=""><span>...</span></li>');

					if($currpage < $pages)
						print('<li><a href="' . $_SERVER['PHP_SELF'] . 
							'?mod=stats&smod=cast&page='. $pages .'">' .$pages. '</a></li>');	
					print('<li><a href="' . $_SERVER['PHP_SELF'] . 
							'?mod=stats&smod=cast&page='. min($currpage+1,$pages) .'"><span uk-tooltip="title: next page" style="color:blue" uk-pagination-next></span></a></li>');
					print('</ul>');				
				}			
		
   ?>	   			
					<table class="uk-table uk-table-divider uk-text-bold uk-table-hover uk-table-striped">
						<thead>
							<tr>							
								<th> Titolo </th>
								<th>Numero attori</th>								
							</tr>
						</thead>
					<tbody>
			<?php				
				if($res){
					
					$nmovies = pg_num_rows($res);										
					while($row = pg_fetch_assoc($res))
					{		
			?>
				 		<tr>
						   <td><?php echo $row['official_title']; ?></td>
						   <td><?php echo $row['cast_component']; ?></td>
					  </tr>
		<?php
				  }
  				  pg_free_result($res);			
				}  				
		?>
				</tbody>
				</table>
		<?php
			break;
   	}

  	 close_pg_connection($db);
?> 

<!-- 
	</nav>     
-->


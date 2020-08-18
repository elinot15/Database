<?php 
	ini_set ("display_errors", "On");
	ini_set("error_reporting", E_ALL);
	include_once ('lib/functions.php'); 
	
	/**
	 * NOTE: il cookie deve essere inizializzato prima dell'emissione dell'output 
	 * affinchè possa essere inviato al client con l'header del pacchetto HTTP.
	 * Controllare il valore della direttiva output_buffering che può influire su questo aspetto. 
	 */
	if(isset($_GET['mod']) && $_GET['mod'] == 'set0'){
		setcookie("visit", '');
	}

	if(isset($_GET['mod']) && $_GET['mod'] == 'sum1'){
		if(isset($_COOKIE['visit'])){
			$count = $_COOKIE['visit'] + 1;
		}else{
			$count = 1;
		}
		setcookie("visit", $count, time()+60);
	}
?>
<!DOCTYPE html>
<html>
    <head>
        <?php include_once ('lib/header.php'); ?>
        <title>
        IMDB app
        </title>
    </head>
    <body>
    <div class="uk-container uk-margin-remove-bottom uk-margin-remove-top">
    <h1 class="uk-article-title">Contatore di visite</h1>
    <?php include_once ('lib/navigation.php'); ?>

    <div class="uk-section uk-section-default">
    	<div class="uk-container">
        
        <?php 
        if (isset($count))
        	echo $count;
        else
        	echo 'Nessun contatore da visualizzare';
         ?>
        
    	</div>
    </div>

    <hr>

    <div class="uk-card uk-card-secondary uk-card-body">
        <a href="<?php echo($_SERVER['PHP_SELF']); ?>?mod=sum1">Incrementa il contatore</a> -
		<a href="<?php echo($_SERVER['PHP_SELF']); ?>?mod=set0">Azzera il contatore</a>
    </div>
    
	<pre>
		<?php print_r($_COOKIE); ?>
	</pre>
    
    </div>
    </body>
</html>
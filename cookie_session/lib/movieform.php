<form class="uk-form-horizontal" action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
	<legend class="uk-legend">Inserisci un nuovo film</legend>

	<div class="uk-margin">     
		<label class="uk-form-label" for="movie-id">Codice</label>
		<div class="uk-form-controls">
			<input class="uk-input" id="movie-id" type="text" placeholder="inserisci il codice" name="movie[id]">
		</div>
	</div>
	<div class="uk-margin">     
		<label class="uk-form-label" for="movie-title">Titolo</label>
		<div class="uk-form-controls">
			<input class="uk-input" id="movie-title" type="text" placeholder="inserisci il titolo" name="movie[title]">
		</div>
	</div>
	<div class="uk-margin">
		<label class="uk-form-label" for="movie-budget">Budget</label>
		<div class="uk-form-controls">
			<input class="uk-input" id="movie-budget" type="number" min="0" value="0" step=".01" placeholder="inserisci il budget" name="movie[budget]">
		</div>
	</div>
	<div class="uk-margin">
		<label class="uk-form-label" for="movie-year">Anno</label>
		<div class="uk-form-controls">
			<input class="uk-input" id="movie-year" type="text" placeholder="inserisci l'anno di produzione" name="movie[year]">
		</div>
	</div>
	<div class="uk-margin">
		<label class="uk-form-label" for="movie-length">Durata</label>
		<div class="uk-form-controls">
			<input class="uk-input" id="movie-length" step="1" type="number" placeholder=" durata in minuti" name="movie[length]">
		</div>
	</div>
	<div class="uk-margin">
		<label class="uk-form-label" for="movie-plot">Trama</label>
		<div class="uk-form-controls">
			<textarea class="uk-textarea" rows="5" placeholder="Inserisci la trama" name="movie[plot]"></textarea>
		</div>
	</div>
	
	<button class="uk-button uk-button-default">Inserisci</button>
</form>
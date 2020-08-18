<nav class="uk-navbar-container" uk-navbar>
    <div class="uk-navbar-left">

        <ul class="uk-navbar-nav">
            <li><a href="index.php">Pagina principale</a></li>
            <li>
                <a href="#">Parametri GET/POST</a>
                <div class="uk-navbar-dropdown">
                    <ul class="uk-nav uk-navbar-dropdown-nav">
                        <li><a href="pass_parameter.php">Passaggio di parametri</a></li>
                    	<li><a href="dynamic_menu.php">Menù dinamico</a></li>
                    </ul>
                </div>
            </li>
            <li>
                <a href="#">Cookie e sessioni</a>
                <div class="uk-navbar-dropdown">
                    <ul class="uk-nav uk-navbar-dropdown-nav">
                        <li><a href="cookie_sess_counter.php">Contatore</a></li>
                    	<li><a href="cookie_login.php">Login (cookie)</a></li>
                    	<li><a href="session_login.php">Login (session)</a></li>
                    </ul>
                </div>
            </li>
            <li>
                <a href="#">Basi di dati</a>
                <div class="uk-navbar-dropdown">
                    <ul class="uk-nav uk-navbar-dropdown-nav">
                        <li><a href="movie.php">Film</a></li>
                    	<li><a href="movie_err.php">Film (SQL injection)</a></li>
                    	<li><a href="movie_fix.php">Film (corretto)</a></li>
                    	<li><a href="movie_paging.php">Film (con paginazione)</a></li>
                    </ul>
                </div>
            </li>
        </ul>

    </div>
</nav>
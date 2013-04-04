API_KEY = 'zut7wayu5xabjx33e8tc22fx'

$(document).on 'pageinit', '#index', () ->
    # set event handlers

    $(this).on 'click', '#search', (e) ->
        # click search button
        e.preventDefault()
        term = $('#term').val()
        hash = "#list-#{term}-1"
        hash = encodeURI(hash)
        window.location.hash = hash

    $(document).on "click", "ul:jqmData(role='listview') a", (e) ->
        # click movie in a list
        e.preventDefault()
        movieId = $(this).data('movieid')
        window.location.hash = "#detail-#{movieId}"

    $(document).on "click", "a.-nav-btn", (e) ->
        # click on prev and next buttons in search list
        window.location.hash = $(this).attr('href')



$(document).on 'mobileinit', () ->
    # global settings
    $.mobile.defaultPageTransition = 'slide'
    $.mobile.loader.prototype.options.textVisible = true
    $.mobile.button.prototype.options.mini = true


getMovies = (query, page=1) ->
    # fetch list of movies
    address = "http://api.rottentomatoes.com/api/public/v1.0/movies.json?callback=?"
    params =
        apikey: API_KEY
        q: query
        page: page
        page_limit: 20

    $.getJSON address, params


getMovie = (id) ->
    # fetch data for a single movie
    address = "http://api.rottentomatoes.com/api/public/v1.0/movies/" + id + ".json?callback=?"
    params = 
        apikey: API_KEY

    $.getJSON address, params


renderMoviesList = (data) ->
    $.Mustache.load('./templates.html').done () ->
        html = $.Mustache.render('moviesTmpl', data)
        page = $(html).appendTo('body').page()
        
        $.mobile.changePage page


renderMovie = (data) ->
    $.Mustache.load('./templates.html').done () ->
        html = $.Mustache.render('movieTmpl', data)
        page = $(html).appendTo('body').page()
        $.mobile.changePage page


$(window).on "navigate", (event, data) ->
    # react to address hash change - so it works when user clicks to get data
    # as well when he edit the browser address bar
    # two operations: list and detail

    hash = decodeURI data.state.hash
    if not hash then return

    [operation, term, page] = hash.split('-')


    if operation is '#list'
        $.mobile.loading 'show'
        $.when(getMovies term, page).done (result) ->
            $.mobile.loading 'hide'

            if result.total
                result.search_term = term
                result.page = page
                result.hash = hash
                result.next_page = "#list-#{term}-#{+page+1}"
                result.prev_page = "#list-#{term}-#{+page-1}"

                renderMoviesList result
            else
                alert "Nothing found for #{term}"
                window.location.hash = ''


    if operation is '#detail'
        $.mobile.loading 'show'
        $.when(getMovie term).done (data) ->
            $.mobile.loading 'hide'
            data.id = term
            renderMovie data

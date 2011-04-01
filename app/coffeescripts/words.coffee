if not Math.randomFromTo?
       Math.randomFromTo = (from, to) ->
           Math.floor(Math.random() * (to - from + 1) + from)

# Has fields
# - word
# - gender
# - article
# - score
# - error

class Word extends Backbone.Model
    setAnswer: (article)->
        if (article == @get('article'))
            increment = if @get('error') then -2 else 1
            @set score: @get('score') + increment
            @save()
            true
        else
            @set error: true
            false

    score: -> @get 'score'


class Words extends Backbone.Collection
    url: "nouns"

    model: Word

    at_random: ->
        # select random from bottom 4 words
        r = 4
        if @size() < 4
            r = @size()
        @at Math.randomFromTo(0, r-1)

    comparator: (word)->
        word.get('score')


class GameEngine extends Backbone.Model

    constructor: (attr)->
        super attr
        @words = attr.words
        @words.bind 'refresh', => @_refresh()

    start: ->
        @words.fetch()

    _refresh: ->
        @words.sort silent:true

        @set current_word: @words.at_random()
        # This is needed because we might
        # select the same word again which
        # will not trigger an event
        @trigger('change:word')

    current_word: ->
        @get('current_word')

    setAnswer: (article)->
        if @current_word().setAnswer article
            @set correct_answer: true
            @_refresh()
        else
            @set correct_answer: false

    word: ->
        @current_word().get('word')

    score: ->
        @current_word().get('score')

    correct_answer: ->
        @get 'correct_answer'


class PlayView extends Backbone.View

    constructor: (attr) ->
        super attr
        @game_engine = new GameEngine(words: attr.words)
        @_bindModel()
        @game_engine.start()
  
    _bindModel: ->
        @game_engine.bind 'change:word', => @changeWord()
        @game_engine.bind 'change:correct_answer', => @renderMessage()

    changeWord: ->
        run = =>
            $("#word-play-link").text(@game_engine.word())
            $("#word-play-score").html("(" + @game_engine.score() + ")")
        window.setTimeout run, 350

        # Rerender the list view
        @options.listview.render()

    renderMessage: ->
        true


    events:
        "click .der a" : "handleDer"
        "click .die a" : "handleDie"
        "click .das a" : "handleDas"

    handleDer: (e)->
        @game_engine.setAnswer('der')
        @flashMessage()

    handleDie: (e)->
        @game_engine.setAnswer('die')
        @flashMessage()

    handleDas: (e)->
        @game_engine.setAnswer('das')
        @flashMessage()

    flashMessage: ->
        if @game_engine.correct_answer()
            $("#color-flash").animate( { backgroundColor: 'lightgreen' }, 10).animate( { backgroundColor: 'white' }, 1000)
        else
            $("#color-flash").animate( { backgroundColor: 'red' }, 10).delay(400).animate( { backgroundColor: 'white' }, 200)

        # Ensure the list view is up to date


class WordAddView extends Backbone.View
             
    events: {"submit form" : "addItem"}

    addItem : (data)->
        item =
            word: $(@el).find("input").val()
        callbacks =
            success: @onSuccess
            error: @onError

        @model.create item, callbacks

    onSuccess: (model,resp)->
        $(@el).find("input").val("")

    onError: (model, resp)->
        $("#messages").html(resp.responseText)

class WordView extends Backbone.View

    tagName: "li"

    render: ->
      $(this.el).html "#{@model.get('article')} #{@model.get('word')} (#{@model.get('score')})"
      $(this.el).addClass(@model.get('article'))
      return this

class WordListView extends Backbone.View

    list: null

    constructor: ->
        super
        @list = $(@el).find("ul")
        @bindModel()
        @model.fetch
            success: =>
                @render()

    bindModel: ->
        @model.bind 'add', (noun)=> @prependWord(noun)

    refresh: ->
        @list.listview("refresh")

    prependWord: (word)->
        wv = new WordView({model: word}).render().el
        @list.prepend( wv )
        @refresh()

    appendWord: (word)->
        wv = new WordView({model: word}).render().el
        @list.append( wv )
        @refresh()

    render: ->
        @list.html("")
        @model.each (word) => @appendWord(word)
        @refresh()


# Every time the leo page is shown we want to refresh
# the IFrame that points to leo dictionary
$('#dict').live 'pageshow', (event) ->
    word = $("#word-play-link").text()
    url = "http://pda.leo.org/?lp=ende&lang=de&searchLoc=0&cmpType=relaxed&relink=off&sectHdr=on&spellToler=&search=#{word}"
    $("iframe").attr('src', url)

app =
    start: ->
        $('#page_sets_manage').live 'pagecreate', (event) =>

            words = new Words()


            listview = new WordListView
                 model: words
                 el: $("#word-list-view")

            new PlayView
                words: words
                el: $("#word-play-view")
                listview: listview

            new WordAddView
                 model: words
                 el: $("#word-add-view")
  
app.start()

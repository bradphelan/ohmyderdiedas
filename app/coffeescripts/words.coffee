if not Math.randomFromTo?
       Math.randomFromTo = (from, to) ->
           Math.floor(Math.random() * (to - from + 1) + from)

# Has fields
# - word
# - gender
# - article
# - score
# - error

class RandomWord extends Backbone.Model
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


class RandomWordCollection extends Backbone.Collection
    url: "nouns"

    model: RandomWord

    at_random: ->
        @at Math.randomFromTo(0, @size()-1)

class GameEngine extends Backbone.Model

    constructor: ->
        super
        @words = new RandomWordCollection()
        @words.bind 'refresh', => @_refresh()

    start: ->
        @words.fetch()

    _refresh: ->
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

    constructor: ->
        super
        @game_engine = new GameEngine()
        @_bindModel()
        @game_engine.start()
  
    _bindModel: ->
        @game_engine.bind 'change:word', => @changeWord()
        @game_engine.bind 'change:correct_answer', => @renderMessage()

    changeWord: ->
        $("#word-play-link").text(@game_engine.word())
        $("#word-play-score").html("(" + @game_engine.score() + ")")

    renderMessage: ->
        if @game_engine.correct_answer()
            $("#word-play-message").html('Richtig')
            $("#word-play-message").removeClass("incorrect")
            $("#word-play-message").addClass("correct")
        else
            $("#word-play-message").html('Falsch')
            $("#word-play-message").removeClass("correct")
            $("#word-play-message").addClass("incorrect")


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
        $("#word-play-message").hide()
        $("#word-play-message").fadeIn(1000)


class Word extends Backbone.Model

class WordView extends Backbone.View
    tagName: "li"

    render: ->
      $(this.el).html(@model.get('article') + " " + @model.get('word'))
      $(this.el).addClass(@model.get('article'))
      return this

class Words extends Backbone.Collection
    model: Word
    url: 'nouns'

class WordAddView extends Backbone.View
             
    events: {"submit form" : "addItem"}

    addItem : (data)->
        @model.create [
           { word: $(@el).find("input").val()
           }
           { success: @onSuccess
             error: @onError
           }
        ]

    onSuccess: (model,resp)->
        $(@el).find("input").val("")

    onError: (model, resp)->
        $("#messages").html(resp.responseText)

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
        @model.bind('add', @prependWord)

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
            words = new Words
                url: 'nouns'

            new PlayView
                el: $("#word-play-view")
                leoView: @leoView

            new WordListView
                 model: words
                 el: $("#word-list-view")

            new WordAddView
                 model: words
                 el: $("#word-add-view")
  
app.start()

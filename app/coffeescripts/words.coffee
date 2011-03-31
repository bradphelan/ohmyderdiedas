# Has fields
# - word
# - gender
# - article
# - score
# - error

class RandomWord extends Backbone.Model
    setAnswer: (article)->
        if (article == @get('article'))
            @save()
            true
        else
            @set error: true
            false


class RandomWordCollection extends Backbone.Collection
    url: ->
        params =
            number: 10

        "random_word?#{$.param params}"

    model: RandomWord

    constructor: (callback)->
        super

class GameEngine extends Backbone.Model

    constructor: ->
        super
        @_load()

    _load: ->
        if not @words? || @words.size() == 0
            @words = new RandomWordCollection
            @words.bind 'refresh', =>
                word = @words.at(0)
                @words.remove(word)
                @current_word = word
                @trigger "change:current_word"


    setAnswer: (article)->
        if @current_word.setAnswer article
            @set correct_answer: true
            @_load()
        else
            @set correct_answer: false

    word: ->
        @current_word.get('word')

    score: ->
        @current_word.get('score')


class PlayView extends Backbone.View

    constructor: ->
        super
        @game_engine = new GameEngine()
        @_bindModel()
  
    _bindModel: ->
        @game_engine.bind 'change:current_word', =>
            @changeWord()
        @game_engine.bind 'change:correct_answer', => 
            @renderMessage()

    changeWord: ->
        $("#word-play-link").slideUp 100, =>
            $("#word-play-link").text(@game_engine.word())
            $("#word-play-score").html("(" + @game_engine.score() + ")")
            $("#word-play-link").slideDown()

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
        $("#word-play-message").fadeOut 100, =>
            $("#word-play-message").fadeIn(100)


class Word extends Backbone.Model

class WordView extends Backbone.View
    tagName: "li"

    render: ->
      $(this.el).html(@model.get('article') + " " + @model.get('word'))
      $(this.el).addClass(@model.get('article'))
      return this

class Words extends Backbone.Collection
    model: Word
    url: 'word'

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
        if @model?
            @model.bind('add', @prependWord)
        else
            alert('model not provided at WordListView#bindModel')

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
                url: $("#word-list-view").data('url')

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

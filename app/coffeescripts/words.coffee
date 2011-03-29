class PlayWord extends Backbone.Model
    constructor: ->
        super
        @set
            message:null
        @resetCorrect()
    
    resetCorrect: ->
        @set correct_answer: true

    url: 'random_word'

    setAnswer: (article) ->
      txt = article + " " + @get('word')
      if (article == @get('article'))
        @set
          message:
              state:true
              message: "Richtig!"
        @save({},{ success: @resetCorrect})
      else
        @set
          message:
              state:false
              message: "Falsch"
          correct_answer: false

        
class PlayView extends Backbone.View

    word: new PlayWord()

    constructor: ->
        super
        @bindModel()
        @word.fetch()
  
    bindModel: ->
        @word.bind 'change:message' , => @renderMessage()
        @word.bind 'change:word'    , => @changeWord()
        @word.bind 'change:score'   , => @changeWord()

    changeWord: ->
        $("#word-play-link").slideUp 100, =>
            $("#word-play-link").text(@word.get('word'))
            $("#word-play-score").html("(" + @word.get('score') + ")")
            $("#word-play-link").slideDown()

    renderMessage: ->
        $("#word-play-message").html(@word.get('message').message)
        if @word.get('message').state
            $("#word-play-message").removeClass("incorrect")
            $("#word-play-message").addClass("correct")
        else
            $("#word-play-message").removeClass("correct")
            $("#word-play-message").addClass("incorrect")


    events:
        "click .der a" : "handleDer"
        "click .die a" : "handleDie"
        "click .das a" : "handleDas"

    handleDer: (e)->
        @word.setAnswer('der')
        @flashMessage()

    handleDie: (e)->
        @word.setAnswer('die')
        @flashMessage()

    handleDas: (e)->
        @word.setAnswer('das')
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

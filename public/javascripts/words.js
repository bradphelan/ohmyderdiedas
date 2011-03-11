$('#mainPage').live('pagecreate',function(event){

  
  var Word = Backbone.Model.extend({
    url: '/words/new.json'
  });

  var WordView = Backbone.View.extend({

    word  : new Word()

    , events: {  "click .der" : "handleDer" ,
               "click .die" : "handleDie" ,
               "click .das" : "handleDas" ,
            }

    ,initialize: function() {
      self = this;
      this.word.bind('change:word', function(model, word) {
        self.setWord(model.get('word'), model.get('article'));
      });
    
    }
            

    ,check: function(guessed_article){

      word = $("#word").data('word');

      article = $("#word").data('article');

      if (guessed_article == article){
        this.setMessage(guessed_article + " " + word + " is correct");
        this.newWord();
      }else{
        this.setMessage(guessed_article + " " + word + " is incorrect");
      }

    }

    ,setMessage: function(message){
        $("#messages").html(message);
    }

    ,setWord: function(word, article){
        $("#word").data('word', word).data('article', article);
        $("#word h1").html(word);
    }


    ,newWord: function(){
      this.word.fetch();
    }


    , handleDer: function(data) {
      this.check('der');
    }
    , handleDie: function(data) {
      this.check('die');
    }
    , handleDas: function(data) {
      this.check('das');
    }

  , render: function() {
    this.delegateEvents();
    return this;
  },

  });

  var view = new WordView({el: $("#derdiedas")});

})    



$('#mainPage').live('pagecreate',function(event){

  var WordView = Backbone.View.extend({

    check: function(guessed_article){
      word = $("#word").data('word');
      article = $("#word").data('article');

      if (guessed_article == article){
        $("#messages").html(guessed_article + " " + word + " is correct");
        this.newWord();
      }else{
        $("#messages").html(guessed_article + " " + word + " is incorrect");
      }

    }

    ,newWord: function(){
      $.getJSON('/words/new.json',
        function(data){
          $("#word").data('word', data.word).data('article', data.article)
          $("#word h1").html(data.word);
        }
        )
    }


    ,events: {  "click .der" : "handleDer" ,
                "click .die" : "handleDie" ,
                "click .das" : "handleDas" ,
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
  view.render();

})    



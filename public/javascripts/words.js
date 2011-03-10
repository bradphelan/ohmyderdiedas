$('#mainPage').live('pagecreate',function(event){

  var word = new Backbone.Model({
    word: "",
  });


  var WordView = Backbone.View.extend({

    check: function(guessed_article){
      word = $("#word").data('word');
      article = $("#word").data('article');

      if (guessed_article == article){
        $("#messages").html(guessed_article + " " + word + " is correct");
      }else{
        $("#messages").html(guessed_article + " " + word + " is incorrect");
      }

    }

    ,events: {   "click .der" : "handleDer" ,
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



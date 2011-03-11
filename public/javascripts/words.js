$('#mainPage').live('pagecreate',function(event){

  // Source of words. Generates JSON data of
  // the form
  //
  // { word: "Mann", article: "der" }
  var Word = Backbone.Model.extend({
    initialize: function() {
      this.fetch();
      this.set({message: ''});
    }

    ,url: '/words/new.json'

    ,setAnswer: function (article){
      txt = article + " " + this.get('word');
      if (article == this.get('article')){
        this.set({message: txt + " is correct"});
        this.fetch();
      }else{
        this.set({message: txt + " is incorrect"});
      }
    }

  });

  var WordView = Backbone.View.extend({

    word: new Word()

    , initialize: function() {
      _.bindAll(this, "message", "render");
      this.word.bind('change:message', this.message);
      this.word.bind('all', this.render);
    }

    , render: function(){
        $("#word h1").html(this.word.get('word'));
    }

    , message: function(){
        $("#messages").html(this.word.get('message'));
    }


    // --------------
    // Event Handling
    // --------------

    , events: {  "click .der" : "handleDer" ,
                 "click .die" : "handleDie" ,
                 "click .das" : "handleDas" ,
              }

    , handleDer: function(data) {
      this.word.setAnswer('der');
    }
    , handleDie: function(data) {
      this.word.setAnswer('die');
    }
    , handleDas: function(data) {
      this.word.setAnswer('das');
    }

  });

  // Attach the view to an element
  var view = new WordView({el: $("#derdiedas")});

})    



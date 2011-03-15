$('.page_set_run').live('pagecreate',function(event){

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
      this.bindModel();
    }
  
    // ---------------------
    // Model Event Handling
    // ---------------------

    , bindModel: function(){
      _.bindAll(this, "renderMessage", "renderWord");
      this.word.bind('change:message', this.renderMessage);
      this.word.bind('change:word', this.renderWord);

    }

    , renderWord: function(){
        $("#word").html(this.word.get('word'));
    }

    , renderMessage: function(){
        $("#messages").html(this.word.get('message'));
    }


    // ------------------
    // UI Event Handling
    // ------------------

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


$('.page_sets_manage').live('pagecreate',function(event){
 $("#set-new-word")
    //.bind("ajax:loading",  toggleLoading)
    //.bind("ajax:complete", toggleLoading)
    .bind("ajax:success", function(e, data, status, xhr) {
      $("#set_list").prepend("<li>" + data.word + "</li>");
      $("#new_word_training_set").val("");
      $("#set_list").listview("refresh");
      $("#messages").html("");
    })
    .bind("ajax:error", function(e, data, status, xhr){
      $("#messages").html(data.responseText);
    });
    
});

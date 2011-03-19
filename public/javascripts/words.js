$('.page_sets_manage').live('pagecreate',function(event){

  // Source of words. Generates JSON data of
  // the form
  //
  // { word: "Mann", article: "der" }
  var PlayWord = Backbone.Model.extend({

    initialize: function() {
      this.fetch();
      this.set({message: ''});
    }

    ,url: function(){
      url = $("#word-play-view").data('url');
      return url;
    }

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

  var PlayView = Backbone.View.extend({

    word: new PlayWord()

    , initialize: function() {
      this.bindModel();
    }
  
    // ---------------------
    // Model Event Handling
    // ---------------------

    , bindModel: function(){
      _.bindAll(this, "renderMessage", "appendWord");
      this.word.bind('change:message', this.renderMessage);
      this.word.bind('change:word', this.appendWord);

    }

    , appendWord: function(){
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

  var Word = Backbone.Model.extend({
  });

  var WordView = Backbone.View.extend({
    tagName: "li"
    ,render: function() {
      $(this.el).html(this.model.get('article') + " " + this.model.get('word'));
      return this;
    },
  }
  );

  var Words = Backbone.Collection.extend({
    model: Word
    ,url: 'word'
  }
  );

  var WordAddView = Backbone.View.extend({
    initialize: function(){
    }

    , events: {"submit form" : "addItem"}
    , addItem : function(data){
      console.log(data);
      val = this.el.find("input").val();
      this.model.create(
        {word: val}

        ,{
          success: function(model, resp){
          }

          ,error: function(model, resp){
            $("#messages").html(resp.responseText);
            console.log('bad');
          }
          
         }
     );
    }
  }
  );

  var WordListView = Backbone.View.extend({
    list: null

    ,words: new Words()

    ,initialize: function(){
      this.list = this.el.find("ul")
      this.bindModel();
      this.model.fetch();
      this.render();

    }

    , bindModel: function(){
      _.bindAll(this, "render", "appendWord", "prependWord", "handleAddNewWord");
      this.model.bind('add', this.prependWord);

    }

    ,prependWord: function(word){
      wv = new WordView({model: word}).render().el;
      self.list.prepend( wv );
      self.list.listview("refresh");
    }

    ,appendWord: function(word){
      wv = new WordView({model: word}).render().el;
      self.list.append( wv );
      self.list.listview("refresh");
    }

    ,render: function(){
      self = this;
      self.list.html("");
      this.model.each(function(word){self.appendWord(word)});
      self.list.listview("refresh");
    }


  }
  );

  // Attach the view to an element
  words = new Words({
    url: $("#word-list-view").data('url')
  }
  );
  new WordListView({model: words, el: $("#word-list-view")});
  new WordAddView({model: words, el: $("#word-add-view")});
  new PlayView({el: $("#word-play-view")});

});

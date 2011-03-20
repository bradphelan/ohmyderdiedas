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
      return $("#word-play-view").data('url');
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
      this.word.fetch();
    }
  
    // ---------------------
    // Model Event Handling
    // ---------------------

    , bindModel: function(){
      _.bindAll(this, "renderMessage", "changeWord");
      this.word.bind('change:message', this.renderMessage);
      this.word.bind('change:word', this.changeWord);

    }

    , changeWord: function(){
        $("#word").html(this.word.get('word'));
    }

    , renderMessage: function(){
        $("#messages").html(this.word.get('message'));
    }


    // ------------------
    // UI Event Handling
    // ------------------

    , events: {  "click .der a" : "handleDer" ,
                 "click .die a" : "handleDie" ,
                 "click .das a" : "handleDas" ,
              }

    , handleDer: function(e) {
      this.word.setAnswer('der');
    }
    , handleDie: function(e) {
      this.word.setAnswer('die');
    }
    , handleDas: function(e) {
      this.word.setAnswer('das');
    }

  });

  var Word = Backbone.Model.extend({
  });

  var WordView = Backbone.View.extend({
    tagName: "li"
    ,render: function() {
      $(this.el).html(this.model.get('article') + " " + this.model.get('word'));
      $(this.el).addClass(this.model.get('article'));
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
    initialize:function(){
      _.bindAll(this, "onSuccess", "onError");
    }
                 
    , events: {"submit form" : "addItem"}

    , addItem : function(data){
        this.model.create
         ( { word: this.el.find("input").val() }
         , { success: this.onSuccess
           , error: this.onError
           }
         );
    }

    , onSuccess: function(model,resp){ this.el.find("input").val(""); }
    , onError: function(model, resp){ $("#messages").html(resp.responseText); }

  }
  );

  var WordListView = Backbone.View.extend({
    list: null

    ,words: new Words()

    ,initialize: function(){
      self=this;
      this.list = this.el.find("ul")
      this.bindModel();
      this.model.fetch({ success: function(){self.render();}});
    }

    , bindModel: function(){
      _.bindAll(this, "render", "appendWord", "prependWord");

      this.model.bind('add', this.prependWord);

    }

    ,refresh: function(){this.list.listview("refresh");}

    ,prependWord: function(word){
      wv = new WordView({model: word}).render().el;
      self.list.prepend( wv );
      self.refresh();
    }

    ,appendWord: function(word){
      wv = new WordView({model: word}).render().el;
      self.list.append( wv );
      self.refresh();
    }

    ,render: function(){
      self = this;
      self.list.html("");
      this.model.each(function(word){self.appendWord(word)});
      self.refresh();
    }


  }
  );

  // Attach the view to an element
  words = new Words({
    url: $("#word-list-view").data('url')
  }
  );
  new PlayView({model: words, el: $("#word-play-view")});
  new WordListView({model: words, el: $("#word-list-view")});
  new WordAddView({model: words, el: $("#word-add-view")});

});

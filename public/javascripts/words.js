/* DO NOT MODIFY. This file was compiled Tue, 29 Mar 2011 19:10:32 GMT from
 * /Users/bradphelan/workspace/derdiedas/app/coffeescripts/words.coffee
 */

(function() {
  var PlayView, PlayWord, Word, WordAddView, WordListView, WordView, Words, app;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  PlayWord = (function() {
    __extends(PlayWord, Backbone.Model);
    function PlayWord() {
      PlayWord.__super__.constructor.apply(this, arguments);
      this.set({
        message: null
      });
      this.resetCorrect();
    }
    PlayWord.prototype.resetCorrect = function() {
      return this.set({
        correct_answer: true
      });
    };
    PlayWord.prototype.url = 'random_word';
    PlayWord.prototype.setAnswer = function(article) {
      var txt;
      txt = article + " " + this.get('word');
      if (article === this.get('article')) {
        this.set({
          message: {
            state: true,
            message: "Richtig!"
          }
        });
        return this.save({}, {
          success: this.resetCorrect
        });
      } else {
        return this.set({
          message: {
            state: false,
            message: "Falsch"
          },
          correct_answer: false
        });
      }
    };
    return PlayWord;
  })();
  PlayView = (function() {
    __extends(PlayView, Backbone.View);
    PlayView.prototype.word = new PlayWord();
    function PlayView() {
      PlayView.__super__.constructor.apply(this, arguments);
      this.bindModel();
      this.word.fetch();
    }
    PlayView.prototype.bindModel = function() {
      this.word.bind('change:message', __bind(function() {
        return this.renderMessage();
      }, this));
      this.word.bind('change:word', __bind(function() {
        return this.changeWord();
      }, this));
      return this.word.bind('change:score', __bind(function() {
        return this.changeWord();
      }, this));
    };
    PlayView.prototype.changeWord = function() {
      return $("#word-play-link").slideUp(100, __bind(function() {
        $("#word-play-link").text(this.word.get('word'));
        $("#word-play-score").html("(" + this.word.get('score') + ")");
        return $("#word-play-link").slideDown();
      }, this));
    };
    PlayView.prototype.renderMessage = function() {
      $("#word-play-message").html(this.word.get('message').message);
      if (this.word.get('message').state) {
        $("#word-play-message").removeClass("incorrect");
        return $("#word-play-message").addClass("correct");
      } else {
        $("#word-play-message").removeClass("correct");
        return $("#word-play-message").addClass("incorrect");
      }
    };
    PlayView.prototype.events = {
      "click .der a": "handleDer",
      "click .die a": "handleDie",
      "click .das a": "handleDas"
    };
    PlayView.prototype.handleDer = function(e) {
      this.word.setAnswer('der');
      return this.flashMessage();
    };
    PlayView.prototype.handleDie = function(e) {
      this.word.setAnswer('die');
      return this.flashMessage();
    };
    PlayView.prototype.handleDas = function(e) {
      this.word.setAnswer('das');
      return this.flashMessage();
    };
    PlayView.prototype.flashMessage = function() {
      return $("#word-play-message").fadeOut(100, __bind(function() {
        return $("#word-play-message").fadeIn(100);
      }, this));
    };
    return PlayView;
  })();
  Word = (function() {
    function Word() {
      Word.__super__.constructor.apply(this, arguments);
    }
    __extends(Word, Backbone.Model);
    return Word;
  })();
  WordView = (function() {
    function WordView() {
      WordView.__super__.constructor.apply(this, arguments);
    }
    __extends(WordView, Backbone.View);
    WordView.prototype.tagName = "li";
    WordView.prototype.render = function() {
      $(this.el).html(this.model.get('article') + " " + this.model.get('word'));
      $(this.el).addClass(this.model.get('article'));
      return this;
    };
    return WordView;
  })();
  Words = (function() {
    function Words() {
      Words.__super__.constructor.apply(this, arguments);
    }
    __extends(Words, Backbone.Collection);
    Words.prototype.model = Word;
    Words.prototype.url = 'word';
    return Words;
  })();
  WordAddView = (function() {
    function WordAddView() {
      WordAddView.__super__.constructor.apply(this, arguments);
    }
    __extends(WordAddView, Backbone.View);
    WordAddView.prototype.events = {
      "submit form": "addItem"
    };
    WordAddView.prototype.addItem = function(data) {
      return this.model.create([
        {
          word: $(this.el).find("input").val()
        }, {
          success: this.onSuccess({
            error: this.onError
          })
        }
      ]);
    };
    WordAddView.prototype.onSuccess = function(model, resp) {
      return $(this.el).find("input").val("");
    };
    WordAddView.prototype.onError = function(model, resp) {
      return $("#messages").html(resp.responseText);
    };
    return WordAddView;
  })();
  WordListView = (function() {
    __extends(WordListView, Backbone.View);
    WordListView.prototype.list = null;
    function WordListView() {
      WordListView.__super__.constructor.apply(this, arguments);
      this.list = $(this.el).find("ul");
      this.bindModel();
      this.model.fetch({
        success: __bind(function() {
          return this.render();
        }, this)
      });
    }
    WordListView.prototype.bindModel = function() {
      return this.model.bind('add', this.prependWord);
    };
    WordListView.prototype.refresh = function() {
      return this.list.listview("refresh");
    };
    WordListView.prototype.prependWord = function(word) {
      var wv;
      wv = new WordView({
        model: word
      }).render().el;
      this.list.prepend(wv);
      return this.refresh();
    };
    WordListView.prototype.appendWord = function(word) {
      var wv;
      wv = new WordView({
        model: word
      }).render().el;
      this.list.append(wv);
      return this.refresh();
    };
    WordListView.prototype.render = function() {
      this.list.html("");
      this.model.each(__bind(function(word) {
        return this.appendWord(word);
      }, this));
      return this.refresh();
    };
    return WordListView;
  })();
  $('#dict').live('pageshow', function(event) {
    var url, word;
    word = $("#word-play-link").text();
    url = "http://pda.leo.org/?lp=ende&lang=de&searchLoc=0&cmpType=relaxed&relink=off&sectHdr=on&spellToler=&search=" + word;
    return $("iframe").attr('src', url);
  });
  app = {
    start: function() {
      return $('#page_sets_manage').live('pagecreate', __bind(function(event) {
        var words;
        words = new Words({
          url: $("#word-list-view").data('url')
        });
        new PlayView({
          el: $("#word-play-view"),
          leoView: this.leoView
        });
        new WordListView({
          model: words,
          el: $("#word-list-view")
        });
        return new WordAddView({
          model: words,
          el: $("#word-add-view")
        });
      }, this));
    }
  };
  app.start();
}).call(this);

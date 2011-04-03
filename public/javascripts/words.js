/* DO NOT MODIFY. This file was compiled Sun, 03 Apr 2011 06:57:26 GMT from
 * /Users/bradphelan/workspace/derdiedas/app/coffeescripts/words.coffee
 */

(function() {
  var GameEngine, PlayView, Word, WordAddView, WordListView, WordView, Words, app;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  if (!(Math.randomFromTo != null)) {
    Math.randomFromTo = function(from, to) {
      return Math.floor(Math.random() * (to - from + 1) + from);
    };
  }
  Word = (function() {
    function Word() {
      Word.__super__.constructor.apply(this, arguments);
    }
    __extends(Word, Backbone.Model);
    Word.prototype.setAnswer = function(article) {
      var increment;
      if (article === this.get('article')) {
        increment = this.get('error') ? -2 : 1;
        this.set({
          score: this.get('score') + increment
        });
        this.save();
        return true;
      } else {
        this.set({
          error: true
        });
        return false;
      }
    };
    Word.prototype.score = function() {
      return this.get('score');
    };
    return Word;
  })();
  Words = (function() {
    function Words() {
      Words.__super__.constructor.apply(this, arguments);
    }
    __extends(Words, Backbone.Collection);
    Words.prototype.url = "nouns";
    Words.prototype.model = Word;
    Words.prototype.at_random = function() {
      var r;
      r = 8;
      if (this.size() < r) {
        r = this.size();
      }
      return this.at(Math.randomFromTo(0, r - 1));
    };
    Words.prototype.comparator = function(word) {
      return word.get('score');
    };
    return Words;
  })();
  GameEngine = (function() {
    __extends(GameEngine, Backbone.Model);
    function GameEngine(attr) {
      GameEngine.__super__.constructor.call(this, attr);
      this.words = attr.words;
    }
    GameEngine.prototype.start = function() {
      this.set({
        current_word: this.words.at_random()
      });
      this.trigger('change:word');
      return this.words.sort();
    };
    GameEngine.prototype.current_word = function() {
      return this.get('current_word');
    };
    GameEngine.prototype.setAnswer = function(article) {
      if (this.current_word().setAnswer(article)) {
        this.set({
          correct_answer: true
        });
        return this.start();
      } else {
        return this.set({
          correct_answer: false
        });
      }
    };
    GameEngine.prototype.word = function() {
      return this.current_word().get('word');
    };
    GameEngine.prototype.score = function() {
      return this.current_word().get('score');
    };
    GameEngine.prototype.correct_answer = function() {
      return this.get('correct_answer');
    };
    return GameEngine;
  })();
  PlayView = (function() {
    __extends(PlayView, Backbone.View);
    function PlayView(attr) {
      PlayView.__super__.constructor.call(this, attr);
      this.game_engine = new GameEngine({
        words: attr.words
      });
      this._bindModel();
    }
    PlayView.prototype.start = function() {
      return this.game_engine.start();
    };
    PlayView.prototype._bindModel = function() {
      this.game_engine.bind('change:word', __bind(function() {
        return this.changeWord();
      }, this));
      return this.game_engine.bind('change:correct_answer', __bind(function() {
        return this.renderMessage();
      }, this));
    };
    PlayView.prototype.changeWord = function() {
      var run;
      run = __bind(function() {
        $("#word-play-link").text(this.game_engine.word());
        return $("#word-play-score").html("(" + this.game_engine.score() + ")");
      }, this);
      return window.setTimeout(run, 350);
    };
    PlayView.prototype.renderMessage = function() {
      return true;
    };
    PlayView.prototype.events = {
      "click .der a": "handleDer",
      "click .die a": "handleDie",
      "click .das a": "handleDas"
    };
    PlayView.prototype.handleDer = function(e) {
      this.game_engine.setAnswer('der');
      return this.flashMessage();
    };
    PlayView.prototype.handleDie = function(e) {
      this.game_engine.setAnswer('die');
      return this.flashMessage();
    };
    PlayView.prototype.handleDas = function(e) {
      this.game_engine.setAnswer('das');
      return this.flashMessage();
    };
    PlayView.prototype.flashMessage = function() {
      if (this.game_engine.correct_answer()) {
        $("#color-flash").effect("highlight", {
          color: "lightgreen"
        }, 600);
        return true;
      } else {
        $("#color-flash").effect("highlight", {
          color: "red"
        }, 600);
        return true;
      }
    };
    return PlayView;
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
      var callbacks, item;
      item = {
        word: $(this.el).find("input").val()
      };
      callbacks = {
        success: this.onSuccess,
        error: this.onError
      };
      return this.model.create(item, callbacks);
    };
    WordAddView.prototype.onSuccess = function(model, resp) {
      return $(this.el).find("input").val("");
    };
    WordAddView.prototype.onError = function(model, resp) {
      return $("#messages").html(resp.responseText);
    };
    return WordAddView;
  })();
  WordView = (function() {
    function WordView() {
      WordView.__super__.constructor.apply(this, arguments);
    }
    __extends(WordView, Backbone.View);
    WordView.prototype.tagName = "li";
    WordView.prototype.render = function() {
      $(this.el).html("" + (this.model.get('article')) + " " + (this.model.get('word')) + " (" + (this.model.get('score')) + ")");
      $(this.el).addClass(this.model.get('article'));
      return this;
    };
    return WordView;
  })();
  WordListView = (function() {
    __extends(WordListView, Backbone.View);
    WordListView.prototype.list = null;
    function WordListView() {
      WordListView.__super__.constructor.apply(this, arguments);
      this.list = $(this.el).find("ul");
      this.bindModel();
    }
    WordListView.prototype.bindModel = function() {
      this.model.bind('add', __bind(function(noun) {
        return this.prependWord(noun);
      }, this));
      return this.model.bind('refresh', __bind(function() {
        return this.render();
      }, this));
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
      var html;
      html = $('<ul/>');
      this.model.each(__bind(function(word) {
        var wv;
        wv = new WordView({
          model: word
        }).render().el;
        return html.append(wv);
      }, this));
      html.listview();
      return this.list.html(html.html());
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
        var listview, play_view, words;
        words = new Words();
        listview = new WordListView({
          model: words,
          el: $("#word-list-view")
        });
        play_view = new PlayView({
          words: words,
          el: $("#word-play-view"),
          listview: listview
        });
        new WordAddView({
          model: words,
          el: $("#word-add-view")
        });
        return words.fetch({
          success: __bind(function() {
            return play_view.start();
          }, this)
        });
      }, this));
    }
  };
  app.start();
}).call(this);

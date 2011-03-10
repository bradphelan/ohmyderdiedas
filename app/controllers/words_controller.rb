
class WordsController < ApplicationController



  WORDS = <<-EOF.each_line.collect.map(&:split)
  das Jahr
  das Mal
  das Beispiel
  die Zeit
  die Frau
  der Mensch
  das Kind
  der Tag
  der Mann
  das Land
  die Frage
  das Haus
  der Fall

  die Geschäftsleute
  die Besprechung
  das Geschäftsessen
  die Meeresfrüchte
  der Flügel
  der Tourist
  die Giraffe
  der Käfig 
  die Schlange
  die Maus
  der affe
  der Hund
  der Löwe
  das Zebra
  das Schwein
  das Huhn
  das Pferd
  das Rind
  das Kalb
  der Fisch
  die Ente
  das Schaf
  der Elefant
  der Bär
  der Wölf
  das Kamel
  der Tiger
  die Katze
  EOF
  

  MAP = {}
  WORDS.each do |l|

    article = l[0] 
    word    = l[1] 

    MAP[word] = {:word => word, :article => article}

  end


  def new

    unless @word = params[:word]
      n = rand(WORDS.size)
      @items = WORDS[n]
      @word    = @items[1] 
    end
    render :index

  end

  def check
    @word = params[:word]
    if MAP[@word][:article] == params[:article]
      params[:article] = nil
      redirect_to new_word_path, :notice => "#{MAP[@word][:article]} #{@word} is correct", :rel => :external
      return
    end
    flash[:notice] = "#{MAP[@word][:article]} #{@word} is incorrect"

    redirect_to new_word_path(@word), :notice => "#{params[:article]} #{@word} is incorrect"
  end

  def get

  end
end

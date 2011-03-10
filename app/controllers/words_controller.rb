# encoding: UTF-8
class WordsController < ApplicationController


  WORDS=<<-EOF.each_line.collect.map(&:split)
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
  WORDS = WORDS.map do |l|
    {:word => l[1], :article => l[0]}
  end
  WORDS.each do |l|
    MAP[l[:word]] = l
  end



  def new

    respond_to do |format|
        
        if params[:word]
          @word = {:word => params[:word]}
        else @word = params[:word]
          @word = rand_word
        end

      format.html do
        render :index
      end

      format.json do
        render :json => @word.to_json
      end
    end

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

  private

  def rand_word
      n = rand(WORDS.size)
      WORDS[n]
  end
end

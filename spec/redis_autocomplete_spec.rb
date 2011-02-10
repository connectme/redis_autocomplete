require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

#require 'redis_autocomplete'

describe RedisAutocomplete do
  before do
    @names = %w[
      ynes
      ynez
      yoko
      yolanda
      yolande
      yolane
      yolanthe
      aaren
      aarika
      abagael
      abagail
      catherine
      cathi
      cathie
      cathleen
      cathlene
      cathrin
      cathrine
      cathryn
      cathy
      cathyleen
      cati
      catie
      catina
      catlaina
      catlee
      catlin
    ]
    @set = :test_female_names
    @r = RedisAutocomplete.new(@set)
    #todo: drop female_names set
    @r.add_words(@names)
  end

  describe "#suggest" do
    it "should include words matching prefix" do
      @r.suggest('c').should == %w[
        catherine
        cathi
        cathie
        cathleen
        cathlene
        cathrin
        cathrine
        cathryn
        cathy
        cathyleen
      ]
    end
    it "should not include words not matching prefix" do
      @r.suggest('cati').should_not include('cathy')
    end

    context "when a max count is supplied" do
      it "should not include more than 10 matches" do
        @r.suggest('c').length.should == 10
      end
      it "should not include more matches than the supplied count" do
        @r.suggest('c', 4).length.should == 4
      end
    end
  end
end

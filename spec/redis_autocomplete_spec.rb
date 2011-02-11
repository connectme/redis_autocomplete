require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

#require 'redis_autocomplete'

describe RedisAutocomplete do
  before :all do
    @names = %w[
      Ynes
      Ynez
      Yoko
      Yolanda
      Yolande
      yolane
      yolanthe
      Aaren
      Aarika
      Abagael
      Abagail
      Catherine
      Cathi
      cathie
      cathleen
      cathlene
      Cathrin
      Cathrine
      Cathryn
      Cathy
      Cathyleen
      Cati
      Catie
      Catina
      Catlaina
      Catlee
      Catlin
    ]
    @set = :test_female_names
  end

  context "with default case sensitivity" do
    before do
      @r = RedisAutocomplete.new(:set_name => @set)
      @r.redis.zremrangebyscore(@set, 0, 0)
      @r.add_words(@names)
    end

    describe "#suggest" do
      it "should include words matching prefix" do
        @r.suggest('C').should == %w[
          Catherine
          Cathi
          Cathrin
          Cathrine
          Cathryn
          Cathy
          Cathyleen
          Cati
          Catie
          Catina
        ]
      end

      it "should not include words not matching prefix" do
        @r.suggest('Cati').should_not include('Cathy')
      end

      it "should not include uppercase when searching on lowercase" do
        @r.suggest('Y').should_not include('yolane', 'yolanthe')
        @r.suggest('Y').should == %w[Ynes Ynez Yoko Yolanda Yolande]
      end

      context "when a max count is supplied" do
        it "should not include more than 10 matches" do
          @r.suggest('C').length.should == 10
        end

        it "should not include more matches than the supplied count" do
          @r.suggest('C', 4).length.should == 4
        end
      end
    end
    
    describe "#remove_word" do
      context "with default options" do
        before do
          @r.remove_word('Catherine')
        end
      
        it "should not include word after removing it" do
          @r.suggest('Cath').should_not include('Catherine')
        end
      
        it "should remove unique word stems" do
          @r.redis.zrank(@set, 'Catherine').should be_nil
          @r.redis.zrank(@set, 'Catheri').should == nil
          @r.redis.zrank(@set, 'Cather').should == nil
          @r.redis.zrank(@set, 'Cathe').should == nil
          @r.redis.zrank(@set, 'Cath').should_not == nil
        end
      end
      
      context "when remove_stems is false" do
        before do
          @r.remove_word('Catherine', nil, false)
        end

        it "should not include word after removing it" do
          @r.suggest('Cath').should_not include('Catherine')
        end

        it "should remove unique word stems" do
          @r.redis.zrank(@set, 'Catherine+').should be_nil
          @r.redis.zrank(@set, 'Catherine').should_not be_nil
          @r.redis.zrank(@set, 'Catheri').should_not be_nil
          @r.redis.zrank(@set, 'Cather').should_not be_nil
          @r.redis.zrank(@set, 'Cathe').should_not be_nil
          @r.redis.zrank(@set, 'Cath').should_not be_nil
        end
      end
    end
  end

  context "with :case_sensitive => false" do
    before do
      @r = RedisAutocomplete.new(:set_name => @set, :case_sensitive => false)
      @r.redis.zremrangebyscore(@set, 0, 0)
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
end
